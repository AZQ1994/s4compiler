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
			word = WM.label(WM.getUpperNamespace()+p_var[0].replace(".","_"))
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
		word = WM.label(WM.getUpperNamespace()+p_var[0].replace(".","_"))
		params.append(word)
	# ins_params[2]
	p_var = re.findall(r'var\(([\s\S]*?)\)', ins_params[2])
	if len(p_var) == 1:
		word = WM.label(WM.getUpperNamespace()+p_var[0].replace(".","_"))
		params.append(word)
	return params
def build_call(ins_params, WM):
	call_params = []
	params = []

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

	for x in ins_params[1:-1]:
		p_var = re.findall(r'var\(([\s\S]*?)\)', x)
		if len(p_var) == 1:
			word = WM.getName(p_var[0].replace(".","_"))
			call_params.append(word)
			#print "test::::::::", word
			#### TODO : check
			continue
		p_int = re.findall(r'int\(([\s\S]*?)\)', x)
		if len(p_int) == 1:
			word = WM.const(p_int[0])
			call_params.append(word)
			#print "int",p_int[0]
			continue
		p_ptr = re.findall(r'ptr\(([\s\S]*?)\)', x)
		if len(p_ptr) == 1:
			word = WM.getName("p_"+p_ptr[0])
			call_params.append(word)
			continue
		call_params.append(x)
	params.append(call_params)
	p_var = re.findall(r'var\(([\s\S]*?)\)', ins_params[-1])
	if len(p_var) == 1:
		word = WM.label(WM.getUpperNamespace(2)+p_var[0].replace(".","_"))
		params.append(word)

	return params

build_methods={
	"br":build_br,
	"call":build_call,
}

