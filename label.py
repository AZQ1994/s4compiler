class Label:
	def __init__(self, name):
		self.name = name.replace(".","_")
	def __repr__(self):
		return self.name

class LabelManager:
	def __init__(self):
		self.nameDict = dict()
		self.label_num = 0
		self.labelDict = dict()
	def new(self, LN, name = None):
		if name != None:
			if self.hasLabel(name):
				LN.label = self.getLabel(name)
			else:
				LN.label =self.addLabel(name)
			
			return LN
		self.label_num += 1
		ID = "L"+str(self.label_num)
		while ID in self.nameDict:
			self.label_num += 1
			ID = "L"+str(self.label_num)
		
		LN.label = self.addLabel(ID)

		return LN
	def delete(self, name):
		LN = self.nameDict.pop(str(name))
		LN.label = None
	"""def search(self, name):
		return self.nameDict[str(name)]
	"""
	def getLabel(self, name):
		return self.nameDict[name]
	def hasLabel(self, name):
		return self.nameDict.has_key(name)
	def addLabel(self, name):
		l = Label(name)
		self.nameDict[name] = l
		return l
	def useLabel(self, LN, label):
		if not self.labelDict.has_key(LN):
			self.labelDict[LN] = {}
		self.labelDict[LN][label] = True
		return 
	def replace(labelA, labelB):
		pass