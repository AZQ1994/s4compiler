#!/usr/bin/python
# -*- coding: utf-8 -*-

from passes import Pass
from instruction_node import *
from word_manager import WordManager
from word import Word, DataWord, DataWords, PointerWord, Address
from utils import check_int

import re
from collections import defaultdict

class BuildPass(Pass):

	def __init__(self, WM, startNode, endNode, xmltree):
		super(BuildPass, self).__init__(WM, startNode, endNode)
		self.pass_name = "Build Pass"
		self.description = "Build Pass: the pass to convert xml to linked list"

		self.xmltree = xmltree

	def do(self):
		self.debug_log("Initializing ListNode structure...")
		### initialize ListNode structure for instructions
		self.startNode.set_next(self.endNode)
		append_node = self.startNode

		#self.WM = WordManager()
		WM = self.WM

		function_dict = {}

		### call main first
		self.debug_log("Adding call to main function...")

		namespace = []

		result_of_main = WM.new_dataword("_ret", 0)
		result_ptr = result_of_main.new_ptr()
		address_of_main = WM.new_address("", None) ### NEED TO FILL IN LATER
		append_node = append_node.append(
				IRCall([result_ptr,address_of_main,[]], "main-call", result_ptr, [], None),### TODO 20181128 IRCall :params, instrStr, des, call_params, BB, comment = ""):
				P_GOTO(WM.get_HALT())
			)

		namespace.append("M_")
		WM.add_namespace(namespace)

		self.debug_log("Starting parsing xml tree...")
		module = self.xmltree.getroot()

		### re pattern for phi operation
		### -- phi: [from_BB: variable] 
		phi_op_pattern = re.compile("\[(.*?):(.*?)\]")

		### functions in modules
		for item1 in module:
			if item1.tag == "Function":
				### functions
				function_name = item1.get('name')
				f = IRFunction(function_name)
				function_dict[function_name] = f
				append_node = append_node.append_block(f.start)

		### recursively read the modules
		for item1 in module:
			### functions and global variables
			if item1.tag == "Globals":
				### global variables:
				for V in item1:
					#print V
					if V.get("type").find("x") != -1:
						### an array
						arr = V.get("init")[1:-1]
						values = [s.split(" ")[1] for s in arr.split(", ")]
						WM.new_datawords(V.get("name"), values)

					elif V.get("type") == "i32":
						WM.new_dataword(V.get("name"), V.get("init"))

					else:
						### 32bit integer only for now
						print "ERROR!!! not done yet!"
				continue

			if item1.tag == "Function":
				### functions
				function_name = item1.get('name')
				append_node = function_dict[function_name].start

				self.debug_log("Function: "+function_name)

				### save the function name as a label to append to the first instruction of this function
				#label_next.append(WM.getNamespace()+function_name)
				
				### namespace push function name
				namespace.append(function_name)
				WM.add_namespace(namespace)

				### prepare graph
				# self.bb_graph[function_name] = Graph()

				### arguments of the function
				args = []
				
				for arg in item1[0]:
					args.append(WM.new_dataword(arg.get('name'), 0))

				# argument information # TODO 20181128
				append_node = append_node.append(
					SystemNode([], "function {0}({1}):".format(function_name, ",".join([str(arg.name) for arg in args]))))
				
				""" 20181125 TODO

				### get all phi node
				for BB in item1[1]:
					BB_name = BB.get("name")
					phi = {} #{from:{var: from_var}}
					for I in BB:
						ins_name = I.get("opName")
						if ins_name != "phi":
							break
						ins_des = I.get("des").replace(".","_")

						op = I.get("values").replace(".","_")
						
						for op_string in op.split(","):
							res = phi_op_pattern.match(op_string)
							if phi.has_key(res.group(2)):
								phi[res.group(2)][ins_des] = res.group(1)
							else:
								phi[res.group(2)] = {ins_des : res.group(1)}
					
					WM.phi[BB_name] = phi
					### add bb graph node
					# self.bb_graph[function_name].newNode(BB_name)
				"""
				### 20181125 maybe sequence should be set to have less brs

				### set root
				firstBB_name = next(iter(item1[1])).get("name")
				# self.bb_graph[function_name].setRoot(self.bb_graph[function_name].getNode(firstBB_name))
				BB_dict = {}
				for BB in item1[1]:
					BB_name = BB.get("name")
					bb = IRBasicBlock(BB_name, function_name)
					BB_dict[BB_name] = bb
					#append_node = append_node.append_block(bb.start)
					self.debug_log("BB: {0}".format(BB_name))
				
				

				phi_vars = defaultdict(list)
				for BB in item1[1]:
					BB_name = BB.get("name")
					for I in BB:
						ins_name = I.get("opName")
						if ins_name != "phi":
							break
						ins_des = I.get("des")

						op = I.get("values")
						for op_string in op.split(","):
							res = phi_op_pattern.match(op_string)
							phi_vars[WM.get_or_add_word(ins_des)].append(WM.get_or_add_word(res.group(1)))

				#print phi_vars

				for BB in item1[1]:
					
					########## NOTES 20181125
					## each BB can be put between a bb_start node and bb_end node
					## with this two nodes, we can arrange the sequence much easier
					## "entry" BB should be the first

					BB_name = BB.get("name")
					append_node = BB_dict[BB_name].start

					# self.bb_graph[function_name].getNode(BB_name).setListNode(append_node)
					
					"""#print phi
					for l,f_bb in WM.phi[BB_name].items():
						#l = "phi_"+BB_name+"-"+l
						for var, from_var in f_bb.items():
							if check_int(var):
								w_var = WM.const(var)
							else:
								w_var = WM.getName(var)
							if check_int(from_var):
								w_from_var = WM.const(from_var)
							else:
								w_from_var = WM.getName(from_var)
							append_node = append_node.append(LM.new(ListNode(Instruction("load", [w_var, w_from_var]),l)))
							l = None
						append_node = append_node.append(LM.new(ListNode(Instruction("br", [WM.label(WM.getUpperNamespace()+BB.get("name").replace(".","_"))]),l)))
					"""
					for I in BB: # instruction
						############### des + params TODO
						ins_name = I.get("opName")
						#if ins_name == "phi":
						#	continue
						ins_params = [] if I.get("operands") == None else re.sub(r'\[.*?(\[.*?\])?.*?\]','', I.get("operands")).replace(" ","").split(",")##################TODO?????
						ins_des = None if I.get("des") == None else I.get("des")
						self.debug_log("- op: {0} {1}".format(ins_name, str(ins_params)))
						if ins_name in build_methods:
							ins = build_methods[ins_name](BB_name, ins_name, ins_des, ins_params, I, WM, BB_dict, function_dict)

						else:
							params = []
							for x in [ins_des]+ins_params if ins_des != None else ins_params:
								if check_int(x):
									params.append(WM.get_const_ptr(x))
									continue
								else:
									params.append(WM.get_or_add_word(x).new_ptr())
									continue
								params.append(x)
							if ins_des != None:
								ins = IRInstructionNode(params, ins_name, BB_dict[BB_name]).set_write_param(0)
							elif ins_name == "store" and False:### TODO
								ins = IRInstructionNode(params, ins_name, BB_dict[BB_name]).set_write_param(1)
							else:
								ins = IRInstructionNode(params, ins_name, BB_dict[BB_name])
						append_node = append_node.append(ins)
				
				# arguments of the function
				for arg in args:
					BB_dict[firstBB_name].start.append(SystemNode([arg.new_ptr()],"arg").set_write_param(0))	#
				WM.function_args[function_name] = args
				WM.function_return_word(function_name)
				### check the BB is executed only once or is looped executed
				to_be_checked = [BB_dict["entry"]]
				checked = {}
				while len(to_be_checked) != 0:
					BB = to_be_checked.pop()
					if BB in checked:
						BB.is_once = True
						continue
					for x in BB.to_bb:
						to_be_checked.append(x)
					checked[BB] = True
					BB.is_once = False
				# test
				#for i in BB_dict:
				#	print BB_dict[i].name, BB_dict[i].is_once

				#for des in phi_vars:
				#	des.calculate_interval()
				#	print des, des.interval
				
				

				#"""
				### combine variables
				# 1. source
				# - if source is a bb only to be executed once
				# it is ok to combine
				# - get the footprint of the des
				for des, source_list in phi_vars.items():
					footprint = {} # true: all posibilities are checked; false: only part of posibilities are checked
					need_check = []
					check = {}
					not_phi_only = {}
					write_ins = None
					print des
					for ins, indexs in des.used.items():
						if type(ins) != IRPhi:
							not_phi_only[ins.BB] = True
						if type(ins) == IRPhi and ins.params[0] == des:
							write_ins = ins
					for ins, indexs in des.used.items():
						# a "des" is modified only in IRPhi node
						# if the ins is not this node, we start our path searching
						# else it matches the start
						if type(ins) == IRPhi and ins.params[0] == des:
							continue
						need_check.append(ins)
						
						# start searching for the path that might be executed
						while len(need_check) != 0:
							# pop
							check_ins = need_check.pop()
							if check_ins in footprint:
								# which means it is finished
								continue
							# if it is not checked yet
							# we see if it matches the start
							if type(check_ins) == IRPhi and check_ins.params[0] == des:
								# finished here
								continue

							if type(check_ins) == IRPhi and check_ins in des.used and check_ins.BB not in not_phi_only:
								# "des" in and in only phi node and is reading mode in this basic block
								# so we don't need to check all "from" nodes
								# (special)
								# search all IRPhi in this block
								c_ins = check_ins
								while type(c_ins) == IRPhi:
									for i in des.used[c_ins]:
										need_check.append(c_ins.params[i-1].value.BB.end)
									if check_ins != ins: #
										for x in source_list:
											if c_ins in s.used:
												check[s] = False
										footprint[c_ins] = True
									c_ins = c_ins.prev
								continue

							
							if check_ins == ins:
								need_check.append(check_ins.prev)
								continue
							footprint[check_ins] = True
							# three edge case: 
							# when 2 phi nodes:
							# phi source, [y, L1]
							# phi x, [des, L1] ==> OK
							# node
							# abc z, des
							# or 
							# phi source, [y, L1]
							# phi x, [des, L1] ==> OK
							# abc z, des (not phi only) ==> OK
							# or
							# phi des, [y, L1]
							# phi x, [source. L1]  ==> OK
							# or
							# phi source, [des, L1] ==> OK? 


							# need_check append new nodes
							if type(check_ins) == BasicBlockStart:
								for bb in check_ins.BB.from_bb:
									need_check.append(bb.end)
									#print "! push", bb
								continue
							# normal check
							for s in source_list:
								if check_ins in s.used:
									if type(check_ins) != IRPhi or check_ins.BB != write_ins.BB:
										check[s] = False

							if check_ins.prev != None:
								need_check.append(check_ins.prev)
					
					#for s in source_list:
					#	if s not in check:
					#		print des, s
					#		des.replace_by(s)
					#		break
					#	else:
					#		print des, s, False


				


				### TEST
				temp = [[],[],[],[],[],[]]
				for key, item in BB_dict.items():
					temp[len(item.to_bb)].append(item)
				for k, x in enumerate(temp):
					print k
					for y in x:
						print y
				finished = {}
				
				tree = defaultdict(list)
				import heapq
				q = []
				#heapq.heappush(q, item), heapq.heappop(q, item)
				entry = BB_dict["entry"]
				for item in entry.to_bb:
					heapq.heappush(q, (1.0/len(entry.to_bb) ,entry, item))

				while len(q) != 0:
					item = heapq.heappop(q)
					finished[id(item[2])] = True
					tree[item[1]].append(item[2])
					for item2 in item[2].to_bb:
						if id(item2) not in finished:
							heapq.heappush(q, (1.0/len(item[2].to_bb) ,item[2], item2))
				
				stack = [entry]
				current_ins = function_dict[function_name].end.prev
				while len(stack) != 0:
					current = stack.pop()
					current_ins.append_block(current.start)
					while True:
						items = tree[current]
						if len(items) != 0:
							for item in items[1:]:
								stack.append(item)

							current_ins = current.end.append_block(items[0].start)
							current = items[0]
						else:
							break;
				

				namespace.pop()
				# end of function
		address_of_main.value = function_dict["main"].start
		#self.print_asm()
		

		# test
		stack = []

