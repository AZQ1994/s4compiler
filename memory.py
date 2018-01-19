from label import Label
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
		return self.manager.addPtrWord(self)#.label)
	def __str__(self):
		if self.label == None:
			label = ""
		else:
			label = self.label + ": "

		#if self.type == "ptr":
		if type(self.value) is Word and self.value.type == "label":
			return label + "&" + str(self.value)

		if self.type=="ptr" and type(self.value) is Word:
			return label + self.value.label
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
class Words(object):
	def __init__(self, values, manager, name):
		self.words = []
		self.manager = manager
		self.name = name
		for i, v in enumerate(values):
			self.words.append( self.manager.addDataWord(v, name+"-"+str(i), type_="data-words") )
#### TODO : getAddr()

	def getStr(self):
		return "\n".join([str(w) for w in self.words])
	def get(self, index=0):
		if index < len(self.words):
			return self.words[index]
		else:
			print "##### ERROR INDEX !!!!!!!!"
	def getPtr(self, index = 0):
		if index < len(self.words):
			return self.words[index].getPtr()
		else:
			print "##### ERROR INDEX !!!!!!!!"

	def __str__(self):
		if len(self.words) != 0:
			return str(self.words[0])
		else:
			return "// empty words"
	def __repr__(self):
		if len(self.words) != 0:
			return str(self.words[0])
		else:
			return "// empty words"
		
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
	def __init__(self, LM):
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
		self.result = self.addDataWord(0, "d_return_data")
		self.LM = LM
	def addNeedSave(self, w):
		self.needSave[w]=False

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
	def turnWordIntoWord(self, W0, W1):
		if W0.type == "data":
			self.wordDataDict.pop(W0.label)
		elif W0.type == "ptr":
			self.wordPtrDict.pop(id(W0))
		elif W0.type == "data-ptr":
			self.wordDataPtrDict.pop(W0.label)

		W0.type = W1.type
		W0.value = W1.value
		W0.label = W1.label

		if W1.type == "data":
			self.wordDataDict[W0.label] = W0
		elif W1.type == "ptr":
			self.wordPtrDict[id(W0)] = W0
		elif W1.type == "data-ptr":
			self.wordDataPtrDict[W0.label] = W0

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

	def addWords(self, values, label, namespace=True):
		if namespace:
			label = self.getNamespace() + label
		while self.wordDataDict.has_key(label) or self.wordDataPtrDict.has_key(label):
			l = label.split("-")
			if len(l) == 1:
				label = l[0] + "-1"
			else:
				label = "-".join(l[:-1]) + "-" + str(int(l[1])+1)
		self.wordDataDict[label] = Words(values, self, label)
		return self.wordDataDict[label]

	def addDataWord(self, value, label, namespace=True, type_="data"):
		if namespace:
			label = self.getNamespace() + label
		while self.wordDataDict.has_key(label) or self.wordDataPtrDict.has_key(label):
			l = label.split("-")
			if len(l) == 1:
				label = l[0] + "-1"
			else:
				label = "-".join(l[:-1]) + "-" + str(int(l[1])+1)
		self.wordDataDict[label] = Word(type_, value, self, label)
		if type(value) == Word:
			self.addrDict[label] = value
		return self.wordDataDict[label]
	def addDataPtrWord(self, value, label, namespace=True):
		if namespace:
			label = self.getNamespace() + label
		while self.wordDataDict.has_key(label) or self.wordDataPtrDict.has_key(label):
			l = label.split("-")
			if len(l) == 1:
				label = l[0] + "-1"
			else:
				label = "-".join(l[:-1]) + "-" + str(int(l[1])+1)
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
			word = Word("data-const", value, self, name)
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
		"""
		all using of label comes from here!
		"""

		if type(name) == Label:
			name = name.name
		#print type(name)
		l = Word("label", name, self)
		if self.labelDict.has_key(name):
			self.labelDict[name].append(l)
		else:
			self.labelDict[name]=[l]
		return l

	def dataMem(self):
		for key, value in self.wordDataDict.items():
			if type(value) == Word and value.getType() != "data-words":
				print value
			if type(value) == Words:
				print value.name+": "+value.getStr()
		if(self.hasFlag("stack")):
			pass
	def stackMem(self):
		if self.hasFlag("stack_init"):
			print "#{"+str(self.stack["size"])+", "+str(self.stack["start_label"])+", 0}#"




"""



"""

#test = WordManager()
#word = test.addPtrWord("abc")
#print id(word)
