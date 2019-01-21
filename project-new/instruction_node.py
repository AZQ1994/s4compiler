from word import *
from compiler.ast import flatten
from collections import defaultdict
class InstructionNode(object):
	def __init__(self, params, instrStr, comment = ""):
		self.params = params
		self.params_write = [False for _ in flatten(params)]
		self.write_params = {}
		self.instrStr = instrStr
		self.comment = comment
		for key, p in enumerate(flatten(params)):
			p.used_in(self, key)
		self.prev = None
		self.next = None

	def set_write_param(self, i):
		self.params_write[i] = True
		self.write_params[i] = True
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
		_next = self.next
		current = self
		for IN in INs:
			current.next = IN
			IN.prev = current
			current = IN
		current.next = _next
		if _next != None:
			_next.prev = current
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
		self.__del__()
		del self
		return IN
	def replace_by_INs(self, INs):
		# !!! TODO !!! need to change the addresses

		_next = self.next
		current = self.prev

		for IN in INs:
			current.next = IN
			IN.prev = current
			current = IN
		current.next = _next
		_next.prev = current
		his = self.prev.next
		self.__del__()
		del self
		return his
	def replace_by_block(self, IN):
		_prev = self.prev
		_next = self.next
		_prev.next = IN
		IN.prev = _prev
		current = IN

		while current.next != None:
			current = current.next
		
		current.next = _next
		_next.prev = current
		self.__del__()
		del self
		return current

	def remove(self):
		_next = self.next
		self.prev.next = _next
		self.next.prev = self.prev
		self.__del__()
		del self

		return _next

	def set_param(self, index, param):

		# index
		to_check = [(self.params, None, 0)]
		i = index
		while len(to_check)!=0:
			check, target, index_of_target = to_check.pop()
			if type(check) == list:
				y = len(check)
				for x in check[::-1]:
					y -= 1
					to_check.append((x, check, y))
			elif i==0:
				target[index_of_target] = param
				break
			else:
				i -= 1

		param.used_in(self, index)

	def to_asm(self):
		return "! " + str(self)

	def __hash__(self):
		return id(self)

	def __del__(self):
		for p in flatten(self.params):
			p.no_longer_used_in(self)
class IRInstructionNode(InstructionNode):
	def __init__(self, params, instrStr, BB, comment = ""):
		super(IRInstructionNode, self).__init__(params, instrStr, comment)
		self.BB = BB
	def __str__(self):
		return "(IRI) {0} {1}".format(self.instrStr, " ".join([str(p) for p in flatten(self.params)]))

	def to_asm(self):
		return "\t{0}\t{1}".format(self.instrStr, ", ".join([p.to_asm() for p in flatten(self.params)]))
class IRIcmpBr3(IRInstructionNode):
	pass

class IRPhi(IRInstructionNode):
	pass

class PrePhi(IRInstructionNode):
	# param: [Address1, [s1,d1], [s2,d2]], [Address2, [s1,s2], [d1,d2]], [Address1, [s1,d1], [s2,d2]], [Address2, [s1,s2], [d1,d2]],
	pass

class IcmpBr3Phi(InstructionNode): # todo
	# icmp x, p1, p2
	# br x, L1(1), L2(-1)
	# phi a <- b
	# ICMPBR3PHI(cond) [ p1, p2, L1, L2, (L1)[[a,a'],[b,b']], (L2)[[c,c']] ]
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
		self.called = []
		self.is_recursive = False
		self.bb_dict = None

class IRBasicBlock(object):
	def __init__(self, name, func_name):
		self.name = name
		self.func_name = func_name
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
	def to_asm(self):
		if self.instrStr == "label" or self.instrStr == "call-ret":
			return "L_{0}:".format(id(self))
		return "//"+str(self)
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
		return "function start:"+self.func_name
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
		return "L_{2}: {0[0]} {0[1]} {0[2]} {0[3]} // {1}".format([p.to_asm() for p in self.params], self.comment, id(self))

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
		_next = _WM.get_NEXT()
		rep = Subneg4InstructionNode(self.params[0], self.params[1], self.params[2], _next, self.comment)
		self.replace_by(rep)


	def __str__(self):
		return "(PSD) {2} = {1} - {0}; // {3}".format(self.params[0], self.params[1], self.params[2], self.comment)
	def __repr__(self):
		return "P_SUB {0[0]} {0[1]} {0[2]}".format(self.params)

