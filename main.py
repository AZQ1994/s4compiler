
from instruction import Instruction
from instr_transform import instrTransform, funcDict, build_methods
from memory import WordManager
#from memory import Memory2
#from memory import MemoryNode
from list_node import ListNode
#from subneg4_list_node import Subneg4ListNode
from label import LabelManager
#from label import Label
from code_parser import CodeParser

import re

"""
MEMO
clang++ tool.cpp -o reader `llvm-config --cxxflags --libs --ldflags --system-libs`

"""
class analyze:
	"""
	First, turn all instructions into objects with arguments object
	
	"""
	def __init__(self, functions):
		label_next = []
		self.startNode = ListNode("start", sys = True)
		self.endNode = ListNode("end", sys = True)
		self.startNode.setNext(self.endNode)
		append_node = self.startNode
		self.WM = WordManager()
		self.LM = LabelManager()
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
					print current.opt
					for x in current.opt:
						self.WM.needSave[x] = True
					self.WM.currentFunction = {
						"backAddress": self.WM.getName("d_"+"_".join(self.WM.getNamespace(False)[1:]+["backAddress"])),
						"returnData" : self.WM.getName("d_"+"_".join(self.WM.getNamespace(False)[1:]+["returnData"]))
					}
				current = current.next
				continue
			if current.ins.instrStr in instrTransform:
				instrTransform[current.ins.instrStr](current, self.WM, self.LM)
			current = current.next
	def subneg4_opt_01(self):
		current = self.startNode
		while current != None:
			if current.sys:
				current = current.next
			current = current.next




#p = CodeParser("test/test_code_03/mult.o2.parse")
#p = CodeParser("test/test_code_01/plus.parse")
p = CodeParser("test/test_code_04/test.parse")
#p = CodeParser("test/test_code_04/fib.parse")
#p = CodeParser("test/test_code_03/main.parse")

p.parse()
p.printModule()
#for x in p.readRaw():
#	print x
print "***************"
print p.functions
print "***************"
a = analyze(p.functions)
a.printNodes()
print "***************"
a.convert()
a.printNodes()

a.WM.dataMem()
a.WM.stackMem()
"""
for x in a.WM.wordDataDict:
	print x 

"""