def trans_alloca(LN, WM, LM):
	LN.remove()
	return
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

	WM.addNeedSave(param0)
	if param1.getType == "data-const":
		m_p1 = WM.const(-param1.value)
		LN1 = LM.new(ListNode(Subneg4Instruction(
				m_p1.getPtr(),
				param2.getPtr(),
				param0.getPtr(),
				NEXT
			)))
		LN.replace(LM, LN1)
		return
	if param2.getType == "data-const":
		m_p2 = WM.const(-param2.value)
		LN1 = LM.new(ListNode(Subneg4Instruction(
				m_p2.getPtr(),
				param1.getPtr(),
				param0.getPtr(),
				NEXT,
				"\t// add"
			)))
		LN.replace(LM, LN1)
		return
	LN1 = LM.new(ListNode(Subneg4Instruction(
			param1.getPtr(),
			c_0.getPtr(),
			temp.getPtr(),
			NEXT,
			"\t// add"
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

	WM.addNeedSave(param0)

	LN1 = LM.new(ListNode(Subneg4Instruction(
			c_0.getPtr(),
			param1.getPtr(),
			param0.getPtr(),
			NEXT,
			"\t// load"
		)))
	LN.replace(LM, LN1)

def trans_store(LN, WM, LM):
	c_0 = WM.const(0)
	NEXT = WM.getNext()
	param1 = LN.ins.params[1]
	param0 = LN.ins.params[0]

	WM.addNeedSave(param1)

	LN1 = LM.new(ListNode(Subneg4Instruction(
			c_0.getPtr(),
			param0.getPtr(),
			param1.getPtr(),
			NEXT,
			"\t// store"
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
			LN.ins.params[0],
			"\t// br %s"%LN.ins.params[0]
		)))
		LN.replace(LM, LN1)
	elif len(LN.ins.params) == 3:
		# if param0 == 1? goto param2, else goto param1
		# different with assembly code in llvm ir
		param0 = LN.ins.params[0]
		# 0, param0, temp, param1
		# 0, -1, temp, param2
		LN1 = LM.new(ListNode(Subneg4Instruction(
			c_0.getPtr(),
			param0.getPtr(),
			temp.getPtr(),
			LN.ins.params[1],
			"\t// br"
		)))
		LN2 = LM.new(ListNode(Subneg4Instruction(
			c_0.getPtr(),
			c_m1.getPtr(),
			temp.getPtr(),
			LN.ins.params[2] 
		)))
		LN.replace(LM, LN1, LN2)
def trans_call(LN, WM, LM):
	temp = WM.getTemp(0)
	c_0 = WM.const(0)
	c_m1 = WM.const(-1)

	returnData = WM.result#WM.getName("d_"+str(LN.ins.params[2])+"_returnData")

	NEXT = WM.getNext()

	LN2 = LM.new(ListNode(Subneg4Instruction(
		# copy return data
		c_0.getPtr(),
		returnData.getPtr(),
		LN.ins.params[0].getPtr(),
		NEXT
	)))

	stack_node = []
	for k, v in WM.needSave.items():
		stack_node.append(LM.new(ListNode(Instruction("STACK_PUSH",[k]))))
	after_stack_node = []
	for k, v in WM.needSave.items()[::-1]:
	#	print k,v
		after_stack_node.append(LM.new(ListNode(Instruction("STACK_POP",[k]))))
	#LN.appendLNs(stack_node)
	#for x in stack_node:
	#	stack_push(x, WM, LM)
	print "!!!!!!!!!!",LN,after_stack_node
	backAddress = WM.addDataWord(WM.label((after_stack_node+[LN2])[0].getALabel()),"nextLabel")

	LN1 = LM.new(ListNode(Subneg4Instruction(
		# 0, -1, temp, goto function
		c_0.getPtr(),
		c_m1.getPtr(),
		temp.getPtr(),
		LN.ins.params[2],
		"\t// call %s"%LN.ins.params[2]
	)))

	LNs = []
	print WM.functionInfo
	if len(WM.functionInfo[str(LN.ins.params[2])]) != len(LN.ins.params[1]):
		print WM.functionInfo[str(LN.ins.params[2])], LN.ins.params[1]
		print "!!!!!!! CALL ERROR !!!!!!!!!!!!!"
		return
	
	for arg, param in zip(WM.functionInfo[str(LN.ins.params[2])], LN.ins.params[1]):
		LNs.append(
			LM.new(ListNode(Subneg4Instruction(
				# 0, param, arg, next
				c_0.getPtr(),
				param.getPtr(),
				arg.getPtr(),
				NEXT,
				">>> arg: $(res)\\n"
			)))
		)#copy params to arg
	addrPushLN = LM.new(ListNode(Instruction("STACK_PUSH",[backAddress])))
	WM.addNeedSave(LN.ins.params[0])
	LN.replaceLNs(LM, stack_node + LNs + [addrPushLN, LN1] + after_stack_node + [LN2])
	

def trans_ret(LN, WM, LM):
	"""
20171105 note:
can't use for to convert listnode of stack to subneg4 instructions
need to loop the conversion or create another way
	"""
	temp = WM.getTemp(0)
	c_0 = WM.const(0)
	c_m1 = WM.const(-1)
	HALT = WM.getHalt()
	NEXT = WM.getNext()
	param = LN.ins.params[0]

	#backAddress = WM.currentFunction["backAddress"]
	returnData = WM.result#WM.currentFunction["returnData"]
	# stack pop, pop, pop
	# set back address = stack pop
	# goto backAddress at last

	address = WM.addDataPtrWord(0,"returnLabel")
	addrPopLN = LM.new(ListNode(Instruction("STACK_POP",[address])))

	LN2 = LM.new(ListNode(Subneg4Instruction(
		c_0.getPtr(),
		param.getPtr(),
		returnData.getPtr(),
		NEXT,
		">>> return data: $(2), $(res)\\n"
	)))
	LN3 = LM.new(ListNode(Subneg4Instruction(
		c_0.getPtr(),
		c_m1.getPtr(),
		temp.getPtr(),
		address,
		"\t// ret"
	)))
	LN.replaceLNs(LM, [addrPopLN] + [LN2, LN3])
	#use stack
	return

def trans_icmp_sle(LN, WM, LM):
	"""
	if param1 <= param2 set 1 else set -1

	param1 < 0? goto L500
	--- (param1 >= 0)
	--- param2 > -1? goto L800 
	L300 *param1 > param2 set -1 goto Lfin
	L500(param1<0)
	--- param2 > -1? goto *param1 <= param2 set 1
	--- --- (param2 < 0)
	L800---  param2 - param1 < 0? goto L300
	--- --- --- param1 <= param2 set 1


	L0: 0 param1 temp L3
	L1: param2 -1 temp L4
	L2: 0 -1 res Lfin
	L3: param2 -1 temp L2
	L4: param1 param2 temp L2
	L5: 0 1 res NEXT
	"""
	param1 = LN.ins.params[1]
	param2 = LN.ins.params[2]
	param0 = LN.ins.params[0]

	c_0 = WM.const(0)
	c_1 = WM.const(1)
	c_m1 = WM.const(-1)
	
	temp = WM.getTemp(0)
	NEXT = WM.getNext()

	LN5 = LM.new(ListNode(Subneg4Instruction(
		c_0.getPtr(),
		c_1.getPtr(),
		param0.getPtr(),
		NEXT
	)))
	LN2 = LM.new(ListNode(Subneg4Instruction(
		c_0.getPtr(),
		c_m1.getPtr(),
		param0.getPtr(),
		WM.label(LN.getNextInst().getALabel())
	)))
	LN4 = LM.new(ListNode(Subneg4Instruction(
		param1.getPtr(),
		param2.getPtr(),
		temp.getPtr(),
		WM.label(LN2.getALabel())
	)))
	LN3 = LM.new(ListNode(Subneg4Instruction(
		param2.getPtr(),
		c_1.getPtr(),
		temp.getPtr(),
		WM.label(LN2.getALabel())
	)))
	LN1 = LM.new(ListNode(Subneg4Instruction(
		param2.getPtr(),
		c_1.getPtr(),
		temp.getPtr(),
		WM.label(LN4.getALabel())
	)))
	LN0 = LM.new(ListNode(Subneg4Instruction(
		c_0.getPtr(),
		param1.getPtr(),
		temp.getPtr(),
		WM.label(LN3.getALabel()),
		"\t// sle"
	)))
	LN.replace(LM, LN0, LN1, LN2, LN3, LN4, LN5)


def trans_icmp_slt(LN, WM, LM):
	#if(LN.next.ins.instrStr=="br" and len(LN.next.ins.params) == 3):
	#	pass#LN1 =
		#LM.new(ListNode)
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
		NEXT
	)))
	LN3 = LM.new(ListNode(Subneg4Instruction(
		param2.getPtr(),
		param1.getPtr(),
		temp.getPtr(),
		WM.label(LN5.getALabel())
	)))
	LN7 = LM.new(ListNode(Subneg4Instruction(#Llt_0
		c_0.getPtr(),
		param2.getPtr(),
		temp.getPtr(),
		WM.label(LN3.getALabel())
	)))
	LN6 = LM.new(ListNode(Subneg4Instruction(
		c_0.getPtr(),
		c_m1.getPtr(),
		temp.getPtr(),
		WM.label(LN.getNextInst().getALabel())
	)))
	LN4 = LM.new(ListNode(Subneg4Instruction(
		c_0.getPtr(),
		c_m1.getPtr(),
		param0.getPtr(),
		WM.label(LN.getNextInst().getALabel())
	)))
	LN2 = LM.new(ListNode(Subneg4Instruction(
		c_0.getPtr(),
		param2.getPtr(),
		temp.getPtr(),
		WM.label(LN4.getALabel())
	)))
	LN1 = LM.new(ListNode(Subneg4Instruction(
		c_0.getPtr(),
		param1.getPtr(),
		temp.getPtr(),
		WM.label(LN7.getALabel()),
		"\t// slt"
	)))

	LN.replace(LM, LN1, LN2, LN3, LN4, LN5, LN6, LN7, LN8)

