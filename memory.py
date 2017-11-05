class MemoryNode:
	## mem_type : temp, const, variable
	def __init__(self, name, mem_type):
		self.name = name
		self.mem_type = mem_type


class Memory2:
	def __init__(self):
		self.memDict = {}
	def hasNode(self, name, mem_type):
		return self.memDict.has_key((name, mem_type))
	def createNode(self, name, mem_type):
		self.memDict[(name, mem_type)] = MemoryNode(name, mem_type)
		return self.memDict[(name, mem_type)]
	def getNode(self, name, mem_type):
		return self.memDict[(name, mem_type)]
	def node(self, name, mem_type):
		if self.memDict.has_key((name,mem_type)):
			return self.memDict[(name, mem_type)]
		else:
			self.createNode(name, mem_type)
	def newNode(self, mem_type):
		pass


class Memory:
	def __init__(self):
		self.memDict = {}
		self.memList = []############TODO
		self.tempDict = {}
		self.tempCount = 0
		self.tempAvailable = []
		self.ptr2reg = {}
		self.reg_count = 0
	def allocate(self, name, size = 1):
		if(name in self.memDict):
			return False
		self.memDict[name] = len(self.memList)
		self.memList.append(name + ": 0")
		for _ in range(1, size):
			self.memList.append("0")
	def const(self, i):
		name = str(i)##################### $
		if(name in self.memDict):
			return name
		else:
			self.memDict[name] = len(self.memList)
			self.memList.append(name+": "+str(i))
			return name
	def const2i(self, name):
		return int(name)#name[1:])
	def ptr(self, addr):
		if addr in self.memDict:
			return addr
		elif addr in self.ptr2reg:
			return self.ptr2reg[addr]
		else:
			self.reg_count += 1
			self.ptr2reg[addr] = "reg_"+str(self.reg_count)
			self.memDict[self.ptr2reg[addr]] = len(self.memList)
			self.memList.append(self.ptr2reg[addr]+": 0")
			return self.ptr2reg[addr]
############!!!!!!!!!!!!!!!!!!!!!!
	def ptr0(self, addr):
		if addr in self.memDict:
			return addr
		
		else:
			self.memDict[addr] = len(self.memList)
			self.memList.append(addr+": 0")
			return addr
	def temp(self):
		if(len(self.tempAvailable)!=0):
			name = self.tempAvailable.pop()
			self.tempDict[name] = True
			return name
		name = "temp_"+str(self.tempCount)
		self.tempCount += 1
		self.tempDict[name] = True
		self.ptr0(name)
		return name
		
	def temp_over(self, name):
		self.tempAvailable.append(name)
		self.tempDict[name] = False

# a word in memory
class Word(object):
	# type: ptr, data, symbol(NEXT & HALT)
	# 
	def __init__(self, type, value, manager, label = None):
		self.type = type
		self.value = value
		self.label = label
		# word manager
		self.manager = manager
		#self.value
		if type == "ptr":
			pass
		elif type == "data":
			pass

	def getType(self):
		return self.type
	#def getName(self):
	#	return self.name
	def getPtr(self):
		if(self.label==None):
			raise Error
		return self.manager.addPtrWord(self.label)
	def __str__(self):
		if self.label == None:
			label = ""
		else:
			label = self.label + ": "

		#if self.type == "ptr":
		if type(self.value) is Word and self.value.type == "label":
			return label + "&" + str(self.value)
		return label + str(self.value) #+ "("+self.type+")"
	def __repr__(self):
		if self.label == None:
			label = ""
		else:
			label = self.label + ": "

		#if self.type == "ptr":
		if type(self.value) is Word and self.value.type == "label":
			return label + "&" + str(self.value)
		return label + str(self.value) #+ "("+self.type+")"

