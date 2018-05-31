
from instruction import Instruction, PseudoInstruction
from instr_transform import instrTransform, funcDict, build_methods, sysTransform, instrOpt, expandDict
from memory import WordManager
from memory import Word, Words
#from memory import MemoryNode
from list_node import ListNode
#from subneg4_list_node import Subneg4ListNode
from label import LabelManager
from label import Label
#from code_parser import CodeParser2

#from graph import Graph

import re

"""
MEMO
clang++ tool.cpp -o reader `llvm-config --cxxflags --libs --ldflags --system-libs`

"""
from utils import check_int # function check_int
class Backend(object):
	"""
		backend entry
	"""
	def __init__(self, filename):
		self.filename = filename
		self.startNode = ListNode("start", sys = True)
		self.endNode = ListNode("end", sys = True)
		self.LM = None
		self.WM = None
		self.bb_graph = {}
	def printNodes(self, is_print_all = False):
		current = self.startNode
		while current != None:
			if is_print_all or not current.sys:
				print current
			current = current.next
	def buildPass(self):
		"""
			buildPass():
			The function for backend to parse ir-xml file into ListNode structure.
		"""

		### initialize ListNode structure for instructions
		self.startNode.setNext(self.endNode)
		append_node = self.startNode
		self.LM = LabelManager()
		LM = self.LM
		self.WM = WordManager(LM)
		WM = self.WM

		label_next = []

		### call main first
		append_node = append_node.append(LM.new(ListNode(Instruction("call",[WM.getName("res"),[],WM.label("f_main")]))))
		append_node = append_node.append(LM.new(ListNode(Instruction("br",[WM.getHalt()]))))
		WM.pushNamespace("f")

		import xml.etree.ElementTree as ET
		tree = ET.parse(self.filename)
		module = tree.getroot()

		### re pattern for phi operation
		### -- phi: [from_BB: variable] 
		phi_op_pattern = re.compile("\[(.*?):(.*?)\]")

		### recursively read the modules
		for item1 in module:
			### functions and global variables
			if item1.tag == "Globals":
				### global variables:
				for V in item1:
					#print V
					if V.get("type").find("x") != -1:
						arr = V.get("init")[1:-1]
						values = [s.split(" ")[1] for s in arr.split(", ")]
						WM.addName(WM.addWords(values, V.get("name").replace(".","_")), V.get("name").replace(".","_"))
					elif V.get("type") == "i32":
						WM.addName(WM.addDataWord(V.get("init"),V.get("name").replace(".","_")), V.get("name").replace(".","_"))
					else:
						### 32bit integer only for now
						print "ERROR!!! not done yet!"
				continue

			if item1.tag == "Function":
				### functions
				function_name = item1.get('name').replace(".","_")
				### save the function name as a label to append to the first instruction of this function
				label_next.append(WM.getNamespace()+function_name)
				### namespace push function name
				WM.pushNamespace(function_name)
				append_node = append_node.append(ListNode("func_begin", sys = True, opt=WM.getNamespace(False)))
				append_node = append_node.append(ListNode("namespace", sys = True, opt=WM.getNamespace(False)))

				### prepare graph
				# self.bb_graph[function_name] = Graph()

				### arguments of the function
				args = []
				
				for arg in item1[0]:
					args.append(WM.addNewName(arg.get('name')))

				WM.functionInfo["_".join(WM.getNamespace(False))] = args
				append_node = append_node.append(ListNode("function", sys = True, opt=args))
				
				### get all phi node
				for BB in item1[1]:
					BB_name = BB.get("name").replace(".","_")
					phi = {} #{from:{var: from_var}}
					for I in BB:
						ins_name = I.get("opName")
						if ins_name != "phi":
							break
						ins_des = I.get("des").replace(".","_")

						op = I.get("values").replace(".","_")
						
						for op_string in op.split(","):
							res = phi_op_pattern.match(op_string)
							if phi.has_key(res.group(2)):
								phi[res.group(2)][ins_des] = res.group(1)
							else:
								phi[res.group(2)] = {ins_des : res.group(1)}
					
					WM.phi[BB_name] = phi
					### add bb graph node
					# self.bb_graph[function_name].newNode(BB_name)
				### set root
				firstBB_name = next(iter(item1[1])).get("name").replace(".","_")
				# self.bb_graph[function_name].setRoot(self.bb_graph[function_name].getNode(firstBB_name))

				for BB in item1[1]:
					BB_name = BB.get("name").replace(".","_")
					label_next.append(WM.getNamespace()+BB_name)	# basic block

					WM.pushNamespace(BB_name)
					append_node = append_node.append(ListNode("namespace", sys = True, opt=WM.getNamespace(False)))
					### BB begin
					append_node = append_node.append(ListNode("bb_begin", sys = True, opt=WM.getNamespace(False)))
					# self.bb_graph[function_name].getNode(BB_name).setListNode(append_node)

					#print phi
					for l,f_bb in WM.phi[BB_name].items():
						l = "phi_"+BB_name+"-"+l
						for var, from_var in f_bb.items():
							if check_int(var):
								w_var = WM.const(var)
							else:
								w_var = WM.getName(var)
							if check_int(from_var):
								w_from_var = WM.const(from_var)
							else:
								w_from_var = WM.getName(from_var)
							append_node = append_node.append(LM.new(ListNode(Instruction("load", [w_var, w_from_var]),l)))
							l = None
						append_node = append_node.append(LM.new(ListNode(Instruction("br", [WM.label(WM.getUpperNamespace()+BB.get("name").replace(".","_"))]),l)))
					for I in BB: # instruction
						############### des + params TODO
						ins_name = I.get("opName")
						if ins_name == "phi":
							continue
						ins_params = [] if I.get("operands") == None else re.sub(r'\[.*?(\[.*?\])?.*?\]','', I.get("operands")).replace(" ","").replace(".","_").split(",")##################TODO
						ins_des = None if I.get("des") == None else I.get("des").replace(".","_")
						ins = Instruction(ins_name, [ins_des]+ins_params if ins_des != None else ins_params)

						if len(label_next) != 0:
							append_node = append_node.append(LM.new(ListNode(ins), label_next))
							label_next = []
						else:
							append_node = append_node.append(LM.new(ListNode(ins)))
						
						if append_node.ins.instrStr in build_methods:
							params = build_methods[append_node.ins.instrStr](append_node.ins.params, WM, I, BB_name)
						else:
							params = []
							for x in append_node.ins.params:
								if check_int(x):
									params.append(WM.const(x))
									continue
								else:
									params.append(WM.getName(x))
									continue
								params.append(x)
						#append_node.ins.updateAll(params)
						append_node.ins.params=params
						#print params
					append_node = append_node.append(ListNode("bb_end", sys = True, opt=WM.getNamespace(False)))
					WM.popNamespace()
				WM.popNamespace()
				append_node = append_node.append(ListNode("func_end", sys = True, opt=WM.getNamespace(False)))

	def transformPass(self):
		"""
			The pass for backend to lower instructions into pseudo instructions
		"""
		current = self.startNode
		### need loops
		while current != None:
			if current.sys:
				if current.ins == "namespace":
					self.WM.setNamespace(current.opt)
				if current.ins == "function":
					self.WM.needSave = {}
					#print current.opt
					for x in current.opt:
						self.WM.addNeedSave(x)
					self.WM.currentFunction = {
						#"backAddress": self.WM.getName("d_"+"_".join(self.WM.getNamespace(False)[1:]+["backAddress"])),
						"returnData" : self.WM.getName("d_"+"_".join(self.WM.getNamespace(False)[1:]+["returnData"]))
					}
				current = current.next
				continue
			n = None
			if current.ins.instrStr in instrTransform:
				n = instrTransform[current.ins.instrStr](current, self.WM, self.LM)
			if n == None:
				current = current.next
			else:
				current = n
		#pass
	def optimizePass(self):
		# null branch
		current = self.startNode
		while current != None:
			if not current.sys and current.ins.instrStr == "p_goto":
				next_inst = current.getNextInst()
				if next_inst != None:
					if str(current.ins.params[0]) in next_inst.labelStringArray():
						current.remove()
			current = current.next
		pass

	def convertPass(self):
		current = self.startNode
		while current != None:
			if not current.sys and current.ins.instrStr in expandDict:
				expandDict[current.ins.instrStr](current, self.WM, self.LM)
			current = current.next

		current = self.startNode
		while current != None:
			if current.sys:
				current = current.next
				continue
			if current.ins.instrStr in sysTransform:
				sysTransform[current.ins.instrStr](current, self.WM, self.LM)
			current = current.next

