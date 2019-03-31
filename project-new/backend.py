
from build_pass import BuildPass
from pre_transform_pass import PreTransformPass
from transform_pass import TransformPass
from assemble_pass import AssemblePass
from instruction_node import SystemNode
from word_manager import WordManager
import re

"""
MEMO
clang++ tool.cpp -o reader `llvm-config --cxxflags --libs --ldflags --system-libs`

"""

import xml.etree.ElementTree as ET
class Backend(object):
	"""
		backend entry
	"""
	def __init__(self, filename):
		self.filename = filename
		self.startNode = SystemNode([], "start")
		self.endNode = SystemNode([], "end")
		self.WM = None


	def build_pass(self):
		
		self.WM = WordManager()

		import xml.etree.ElementTree as ET
		tree = ET.parse(self.filename)
		bp = BuildPass(self.WM, self.startNode, self.endNode, tree)
		bp.debug_execute()

	def pre_transform_pass(self):
		tp = PreTransformPass(self.WM, self.startNode, self.endNode)
		tp.debug_execute()

	def transform_pass(self):
		tp = TransformPass(self.WM, self.startNode, self.endNode)
		tp.debug_execute()
	def assemble_pass(self):
		tp = AssemblePass(self.WM, self.startNode, self.endNode)
		tp.debug_execute()
#b = Backend("../test/test_code_05/array.xml")
#b = Backend("../test/test_code_quick/mips-quick-test.xml")
#b = Backend("../test/test_code_quick/mips-quick.xml")
#b = Backend("../test/test_code_quick_new/main.xml")
#b = Backend("../test/test_code_quick_new/main2.xml")
#b = Backend("../test/test_code_loop/main.xml")
b = Backend("../test/lev/lev-modified.xml")
b.build_pass()

b.pre_transform_pass()
b.transform_pass()
b.assemble_pass()