### build methods
#   methods for each ir instruction to build a instruction node
def build_getelementptr(bb_name, ins_name, des, ins_params, I, WM, BB_dict, function_dict):
	# [*1] https://llvm.org/docs/LangRef.html#getelementptr-instruction
	# <result> = getelementptr <ty>, <ty>* <ptrval>{, [inrange] <ty> <idx>}*
	# <result> = getelementptr inbounds <ty>, <ty>* <ptrval>{, [inrange] <ty> <idx>}*
	# <result> = getelementptr <ty>, <ptr vector> <ptrval>, [inrange] <vector index type> <idx>
	# [*2] https://llvm.org/docs/GetElementPtr.html

	# for now, we only focus on 1-d array of integers
	# on this case, there are 4 parameters
	# 0: destination
	# 1: pointer to the array
	# 2: index1 (0 at this time - https://llvm.org/docs/GetElementPtr.html#why-is-the-extra-0-index-required)
	# 3: index2
	if len(ins_params) != 3:
		print "!!!!!!!!!!!!!!!!TODO!!!!!!!!"
		raise Exception
	
	params = []
	params.append(WM.new_datapointerword(des, -1).new_ptr())
	params.append(WM.get_word(ins_params[0]).new_ptr())
		
	if check_int(ins_params[1]):
		params.append(WM.get_const_ptr(ins_params[1]))
	else:
		params.append(WM.get_or_add_word(ins_params[1]).new_ptr())

	if check_int(ins_params[2]):
		params.append(WM.get_const_ptr(ins_params[2]))
	else:
		params.append(WM.get_or_add_word(ins_params[2]).new_ptr())

	node = IRInstructionNode(params, ins_name, BB_dict[bb_name])
	node.set_write_param(0)
	return node

