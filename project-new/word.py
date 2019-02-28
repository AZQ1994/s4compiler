from collections import defaultdict
from compiler.ast import flatten
import instruction_node
class Word(object):
	def __init__(self, _type, name, value, manager):
		self.type = _type
		self.value = value
		
		if name != "" and name != None:
			self.name = name
		else:
			self.name = id(self)

		self.manager = manager
		if manager != None:
			self.manager.reg(self)
		self.used = defaultdict(list)
		self.pointers = {}
		self.namespace = None

		self.interval = {}

	def new_ptr(self, name = None):
		ptr = self.manager.new_pointerword(name, self)
		self.pointers[ptr] = ptr
		return ptr

	def used_in(self, IN, key):
		self.used[IN].append(key)

	def no_longer_used_in(self, IN):
		self.used.pop(IN, None)

	def replace_by(self, word):
		#print "replacing:", self, "->", word
		for IN, indexs in self.used.items():
			#print "$ set param ", IN, indexs
			#print "word original", word.used[IN]
			for index in indexs:
				if flatten(IN.params)[index] == self:
					IN.set_param(index, word)
					#word.used_in(IN, index)
					#self.no_longer_used_in(IN)
				else:
					p = flatten(IN.params)[index]
					
					while p.value != self:
						#print "+1"
						if isinstance(p, Word):
							p = p.value
						else:
							raise Exception
							break
					p.value.no_longer_used_in(IN)
					p.value = word
					word.used_in(IN, index)
					print word.used[IN]
			
	def calculate_interval(self):

		BB_map = defaultdict(dict) # from a bb, which bb is possible entrance
		#
		finished = {}
		check_after = []
		self.interval = {}
		# This search begins from back to forward
		# 3 stages:
		#	1. check
		# 	2. mark
		for ins in self.used:
			#print ">.>.>", ins
			has_write = False
			has_read = False
			for i in self.used[ins]:
				if ins.params_write[i] == True:
					has_write = True
				else:
					has_read = True
			if has_write:
				self.interval[ins] = True
			if not has_read:
				continue

			# this instruction has 'read'
			stack = [(ins, [])] #[(next_node, mark_list, ),...]

			while len(stack) != 0:
				current, mark_list = stack.pop()
				#print ".....", current, mark_list
				if current in finished:
					if current in self.interval: # finished, so mark all
						for i in mark_list:
							self.interval[i] = True
					else:
						# finished, but still not marked
						check_after.append((current, mark_list))
						#print "check after:", current, mark_list
					continue
				if hasattr(current, "BB") and current.BB == None:
					# no BB (ex. calling main)
					continue
				
				# word is used in current
				if current in self.used:
					finished[current] = True
					has_write = False
					has_read = False
					for i in self.used[current]:
						if current.params_write[i] == True:
							has_write = True
						else:
							has_read = True

					if has_write:
						for i in mark_list:
							self.interval[i] = True
						mark_list = []
						#print "wrote"
					if not has_read:
						continue
					if isinstance(current, instruction_node.PrePhi):
						if not has_write and current == ins:
							finished.pop(current)
						if has_write or current == ins: # two ways? or one way
							for i in self.used[current]:
								if current.params_write[i] == False:
									#current.params
									x = 0
									BB = None
									for ps in current.params:
										x += len(ps)*2-1
										if i < x:
											BB = ps[0].value.BB
											break
									BB_map[current.BB][BB] = True
						else:
							BB_map.pop(current.BB, None)
					stack.append((current.prev, mark_list+[current]))
					
				else:
					finished[current] = True
					if isinstance(current, instruction_node.BasicBlockStart):
						if current.BB in BB_map:
							for BB in BB_map[current.BB]:
								stack.append((BB.end, mark_list+[current]))
						else:
							for BB in current.BB.from_bb:
								stack.append((BB.end, mark_list+[current]))
					else:
						stack.append((current.prev, mark_list+[current]))
		check = True
		while check:
			check = False
			for key, (ins, to_do_stack) in enumerate(check_after):
				if ins in self.interval:
					check = True
					check_after.pop(key)
					for i in to_do_stack:
						self.interval[i] = True
		for ins in self.interval:
			has_write = False
			has_read = False
			if ins in self.used:
				for i in self.used[ins]:
					if ins.params_write[i] == True:
						has_write = True
					else:
						has_read = True
				if has_read and has_write:
					self.interval[ins] = ")("
				elif has_write:
					self.interval[ins] = "("
				elif ins.next in self.interval: # has read but the next node is also in the interval
					if ins.next in self.used:
						has_write_1 = False
						has_read_1 = False
						for i in self.used[ins.next]:
							if ins.next.params_write[i] == True:
								has_write_1 = True
							else:
								has_read_1 = True
						if not has_read_1 and has_write_1:
							self.interval[ins] = ")"
						else:
							self.interval[ins] = "-"
					else:
						self.interval[ins] = "-"
				else: # last node of a interval
					self.interval[ins] = ")"

			else:
				self.interval[ins] = "-"
	
	def to_asm(self):
		return "WORD"

	def __hash__(self):
		return id(self)

	def __str__(self):
		return "({0}){1}".format(self.type, self.name)