class analyze:
	"""
	First, turn all instructions into objects with arguments object
	
	"""
	def __init__(self, filename):
		self.startNode, self.endNode, self.LM, self.WM = CodeParser2().parse(filename)
	def printNodes(self):
		current = self.startNode
		while current != None:
			print current
			current = current.next

	def buildPath(self):
		pass
	def convert(self):
		current = self.startNode
		### need loops
		while current != None:
			if current.sys:
				if current.ins == "namespace":
					self.WM.setNamespace(current.opt)
				if current.ins == "function":
					self.WM.needSave = {}
					#print current.opt
					for x in current.opt:
						self.WM.addNeedSave(x)
					self.WM.currentFunction = {
						#"backAddress": self.WM.getName("d_"+"_".join(self.WM.getNamespace(False)[1:]+["backAddress"])),
						"returnData" : self.WM.getName("d_"+"_".join(self.WM.getNamespace(False)[1:]+["returnData"]))
					}
				current = current.next
				continue
			n = None
			if current.ins.instrStr in instrTransform:
				n = instrTransform[current.ins.instrStr](current, self.WM, self.LM)
			if n == None:
				current = current.next
			else:
				current = n
		
		current = self.startNode
		while current != None:
			if current.sys:
				current = current.next
				continue
			if current.ins.instrStr in sysTransform:
				sysTransform[current.ins.instrStr](current, self.WM, self.LM)
			current = current.next

	def opt_label(self):
		current = self.startNode
		#print self.WM.labelDict
		while current != None:
			if len(current.label) > 1:
				if type(current.label[0]) != Label:
					print "label incorrect class!!!!!!"
				for l in current.label[1:]:
					if type(l) != Label:
						print "label incorrect class!!!!!!"
						continue
					if self.WM.labelDict.has_key(l.name):
						for li in self.WM.labelDict[l.name]:
							if li.type != "label":
								print "word incorrect type!!!!!!"
							li.value = current.label[0].name
				current.label=[current.label[0]]
			current = current.next
	def subneg4_opt_01(self):
		current = self.startNode
		while current != None:
			if current.sys:
				current = current.next
			current = current.next
	def opt_variable_name(self):
		count = 0
		for key, value in self.WM.wordDataDict.items():
			if type(value) == Word:
				#print value
				value.label = "V"+str(count)
				count += 1
			elif type(value) == Words:
				pass
			else:
				print "what????"+str(value)+"  "+str(type(value))
		for key, value in self.WM.wordDataPtrDict.items():
			if type(value) == Word:
				#print value
				value.label = "V"+str(count)
				count += 1
			else:
				print "what????"+str(value)+"  "+str(type(value))


#backend = Backend("test/test_code_quick/mips-quick.xml")
backend = Backend("test/test_code_quick/mips-quick-test.o3.xml")
#backend = Backend("test/test_code_quick/quick.xml")
backend.buildPass()
#backend.printNodes(True)
#print " ################################################# "
backend.transformPass()
backend.optimizePass()
backend.convertPass()
backend.printNodes(True)

backend.WM.dataMem()
backend.WM.stackMem()
"""
for x in a.WM.wordDataDict:
	print x 

"""
