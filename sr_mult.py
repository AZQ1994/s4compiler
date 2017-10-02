from list_node import ListNode
from instruction import Instruction, Subneg4Instruction


def sr_mult(WM, LM):
	c_0 = WM.const(0)
	c_1 = WM.const(1)
	c_m1 = WM.const(-1)
	c_32 = WM.const(32)

	a = WM.addDataWord(0, "mult_arg1")
	b = WM.addDataWord(0, "mult_arg2")
	ret_addr = WM.addDataWord(0, "mult_ret_addr")

	temp = WM.addDataWord(0, "mult_temp")

	count = WM.addDataWord(0, "mult_count")
	hi = WM.addDataWord(0, "mult_hi")
	lo = WM.addDataWord(0, "mult_lo")
	sign = WM.addDataWord(0, "mult_sign")

	NEXT = WM.getNext()
	#HALT = WM.getHalt()

	
	LNs = (
		LM.new(ListNode("sr_mult", sys = True)),
		LM.new(ListNode(Subneg4Instruction(
			c_1.getPtr(),
			a.getPtr(), 
			temp.getPtr(), 
			WM.label("sr_mult_L010")
		)), "sr_mult_start"),
		LM.new(ListNode(Subneg4Instruction(
			c_0.getPtr(), 
			c_0.getPtr(), 
			sign.getPtr(), 
			NEXT
		))),
		LM.new(ListNode(Subneg4Instruction(
			c_0.getPtr(), 
			c_m1.getPtr(), 
			temp.getPtr(), 
			WM.label("sr_mult_L020")
		))),
		LM.new(ListNode(Subneg4Instruction(
			a.getPtr(), 
			c_0.getPtr(), 
			a.getPtr(), 
			NEXT
		)),"sr_mult_L010"),
		LM.new(ListNode(Subneg4Instruction(
			c_0.getPtr(), 
			c_1.getPtr(), 
			sign.getPtr(), 
			NEXT
		))),
		LM.new(ListNode(Subneg4Instruction(
			c_1.getPtr(), 
			b.getPtr(), 
			temp.getPtr(), 
			WM.label("sr_mult_L030")
		)),"sr_mult_L020"),
		LM.new(ListNode(Subneg4Instruction(
			c_32.getPtr(), 
			c_0.getPtr(), 
			count.getPtr(), 
			WM.label("sr_mult_L050")
		))),
		LM.new(ListNode(Subneg4Instruction(
			b.getPtr(), 
			c_0.getPtr(), 
			b.getPtr(), 
			NEXT
		)),"sr_mult_L030"),
		LM.new(ListNode(Subneg4Instruction(
			sign.getPtr(), 
			c_m1.getPtr(), 
			sign.getPtr(), 
			NEXT
		))),
		LM.new(ListNode(Subneg4Instruction(
			c_32.getPtr(), 
			c_0.getPtr(), 
			count.getPtr(), 
			NEXT
		)),"sr_mult_L040"),
		LM.new(ListNode(Subneg4Instruction(
			c_0.getPtr(), 
			c_0.getPtr(), 
			hi.getPtr(), 
			NEXT
		)),"sr_mult_L050"),
		LM.new(ListNode(Subneg4Instruction(
			c_0.getPtr(), 
			c_0.getPtr(), 
			lo.getPtr(), 
			NEXT
		))),
		LM.new(ListNode(Subneg4Instruction(
			hi.getPtr(), 
			c_0.getPtr(), 
			temp.getPtr(), 
			NEXT
		)),"sr_mult_L100"),
		LM.new(ListNode(Subneg4Instruction(
			temp.getPtr(), 
			hi.getPtr(), 
			hi.getPtr(), 
			NEXT
		))),
		LM.new(ListNode(Subneg4Instruction(
			lo.getPtr(), 
			c_m1.getPtr(), 
			temp.getPtr(), 
			WM.label("sr_mult_L110")
		))),
		LM.new(ListNode(Subneg4Instruction(
			c_m1.getPtr(), 
			hi.getPtr(), 
			hi.getPtr(), 
			NEXT
		))),
		LM.new(ListNode(Subneg4Instruction(
			lo.getPtr(), 
			c_0.getPtr(), 
			temp.getPtr(),
			NEXT
		)),"sr_mult_L110"),
		LM.new(ListNode(Subneg4Instruction(
			temp.getPtr(),
			lo.getPtr(),
			lo.getPtr(),
			NEXT
		))),
		LM.new(ListNode(Subneg4Instruction(
			a.getPtr(),
			c_m1.getPtr(),
			temp.getPtr(),
			WM.label("sr_mult_L800")
		))),
		LM.new(ListNode(Subneg4Instruction(
			b.getPtr(),
			c_0.getPtr(),
			temp.getPtr(),
			NEXT
		)),"sr_mult_L200"),
		LM.new(ListNode(Subneg4Instruction(
			temp.getPtr(),
			lo.getPtr(),
			lo.getPtr(),
			WM.label("sr_mult_L300")
		))),
		LM.new(ListNode(Subneg4Instruction(
			c_0.getPtr(),
			b.getPtr(),
			temp.getPtr(),
			WM.label("sr_mult_L500")
		))),
		LM.new(ListNode(Subneg4Instruction(
			b.getPtr(), 
			lo.getPtr(), 
			temp.getPtr(), 
			WM.label("sr_mult_L500")
		))),
		LM.new(ListNode(Subneg4Instruction(
			c_0.getPtr(), 
			c_m1.getPtr(), 
			temp.getPtr(), 
			WM.label("sr_mult_L800")
		))),
		LM.new(ListNode(Subneg4Instruction(
			b.getPtr(), 
			c_m1.getPtr(), 
			temp.getPtr(), 
			WM.label("sr_mult_L800")
		)),"sr_mult_L300"),
		LM.new(ListNode(Subneg4Instruction(
			b.getPtr(), 
			lo.getPtr(), 
			temp.getPtr(), 
			WM.label("sr_mult_L800")
		))),
		LM.new(ListNode(Subneg4Instruction(
			c_m1.getPtr(), 
			hi.getPtr(), 
			hi.getPtr(), 
			NEXT
		)),"sr_mult_L500"),
		LM.new(ListNode(Subneg4Instruction(
			a.getPtr(), 
			c_0.getPtr(), 
			temp.getPtr(), 
			NEXT
		)),"sr_mult_L800"),
		LM.new(ListNode(Subneg4Instruction(
			temp.getPtr(), 
			a.getPtr(), 
			a.getPtr(), 
			NEXT
		))),
		LM.new(ListNode(Subneg4Instruction(
			c_m1.getPtr(), 
			count.getPtr(), 
			count.getPtr(), 
			WM.label("sr_mult_L100")
		))),
		LM.new(ListNode(Subneg4Instruction(
			sign.getPtr(), 
			c_m1.getPtr(), 
			temp.getPtr(), 
			WM.label("sr_mult_L990")
		)),"sr_mult_L900"),
		LM.new(ListNode(Subneg4Instruction(
			lo.getPtr(), 
			c_0.getPtr(), 
			lo.getPtr(), 
			NEXT
		))),
		LM.new(ListNode(Subneg4Instruction(
			hi.getPtr(), 
			c_0.getPtr(), 
			hi.getPtr(), 
			NEXT
		))),
		LM.new(ListNode(Subneg4Instruction(
			c_0.getPtr(), 
			hi.getPtr(), 
			temp.getPtr(), 
			NEXT
		)),"sr_mult_L990"),
		LM.new(ListNode(Subneg4Instruction(
			c_0.getPtr(), 
			lo.getPtr(), 
			temp.getPtr(),
			NEXT
		))),
		LM.new(ListNode(Subneg4Instruction(
			c_0.getPtr(), 
			c_m1.getPtr(), 
			temp.getPtr(), 
			ret_addr
		)))
	)
	return LNs, a, b, ret_addr, lo