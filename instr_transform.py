from instruction import Instruction
from list_node import ListNode
from label import Label

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
		pass#LN1 = LM.new(ListNode)
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
