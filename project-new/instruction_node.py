from word import *
from compiler.ast import flatten
from collections import defaultdict
class InstructionNode(object):
	def __init__(self, params, instrStr, comment = ""):
		self.params = params
		self.params_write = [False for _ in flatten(params)]
		self.instrStr = instrStr
		self.comment = comment
		for key, p in enumerate(flatten(params)):
			p.used_in(self, key)
		self.prev = None
		self.next = None

	def set_write_param(self, i):
		self.params_write[i] = True
		return self

	def get_param(self, i):
		return flatten(self.params)[i]

	def get_next(self):
		return self.next

	def get_next_inst(self):
		current = self.next
		while current != None and isinstance(current, SystemNode):
			current = current.next
		# [Warning] In this case, None is possibly returned
		return current

	def set_next(self, IN):
		"""
		Append a Node after self and return self
		"""
		self.next = IN
		IN.prev = self
		return self
	def append(self, *INs):
		temp = self.next
		current = self
		for IN in INs:
			current.next = IN
			IN.prev = current
			current = IN
		current.next = temp
		temp.prev = current
		return current
	def appendINs(self, INs):
		temp = self.next
		current = self
		for IN in INs:
			current.next = IN
			IN.prev = current
			current = IN
		current.next = temp
		temp.prev = current
		return current

	def append_block(self, IN):
		temp = self.next
		self.set_next(IN)
		current = IN
		while current.next != None:
			current = current.next
		current.set_next(temp)
		return current

	def replace_by(self, IN):
		_prev = self.prev
		_next = self.next
		_prev.next = IN
		_next.prev = IN
		IN.prev = _prev
		IN.next = _next

		del self
		return IN
	
	def remove(self):
		_next = self.next
		self.prev.next = _next
		self.next.prev = self.prev
		del self
		return _next

	def set_param(self, index, param):
		self.params[index] = param
		param.used_in(self, index)

	def to_asm(self):
		return "! " + str(self)

	def __hash__(self):
		return id(self)

	def __del__(self):
		for p in self.params:
			p.no_longer_used_in(self)
class IRInstructionNode(InstructionNode):
	def __init__(self, params, instrStr, BB, comment = ""):
		super(IRInstructionNode, self).__init__(params, instrStr, comment)
		self.BB = BB
	def __str__(self):
		return "(IRI) {0} {1}".format(self.instrStr, " ".join([str(p) for p in self.params]))

	def to_asm(self):
		return "\t{0}\t{1}".format(self.instrStr, ", ".join([p.to_asm() for p in flatten(self.params)]))
class IRPhi(IRInstructionNode):

	pass

class PrePhi(IRInstructionNode):
	# param: Address, source, des
	pass

class IRCall(IRInstructionNode):
	def __init__(self, params, instrStr, des, call_params, BB, comment = ""):
		super(IRCall, self).__init__(params, instrStr, BB, comment)
		self.des = des
		self.call_params = call_params
	def set_param(self, index, param):
		if self.des == None:
			self.call_params[index] = param
		else:
			self.call_params[index-1] = param
		self.params[index] = param
		param.used_in(self, index)

class IRReturn(IRInstructionNode):
	pass

class IRFunction(object):
	def __init__(self, name):
		self.name = name
		self.start = FunctionStart(name)
		self.end = FunctionEnd(name)
		self.start.set_next(self.end)

class IRBasicBlock(object):
	def __init__(self, name):
		self.name = name
		self.start = BasicBlockStart(name, self)
		self.end = BasicBlockEnd(name, self)
		self.start.set_next(self.end)
		self.to_bb = []
		self.from_bb = []
		self.with_phi = False
		self.is_once = None

	def __hash__(self):
		return id(self)
	def __str__(self):
		return "BB: {0}\t".format(self.name)

class SystemNode(InstructionNode):
	#def __init__(self):
	#	pass
	def __str__(self):
		return "(SYS) {0}".format(self.instrStr)
	def __repr__(self):
		return self.instrStr

class BasicBlockStart(SystemNode):
	def __init__(self, name, BB):
		super(BasicBlockStart, self).__init__([], "bb_start", "Basic Block start: " + name)
		self.bb_name = name
		self.BB = BB
	def to_asm(self):
		return "L_{0}: // {1}".format(id(self), self.bb_name)
	def __str__(self):
		return "//bb_start: "+self.bb_name
class BasicBlockEnd(SystemNode):
	def __init__(self, name, BB):
		super(BasicBlockEnd, self).__init__([], "bb_end", "Basic Block end: " + name)
		self.bb_name = name
		self.BB = BB
	def to_asm(self):
		return ""
	def __str__(self):
		return "//bb_end"
