from log import Log
from utils import terminal_info
from compiler.ast import flatten

import traceback

class Pass(object):

	def __init__(self, WM, startNode, endNode):
		self.pass_name = "pass"
		self.description = "description"
		self.WM = WM
		self.startNode = startNode
		self.endNode = endNode
		self.debug_info = []
		pass
	
	# log level:
	#     0: normal
	#     1: notice
	#     2: warning
	#     3: hight-level-warning
	#     4: error
	def debug_logs(self, info):
		for log in info:
			if len(log) == 1:
				self.debug_log(log[0])
			else:
				self.debug_log(log[0], log[1])
	def debug_log(self, message,level=0):
		self.debug_info.append(Log(message,level))

	def debug_log_output(self):
		return "\n".join([str(log) for log in self.debug_info])

	def debug_critical_log_output(self, level = 3):
		ret_str = ""
		for log in self.debug_info:
			if log.level >= level:
				ret_str += str(log) + "\n"
		return ret_str

	def do(self):
		raise NotImplementedError

	def execute(self):
		print terminal_info("=== " + self.pass_name +" start ===")
		print "> " + self.description
		try:
			self.do()
		except Exception as e:
			traceback.print_exc()
			print terminal_info(">>> debug_info >>>")
			print self.debug_critical_log_output()
			print terminal_info(">>> debug_info end >>>")
	def debug_execute(self):
		try:
			self.do()
		except Exception as e:
			traceback.print_exc()
		finally:
			print terminal_info("=== debug_info ===")
			print self.debug_log_output()
			print terminal_info("=== debug_info end ===")

	def printIN(self):
		WM = self.WM
		book = WM.book.copy()

		current = self.startNode

		while current != None:
			for p in flatten(current.params):
				if p in book:
					book.pop(p)
				else:
					print "Warning: word not found in book"
					print p
					print current
			self.debug_log( current, 2 )
			current = current.next

		for item in book.values():
			self.debug_log( item, 2 )

	def print_asm(self):
		WM = self.WM
		book = WM.book.copy()

		current = self.startNode

		while current != None:
			for p in flatten(current.params):
				book.pop(p, None)
			#self.debug_log( current.to_asm(), 2 )
			print current.to_asm()
			current = current.next

		for item in book.values():
			#self.debug_log( item.to_asm(), 2 )
			print item.to_asm()