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