def trans_icmp_ult(LN, WM, LM):
	
	param1 = LN.ins.params[1]
	param2 = LN.ins.params[2]
	param0 = LN.ins.params[0]

	c_0 = WM.const(0)
	c_1 = WM.const(1)
	c_m1 = WM.const(-1)
	
	temp = WM.getTemp(0)
	NEXT = WM.getNext()

	if(LN.next.ins.instrStr=="br" and len(LN.next.ins.params) == 3):
		pass#LN1 =
		#LM.new(ListNode)
	

	"""


	param1 < 0? goto L500
	--- (param1 >= 0)
	--- param2 < 0? -----> goto param2 >= param1
	--- --- (param2 >= 0)
	--- --- param1 - param2 < 0? -------> goto param1 < param2
	--- --- ---------> goto param1 >= param2

	L500 (param1 < 0)
	--- param2 >= 0?(-1 - param2 < 0?) -----> goto param1 >= param2
	--- (param2 < 0) param1 - param2 < 0? goto param1 < param2
	--- --- goto param1 >= param2

	L1: 0, param1, temp, L5
	L2: 0, param2, temp, L7
	L3: param2, param1, temp, L8
	L4: 0, -1, res, Lfin
	L5: param2, -1, temp, L7
	L6: param2, param1, temp, L8
	L7: 0, -1, res, Lfin
	L8: 0, 1, res, NEXT

L=-1 param1 >= param2
L=1 param1 < param2

	"""
	LN8 = LM.new(ListNode(Subneg4Instruction(
		c_0.getPtr(),
		c_1.getPtr(),
		param0.getPtr(),
		NEXT
	)))
	LN7 = LM.new(ListNode(Subneg4Instruction(
		c_0.getPtr(),
		c_m1.getPtr(),
		param0.getPtr(),
		WM.label(LN.getNextInst().getALabel())
	)))
	LN6 = LM.new(ListNode(Subneg4Instruction(
		param2.getPtr(),
		param1.getPtr(),
		temp.getPtr(),
		WM.label(LN8.getALabel())
	)))
	LN5 = LM.new(ListNode(Subneg4Instruction(
		param2.getPtr(),
		c_m1.getPtr(),
		temp.getPtr(),
		WM.label(LN8.getALabel())
	)))
	LN4 = LM.new(ListNode(Subneg4Instruction(
		c_0.getPtr(),
		c_m1.getPtr(),
		param0.getPtr(),
		WM.label(LN.getNextInst().getALabel())
	)))
	LN3 = LM.new(ListNode(Subneg4Instruction(
		param2.getPtr(),
		param1.getPtr(),
		temp.getPtr(),
		WM.label(LN8.getALabel())
	)))
	LN2 = LM.new(ListNode(Subneg4Instruction(
		c_0.getPtr(),
		param2.getPtr(),
		temp.getPtr(),
		WM.label(LN7.getALabel())
	)))
	LN1 = LM.new(ListNode(Subneg4Instruction(
		c_0.getPtr(),
		param1.getPtr(),
		temp.getPtr(),
		WM.label(LN5.getALabel()),
		"\t// ult"
	)))


	LN.replace(LM, LN1, LN2, LN3, LN4, LN5, LN6, LN7, LN8)




