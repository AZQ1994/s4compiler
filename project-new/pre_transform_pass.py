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
			n = None
			c_n = current.next
			if current.instrStr in transform_dict:
				n = transform_dict[current.instrStr](current, WM)
			if n != None:
				current = n
			else:
				current = c_n

		#self.print_asm()

def trans_call(IN, WM):
	# need save
	need_save = {}
	print "!!!!!!!!!!!!!"
	# which variable should be saved
	# - written in front, read in below or following blocks
	
	for var in WM.book:
		if isinstance(var, DataWord):
			if IN in var.interval and IN.next in var.interval:
				print var







	"""
	# failed

	finished = {IN: True}
	stack = [(IN.prev, {IN: True, IN.prev: True})]

	while len(stack) != 0:
		current, path = stack.pop()
		if current in finished:
			continue
		finished[current] = True
		for i in current.write_params:
			p = flatten(current.params)[i]
			if isinstance(p, PointerWord):
				p = p.value
			else:
				print "notice:", p, type(p)
				#continue
			print "checking:", p, current.to_asm()
			for instr in p.used:
				if instr not in path:
					# need save!
					need_save[p] = True
					print instr.to_asm()

		if type(current) == BasicBlockStart:
			for bb in current.BB.from_bb:
				new_path = path.copy()
				new_path[bb.end] = True
				stack.append((bb.end, new_path))
		else:
			path[current.prev] = True
			stack.append((current.prev, path))
	print "ins:",IN.to_asm()
	for x in need_save:
		print "need_save:",x
		for i in x.used:
			print i.to_asm()


	# evacuate variables
	# copy params
	"""

	# search path
	"""
	stack = [IN.prev]
	path = {}
	changed_vars = {}

	while len(stack) != 0:
		current = stack.pop()
		if current in path:
			continue
		path[current] = True
		for i in current.write_params:
			p = flatten(current.params)[i].value
			changed_vars[p] = True

		if type(current) == BasicBlockStart:
			for bb in current.BB.from_bb:
				stack.append(bb.end)
		else:
			stack.append(current.prev)

	for p in changed_vars:
		print "checking:", p, current.to_asm()
		for instr in p.used:
			if instr not in path:
				# need save!
				need_save[p] = True
				print instr.to_asm()
	"""

def trans_ret(IN, WM):
	pass

transform_dict = {
	"call": trans_call,
	#"sub": trans_sub,
	#"add": trans_sub,
}