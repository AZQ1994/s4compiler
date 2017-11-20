class Label(object):
	def __init__(self, name):
		self.name = name.replace(".","_")
	def __repr__(self):
		return self.name

class LabelManager(object):
	def __init__(self):
		self.nameDict = dict()
		self.label_num = 0
		self.labelDict = dict()
	def new(self, LN, name = None):
		if name != None:
			if type(name) is list:
				pass
			else:
				name = [name]
			for n in name:
				if self.hasLabel(n):
					LN.addLabel(self.getLabel(n))
				else:
					LN.addLabel(self.addLabel(n))
			return LN
		self.label_num += 1
		ID = "L"+str(self.label_num)
		while ID in self.nameDict:
			self.label_num += 1
			ID = "L"+str(self.label_num)
		
		LN.addLabel(self.addLabel(ID))
		return LN
	def delete(self, name):
		LN = self.nameDict.pop(str(name))
		LN.label = []
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