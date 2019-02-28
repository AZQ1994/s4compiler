#!/usr/bin/python
# -*- coding: utf-8 -*-

from passes import Pass
from instruction_node import *
from word_manager import WordManager
from word import Word, DataWord, DataWords, PointerWord, Address
from utils import check_int, AddressBeforeUsingHandler

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

def trans_sub(IN, WM, logs):
	p0 = IN.params[0]
	p1 = IN.params[1]
	p2 = IN.params[2]

	node = P_SUB(p2, p1, p0)
	IN.replace_by(node)

def trans_add(IN, WM, logs):
	p0 = IN.params[0]
	p1 = IN.params[1]
	p2 = IN.params[2]

	node = P_ADD(p2, p1, p0)
	IN.replace_by(node)



def trans_br1(IN, WM, logs):
	p0 = IN.params[0]
	IN.replace_by(P_GOTO(p0))

def trans_load(IN, WM, logs):
	#logs.append(("load"))
	c_0 = WM.get_const_ptr()
def trans_icmp_sub_br3(IN, WM, logs):
	IN.params.append([])
	IN.params.append([])
	return trans_icmp_sub_br3_phi(IN, WM, logs)
def trans_icmp_sub_br3_phi(IN, WM, logs):
	h = AddressBeforeUsingHandler(WM)
	p1 = IN.params[0]
	p2 = IN.params[1]
	L1 = IN.params[2]
	L2 = IN.params[3]
	L1_cp = []
	L2_cp = []
	for l in IN.params[4]:
		L1_cp.append(P_CP(l[0], l[1]))
	for l in IN.params[5]:
		L2_cp.append(P_CP(l[0], l[1]))
	LNs = [
			Subneg4InstructionNode(p2, p1, WM.get_temp_ptr(), h.use("L1") if len(L1_cp) != 0 else L1),
			# L2
		] + L2_cp + [
			P_GOTO(L2),
		] + (([
			# L1
			h.attach(
				SystemNode([],"label"),
				"L1"
			),
		] + L1_cp + [P_GOTO(L1)] )if len(L1_cp) != 0 else [] )
	h.solve()
	IN.replace_by_INs(LNs)

def trans_icmp_br3_phi(IN, WM, logs):
	if IN.instrStr != "icmp_slt_br3_phi":
		raise Exception
	h = AddressBeforeUsingHandler(WM)
	cp = WM.get_const_ptr
	tp = WM.get_temp_ptr
	param1 = IN.params[0].value
	param2 = IN.params[1].value
	L1 = IN.params[2]
	L2 = IN.params[3]
	L1_cp = []
	L2_cp = []
	for l in IN.params[4]:
		L1_cp.append(P_CP(l[0], l[1]))
	for l in IN.params[5]:
		L2_cp.append(P_CP(l[0], l[1]))
	# TODO: check if L1_cp or L2_cp is empty
	if L2.value.BB != IN.get_next_inst().prev.BB:
		LNs = [
			P_NEG(IN.params[0], h.use("L500")),
			P_NEG(
				IN.params[1],
				h.use("L300") if len(L2_cp) != 0 else WM.new_address(None, L2.value)
				),
			Subneg4InstructionNode(
				param2.new_ptr(),
				param1.new_ptr(),
				tp(),
				h.use("L800") if len(L1_cp) != 0 else WM.new_address(None, L1.value)
			),
			h.attach(
				SystemNode([],"label"),
				"L300"
			),
			P_GOTO(
				h.use("L700") if len(L2_cp) != 0 else WM.new_address(None, L2.value)
			),
			h.attach(
				SystemNode([],"label"),
				"L500"
			),
			Subneg4InstructionNode(
				param2.new_ptr(),
				cp(-1),
				tp(),
				h.use("L800") if len(L1_cp) != 0 else WM.new_address(None, L1.value)
			),
			Subneg4InstructionNode(
				param2.new_ptr(),
				param1.new_ptr(),
				tp(),
				h.use("L800") if len(L1_cp) != 0 else WM.new_address(None, L1.value)
			),
			h.attach(
				SystemNode([],"label"),
				"L700"
			)
		] + L2_cp + [
			P_GOTO(L2),
			h.attach(
				SystemNode([],"label"),
				"L800"
			)
		] + L1_cp + [
			P_GOTO(L1)
		]
		h.solve()
		IN.replace_by_INs(LNs)
	else:
		LNs = [
			P_NEG(IN.params[1], h.use("L500")),
			P_NEG(
				IN.params[0],
				h.use("L300") if len(L1_cp) != 0 else WM.new_address(None, L1.value)
			),
			Subneg4InstructionNode(
				param2.new_ptr(),
				param1.new_ptr(),
				tp(),
				h.use("L300") if len(L1_cp) != 0 else WM.new_address(None, L1.value)
			),
			P_GOTO(
				h.use("L800") if len(L2_cp) != 0 else WM.new_address(None, L2.value)
			),
			h.attach(
				SystemNode([], "label"),
				"L300"
			)
		] + L1_cp + [
			P_GOTO(L1),
			h.attach(
				SystemNode([], "label"),
				"L500"
			),
			Subneg4InstructionNode(
				param1.new_ptr(),
				cp(-1),
				tp(),
				h.use("L800") if len(L2_cp) != 0 else WM.new_address(None, L2.value)
			),
			Subneg4InstructionNode(
				param2.new_ptr(),
				param1.new_ptr(),
				tp(),
				h.use("L300") if len(L1_cp) != 0 else WM.new_address(None, L1.value)
			),
			h.attach(
				SystemNode([], "label"),
				"L800"
			)
		] + L2_cp + [
			P_GOTO(L2)
		]
		h.solve()
		IN.replace_by_INs(LNs)