# Every basic block in a program ends with a "Terminator" instruction, which indicates which block should be executed after the current block is finished. These terminator instructions typically yield a 'void' value: they produce control flow, not values (the one exception being the 'invoke' instruction).
# The terminator instructions are: 'ret', 'br', 'switch', 'indirectbr', 'invoke', 'resume', 'catchswitch', 'catchret', 'cleanupret', and 'unreachable'.

def build_br(bb_name, ins_name, des, ins_params, I, WM, BB_dict, function_dict):
	# branch
	# br i1 <cond>, label <iftrue>, label <iffalse>
	# br label <dest>          ; Unconditional branch

	# need to consider phi nodes
	#
	print ins_params
	params = []
	if len(ins_params)==1:
		#print ins_params[0], BB_name, WM.phi#!!!!!!!!
		#if WM.phi.has_key(ins_params[0]):
		#	if WM.phi[ins_params[0]].has_key(BB_name):
		#		word = WM.label( "phi_"+ins_params[0]+"-"+BB_name )
		#		#print word
		#	else:
		#		word = WM.label(WM.getUpperNamespace()+ins_params[0])
		#		#print "WARNING", BB_name, ins_params[0]
		#else:
		#	word = WM.label(WM.getUpperNamespace()+ins_params[0])
		#params.append(word)
		#return params
		params.append(WM.new_address(None, BB_dict[ins_params[0]].start))
		BB_dict[bb_name].to_bb.append(params[0].value.BB)
		params[0].value.BB.from_bb.append(BB_dict[bb_name])
		return IRInstructionNode(params, "br", BB_dict[bb_name])

	# ins_params[0]
	if check_int(ins_params[0]):
		params.append(WM.get_const_ptr(ins_params[0]))
	else:
		params.append(WM.get_or_add_word(ins_params[0]).new_ptr())

	# ins_params[1]
	#if WM.phi.has_key(ins_params[1]):
	#	if WM.phi[ins_params[1]].has_key(BB_name):
	#		word = WM.label( "phi_"+ins_params[1]+"-"+BB_name )
	#	else:
	#		#print "WARNING!!!!!!",BB_name,ins_params[1]
	#		word = WM.label(WM.getUpperNamespace()+ins_params[1])
	#else:
	#	word = WM.label(WM.getUpperNamespace()+ins_params[1])
	#params.append(word)
	params.append(WM.new_address(None, BB_dict[ins_params[1]].start))

	# ins_params[2]
	#if WM.phi.has_key(ins_params[2]):
	#	if WM.phi[ins_params[2]].has_key(BB_name):
	#		word = WM.label( "phi_"+ins_params[2]+"-"+BB_name )
	#	else:
	#		#print "WARNING!!!!!!",BB_name,ins_params[2]
	#		word = WM.label(WM.getUpperNamespace()+ins_params[2])
	#else:
	#	word = WM.label(WM.getUpperNamespace()+ins_params[2])
	#params.append(word)
	params.append(WM.new_address(None, BB_dict[ins_params[2]].start))
	BB_dict[bb_name].to_bb.append(params[1].value.BB)
	BB_dict[bb_name].to_bb.append(params[2].value.BB)
	params[1].value.BB.from_bb.append(BB_dict[bb_name])
	params[2].value.BB.from_bb.append(BB_dict[bb_name])
	return IRInstructionNode(params, "br3", BB_dict[bb_name])

