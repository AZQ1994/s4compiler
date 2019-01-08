from utils import AddressBeforeUsingHandler
from instruction_node import *

def sr_mult(IN, WM):
	namespace_bak = WM.currentNamespace
	WM.currentNamespace = ["sr","mult"]

	### methods
	# const pointer
	cp = WM.get_const_ptr
	tp = WM.get_temp_ptr

	a = WM.new_dataword("arg1", 0)
	b = WM.new_dataword("arg2", 0)
	ret_addr = WM.new_datapointerword("ret_addr", 0)

	count = WM.new_dataword("count", 0)
	hi = WM.new_dataword("hi", 0)
	lo = WM.new_dataword("lo", 0)
	sign = WM.new_dataword("sign", 0)

	# handler
	h = AddressBeforeUsingHandler(WM)

	LNs = (
		LM.new(ListNode("sr_mult", sys = True)),
		#
		SystemNode([], "sr_mult"),
		h.attach(Subneg4InstructionNode(
				cp(1),
				a.new_ptr(),
				tp(0),
				h.use("sr_mult_L010")
			), "sr_mult_start"),
		P_CP(
				sign.new_ptr(),
				cp(0)
			),
		P_GOTO(
				h.use("sr_mult_L020")
			),
		h.attach(P_SUB(
				a.new_ptr(),
				cp(0),
				a.new_ptr()
			),"sr_mult_L010"),
		P_CP(
				sign.new_ptr(),
				cp(1)
			),
		h.attach(Subneg4InstructionNode(
				cp(1),
				b.new_ptr(),
				tp(0),
				h.use("sr_mult_L030")
			), "sr_mult_L020"),
		Subneg4InstructionNode(
				cp(32),
				cp(0),
				count.new_ptr(),
				h.use("sr_mult_L050")
			),
		h.attach(P_SUB(
				b.new_ptr(),
				cp(0),
				b.new_ptr()
			), "sr_mult_L030"),
		P_SUB(
				sign.new_ptr(),
				cp(-1),
				sign.new_ptr()
			),
		h.attach(P_SUB(
				cp(32),
				cp(0),
				count.new_ptr()
			), "sr_mult_L040"),
		h.attach(P_CP(
				hi.new_ptr(),
				cp(0)
			), "sr_mult_L050"),
		P_CP(
				lo.new_ptr(),
				cp(0)
			),
		h.attach(P_SUB(
				hi.new_ptr(),
				cp(0),
				tp(0)
			), "sr_mult_L100"),
		P_SUB(
				tp(0),
				hi.new_ptr(),
				hi.new_ptr()
			),
		Subneg4InstructionNode(
				lo.new_ptr(),
				cp(-1),
				tp(0),
				h.use("sr_mult_L110")
			),
		P_SUB(
				cp(-1),
				hi.new_ptr(),
				hi.new_ptr()
			),
		h.attach(P_SUB(
				lo.new_ptr(),
				cp(0),
				tp(0)
			), "sr_mult_L110"),
		P_SUB(
				tp(0),
				lo.new_ptr(),
				lo.new_ptr()
			),
		Subneg4InstructionNode(
				a.new_ptr(),
				cp(-1),
				tp(0),
				h.use("sr_mult_L800")
			),
		h.attach(P_SUB(
				b.new_ptr(),
				cp(0),
				tp(0)
			), "sr_mult_L200"),
		Subneg4InstructionNode(
				tp(0),
				lo.new_ptr(),
				lo.new_ptr(),
				h.use("sr_mult_L300")
			),
		Subneg4InstructionNode(
				cp(0),
				b.new_ptr(),
				tp(0),
				h.use("sr_mult_L500")
			),
		Subneg4InstructionNode(
				b.new_ptr(),
				lo.new_ptr(),
				tp(0),
				h.use("sr_mult_L500")
			),
		P_GOTO(
				h.use("sr_mult_L800")
			),
		h.attach(Subneg4InstructionNode(
				b.new_ptr(),
				cp(-1),
				tp(0),
				h.use("sr_mult_L800")
			), "sr_mult_L300"),
		Subneg4InstructionNode(
				b.new_ptr(),
				lo.new_ptr(),
				tp(0),
				h.use("sr_mult_L800")
			),
		h.attach(P_SUB(
				cp(-1),
				hi.new_ptr(),
				hi.new_ptr()
			), "sr_mult_L500"),
		h.attach(P_SUB(
				a.new_ptr(),
				cp(0),
				tp(0)
			), "sr_mult_L800"),
		P_SUB(
				tp(0),
				a.new_ptr(),
				a.new_ptr()
			),
		Subneg4InstructionNode(
				cp(-1),
				count.new_ptr(),
				count.new_ptr(),
				h.use("sr_mult_L100")
			),
		h.attach(Subneg4InstructionNode(
				sign.new_ptr(),
				cp(-1),
				tp(0),
				h.use("sr_mult_L990")
			), "sr_mult_L900")
		P_SUB(
				lo.new_ptr(),
				cp(0),
				lo.new_ptr()
			),
		P_SUB(
				hi.new_ptr(),
				cp(0),
				hi.new_ptr()
			),
		h.attach(P_SUB(
				cp(0),
				hi.new_ptr(),
				tp(0)
			), "sr_mult_L990"),
		Subneg4InstructionNode(
				cp(0),
				lo.new_ptr(),
				tp(0)
			),
		P_GOTO(ret_addr)

	)

	h.solve()