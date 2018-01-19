
from instruction import Instruction
from instr_transform import instrTransform, funcDict, build_methods, sysTransform
from memory import WordManager
from memory import Word
#from memory import MemoryNode
from list_node import ListNode
#from subneg4_list_node import Subneg4ListNode
from label import LabelManager
from label import Label
from code_parser import CodeParser2

import re

"""
MEMO
clang++ tool.cpp -o reader `llvm-config --cxxflags --libs --ldflags --system-libs`

"""
class analyze:
	"""
	First, turn all instructions into objects with arguments object
	
	"""
	def __init__(self, filename):
		"""
		label_next = []
		self.startNode = ListNode("start", sys = True)
		self.endNode = ListNode("end", sys = True)
		self.startNode.setNext(self.endNode)
		append_node = self.startNode
		self.LM = LabelManager()
		self.WM = WordManager(self.LM)
		
		append_node = append_node.append(self.LM.new(ListNode(Instruction("call",[self.WM.getName("res"),[],self.WM.label("f_main")]))))
		append_node = append_node.append(self.LM.new(ListNode(Instruction("br",[self.WM.getHalt()]))))
		self.WM.pushNamespace("f")
		for kx,x in functions.items():
			print " Analyzing Function:", kx	#function
			##### TODO
			##### memory 
			#print x.keys()
			label_next.append(self.WM.getNamespace()+kx.replace(".","_"))
			self.WM.pushNamespace(kx.replace(".","_"))
			
			append_node = append_node.append(ListNode("namespace", sys = True, opt=self.WM.getNamespace(False)))
			
			args = []
			
			for arg in x['args']:
				args.append(self.WM.addNewName(arg))

			self.WM.functionInfo["_".join(self.WM.getNamespace(False))] = args

			append_node = append_node.append(ListNode("function", sys = True, opt=args))
			
			for ky, y in x["function"].items():
				
				label_next.append(self.WM.getNamespace()+ky.replace(".","_"))	# basic block

				self.WM.pushNamespace(ky.replace(".","_"))
				append_node = append_node.append(ListNode("namespace", sys = True, opt=self.WM.getNamespace(False)))
				
				for z in y: # instruction
					if len(label_next) != 0:
						append_node = append_node.append(self.LM.new(ListNode(z), label_next))
						label_next = []
					else:
						append_node = append_node.append(self.LM.new(ListNode(z)))
					
					if append_node.ins.instrStr in build_methods:
						params = build_methods[append_node.ins.instrStr](append_node.ins.params, self.WM)
					else:
						params = []
						for x in append_node.ins.params:
							p_var = re.findall(r'var\(([\s\S]*?)\)', x)
							if len(p_var) == 1:
								word = self.WM.getName(p_var[0].replace(".","_"))
								params.append(word)
								#print "test::::::::", word
								#### TODO : check
								continue
							p_int = re.findall(r'int\(([\s\S]*?)\)', x)
							if len(p_int) == 1:
								word = self.WM.const(p_int[0])
								params.append(word)
								#print "int",p_int[0]
								continue
							p_ptr = re.findall(r'ptr\(([\s\S]*?)\)', x)
							if len(p_ptr) == 1:
								word = self.WM.getName("p_"+p_ptr[0])
								params.append(word)
								continue
							params.append(x)
					append_node.ins.updateAll(params)
					#print params
				self.WM.popNamespace()
			self.WM.popNamespace()
		#self.printNodes()
		#self.WM.dataMem()
		"""
		self.startNode, self.endNode, self.LM, self.WM = CodeParser2().parse(filename)
	def printNodes(self):
		current = self.startNode
		while current != None:
			print current
			current = current.next
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
			if current.ins.instrStr in instrTransform:
				instrTransform[current.ins.instrStr](current, self.WM, self.LM)
			current = current.next
		
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
			else:
				print "what????"+str(value)+"  "+str(type(value))
		for key, value in self.WM.wordDataPtrDict.items():
			if type(value) == Word:
				#print value
				value.label = "V"+str(count)
				count += 1
			else:
				print "what????"+str(value)+"  "+str(type(value))


#p = CodeParser("test/test_code_03/mult.o2.parse")
#p = CodeParser("test/test_code_01/plus.parse")
#p = CodeParser("test/test_code_04/test.parse")
#p = CodeParser("test/test_code_04/fib.parse")
#p = CodeParser("test/test_code_03/main.parse")
#p = CodeParser("test/presentation_20171120/main.parse")

#p.parse()
#p.printModule()
#for x in p.readRaw():
#	print x
#print "***************"
#print p.functions
#print "***************"
#a = analyze("test/test_code_quick/mips-quick-test.o0.xml")
#a = analyze("test/debug/test.xml")
a = analyze("test/test_code_quick/mips-quick-test.a.xml")
#a = analyze("test/test_code_01/plus.o0.xml")
#a.printNodes()
#print "***************"
a.convert()
#print "***************"
#a.opt_label()
#a.opt_variable_name()
a.printNodes()

a.WM.dataMem()
a.WM.stackMem()
"""
for x in a.WM.wordDataDict:
	print x 

"""
