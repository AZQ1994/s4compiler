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
		self.pointers[id(ptr)] = ptr
		return ptr

	def used_in(self, IN, key):
		self.used[IN].append(key)

	def no_longer_used_in(self, IN):
		self.used.pop(IN, None)

	def replace_by(self, word):
		print "replacing:", self, word
		for IN, indexs in self.used.items():
			for index in indexs:
				if IN.params[index] == self:
					IN.set_param(index, word)
				else:
					p = flatten(IN.params)[index]
					while p.value != self:
						if isinstance(p, Word):
							p = p.value
						else:
							raise Exception
							break
					p.value = word
	
	def calculate_interval(self):# on going

		BB_map = defaultdict(dict)
		finished = {}
		check_after = []
		for ins in self.used:
			check = True # is_write
			for i in self.used[ins]:
				if ins.params_write[i] != True:
					check = False
			if check:
				# finished
				self.interval[ins] = True
				continue
			stack = [(ins,[],True)]

			while len(stack) != 0:
				current, to_do_stack, real_fin = stack.pop()
				#print current
				if current in finished and finished[current] == True:
					if current in self.interval:
						for i in to_do_stack:
							self.interval[i] = True
					else:
						check_after.append((current,to_do_stack))
					continue
				if hasattr(current, "BB") and current.BB == None:
					#print "NO BB!", current
					continue
				if current in self.used:
					check = True # is_read
					for i in self.used[current]:
						if current.params_write[i] != True:
							check = False
					if check:
						# check to finished
						for i in to_do_stack:
							self.interval[i] = True
						continue

					

					# not finished, current is in used
					if isinstance(current, instruction_node.IRPhi):
						# so that we should investigate path
						real_fin = False
						for i in self.used[current]:
							if current.params_write[i] == False:
								BB = current.params[i - 1].value.BB
								BB_map[current.BB][BB] = True
					else:
						for BB in current.BB.from_bb:
							BB_map[current.BB][BB] = True

					stack.append((current.prev, to_do_stack+[current], real_fin))
					finished[current] = real_fin
				else:
					# current not using 'self'
					finished[current] = real_fin
					if isinstance(current, instruction_node.BasicBlockStart):
						if current.BB in BB_map:
							for BB in BB_map[current.BB]:
								stack.append((BB.end, to_do_stack+[current], True))
						else:
							for BB in current.BB.from_bb:
								stack.append((BB.end, to_do_stack+[current], True))
					else:
						#self.interval[current] = True
						stack.append((current.prev, to_do_stack+[current], real_fin))
		check = True
		while check:
			check = False
			for key, (ins, to_do_stack) in enumerate(check_after):
				if ins in self.interval:
					check = True
					check_after.pop(key)
					for i in to_do_stack:
						self.interval[i] = True

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
			self.value.pop(IN, None) # no recursive call

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
	pass
	def __str__(self):
		return "{0}: {1}".format(self.name, self.value)

class Address(Word):
	def __init__(self, name, value, manager):
		super(Address, self).__init__("address", name, value, manager)

	def to_asm(self):
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