# coding=UTF-8

from instruction import Instruction, Subneg4Instruction
from list_node import ListNode
from label import Label

from memory import Word

#test
from label import LabelManager
from memory import WordManager
from instruction import SystemInstruction

"""
how to give a namespace to WordManager

WM.setNameSpace = "__STRING__"



ListNode


"""
import re

def build_br(ins_params, WM):
	params = []
	if len(ins_params)==1:
		p_var = re.findall(r'var\(([\s\S]*?)\)', ins_params[0])
		if len(p_var) == 1:
			word = WM.label(p_var[0].replace(".","_"))
			params.append(word)
			return params
		p_ptr = re.findall(r'ptr\(([\s\S]*?)\)', ins_params[0])
		if len(p_ptr) == 1:
			word = WM.label("p_"+p_ptr[0])
			params.append(word)
		return params
	# ins_params[0]
	p_var = re.findall(r'var\(([\s\S]*?)\)', ins_params[0])
	if len(p_var) == 1:
		word = WM.getName(p_var[0].replace(".","_"))
		params.append(word)
	
	p_int = re.findall(r'int\(([\s\S]*?)\)', ins_params[0])
	if len(p_int) == 1:
		word = WM.const(p_int[0])
		params.append(word)
	
	p_ptr = re.findall(r'ptr\(([\s\S]*?)\)', ins_params[0])
	if len(p_ptr) == 1:
		word = WM.getName("p_"+p_ptr[0])
		params.append(word)
	# ins_params[1]
	p_var = re.findall(r'var\(([\s\S]*?)\)', ins_params[1])
	if len(p_var) == 1:
		word = WM.label(p_var[0].replace(".","_"))
		params.append(word)
	p_ptr = re.findall(r'ptr\(([\s\S]*?)\)', ins_params[1])
	if len(p_ptr) == 1:
		word = WM.label("p_"+p_ptr[0])
		params.append(word)
	# ins_params[2]
	p_var = re.findall(r'var\(([\s\S]*?)\)', ins_params[2])
	if len(p_var) == 1:
		word = WM.label(p_var[0].replace(".","_"))
		params.append(word)
	p_ptr = re.findall(r'ptr\(([\s\S]*?)\)', ins_params[2])
	if len(p_ptr) == 1:
		word = WM.label("p_"+p_ptr[0])
		params.append(word)
	return params



build_methods={
	"br":build_br
}

def trans_alloca(LN, WM, LM):
	LN.remove()
	pass
	#WM.addName(WM.addDataWord(0, LN.ins.params[0]), LN.ins.params[0])
	# ??
	
	LN.remove()
	##########
	# need to save the label
	##########
def trans_add(LN, WM, LM):
	# param0 = param1 + param2
	temp = WM.getTemp(0)
	param1 = LN.ins.params[1]
	param2 = LN.ins.params[2]
	param0 = LN.ins.params[0]
	c_0 = WM.const(0)
	NEXT = WM.getNext()

	LN1 = LM.new(ListNode(Subneg4Instruction(
			param1.getPtr(),
			c_0.getPtr(),
			temp.getPtr(),
			NEXT
		)))
	LN2 = LM.new(ListNode(Subneg4Instruction(
			temp.getPtr(),
			param2.getPtr(),
			param0.getPtr(),
			NEXT
		)))
	LN.replace(LM, LN1, LN2)


def trans_load(LN, WM, LM):
	c_0 = WM.const(0)
	NEXT = WM.getNext()
	param1 = LN.ins.params[1]
	param0 = LN.ins.params[0]

	LN1 = LM.new(ListNode(Subneg4Instruction(
			c_0.getPtr(),
			param1.getPtr(),
			param0.getPtr(),
			NEXT
		)))
	LN.replace(LM, LN1)

def trans_store(LN, WM, LM):
	c_0 = WM.const(0)
	NEXT = WM.getNext()
	param1 = LN.ins.params[1]
	param0 = LN.ins.params[0]

	LN1 = LM.new(ListNode(Subneg4Instruction(
			c_0.getPtr(),
			param0.getPtr(),
			param1.getPtr(),
			NEXT
		)))
	LN.replace(LM, LN1)

def trans_br(LN, WM, LM):
	
	temp = WM.getTemp(0)
	c_0 = WM.const(0)
	c_m1 = WM.const(-1)

	if len(LN.ins.params) == 1:
		LN1 = LM.new(ListNode(Subneg4Instruction(
			c_0.getPtr(),
			c_m1.getPtr(),
			temp.getPtr(),
			LN.ins.params[0]
		)))
		LN.replace(LM, LN1)
	elif len(LN.ins.params) == 3:

		param0 = LN.ins.params[0]
		# 0, param0, temp, param1
		# 0, -1, temp, param2
		LN1 = LM.new(ListNode(Subneg4Instruction(
			c_0.getPtr(),
			param0.getPtr(),
			temp.getPtr(),
			LN.ins.params[2]
		)))
		LN2 = LM.new(ListNode(Subneg4Instruction(
			c_0.getPtr(),
			c_m1.getPtr(),
			temp.getPtr(),
			LN.ins.params[1] 
		)))
		LN.replace(LM, LN1, LN2)


