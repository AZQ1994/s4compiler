
from config import config

class Instruction:
	def __init__(self, instrStr, params, comment = ""):
		self.instrStr = instrStr
		self.params = params
		#self.label = ""
		self.instrFormat = config.getInstrFormat()
		if self.instrFormat.has_key(instrStr):
			pass#self.str = self.instrFormat[instrStr].format(*params)
		self.comment = comment
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
		return "<Instruction: " + self.instrStr + "(" + ",".join([str(x) for x in self.params])+ ")>" + self.comment
class Subneg4Instruction(Instruction):
	def __init__(self, p1, p2, p3, p4, comment = ""):
		self.params = [p1,p2,p3,p4]
		self.instrStr = "SBN4"
		self.comment = comment
	def __repr__(self):
		#return "/*SBN4*/ "+ str(self.params[0]) + " " + str(self.params[1]) + " " + str(self.params[2]) + " " + str(self.params[3])
		return str(self.params[0]) + " " + str(self.params[1]) + " " + str(self.params[2]) + " " + str(self.params[3]) + self.comment

class PseudoInstruction(Instruction):
	# instruction: 
	 			#p_sub:			a,b,c --> c = b - a
				#p_add:			a,b,c --> c = b + a 	>>>>>>>> temp = -a, c = b - temp
				#p_cp:			a,b   --> b = a
				#p_neg:			a,b   --> b = -a
				#p_goto:		L     --> goto L
				#p_flag_goto?
	pass
class P_SUB(PseudoInstruction):
	def __init__(self, p1, p2, p3, comment = ""):
		self.params = [p1, p2, p3]
		self.instrStr = "p_sub"
		self.comment = comment
	def __repr__(self):
		return "<PESUDO> p_sub "+ str(self.params[0]) + ", " + str(self.params[1]) + ", " + str(self.params[2])
class P_ADD(PseudoInstruction):
	def __init__(self, p1, p2, p3, comment = ""):
		self.params = [p1, p2, p3]
		self.instrStr = "p_add"
		self.comment = comment
	def __repr__(self):
		return "<PESUDO> p_add "+ str(self.params[0]) + ", " + str(self.params[1]) + ", " + str(self.params[2])
class P_CP(PseudoInstruction):
	def __init__(self, p1, p2, comment = ""):
		self.params = [p1, p2]
		self.instrStr = "p_cp"
		self.comment = comment
	def __repr__(self):
		return "<PESUDO> p_cp "+ str(self.params[0]) + ", " + str(self.params[1])
class P_NEG(PseudoInstruction):
	def __init__(self, p1, p2, comment = ""):
		self.params = [p1, p2]
		self.instrStr = "p_neg"
		self.comment = comment
	def __repr__(self):
		return "<PESUDO> p_neg "+ str(self.params[0]) + ", " + str(self.params[1])
class P_GOTO(PseudoInstruction):
	def __init__(self, p1, comment = ""):
		self.params = [p1]
		self.instrStr = "p_goto"
		self.comment = comment
	def __repr__(self):
		return "<PESUDO> p_goto "+ str(self.params[0])

class SystemInstruction(Instruction):
	"""
	def __init__(self, name, param, res):
		self.name = name
		self.param = param
		self.res = res
	"""
	pass