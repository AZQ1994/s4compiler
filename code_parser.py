from instruction import Instruction
import re

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
"""
	def parseLine(self, line):
		pass
"""
"""
#test
p = Parser("test/test_code_01/plus.parse")

p.parse()
p.printModule()
"""