def build_call(bb_name, ins_name, des, ins_params, I, WM, BB_dict, function_dict):
	call_params = []
	params = []

	# if there is a assignment for the returned value
	if des != None:
		d = WM.get_or_add_word(des).new_ptr()
		params.append(d)

	function = WM.new_address(None, function_dict[ins_params[0]].start)
	params.append(function)

	for x in ins_params[1:]:
		if check_int(x):
			call_params.append(WM.get_const_ptr(x))
			continue
		else:
			call_params.append(WM.get_word(x).new_ptr())
			continue
	params.append(call_params)

	node = IRCall(params, ins_name, d, call_params, BB_dict[bb_name])

	if des != None:
		node.set_write_param(0)

	return node

def build_ret(bb_name, ins_name, des, ins_params, I, WM, BB_dict, function_dict):
	if ins_params[0] == "void":
		return IRReturn([], ins_name, BB_dict[bb_name])
	elif len(ins_params) == 1:
		if check_int(ins_params[0]):
			param = WM.get_const_ptr(ins_params[0])
		else:
			param = WM.get_word(ins_params[0]).new_ptr()
		return IRReturn([param], ins_name, BB_dict[bb_name])
	else:
		# not gonna happen
		raise Exception

def build_phi(bb_name, ins_name, des, ins_params, I, WM, BB_dict, function_dict):
	op = I.get("values")
	params = [WM.get_or_add_word(des)]
	phi_op_pattern = re.compile("\[(.*?):(.*?)\]")
	for op_string in op.split(","):
		res = phi_op_pattern.match(op_string)
		params.append(WM.new_address(None, BB_dict[res.group(2)].start))
		params.append(WM.get_or_add_word(res.group(1)).new_ptr())
	node = IRPhi(params, ins_name, BB_dict[bb_name])
	node.set_write_param(0)
	return node

#def build_alloca

build_methods={
	"phi": build_phi,
	"br":	build_br,
	"call":	build_call,
	"ret":	build_ret,
	"getelementptr":	build_getelementptr,
}