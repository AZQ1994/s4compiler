from instruction import Instruction, Subneg4Instruction
from list_node import ListNode
from label import Label

from memory import Word

#test
from label import LabelManager
from memory import WordManager
from instruction import SystemInstruction

def trans_alloca(LN, Mem, LM):
	Mem.allocate(LN.ins.params[0], Mem.const2i(LN.ins.params[1]))
	LN.remove()
	##########
	# need to save the label
	##########
def trans_add(LN, Mem, LM):
	temp = Mem.temp()
	ins1 = Instruction("subneg4",[Mem.ptr(LN.ins.params[1]),Mem.const(0),temp,"NEXT"])
	ins2 = Instruction("subneg4",[temp, Mem.ptr(LN.ins.params[2]), Mem.ptr(LN.ins.params[0]), "NEXT"])
	LN1 = LM.new(ListNode(ins1))
	LN2 = LM.new(ListNode(ins2))
	LN1.ins.update(3, LN2.label)
	Mem.temp_over(temp)
	#print LN1.ins.params,LN2.ins.params
	LN.replace(LM, LN1, LN2)
	LN2.ins.update(3, LN2.next.label)
def trans_load(LN, Mem, LM):
	ins1 = Instruction("subneg4",[Mem.const(0),Mem.ptr(LN.ins.params[1]),Mem.ptr(LN.ins.params[0]),"NEXT"])
	LN1 = ListNode(ins1)
	#print LN1.ins.params,LN2.ins.params
	LN.replace(LM, LN1)
	LN1.ins.update(3, LN1.next.label)
def trans_store(LN, Mem, LM):
	ins1 = Instruction("subneg4",[Mem.const(0),Mem.ptr(LN.ins.params[0]),Mem.ptr(LN.ins.params[1]),"NEXT"])
	LN1 = ListNode(ins1)
	#print LN1.ins.params,LN2.ins.params
	LN.replace(LM, LN1)
	#print LN1.ins.params,LN1.next.label
	LN1.ins.update(3, LN1.next.label)
def trans_br(LN, Mem, LM):
	if len(LN.ins.params) == 1:
		temp = Mem.temp()
		ins1 = Instruction("subneg4",[Mem.const(0),Mem.const(-1),temp,LM.getLabel(LN.ins.params[0])])
		LN1 = LM.new(ListNode(ins1))
		Mem.temp_over(temp)
		LN.replace(LM, LN1)
	elif len(LN.ins.params) == 3:
		temp = Mem.temp()

		ins1 = Instruction("subneg4",[Mem.const(0),Mem.ptr(LN.ins.params[0]),temp,LM.getLabel(LN.ins.params[1])])
		ins2 = Instruction("subneg4",[Mem.const(0),Mem.const(-1),temp,LM.getLabel(LN.ins.params[2])])
		Mem.temp_over(temp)
		LN1 = LM.new(ListNode(ins1))
		LN2 = LM.new(ListNode(ins2))
		LN.replace(LM, LN1, LN2)


def trans_ret(LN, Mem, LM):
	temp = Mem.temp()
	ins1 = Instruction("subneg4",[Mem.const(0),Mem.const(-1),temp,Label("HALT")])
	LN1 = LM.new(ListNode(ins1))
	Mem.temp_over(temp)
	LN.replace(LM, LN1)

def trans_icmp_slt(LN, Mem, LM):
	if(LN.next.ins.instrStr=="br" and len(LN.next.ins.params) == 3):
		pass#LN1 =
		LM.new(ListNode)
	# if arg1 < arg2 temp = 1
	# arg1 arg2 temp    temp=arg2-arg1 if temp < 0 arg2 > arg1
	# 
	#temp = Mem.temp()
	ins1 = Instruction("subneg4",[Mem.ptr(LN.ins.params[1]), Mem.ptr(LN.ins.params[2]), Mem.ptr(LN.ins.params[0]), Label("NEXT")])
	LN1 = LM.new(ListNode(ins1))
	LN.replace(LM, LN1)




instrTransform = {
	"alloca" : trans_alloca,
	"add" : trans_add,
	"load" : trans_load,
	"store" : trans_store,
	"br" : trans_br,
	"ret" : trans_ret,
	"icmp_slt" : trans_icmp_slt,
}



funcDict = {
	"alloca" : trans_alloca,
	"add" : trans_add,
	"load" : trans_load,
	"store" : trans_store,
	"br" : trans_br,
	"ret" : trans_ret,
	"icmp_slt" : trans_icmp_slt,
}


#subroutine
def goto_mult(LN, WM, LM):
	

	if WM.hasFlag("sr_mult"):
		arg1, arg2, ret_addr = WM.getFlag("sr_mult")
	else:
		lastNode = LN
		while lastNode.next != None:
			lastNode = lastNode.next
		nodes, arg1, arg2, ret_addr, res = sr_mult(WM, LM)
		lastNode.prev.appendLNs(nodes)
		WM.setFlag("sr_mult", (arg1, arg2, ret_addr, res))


	# mult
	"""
	arg1 = a
	arg2 = b
	ret_addr = label for return
	branch
	res = res_mult
	"""
	NEXT = WM.getNext()
	#multAddress = WM.addDataWord(WM.label("sr_mult_start"),"sr_mult_addr")
	c_0 = WM.const(0)
	c_m1 = WM.const(-1)
	after_LNs = [
		LM.new(ListNode(Subneg4Instruction(
			# 
			c_0.getPtr(),
			res.getPtr(),
			LN.ins.res.getPtr(),
			NEXT
		))),
	]
	backAddress = WM.addDataWord(WM.label(after_LNs[0].label),"backAddress")
	pre_LNs = [
		LM.new(ListNode(Subneg4Instruction(
			# 
			c_0.getPtr(),
			LN.ins.param[0].getPtr(),
			arg1.getPtr(),
			NEXT
		))),
		LM.new(ListNode(Subneg4Instruction(
			# 
			c_0.getPtr(),
			LN.ins.param[1].getPtr(),
			arg2.getPtr(),
			NEXT
		))),
		LM.new(ListNode(Subneg4Instruction(
			# 
			c_0.getPtr(),
			backAddress.getPtr(),
			ret_addr.getPtr(),
			NEXT
		))),
		LM.new(ListNode(Subneg4Instruction(
			# 
			c_0.getPtr(),
			c_m1.getPtr(),
			c_m1.getPtr(),
			WM.label("sr_mult_start")
		))),
	]
	LN.replaceLNs(LM, pre_LNs+after_LNs)

	
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

"""
subroutine
-- return all needed params
-- mult:
-- -- arg1: word
-- -- arg2: word
-- -- ret_addr: word


WM.label("sr_mult_L030")
,"sr_mult_L010"
.append(LM.new(ListNode(Subneg4Instruction(
		
	))))

"""

LM = LabelManager()
WM = WordManager()
start = ListNode("start", sys = True)
endNode = ListNode("end", sys = True)
LN = LM.new(ListNode(SystemInstruction("pseudo",[WM.addDataWord(100,"test_1"),WM.addDataWord(200,"test_2")],WM.addDataWord(200,"test_res"))))
start.setNext(LN)
LN.setNext(endNode)
goto_mult(LN, WM, LM)

n = start
while n != None:
	print n
	n = n.next

#nodes, arg1, arg2, ret_addr, res = sr_mult(WM, LM)
#for n in nodes:
#	print n
#print arg1
#print arg2
#print ret_addr
#print res

for key, value in WM.wordDataDict.items():
	print value