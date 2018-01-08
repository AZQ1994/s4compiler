from instruction import Instruction
import re
from list_node import ListNode
from label import LabelManager
from memory import WordManager
from instr_transform import build_methods
class CodeParser:
	def __init__(self, filename = None):
		self.setFile(filename)

	def printModule(self):
		print "Module :"#module
		for kx,x in self.functions.items():
			print "  Function:", kx	#function
			for ky, y in x["function"].items():
				print "    BasicBlock:",ky	#function
				for z in y:
					print "      "+str(z)	#basicBlock

	def printHtml(self):
		pass

	def setFile(self, filename):
		self.filename = filename
		f = open(filename,"r")
		self.fullText = f.read()
		f.close()

	def readRaw(self):
		return self.fullText

	def parse(self):
		#print self.fullText
		self.removeComment()
		#print self.fullText
		self.parseModule()

	def parseModule(self):
		functionSplitText = re.findall(r'\[Function\:([\S\s]*?)\]\(([\S\s]*?)\)\{([\S\s]*?)\}\[Function\]', self.fullText)
		#print functionSplitText
		self.functionList = [x[0] for x in functionSplitText]
		self.functions = {x[0] : self.parseFunction(x[2],x[1]) for x in functionSplitText}
		#print self.functions

	def parseFunction(self, functionText, argsText):
		blockSplitText = re.findall(r'\[BasicBlock\]\(([\S\s]*?)\)\{([\S\s]*?)\}\[BasicBlock\]',functionText)
		argsSplitText = argsText.strip().split()
		
		blocks = {x[0]:self.parseBlock(x[1]) for x in blockSplitText}
		return {"args":argsSplitText,"function":blocks}
		
	def parseBlock(self, blockText):
		instructionsText = re.findall(r'\[Instruction\]\([\S\s]*?\)\s*:\s*([\S\s]*?)[\n\r]',blockText)
		instructions = [self.parseInstruction(x) for x in instructionsText]
		return instructions
	def parseInstruction(self, instructionText):
		splitText = [x.strip() for x in instructionText.split(":")]
		if len(splitText) == 1:
			print "Error", splitText
			return
		splitParam = [x.strip() for x in splitText[1].split(",")]
		return Instruction(splitText[0], splitParam)

	def strip(self):
		def w_strip(a):
			return a.strip()
		self.fullText = map(w_strip,self.fullText)
	def removeComment(self):
		self.fullText = re.sub(r'\/\*[\S\s]*?\*\/|\/\/[\S\s]*?[\n\r]|\#[\S\s]*?[\r\n]','',self.fullText)
		#self.fullText = re.sub(r'\/\/[\S\s]*?[\n\r]|\#[\S\s]*?[\r\n]','',self.fullText)
		#self.fullText = re.sub(r'\/\*[\S\s]*?\*\/','',self.fullText)
import xml.etree.ElementTree as ET
class CodeParser2(object):

	def parse(self, filename):
		startNode = ListNode("start", sys = True)
		endNode = ListNode("end", sys = True)
		startNode.setNext(endNode)
		append_node = startNode
		LM = LabelManager()
		WM = WordManager(LM)

		label_next = []

		append_node = append_node.append(LM.new(ListNode(Instruction("call",[WM.getName("res"),[],WM.label("f_main")]))))
		append_node = append_node.append(LM.new(ListNode(Instruction("br",[WM.getHalt()]))))
		WM.pushNamespace("f")

		tree = ET.parse(filename)
		module = tree.getroot()

		for item1 in module:
			# functions and global variables
			print "- ",item1.tag,": ",item1.attrib
			if item1.tag == "Function":
				
				label_next.append(WM.getNamespace()+item1.get('name').replace(".","_"))
				WM.pushNamespace(item1.get('name').replace(".","_"))

				append_node = append_node.append(ListNode("namespace", sys = True, opt=WM.getNamespace(False)))

				args = []
				
				for arg in item1[0]:
					args.append(WM.addNewName(arg.get('name')))

				WM.functionInfo["_".join(WM.getNamespace(False))] = args
				append_node = append_node.append(ListNode("function", sys = True, opt=args))

				for BB in item1[1]:
					label_next.append(WM.getNamespace()+BB.get("name").replace(".","_"))	# basic block

					WM.pushNamespace(BB.get("name").replace(".","_"))
					append_node = append_node.append(ListNode("namespace", sys = True, opt=WM.getNamespace(False)))
					
					for I in BB: # instruction
						############### des + params TODO
						ins_name = I.get("opName")
						ins_params = [] if I.get("operands") == None else re.sub(r'\[.*?\]','', I.get("operands")).replace(" ","").replace(".","_").split(",")##################TODO
						ins_des = None if I.get("des") == None else I.get("des").replace(".","_")
						ins = Instruction(ins_name, [ins_des]+ins_params if ins_des != None else ins_params)

						if len(label_next) != 0:
							append_node = append_node.append(LM.new(ListNode(ins), label_next))
							label_next = []
						else:
							append_node = append_node.append(LM.new(ListNode(ins)))
						
						if False:#append_node.ins.instrStr in build_methods:
							params = build_methods[append_node.ins.instrStr](append_node.ins.params, WM)
						else:
							params = []
							for x in append_node.ins.params:
								params.append(x)
						#append_node.ins.updateAll(params)
						#print params
					WM.popNamespace()
				WM.popNamespace()


		return startNode, endNode, LM, WM

"""
	def parseLine(self, line):
		pass
"""

#test

startNode, endNode, LM, WM = CodeParser2().parse("test/test_code_01/plus.xml")

current = startNode
while current != None:
	print current
	current = current.next

"""
tree = ET.parse('test/test_code_01/plus.xml')
module = tree.getroot()
ET.dump(tree)
functions = {}
for item1 in module:
	print "- ",item1.tag,": ",item1.attrib
	if item1.tag == "Function":
		functions.append()
	for c2 in c:
		print "--- ",c2.tag,": ",c2.attrib
		for c3 in c2:
			print "----- ",c3.tag,": ", c3.attrib
			for c4 in c3:
				print "------- ",c4.tag, ": ", c4.attrib
"""