class DataWord(Word):
	def __init__(self, name, value, manager):
		super(DataWord, self).__init__("data-word", name, value, manager)

	def to_asm(self):
		return str(self)

	def __str__(self):
		return "{0}: {1}".format(self.name, self.value)

class DataPointerWord(DataWord):
	# in data memory, but a pointer

	#def __init__(self, name, value, manager):
	#	pass
	def __str__(self):
		if type(self.name) == str:
			if isinstance(self.value, Word):
				return "{0}: (ptr){1}".format(self.name, self.value.name)
			else:
				return "{0}: (ptr)null".format(self.name)
		else:
			if isinstance(self.value, Word):
				return "(ptr){0}".format(self.value.name)
			else:
				return "(ptr)null"
	def to_asm(self):
		if type(self.name) == str:
			if isinstance(self.value, Word):
				return "{0}: 0".format(self.name, self.value.name)
			else:
				return "{0}: 0".format(self.name)
		else:
			if isinstance(self.value, Word):
				return "{0}".format(self.value.name)
			else:
				return "0"

class DataWords(DataPointerWord):
	def __init__(self, name, values, manager):
		self.array = []
		self.length = len(values)
		for k in range(self.length):
			self.array.append(DataWord("{0}[{1}]".format(name, k), values[k], None))
		super(DataWords, self).__init__(name, self.array[0], manager)
	def to_asm(self):
		return "\n".join(["{0}: &{1}".format(self.name, self.array[0].name)]+[item.to_asm() for item in self.array])
	def __str__(self):
		return "\n".join(["{0}: (array length:{1})".format(self.name, self.length)]+[str(item) for item in self.array])

class PointerWord(Word):
	def __init__(self, name, value, manager):
		super(PointerWord, self).__init__("pointer-word", name, value, manager)

	def used_in(self, IN, key):
		self.used[IN].append(key)
		if isinstance(self.value, Word):
			self.value.used[IN].append(key) # no recursive call

	def no_longer_used_in(self, IN):
		self.used.pop(IN, None)
		if isinstance(self.value, Word):
			self.value.used.pop(IN, None) # no recursive call

	def to_asm(self):
		if type(self.name) == str:
			return "{0}: {1}".format(self.name, self.value.name)
		else:
			return "{0}".format(self.value.name)

	def __str__(self):
		if type(self.name) == str:
			return "{0}: (ptr){1}".format(self.name, self.value.name)
		else:
			return "(ptr){0}".format(self.value.name)

class PointerDataWord(PointerWord):
	# in prog memory, but a calculated word
	def used_in(self, IN, key):
		self.used[IN].append(key)

	def no_longer_used_in(self, IN):
		self.used.pop(IN, None)
	def to_asm(self):
		if isinstance(self.value, Word):
			value = self.value.name
		else:
			value = 0
		
		return "{0}: {1}".format(self.name, value)
	def __str__(self):
		return "{0}: {1}".format(self.name, self.value)

class Address(Word):
	def __init__(self, name, value, manager):
		super(Address, self).__init__("address", name, value, manager)

	def to_asm(self):
		if self.value == "HALT":
			return "HALT"
		if self.value == "NEXT":
			return "NEXT"
		if type(self.name) != str:
			if isinstance(self.value, object):
				return "L_{0}".format(id(self.value)) ### TODO 20181127 # how to represent a label
			else:
				return "{0}".format(self.value)
		else:
			if isinstance(self.value, object):
				return "{0}: L_{1}".format(self.name, id(self.value)) ### TODO 20181127 # how to represent a label
			else:
				return "{0}: {1}".format(self.name, self.value)
			
	def __str__(self):
		if type(self.name) != str:
			if isinstance(self.value, object):
				return "(addr){0}".format(self.value) ### TODO 20181127 # how to represent a label
			else:
				return "(addr){0}".format(self.value)
		else:
			return "{0}: {1}".format(self.name, self.value)
class DataAddress(Address):

	def to_asm(self):
		if isinstance(self.value, object):
			return "{0}: &L_{1}".format(self.name, id(self.value)) ### TODO 20181127 # how to represent a label
		else:
			return "{0}: {1}".format(self.name, self.value)