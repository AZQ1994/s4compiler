from word import Word, DataWord, DataWords, PointerWord, DataPointerWord, PointerDataWord, Address
from utils import NamespaceTree, NameTreeNode


class WordManager(object):
	def __init__(self):
		self.book = {}
		self.namespace = NamespaceTree()
		self.currentNamespace = []
		self.const = {}
		self.temp = {}

	def new_word(self,  _type, name, value, namespace = None):
		if namespace == None:
			namespace = self.currentNamespace
		return self.namespace.add_word(Word(_type, value, name, self), namespace)

	def new_dataword(self, name, value, namespace = None):
		if namespace == None:
			namespace = self.currentNamespace
		return self.namespace.add_word(DataWord(name, value, self), namespace)

	def new_datapointerword(self, name, value, namespace = None):
		# a pointer but in data memory
		if namespace == None:
			namespace = self.currentNamespace
		return self.namespace.add_word(DataPointerWord(name, value, self), namespace)
	
	def new_datawords(self, name, value, namespace = None):
		if namespace == None:
			namespace = self.currentNamespace
		return self.namespace.add_word(DataWords(name, value, self), namespace)

	def new_pointerword(self, name, value, namespace = None):
		if namespace == None:
			namespace = self.currentNamespace
		return self.namespace.add_word(PointerWord(name, value, self), namespace)

	def new_pointerdataword(self, name, value, namespace = None):
		# a data but in prog memory
		if namespace == None:
			namespace = self.currentNamespace
		return self.namespace.add_word(PointerDataWord(name, value, self), namespace)

	def new_address(self, name, value, namespace = None):
		if namespace == None:
			namespace = self.currentNamespace
		return self.namespace.add_word(Address(name, value, self), namespace)

	def reg(self, word):
		# called on creating a word object
		self.book[word] = word

	def add_namespace(self, namespace):
		self.currentNamespace = namespace
		self.namespace.add_namespace(namespace)

	def get_HALT(self, namespace = None): ### TODO
		if namespace == None:
			namespace = self.currentNamespace
		return self.namespace.add_word(Address("", "HALT", self), namespace)

	def get_NEXT(self, namespace = None): ### TODO
		if namespace == None:
			namespace = self.currentNamespace
		return self.namespace.add_word(Address("", "NEXT", self), namespace)

	def get_const_ptr(self, num):
		if num in self.const:
			return self.const[num].new_ptr()
		else:
			word = self.new_dataword("C_"+str(num), num)
			self.const[num] = word
			return word.new_ptr()

	def get_word(self, name, namespace = None):
		if namespace == None:
			namespace = self.currentNamespace
		return self.namespace.search_name(name, namespace) # get pointer

	def get_or_add_word(self, name, namespace = None):
		if namespace == None:
			namespace = self.currentNamespace
		word = self.namespace.search_name(name, namespace) # get pointer
		if word != None:
			return word
		else:
			return self.new_dataword(name, 0, namespace)

	def get_temp(self, i):
		if i in self.temp:
			return self.temp[i]
		else:
			self.temp[i] = new_dataword("temp_"+str(i))
			return self.temp[i]

	def get_temp_ptr(self, i = 0):
		return self.get_temp(i).new_ptr()


"""
- what does a namespace do?
tree
a tree that can find a word easily

what about instructions?

labels for instructions also needs namespace

because we use "address" to do a label job
so the address should be


how about record the first instruction node of namespace

"""