def stack_init(WM):
	if WM.hasFlag("stack_init"):
		return
	WM.stack={
		"size": 100,
		"start_label": "stack_start"
	}
	base = WM.addDataWord(WM.label("stack_start"),"stack_base")
	pointer = WM.addDataWord(WM.label("stack_start"),"stack_pointer")
	WM.setFlag("stack_init",(base, pointer))

def raw_stack_push(LN, WM, LM):
	c_0 = WM.const(0)
	c_m1 = WM.const(-1)
	NEXT = WM.getNext()

	if not WM.hasFlag("stack_init"):
		stack_init(WM)
	base, pointer = WM.getFlag("stack_init")
	"""
	# LN: param0: 

	"""

	WRITE = WM.addDataPtrWord(0, "push_write")
	param = LN.ins.params[0]
	nodes = [
		LM.new(ListNode(Subneg4Instruction(
			# 0, pointer, write, next
			c_0.getPtr(),
			pointer.getPtr(),
			WRITE.getPtr(),
			NEXT
		))),
		LM.new(ListNode(Subneg4Instruction(
			# 0, arg, write: 0, next
			c_0.getPtr(),
			param.getPtr(),
			WRITE,
			NEXT,
			">>> stack push: arg:${2} write:${3} result:${}\\n"
		))),
		LM.new(ListNode(Subneg4Instruction(
			# -1, pointer, pointer, next
			c_m1.getPtr(),
			pointer.getPtr(),
			pointer.getPtr(),
			NEXT
		)))
	]
	LN.replaceLNs(LM, nodes)
