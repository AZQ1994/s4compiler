
#from instruction import Instruction
from instr_transform import instrTransform, funcDict
from memory import Memory
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
		self.Mem = Memory()
		self.LM = LabelManager()
		
		for kx,x in functions.items():
			print " Analyzing Function:", kx	#function
			##### TODO
			##### memory 
			print x.keys()
			for arg in x['args']:
				self.Mem.allocate(arg)
			for ky, y in x["function"].items():

				label_next = ky	#function
				for z in y:
					if label_next != None:
						append_node = append_node.append(self.LM.new(ListNode(z), label_next.replace(".","_")))
						label_next = None
					else:
						append_node = append_node.append(self.LM.new(ListNode(z)))
					params = []
					for x in append_node.ins.params:
						p_var = re.findall(r'var\(([\s\S]*?)\)', x)
						if len(p_var) == 1:
							params.append(p_var[0].replace(".","_"))
							#### TODO : check
							continue
						p_int = re.findall(r'int\(([\s\S]*?)\)', x)
						if len(p_int) == 1:
							params.append(self.Mem.const(p_int[0]))
							#print "int",p_int[0]
							continue
						p_ptr = re.findall(r'ptr\(([\s\S]*?)\)', x)
						if len(p_ptr) == 1:
							params.append(self.Mem.ptr("p_"+p_ptr[0]))
							continue
						self.params.append(x)
					append_node.ins.updateAll(params)
					print params
		self.printNodes()
		print self.Mem.memDict
	def printNodes(self):
		current = self.startNode
		while current != None:
			print current
			current = current.next
	def convert(self):
		current = self.startNode
		while current != None:
			if current.sys:
				current = current.next
				continue
			if current.ins.instrStr in instrTransform:
				instrTransform[current.ins.instrStr](current, self.Mem, self.LM)
			current = current.next
	def subneg4_opt_01(self):
		current = self.startNode
		while current != None:
			if current.sys:
				current = current.next
			current = current.next




p = CodeParser("test/test_code_03/mult.o2.parse")

p.parse()
p.printModule()
#for x in p.readRaw():
#	print x
a = analyze(p.functions)
a.printNodes()
print "***************"
a.convert()
a.printNodes()

for x in a.Mem.memList:
	print x 