class P_CP(PseudoInstructionNode):
	def __init__(self, p1, p2, comment = ""):
		super(P_CP, self).__init__([p1, p2], "P_CP", comment) # p1: des, p2: source
	def rep(self):
		if self.params[0].value == self.params[1].value:
			self.remove()
			self.params[0].manager.unreg(self.params[0])
			self.params[1].manager.unreg(self.params[1])
			return
		_WM = self.params[0].manager
		_next = _WM.get_NEXT()
		c_0 = _WM.get_const_ptr(0)
		rep = Subneg4InstructionNode(c_0, self.params[1], self.params[0], _next, self.comment)
		self.replace_by(rep)


	def __str__(self):
		return "(PSD) {0} = {1}; // {2}".format(self.params[0], self.params[1], self.comment)
	def __repr__(self):
		return "P_CP {0[0]} {0[1]}".format(self.params)

class P_ADD(PseudoInstructionNode):
	def __init__(self, p1, p2, p3, comment = ""):
		super(P_ADD, self).__init__([p1, p2, p3], "P_ADD", comment)
	def rep(self):
		_WM = self.params[0].manager
		
		if self.params[0].value.type == "data-const":
			print self
			_next = _WM.get_NEXT()
			c_m = _WM.get_const_ptr(0-self.params[0].value.value)
			print c_m
			rep = Subneg4InstructionNode(c_m, self.params[1], self.params[2], _next)
			self.replace_by(rep)
			print rep
			_WM.unreg(self.params[0])
			return
		"""
		if self.params[1].value.type == "data-const":
			print self
			_next = _WM.get_NEXT()
			c_m = _WM.get_const_ptr(0-self.params[1].value.value)
			self.replace_by(Subneg4InstructionNode(c_m, self.params[0], self.params[2], _next))
			_WM.unreg(self.params[1])
			return
		"""
		_next1 = _WM.get_NEXT()
		_next2 = _WM.get_NEXT()
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
		if self.get_next_inst() != None and self.params[0].value == self.get_next_inst().prev:
			self.remove()
			self.params[0].manager.unreg(self.params[0])
			return
		_WM = self.params[0].manager
		c_0 = _WM.get_const_ptr(0)
		c_m1 = _WM.get_const_ptr(-1)
		temp = _WM.get_temp_ptr()

		rep = Subneg4InstructionNode(c_0, c_m1, temp, self.params[0], self.comment)
		self.replace_by(rep)


	def __str__(self):
		return "(PSD) goto {0}; // {1}".format(self.params[0], self.comment)
	def __repr__(self):
		return "P_GOTO {0}".format(self.params[0])
class P_NEG(PseudoInstructionNode):
	def __init__(self, p1, p2, comment = ""):
		super(P_NEG, self).__init__([p1, p2], "P_NEG", comment)
	def rep(self):
		_WM = self.params[0].manager
		c_0 = _WM.get_const_ptr(0)
		temp = _WM.get_temp_ptr()

		rep = Subneg4InstructionNode(c_0, self.params[0], temp, self.params[1], self.comment)
		self.replace_by(rep)


	def __str__(self):
		return "(PSD) neg {0} < 0 ? goto {1}; // {2}".format(self.params[0], self.params[1], self.comment)
	def __repr__(self):
		return "P_NEG {0} {1}".format(self.params[0], self.params[1])

class P_PUSH(PseudoInstructionNode):
	def __init__(self, p1, comment = ""):
		super(P_PUSH, self).__init__([p1], "P_PUSH", comment)
	def rep(self):
		param = self.params[0]
		WM = param.manager
		write = WM.new_pointerdataword("", None)
		c_m1 = WM.get_const_ptr(-1)
		stack_pointer = WM.stack["pointer"]

		nodes = [
			P_CP(write.new_ptr(), stack_pointer.new_ptr()),
			P_CP(write, param.new_ptr()),
			P_SUB(c_m1, stack_pointer.new_ptr(), stack_pointer.new_ptr())
		]
		self.replace_by_INs(nodes)

	def __str__(self):
		return "(PSD) push {0}; // {1}".format(self.params[0], self.comment)
	def __repr__(self):
		return "P_PUSH {0}".format(self.params[0])
class P_POP(PseudoInstructionNode):
	def __init__(self, p1, comment = ""):
		super(P_POP, self).__init__([p1], "P_POP", comment)
	def rep(self):
		param = self.params[0]
		WM = param.manager
		read = WM.new_pointerdataword("", None)
		c_1 = WM.get_const_ptr(1)
		stack_pointer = WM.stack["pointer"]

		nodes = [
			P_SUB(c_1, stack_pointer.new_ptr(), stack_pointer.new_ptr()),
			P_CP(read.new_ptr(), stack_pointer.new_ptr()),
			P_CP(param.new_ptr(), read)
		]
		self.replace_by_INs(nodes)


	def __str__(self):
		return "(PSD) pop {0}; // {1}".format(self.params[0], self.comment)
	def __repr__(self):
		return "P_POP {0}".format(self.params[0])


class ClassName(object):
	"""docstring for ClassName"""
	def __init__(self, arg):
		super(ClassName, self).__init__()
		self.arg = arg
		