def stack_push(LN, WM, LM):
	c_0 = WM.const(0)
	c_m1 = WM.const(-1)
	NEXT = WM.getNext()
	if WM.hasFlag("sr_stack_push"):
		arg1, ret_addr = WM.getFlag("sr_stack_push")
	else:
		lastNode = LN
		while lastNode.next != None:
			lastNode = lastNode.next
		nodes, arg1, ret_addr = sr_stack_push(WM, LM)

		lastNode.prev.appendLNs(nodes)
		WM.setFlag("sr_stack_push", (arg1, ret_addr))
	backAddress = WM.addDataWord(WM.label(LN.next.getALabel()),"backAddress")	
	temp = WM.getTemp(0)
	pre_LNs = [
		LM.new(ListNode(Subneg4Instruction(
			# 
			c_0.getPtr(),
			LN.ins.params[0].getPtr(),
			arg1.getPtr(),
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
			temp.getPtr(),
			WM.label("sr_stack_push_start")
		))),
	]

	LN.replaceLNs(LM, pre_LNs)
	return
def raw_stack_pop(LN, WM, LM):
	c_0 = WM.const(0)
	c_1 = WM.const(1)
	NEXT = WM.getNext()

	param = LN.ins.params[0]

	if not WM.hasFlag("stack_init"):
		stack_init(WM)
	base, pointer = WM.getFlag("stack_init")

	READ = WM.addDataPtrWord(0, "pop_read")

	nodes = [
		LM.new(ListNode(Subneg4Instruction(
			# 1, pointer, pointer, next
			c_1.getPtr(),
			pointer.getPtr(),
			pointer.getPtr(),
			NEXT
		))),
		LM.new(ListNode(Subneg4Instruction(
			# 0, pointer, read, next
			c_0.getPtr(),
			pointer.getPtr(),
			READ.getPtr(),
			NEXT
		))),
		LM.new(ListNode(Subneg4Instruction(
			# 0, read:0, param, next
			c_0.getPtr(),
			READ,
			param.getPtr(),
			NEXT,
			">>> stack pop: read:${2} arg:${3} result:$()\\n"
		)))
	]
	LN.replaceLNs(LM, nodes)