def trans_ret(LN, WM, LM):
	temp = WM.getTemp(0)
	c_0 = WM.const(0)
	c_m1 = WM.const(-1)
	HALT = WM.getHalt()
	LN1 = LM.new(ListNode(Subneg4Instruction(
		c_0.getPtr(),
		c_m1.getPtr(),
		temp.getPtr(),
		HALT
	)))
	LN.replace(LM, LN1)
	#use stack
	return
	temp = Mem.temp()
	ins1 = Instruction("subneg4",[Mem.const(0),Mem.const(-1),temp,Label("HALT")])
	LN1 = LM.new(ListNode(ins1))
	Mem.temp_over(temp)
	LN.replace(LM, LN1)

def trans_icmp_slt(LN, WM, LM):
	if(LN.next.ins.instrStr=="br" and len(LN.next.ins.params) == 3):
		pass#LN1 =
		LM.new(ListNode)
	# if arg1 < arg2 temp = 1
	# arg1 arg2 temp    temp=arg2-arg1 if temp < 0 arg2 > arg1
	# 
	# temp = Mem.temp()

	# param1, param2, param0, next

	#if param1 < param2: param0 = 1 else -1


		"""
	i1         c_0 param1 param1 L_slt_1
	i2         c_0 param2 param2 Lge_0
	i3 L_sge_tge_1:    param2 param1 T0 Llt_0
	i4         DEC c_0 TJ Lge_0
	i5 L_slt_1:        c_0 param2 param2 L_sge_tge_1
	i6     DEC c_0 TJ Llt_0
	i7 Llt_0:  INC c_0 param0
	i8         DEC c_0 TJ Lfinish
	i9 Lge_0:  c_0 c_0 param0
	#i10         DEC c_0 TJ Lfinish
		"""

	"""
	param1 < 0? goto L500
	--- (param1 >= 0)
	--- param2 < 0? goto L800
	--- --- (param2 >= 0)
	L700--- param1 - param2 < 0? goto L200
	L800--- --- (param1 - param2 >= 0) => (param1 >= param2) =======> set -1 => over
	L200--- --- (param1 - param2 < 0) => param1 < param2 ======> set 1
	--- --- --- --- branch over
	L500(param1 < 0)
	--- param2 < 0? goto L700
	--- (param2 >= 0) => (param1 < param2) ======> set 1
	--- branch over

	I1:	0, param1, temp, I7
	I2:	0, param2, temp, I4
	I3:	param2, param1, temp, I5
	I4: 0, -1, param0, HALT
	I5: 0, 1, param0, NEXT
	I6:	0, -1, temp, HALT
	I7:	0, param2, temp, I3
	I8:	0, 1, param0, NEXT

	"""


	
	param1 = LN.ins.params[1]
	param2 = LN.ins.params[2]
	param0 = LN.ins.params[0]

	c_0 = WM.const(0)
	c_1 = WM.const(1)
	c_m1 = WM.const(-1)
	
	temp = WM.getTemp(0)
	NEXT = WM.getNext()
	"""
	LN1 = LM.new(ListNode(Subneg4Instruction(
		param1.getPtr(),
		param2.getPtr(),
		param0.getPtr(),
		NEXT
	)))
	"""


	LN8 = LM.new(ListNode(Subneg4Instruction(
		c_0.getPtr(),
		c_1.getPtr(),
		param0.getPtr(),
		NEXT
	)))
	LN5 = LM.new(ListNode(Subneg4Instruction(
		c_0.getPtr(),
		c_1.getPtr(),
		param0.getPtr(),
		WM.label(LN.next.label)
	)))
	LN3 = LM.new(ListNode(Subneg4Instruction(
		param2.getPtr(),
		param1.getPtr(),
		temp.getPtr(),
		WM.label(LN5.label)
	)))
	LN7 = LM.new(ListNode(Subneg4Instruction(#Llt_0
		c_0.getPtr(),
		param2.getPtr(),
		temp.getPtr(),
		WM.label(LN3.label)
	)))
	LN6 = LM.new(ListNode(Subneg4Instruction(
		c_0.getPtr(),
		c_m1.getPtr(),
		temp.getPtr(),
		WM.label(LN.next.label)
	)))
	LN4 = LM.new(ListNode(Subneg4Instruction(
		c_0.getPtr(),
		c_m1.getPtr(),
		param0.getPtr(),
		NEXT
	)))
	LN2 = LM.new(ListNode(Subneg4Instruction(
		c_0.getPtr(),
		param2.getPtr(),
		temp.getPtr(),
		WM.label(LN4.label)
	)))
	LN1 = LM.new(ListNode(Subneg4Instruction(
		c_0.getPtr(),
		param1.getPtr(),
		temp.getPtr(),
		WM.label(LN7.label)
	)))

	LN.replace(LM, LN1, LN2, LN3, LN4, LN5, LN6, LN7, LN8)

