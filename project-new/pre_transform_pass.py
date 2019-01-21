#!/usr/bin/python
# -*- coding: utf-8 -*-

from passes import Pass
from instruction_node import *
from word_manager import WordManager
from word import Word, DataWord, DataWords, PointerWord, Address, DataAddress
from utils import check_int

import re
from collections import defaultdict
from compiler.ast import flatten

class PreTransformPass(Pass):

	def __init__(self, WM, startNode, endNode):
		super(PreTransformPass, self).__init__(WM, startNode, endNode)
		self.pass_name = "Pre Transform Pass"
		self.description = "Pre Transform Pass: preproccessing"


	def do(self):
		self.debug_log("Pre Transform Pass")
		current = self.startNode
		WM = self.WM

		for var in WM.book:
			
			if isinstance(var, DataWord):
				#print "+ VAR: ",var
				var.calculate_interval()

		while current != None:
			logs = []
			n = None
			c_n = current.next
			if current.instrStr in transform_dict:
				n = transform_dict[current.instrStr](current, WM, logs)
			if n != None:
				current = n
			else:
				current = c_n
			self.debug_logs(logs)

		# combination
		
		current = self.startNode
		while current != None:
			logs = []
			n = None
			c_n = current.next
			if current.instrStr in combination_dict:
				c = current
				d = combination_dict[current.instrStr]
				failed = False
				while type(d) == dict:
					c = c.next
					if c.instrStr in d:
						d = d[c.instrStr]
					elif "*" in d:
						d = d["*"]
					else:
						failed = True
						break
				if not failed:
					#print "combine:", current
					n = d(current)# TODO
					#print n
			if n != None:
				current = n
			else:
				current = c_n

		
		current = self.startNode
		to_do_dict = defaultdict(lambda: defaultdict(list)) # {BB: {L1: []}
		while current != None:
			logs = []
			c_n = current.next
			if current.instrStr == "prephi":
				for arr in current.params:
					addr = arr[0]
					new_params = arr[1:]
					"""
					when br1: append copys before br1!
					when br3:
					when icmp_br3:

					"""
					from_bb = addr.value.BB
					now_bb = current.BB
					br_node = from_bb.end.prev
					if br_node.instrStr == "br":
						cp_list = []
						for ps in new_params:
							cp_list.append(P_CP(ps[0],ps[1]))
						br_node.prev.appendINs(cp_list)
						WM.unreg(addr)
						#print cp_list
					elif isinstance(br_node, IRIcmpBr3):
						to_do_dict[br_node.BB][current.BB] = new_params
						WM.unreg(addr)
					else:
						print "!", br_node
				current.remove()
			
			current = c_n
		for from_bb in to_do_dict:
			br_ins = from_bb.end.prev
			params = br_ins.params
			params.append(to_do_dict[from_bb][params[2].value.BB])
			params.append(to_do_dict[from_bb][params[3].value.BB])
			br_ins.replace_by(IcmpBr3Phi(params, br_ins.instrStr+"_phi"))
		#self.print_asm()

"""
   icmp_slt_br(param1, param2, L1, L2)
== icmp_sgt_br(param2, param1, L1, L2)
== icmp_sge_br(param1, param2, L2, L1)
== icmp_sle_br(param2, param1, L2, L1)
"""
def comb_icmp_br3(current):
	c_n = current.next
	if len(current.params[0].value.used) != 2:
		raise Exception
	if current.instrStr == "icmp_slt":
		new = IRIcmpBr3([current.params[1], current.params[2], c_n.params[1], current.next.params[2]], current.instrStr + "_br3", current.BB)
	elif current.instrStr == "icmp_sgt":
		new = IRIcmpBr3([current.params[2], current.params[1], c_n.params[1], current.next.params[2]], "icmp_slt_br3", current.BB)
	current.params[0].manager.unreg(current.params[0])
	c_n.params[0].manager.unreg(c_n.params[0])
	c_n.append(new)
	c_n.remove()
	current.remove()
	return new
def gep_load(current):
	i1 = current
	i2 = current.next
	# gep addr, array, 0, i
	# load des, addr
	#print i1.params[0], i2.params[1]
	if i1.params[0].value != i2.params[1].value:
		return

	# addr = array + i
	# des = mem[addr]
	i2.appendINs([
			#P_ADD(i1.params[1], i1.params[3], i1.params[0]),
			#P_CP(i2.params[0], i1.params[0].value)
			IRInstructionNode([i2.params[0], i1.params[0], i1.params[1], i1.params[3]], "gep_load", i1.BB)
		])
	i1.params[2].manager.unreg(i1.params[2])
	i2.params[1].manager.unreg(i2.params[1])
	i1.remove()
	i2.remove()
