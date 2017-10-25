
#from instruction import Instruction
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

class analyze:
	"""
	First, turn all instructions into objects with arguments object
	
	"""
	def __init__(self, functions):
		label_next = None
		self.startNode = ListNode("start", sys = True)
		self.endNode = ListNode("end", sys = True)
		self.startNode.setNext(self.endNode)
		append_node = self.startNode
		self.WM = WordManager()
		self.LM = LabelManager()
		
		
		for kx,x in functions.items():
			print " Analyzing Function:", kx	#function
			##### TODO
			##### memory 
			print x.keys()
			self.WM.pushNamespace(kx.replace(".","_"))
			append_node = append_node.append(ListNode("namespace", sys = True, opt=self.WM.getNamespace(False)))
			for arg in x['args']:
				print self.WM.addNewName(arg)

			for ky, y in x["function"].items():
				
				label_next = ky.replace(".","_")	# basic block

				self.WM.pushNamespace(ky.replace(".","_"))
				append_node = append_node.append(ListNode("namespace", sys = True, opt=self.WM.getNamespace(False)))
				
				for z in y: # instruction
					if label_next != None:
						append_node = append_node.append(self.LM.new(ListNode(z), label_next.replace(".","_")))
						label_next = None
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
					print params
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
p = CodeParser("test/test_code_01/plus.parse")

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
"""
for x in a.WM.wordDataDict:
	print x 

"""