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

		#self.print_asm()

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
	
	first_node = SystemNode([],"call")
	append_node = first_node
	# push
	for var in need_save:
		append_node = append_node.append(P_PUSH(var.new_ptr()))


	
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
		append_node = append_node.append(P_CP(var_func, var))

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
		append_node = append_node.append(P_POP(var.new_ptr()))

	IN.replace_by_block(first_node)


def trans_ret(IN, WM, logs):
	# copy result
	# pop address go back
	# go back
	func_name = IN.BB.func_name
	result = WM.function_return[func_name].new_ptr()
	first_node = P_CP(result, IN.params[0])
	ret_addr = WM.new_address("", return_node, WM)
	append_node = first_node
	append_node = append_node.append(P_POP(ret_addr))
	append_node = append_node.append(P_GOTO(ret_addr))

	IN.replace_by_block(first_node)


transform_dict = {
	"call": trans_call,
	"main-call": trans_call,
	#"sub": trans_sub,
	#"add": trans_sub,
}