def gep_store(current):
	i1 = current
	i2 = current.next
	# gep addr, array, 0, i
	# store data, addr
	print i1.params[0], i2.params[1]
	if i1.params[0].value != i2.params[1].value:
		return
	#params: data, addr, array, i

	# addr = array + i
	# mem[addr] = data
	i2.appendINs([
			#P_ADD(i1.params[1], i1.params[3], i1.params[0]),
			#P_CP(i1.params[0].value, i2.params[0])
			IRInstructionNode([i2.params[0], i1.params[0], i1.params[1], i1.params[3]], "gep_store", i1.BB)
		])
	WM.unreg(i1.params[2])
	i1.remove()
	i2.remove()
def icmp_x_br3(current):
	i1 = current
	i2 = i1.next
	i3 = i2.next

	i1.prev.set_next(i2)
	i2.set_next(i1)
	i1.set_next(i3)
	return i2

combination_dict = {
	"icmp_slt" : {
		"br3" : comb_icmp_br3,
		"*" : {
			"br3": icmp_x_br3,
		}
	},
	"icmp_sgt" : {
		"br3" : comb_icmp_br3,
		"*" : {
			"br3": icmp_x_br3,
		}
	},
	"getelementptr": {
		"load": gep_load,
		"store": gep_store,
	},
}
"""
	
	"icmp_sgt" : {
		"br3" : comb_icmp_br3,
	},
	"icmp_sge" : {
		"br3" : comb_icmp_br3,
	},
	"icmp_sle" : {
		"br3" : comb_icmp_br3,
	},
	"icmp_ult" : {
		"br3" : comb_icmp_br3,
	},
	"icmp_ugt" : {
		"br3" : comb_icmp_br3,
	},
	"icmp_uge" : {
		"br3" : comb_icmp_br3,
	},
	"icmp_ule" : {
		"br3" : comb_icmp_br3,
	},
	"icmp_eq" : {
		"br3" : comb_icmp_br3,
	},
	"icmp_ne" : {
		"br3" : comb_icmp_br3,
	},
"""


def trans_call(IN, WM, logs):
	# call:
	# save variables: push
	# copy args
	# push return address
	# goto function 							# function-> copy result, pop address, go back
	# &return address
	# copy result
	# pop saved variables
	# 


	# need save
	need_save = []

	# which variable should be saved
	# - written in front, read in below or following blocks
	
	for var in WM.book:
		if isinstance(var, DataWord):
			if IN in var.interval and IN.next in var.interval:
				need_save.append(var)
				logs.append(("need_save: "+str(var),4))
	first_node = SystemNode([],"call")
	append_node = first_node
	# push
	for var in need_save:
		append_node = append_node.append(P_PUSH(var))


	
	if IN.des != None:
		function_addr = IN.params[1]
		function_name = function_addr.value.func_name
		function_res = WM.function_return[function_name].new_ptr()
		copy_res_node = P_CP(IN.des, function_res)
	else:
		function_addr = IN.params[0]
		function_name = function_addr.value.func_name
		copy_res_node = None

	for var, var_func in zip(IN.call_params, WM.function_args[function_name]):
		append_node = append_node.append(P_CP(var_func.new_ptr(), var))

	return_node = SystemNode([],"call-ret")
	ret_addr = WM.new_dataaddress("", return_node)
	
	# return addr
	append_node = append_node.append(P_PUSH(ret_addr))
	# goto
	append_node = append_node.append(P_GOTO(function_addr))

	append_node = append_node.append(return_node)
	if copy_res_node != None:
		append_node = append_node.append(copy_res_node)

	for var in need_save[::-1]:
		append_node = append_node.append(P_POP(var))

	IN.replace_by_block(first_node)


def trans_ret(IN, WM, logs):
	# copy result
	# pop address go back
	# go back
	func_name = IN.BB.func_name
	result = WM.function_return[func_name].new_ptr()
	first_node = P_CP(result, IN.params[0])
	ret_addr = WM.new_pointerdataword(None, None)
	append_node = first_node
	append_node = append_node.append(P_POP(ret_addr))
	append_node = append_node.append(P_GOTO(ret_addr))

	IN.replace_by_block(first_node)



transform_dict = {
	"call": trans_call,
	"ret": trans_ret,
	"main-call": trans_call,
	#"sub": trans_sub,
	#"add": trans_sub,
}