class WordManager(object):
	"""
	wordPtrDict			
		-- for pointers to data
		-- {
			id(word) : word
		}
	wordDataDict		
	wordSymbolDict		
	"""
	def __init__(self):
		self.wordPtrDict = {}
		self.wordDataDict = {}
		self.wordDataPtrDict = {}
		self.wordSymbolDict = {
			"next": Word("symbol", "NEXT", self),
			"halt": Word("symbol", "HALT", self)
		}
		self.labelDict = {}
		self.flags = {}
		self.addrDict = {} # same to word data
		self.stack = {
			
			# #{100, a, 0}#(in debug tool)
		}
		self.nameToWord = {}
		self.temp = {}
		self.namespace = []
		self.needSave = {}
		self.currentFunction = {
			#"return": 
		}
		self.functionInfo = {
			#
		}
	def addNeedSave(self, w):
		self.needSave[w]=True

	def setNamespace(self, namespace):
		self.namespace = namespace
	def getUpperNamespace(self, i = 1):
		a = self.namespace[:-i]
		return "_".join(a+[""])
	def getNamespace(self, string=True):
		if string:
			return "_".join(self.namespace+[""])
		else:
			return self.namespace
	def pushNamespace(self, name):
		self.namespace.append(name)
		return self.getNamespace()
	def popNamespace(self):
		return self.namespace.pop()
	def getTemp(self, name):
		name = str(name)
		if self.temp.has_key(name):
			return self.temp[name]
		else:
			self.temp[name] = self.addDataWord(0, "t_"+name, False)
			return self.temp[name]
	def addName(self, word, name):
		#name = self.getNamespace() + name
		self.nameToWord[name] = word
		return word
	def addNewName(self, name):
		word = self.addDataWord(0, name)
		self.addName(word, name)
		return word
	def getName(self, name):
		if self.nameToWord.has_key(name):
			return self.nameToWord[name]
		else:
			word = self.addDataWord(0, name)
			self.addName(word, name)
			return word

	def addPtrWord(self, value, label=None):
		word = Word("ptr", value, self, label)
		self.wordPtrDict[id(word)] = word
		#print id(word),id(self.wordPtrDict[id(word)])

		return word
	def getPtrWord(word_id):
		if self.wordPtrDict.has_key(word_id):
			return self.wordPtrDict[word_id]
		else:
			return None
	def deletePtrWord(word_id):
		return self.wordPtrDict.pop(word_id)

	def addDataWord(self, value, label, namespace=True):
		if namespace:
			label = self.getNamespace() + label
		while self.wordDataDict.has_key(label) or self.wordDataPtrDict.has_key(label):
			l = label.split("-")
			label = l[0] + "-" + ("1" if len(l)==1 else str(int(l[1])+1))
		self.wordDataDict[label] = Word("data", value, self, label)
		if type(value) == Word:
			self.addrDict[label] = value
		return self.wordDataDict[label]
	def addDataPtrWord(self, value, label, namespace=True):
		if namespace:
			label = self.getNamespace() + label
		while self.wordDataDict.has_key(label) or self.wordDataPtrDict.has_key(label):
			l = label.split("-")
			label = l[0] + "-" + ("1" if len(l)==1 else str(int(l[1])+1))
		word = Word("data-ptr", value, self, label)
		self.wordDataPtrDict[label] = word
		return word
	def deleteDataWord(self, word):
		if self.wordDataDict.has_key(word.label):
			return self.wordDataDict.pop(word.label)
	def const(self, value):
		name = "c_"+str(value).replace("-","m")
		if name in self.wordDataDict:
			return self.wordDataDict[name]
		else:
			word = Word("data", value, self, name)
			self.wordDataDict[name] = word
			self.nameToWord[name] = word
			return word
	def getFlag(self, name):
		if self.flags.has_key(name):
			return self.flags[name]
		else:
			return None
	def setFlag(self, name, value):
		self.flags[name] = value
	def hasFlag(self, name):
		return self.flags.has_key(name)

	def getNext(self):
		return self.wordSymbolDict["next"]
	def getHalt(self):
		return self.wordSymbolDict["halt"]

	def label(self, name):
		l = Word("label", name, self)
		self.labelDict[id(l)]=l
		return l

	def dataMem(self):
		for key, value in self.wordDataDict.items():
			if type(value) == Word:
				print value
		if(self.hasFlag("stack")):
			pass
	def stackMem(self):
		if self.hasFlag("stack_init"):
			print "#{"+str(self.stack["size"])+", "+str(self.stack["start_label"])+", 0}#"




"""



"""

test = WordManager()
word = test.addPtrWord("abc")
print id(word)
