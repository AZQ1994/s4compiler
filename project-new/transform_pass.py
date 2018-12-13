#!/usr/bin/python
# -*- coding: utf-8 -*-

from passes import Pass
from instruction_node import *
from word_manager import WordManager
from word import Word, DataWord, DataWords, PointerWord, Address
from utils import check_int

import re
from collections import defaultdict

class TransformPass(Pass):

	def __init__(self, WM, startNode, endNode):
		super(TransformPass, self).__init__(WM, startNode, endNode)
		self.pass_name = "Transform Pass"
		self.description = "Transform Pass: the pass to convert ir to pesudo instructions"


	def do(self):
		self.debug_log("")
		current = self.startNode
		WM = self.WM


		while current != None:
			n = None
			c_n = current.next
			if current.instrStr in transform_dict:
				n = transform_dict[current.instrStr](current, WM)
			if n != None:
				current = n
			else:
				current = c_n

		self.print_asm()

def trans_sub(IN, WM):
	p0 = IN.params[0]
	p1 = IN.params[1]
	p2 = IN.params[2]

	node = P_SUB(p2, p1, p0)
	IN.replace_by(node)

def trans_add(IN, WM):
	p0 = IN.params[0]
	p1 = IN.params[1]
	p2 = IN.params[2]

	node = P_ADD(p2, p1, p0)
	IN.replace_by(node)

def trans_alloca(IN, WM):
	IN.remove()
	#IN.params[0].

transform_dict = {
	"add": trans_add,
	"sub": trans_sub,
	#"add": trans_sub,
}