class FunctionStart(SystemNode):
	def __init__(self, name):
		super(FunctionStart, self).__init__([], "func_start", "function {0}(): ".format(name))
		self.func_name = name
	def to_asm(self):
		return "L_{0}: // {1}".format(id(self), self.func_name)
	def __str__(self):
		return ""
class FunctionEnd(SystemNode):
	def __init__(self, name):
		super(FunctionEnd, self).__init__([], "func_end", "function end: " + name)
		self.func_name = name
	def to_asm(self):
		return ""
	def __str__(self):
		return ""
class Subneg4InstructionNode(InstructionNode):
	def __init__(self, p1, p2, p3, p4, comment = ""):
		super(Subneg4InstructionNode, self).__init__([p1, p2, p3, p4],"SBN4",comment)
	def to_asm(self):
		return "L_{2}: {0[0]} {0[1]} {0[2]} {0[3]}; // {1}".format(self.params, self.comment, id(self))

	def __str__(self):
		return "(SNG) {0[0]} {0[1]} {0[2]} {0[3]}; // {1}".format(self.params, self.comment)

	def __repr__(self):
		return "SNG4 {0[0]} {0[1]} {0[2]} {0[3]}".format(self.params)

class PseudoInstructionNode(InstructionNode):
	def rep(self):
		raise Exception

class P_SUB(PseudoInstructionNode):
	def __init__(self, p1, p2, p3, comment = ""):
		super(P_SUB, self).__init__([p1, p2, p3], "P_SUB", comment)
	def rep(self):
		_WM = self.params[0].manager
		_next = _WM.getNext()
		rep = Subneg4InstructionNode(self.params[0], self.params[1], self.params[2], _next, self.comment)
		self.replace_by(rep)


	def __str__(self):
		return "(PSD) {2} = {1} - {0}; // {3}".format(self.params[0], self.params[1], self.params[2], self.comment)
	def __repr__(self):
		return "P_SUB {0[0]} {0[1]} {0[2]}".format(self.params)

class P_CP(PseudoInstructionNode):
	def __init__(self, p1, p2, comment = ""):
		super(P_CP, self).__init__([p1, p2], "P_CP", comment)
	def rep(self):
		_WM = self.params[0].manager
		_next = _WM.getNext()
		c_0 = _WM.get_const_ptr(0)
		rep = Subneg4InstructionNode(c_0, self.params[2], self.params[1], _next, self.comment)
		self.replace_by(rep)


	def __str__(self):
		return "(PSD) {0} = {1}; // {2}".format(self.params[0], self.params[1], self.comment)
	def __repr__(self):
		return "P_CP {0[0]} {0[1]}".format(self.params)

class P_ADD(PseudoInstructionNode):
	def __init__(self, p1, p2, p3, comment = ""):
		super(P_SUB, self).__init__([p1, p2, p3], "P_ADD", comment)
	def rep(self):
		_WM = self.params[0].manager
		_next1 = _WM.getNext()
		_next2 = _WM.getNext()
		temp_p1 = _WM.get_temp_ptr()
		temp_p2 = _WM.get_temp_ptr()
		c_0 = _WM.get_const_ptr(0)
		rep1 = Subneg4InstructionNode(self.params[0], c_0, temp_p1, _next1, self.comment)
		rep2 = Subneg4InstructionNode(temp_p2, self.params[1], self.params[2], _next2, self.comment)
		self.replace_by(rep1).append(rep2)


	def __str__(self):
		return "(PSD) {2} = {1} + {0}; // {3}".format(self.params[0], self.params[1], self.params[2], self.comment)
	def __repr__(self):
		return "P_ADD {0[0]} {0[1]} {0[2]}".format(self.params)

class P_GOTO(PseudoInstructionNode):
	def __init__(self, p1, comment = ""):
		super(P_GOTO, self).__init__([p1], "P_GOTO", comment)
	def rep(self):
		_WM = self.params[0].manager
		c_0 = _WM.const(0)
		c_m1 = _WM.const(-1)
		temp = _WM.getTemp(0)

		rep = Subneg4InstructionNode(c_0, c_m1, temp, self.params[0], self.comment)
		self.replace_by(rep)


	def __str__(self):
		return "(PSD) goto {0}; // {1}".format(self.params[0], self.comment)
	def __repr__(self):
		return "P_GOTO {0}".format(self.params[0])

class ClassName(object):
	"""docstring for ClassName"""
	def __init__(self, arg):
		super(ClassName, self).__init__()
		self.arg = arg
		