def stack_pop(LN, WM, LM):
	c_0 = WM.const(0)
	c_m1 = WM.const(-1)
	NEXT = WM.getNext()
	if WM.hasFlag("sr_stack_pop"):
		res, ret_addr = WM.getFlag("sr_stack_pop")
	else:
		lastNode = LN
		while lastNode.next != None:
			lastNode = lastNode.next
		nodes, res, ret_addr = sr_stack_pop(WM, LM)

		lastNode.prev.appendLNs(nodes)
		WM.setFlag("sr_stack_pop", (res, ret_addr))	
	after_LNs = [
		LM.new(ListNode(Subneg4Instruction(
			# 
			c_0.getPtr(),
			res.getPtr(),
			LN.ins.params[0].getPtr(),
			NEXT
		))),
	]
	backAddress = WM.addDataWord(WM.label(after_LNs[0].getALabel()),"backAddress")
	temp = WM.getTemp(0)
	pre_LNs = [
		LM.new(ListNode(Subneg4Instruction(
			# 
			c_0.getPtr(),
			backAddress.getPtr(),
			ret_addr.getPtr(),
			NEXT,

		))),
		LM.new(ListNode(Subneg4Instruction(
			# 
			c_0.getPtr(),
			c_m1.getPtr(),
			temp.getPtr(),
			WM.label("sr_stack_pop_start")
		))),
	]
	#print pre_LNs+after_LNs
	LN.replaceLNs(LM, pre_LNs+after_LNs)






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


def sr_stack_push(WM, LM):
	namespace_bak = WM.getNamespace(string=False)
	WM.setNamespace(["sr","st"])

	c_0 = WM.const(0)
	c_1 = WM.const(1)
	c_m1 = WM.const(-1)
	temp = WM.getTemp(0)
	NEXT = WM.getNext()

	if not WM.hasFlag("stack_init"):
		stack_init(WM)
	base, pointer = WM.getFlag("stack_init")
	"""
	-1, p, p ,next
	0, pointer, WRITE, next
	0, arg, WRITE:0, next
	0, -1, temp, L_backaddress

	"""

	ret_addr = WM.addDataPtrWord(0, "push_ret_addr")
	arg = WM.addDataWord(0, "push_arg")
	WRITE = WM.addDataPtrWord(0, "push_write")

	nodes = [
		LM.new(ListNode(Subneg4Instruction(
			# 0, pointer, write, next
			c_0.getPtr(),
			pointer.getPtr(),
			WRITE.getPtr(),
			NEXT
		)),"sr_stack_push_start"),
		LM.new(ListNode(Subneg4Instruction(
			# 0, arg, write: 0, next
			c_0.getPtr(),
			arg.getPtr(),
			WRITE,
			NEXT,
			">>> stack push: arg:${2} write:${3} result:${}\\n"
		))),
		LM.new(ListNode(Subneg4Instruction(
			# -1, pointer, pointer, next
			c_m1.getPtr(),
			pointer.getPtr(),
			pointer.getPtr(),
			NEXT
		))),
		LM.new(ListNode(Subneg4Instruction(
			# 0, -1, temp, backaddress
			c_0.getPtr(),
			c_m1.getPtr(),
			temp.getPtr(),
			ret_addr
		))),
	]
	WM.setNamespace(namespace_bak)
	return nodes, arg, ret_addr

