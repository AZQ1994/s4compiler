#!/usr/bin/python
# -*- coding: utf-8 -*-

from passes import Pass
from instruction_node import *
from word_manager import WordManager
from word import Word, DataWord, DataWords, PointerWord, Address
from utils import check_int

import re
from collections import defaultdict

class AssemblePass(Pass):

	def __init__(self, WM, startNode, endNode):
		super(AssemblePass, self).__init__(WM, startNode, endNode)
		self.pass_name = "Assemble Pass"
		self.description = "Assemble Pass: the pass to convert pesudo instructions to subneg4"


	def do(self):
		self.debug_log("")
		
		WM = self.WM
		check = True
		while check:
			current = self.startNode
			check = False
			while current != None:
				logs = []
				n = None
				c_n = current.next
				if isinstance(current, PseudoInstructionNode):
					current.rep()
					check = True
				self.debug_logs(logs)
				current = c_n
		# opposite
		for word in WM.opposite:
			self.startNode.append(P_SUB(word.new_ptr(), WM.get_const_ptr(0), word.opposite.new_ptr())).rep()
		self.print_asm()