def trans_icmp_ult(LN, Mem, LM):
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






def stack_push(LN, WM, LM):
	if WM.hasFlag("sr_stack_push"):
		arg1, ret_addr = WM.getFlag("sr_stack_push")
	else:
		lastNode = LN
		while lastNode.next != None:
			lastNode = lastNode.next
		nodes, arg1, arg2, ret_addr, res = sr_mult(WM, LM)
		lastNode.prev.appendLNs(nodes)
		WM.setFlag("sr_stack_push", (arg1, ret_addr, res))

def stack_init(WM):
	if WM.hasFlag("stack_init"):
		return



	#WM.
"""
首先，stack初始化的时候
要先把变量做出来，
但这个变量是特殊的
其实可以用WM去做吧


stack使用

* call
函数被call之后需要将正在执行的函数的需要备份的变量一次push到stack里面
并把相应的返回地址（需要把地址存在内存里）带入到相应函数的位置
然后把带入的数据放入被呼出的函数的相应变量的位置，
执行函数
准备好返回的时候的相应

func
func_arg1
func_arg2
...
func_ret_label
func_ret_data_label

* ret




goto_addr, arg ret_addr
push(var)
backaddress

0, var, arg1, goto_addr
L_backaddress:

-1, pointer, pointer, NEXT
0, pointer, WRITE, NEXT
0, arg1, WRITE: 0, NEXT
0, -1, temp, L_backaddress



"""

def stack_pop(LN, WM, LM):
	pass
def sr_stack_push():
	c_0 = WM.const(0)
	c_1 = WM.const(1)
	c_m1 = WM.const(-1)

	if WM.hasFlag("stack_pointer"):
		pass
	ret_addr = WM.addDataWord(0, "stack_push_ret_addr")
def sr_stack_pop():
	c_0 = WM.const(0)
	c_1 = WM.const(1)
	c_m1 = WM.const(-1)

	ret_addr = WM.addDataWord(0, "stack_pop_ret_addr")
	pass
#subroutine
def goto_mult(LN, WM, LM):
	print LN

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
			LN.ins.params[0].getPtr(),
			NEXT
		))),
	]
	backAddress = WM.addDataWord(WM.label(after_LNs[0].label),"backAddress")
	pre_LNs = [
		LM.new(ListNode(Subneg4Instruction(
			# 
			c_0.getPtr(),
			LN.ins.params[1].getPtr(),
			arg1.getPtr(),
			NEXT
		))),
		LM.new(ListNode(Subneg4Instruction(
			# 
			c_0.getPtr(),
			LN.ins.params[2].getPtr(),
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



from sr_mult import sr_mult



instrTransform = {
	"alloca" : trans_alloca,
	"add" : trans_add,
	"load" : trans_load,
	"store" : trans_store,
	"br" : trans_br,
	"ret" : trans_ret,
	"icmp_slt" : trans_icmp_slt,
	"mul" : goto_mult,
}



funcDict = {
	"alloca" : trans_alloca,
	"add" : trans_add,
	"load" : trans_load,
	"store" : trans_store,
	"br" : trans_br,
	"ret" : trans_ret,
	"icmp_slt" : trans_icmp_slt,
	"mul" : goto_mult,
}












"""

LM = LabelManager()
WM = WordManager()
start = ListNode("start", sys = True)
endNode = ListNode("end", sys = True)
#LN = LM.new(ListNode(SystemInstruction("pseudo",[WM.addDataWord(100,"test_1"),WM.addDataWord(200,"test_2")],WM.addDataWord(200,"test_res"))))
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

"""



"""
命名规则
c_*** -> constant

f_**_***** -> address ***** of function **
v_**_***** -> data ***** of function **
L_*** -> label
sr_***_*** -> subroutine
srd_***_*** -> subroutine data

t_** -> system temporaries

"""


"""
        Z src1 src1 L_slt_1
L_sge_1:        Z src2 src2 Lge_0
L_sge_tge_1:    src2 src1 T0 Llt_0
        DEC Z TJ Lge_0
L_slt_1:        Z src2 src2 L_sge_tge_1
L_slt_tge_1:    DEC Z TJ Llt_0
Llt_0:  INC Z dest
        DEC Z TJ Lfinish
Lge_0:  Z Z dest
        DEC Z TJ Lfinish
        Z Z Z
        MIN src1 T0 L_slt_3
L_sge_3:        MIN src2 T1 L_sge_tlt_3
L_sge_tge_3:    T1 T0 T0 Llt_2
        DEC Z TJ Lge_2
L_slt_3:        MIN src2 T1 L_sge_tge_3
L_slt_tge_3:    DEC Z TJ Llt_2
L_sge_tlt_3:    DEC Z TJ Lge_2
Llt_2:  INC Z dest
        DEC Z TJ Lfinish
Lge_2:  Z Z dest
        DEC Z TJ Lfinish

"""