def sr_stack_pop(WM, LM):
	namespace_bak = WM.getNamespace(string=False)
	WM.setNamespace(["sr","st"])

	c_0 = WM.const(0)
	c_1 = WM.const(1)
	c_m1 = WM.const(-1)
	temp = WM.getTemp(0)
	NEXT = WM.getNext()

	if not WM.hasFlag("stack_init"):
		stack_init(WM)
	base, pointer = WM.getFlag("stack_init")

	ret_addr = WM.addDataPtrWord(0, "pop_ret_addr")
	res = WM.addDataWord(0, "pop_res")
	READ = WM.addDataPtrWord(0, "pop_read")

	nodes = [
		LM.new(ListNode(Subneg4Instruction(
			# 1, pointer, pointer, next
			c_1.getPtr(),
			pointer.getPtr(),
			pointer.getPtr(),
			NEXT
		)),"sr_stack_pop_start"),
		LM.new(ListNode(Subneg4Instruction(
			# 0, pointer, read, next
			c_0.getPtr(),
			pointer.getPtr(),
			READ.getPtr(),
			NEXT
		))),
		LM.new(ListNode(Subneg4Instruction(
			# 0, read:0, res, next
			c_0.getPtr(),
			READ,
			res.getPtr(),
			NEXT,
			">>> stack pop: read:${2} arg:${3} result:$()\\n"
		))),
		LM.new(ListNode(Subneg4Instruction(
			# 0, -1, temp, backaddress
			c_0.getPtr(),
			c_m1.getPtr(),
			temp.getPtr(),
			ret_addr
		))),
	]
	WM.setNamespace(namespace_bak)
	return nodes, res, ret_addr
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
			LN.ins.params[0].getPtr(),
			NEXT
		))),
	]
	backAddress = WM.addDataWord(WM.label(after_LNs[0].getALabel()),"backAddress")
	temp = WM.getTemp(0)
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
			temp.getPtr(),
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
	"icmp_ult" : trans_icmp_ult,
	"icmp_sle" : trans_icmp_sle,
	"mul" : goto_mult,
	"call" : trans_call,
}

sysTransform = {
	"STACK_POP": raw_stack_pop,
	"STACK_PUSH": raw_stack_push
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
	"call" : trans_call,
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

"""
stack_start: 0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0

 stack start push: arg:16 write:0 result:${res}
 stack start push: arg:76 write:0 result:${res}



stack push: arg:16 write:0 result:16
arg: 10
stack push: arg:340 write:0 result:340
stack push: arg:10 write:0 result:10
stack push: arg:8 write:0 result:8
arg: 8
stack push: arg:160 write:0 result:160
stack push: arg:8 write:0 result:8
stack push: arg:6 write:0 result:6
arg: 6
stack push: arg:160 write:0 result:160
stack push: arg:6 write:0 result:6
stack push: arg:4 write:0 result:4
arg: 4
stack push: arg:160 write:0 result:160
stack push: arg:4 write:0 result:4
stack push: arg:2 write:0 result:2
arg: 2
stack push: arg:160 write:0 result:160
stack push: arg:2 write:0 result:2
stack push: arg:0 write:0 result:0
arg: 0
stack push: arg:160 write:0 result:160
stack pop: read:160 arg:0 result:160
return data: 0, 0
stack push: arg:0 write:160 result:0
stack push: arg:0 write:0 result:0
stack push: arg:-1 write:0 result:-1
stack push: arg:0 write:0 result:0
arg: -1
stack push: arg:288 write:0 result:288
stack pop: read:288 arg:160 result:288
return data: -1, -1
stack pop: read:0 arg:288 result:0
return data: -1, -1
stack push: arg:16 write:0 result:16
arg: 10
stack push: arg:340 write:0 result:340
stack push: arg:10 write:0 result:10
stack push: arg:8 write:0 result:8
arg: 8
stack push: arg:160 write:0 result:160
stack push: arg:8 write:0 result:8
stack push: arg:6 write:0 result:6
arg: 6
stack push: arg:160 write:0 result:160
stack push: arg:6 write:0 result:6
stack push: arg:4 write:0 result:4
arg: 4
stack push: arg:160 write:0 result:160
stack push: arg:4 write:0 result:4
stack push: arg:2 write:0 result:2
arg: 2
stack push: arg:160 write:0 result:160
stack push: arg:2 write:0 result:2
stack push: arg:0 write:0 result:0
arg: 0
stack push: arg:160 write:0 result:160
stack pop: read:160 arg:0 result:160
return data: 0, 0
stack push: arg:0 write:160 result:0
stack push: arg:0 write:0 result:0
stack push: arg:-1 write:0 result:-1
stack push: arg:0 write:0 result:0
arg: -1
stack push: arg:288 write:0 result:288
stack pop: read:288 arg:160 result:288
return data: -1, -1
stack pop: read:0 arg:288 result:0
return data: -1, -1

"""