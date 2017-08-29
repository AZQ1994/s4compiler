
from config import config

class Instruction:
	def __init__(self, instrStr, params):
		self.instrStr = instrStr
		self.params = params
		#self.label = ""
		self.instrFormat = config.getInstrFormat()
		if self.instrFormat.has_key(instrStr):
			self.str = self.instrFormat[instrStr].format(*params)
	def update(self, i, p):
		self.params[i] = p
		if self.instrFormat.has_key(self.instrStr):
			self.str = self.instrFormat[self.instrStr].format(*self.params)
	def updateAll(self, p):
		self.params = p
		if self.instrFormat.has_key(self.instrStr):
			self.str = self.instrFormat[self.instrStr].format(*self.params)
	#def __str__(self):
	#	return "Instruction: " + self.instrStr + "(" + ",".join(self.params)+ ")"
	def __repr__(self):
		if hasattr(self, 'str'):
			return self.str
		return "[Instruction: " + self.instrStr + "(" + ",".join(self.params)+ ")]"
class Subneg4Instruction(Instruction):
	pass

class SystemInstruction(Instruction):
	pass