def trans_icmp_br3(IN, WM, logs):
	if IN.instrStr != "icmp_slt_br3":
		raise Exception
	h = AddressBeforeUsingHandler(WM)
	cp = WM.get_const_ptr
	tp = WM.get_temp_ptr
	param1 = IN.params[0].value
	param2 = IN.params[1].value
	L1 = IN.params[2]
	L2 = IN.params[3]
	L1_cp = []
	L2_cp = []
	# TODO: check if L1_cp or L2_cp is empty
	if L2.value.BB != IN.get_next_inst().prev.BB:
		LNs = [
			P_NEG(IN.params[0], h.use("L500")),
			P_NEG(
				IN.params[1],
				h.use("L300") if len(L2_cp) != 0 else WM.new_address(None, L2.value)
				),
			Subneg4InstructionNode(
				param2.new_ptr(),
				param1.new_ptr(),
				tp(),
				h.use("L800") if len(L1_cp) != 0 else WM.new_address(None, L1.value)
			),
			h.attach(
				SystemNode([],"label"),
				"L300"
			),
			P_GOTO(
				h.use("L700") if len(L2_cp) != 0 else WM.new_address(None, L2.value)
			),
			h.attach(
				SystemNode([],"label"),
				"L500"
			),
			Subneg4InstructionNode(
				param2.new_ptr(),
				cp(-1),
				tp(),
				h.use("L800") if len(L1_cp) != 0 else WM.new_address(None, L1.value)
			),
			Subneg4InstructionNode(
				param2.new_ptr(),
				param1.new_ptr(),
				tp(),
				h.use("L800") if len(L1_cp) != 0 else WM.new_address(None, L1.value)
			),
			h.attach(
				SystemNode([],"label"),
				"L700"
			)
		] + L2_cp + [
			P_GOTO(L2),
			h.attach(
				SystemNode([],"label"),
				"L800"
			)
		] + L1_cp + [
			P_GOTO(L1)
		]
		h.solve()
		IN.replace_by_INs(LNs)
	else:
		LNs = [
			P_NEG(IN.params[1], h.use("L500")),
			P_NEG(
				IN.params[0],
				h.use("L300") if len(L1_cp) != 0 else WM.new_address(None, L1.value)
			),
			Subneg4InstructionNode(
				param2.new_ptr(),
				param1.new_ptr(),
				tp(),
				h.use("L300") if len(L1_cp) != 0 else WM.new_address(None, L1.value)
			),
			P_GOTO(
				h.use("L800") if len(L2_cp) != 0 else WM.new_address(None, L2.value)
			),
			h.attach(
				SystemNode([], "label"),
				"L300"
			)
		] + L1_cp + [
			P_GOTO(L1),
			h.attach(
				SystemNode([], "label"),
				"L500"
			),
			Subneg4InstructionNode(
				param1.new_ptr(),
				cp(-1),
				tp(),
				h.use("L800") if len(L2_cp) != 0 else WM.new_address(None, L2.value)
			),
			Subneg4InstructionNode(
				param2.new_ptr(),
				param1.new_ptr(),
				tp(),
				h.use("L300") if len(L1_cp) != 0 else WM.new_address(None, L1.value)
			),
			h.attach(
				SystemNode([], "label"),
				"L800"
			)
		] + L2_cp + [
			P_GOTO(L2)
		]
		h.solve()
		IN.replace_by_INs(LNs)

def trans_gep_load(IN, WM, logs):
	IN.replace_by_INs([
			P_ADD(IN.params[2], IN.params[3], IN.params[1]),
			P_CP(IN.params[0], IN.params[1].value)
		])
def trans_gep_store(IN, WM, logs):
	IN.replace_by_INs([
			P_ADD(IN.params[2], IN.params[3], IN.params[1]),
			P_CP(IN.params[1].value, IN.params[0])
		])
def trans_load(IN, WM, logs):
	if IN.params[1].value in WM.mem2reg_mapped:
		IN.replace_by(P_CP(IN.params[0], IN.params[1]))
	else:
		read = WM.new_pointerdataword(None, 0)
		IN.replace_by_INs([
			P_CP(read.new_ptr(), IN.params[1]),
			P_CP(IN.params[0], read)
			])

def trans_store(IN, WM, logs):
	if IN.params[1].value in WM.mem2reg_mapped:
		IN.replace_by(P_CP(IN.params[1], IN.params[0]))
	else:
		write = WM.new_pointerdataword(None, 0)
		IN.replace_by_INs([
			P_CP(write.new_ptr(), IN.params[1]),
			P_CP(write, IN.params[0])
			])
def trans_getelementptr2(IN, WM, logs):
	IN.replace_by(P_ADD(IN.params[1], IN.params[2], IN.params[0]))

transform_dict = {
	"add": trans_add,
	"sub": trans_sub,
	#"add": trans_sub,
	"br": trans_br1,
	"icmp_slt_br3_phi": trans_icmp_sub_br3_phi, #trans_icmp_br3_phi,
	"icmp_slt_br3": trans_icmp_sub_br3, #trans_icmp_br3,
	"gep_load": trans_gep_load,
	"gep_store": trans_gep_store,
	"load": trans_load,
	"store": trans_store,
	"getelementptr2": trans_getelementptr2,
}