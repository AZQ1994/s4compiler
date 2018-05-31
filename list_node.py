from label import Label
class ListNode(object):
	def __init__(self, ins, label = None, sys = False, opt = None):
		self.ins = ins
		self.next = None
		self.prev = None
		self.sys = sys
		self.label = []
		self.opt = opt
		if label != None:
			self.label.append(label)
	def getNextInst(self):
		current = self.next
		while current != None and current.sys:
			current = current.next
		return current
	def setNext(self, LN):
		self.next = LN
		LN.prev = self
		return self

	def setPrev(self, LN):
		self.prev = LN
		LN.next = self
		return self

	def appendLNs(self, LNs):
		#print LNs
		temp = self.next
		current = self
		for LN in LNs:
			current.next = LN
			LN.prev = current
			current = LN
		current.next = temp
		temp.prev = current
		return current

	def append(self, *LNs):
		temp = self.next
		current = self
		for LN in LNs:
			current.next = LN
			LN.prev = current
			current = LN
		current.next = temp
		temp.prev = current
		return current
	def replaceLNs(self, LM, LNs):
		temp = self.next
		current = self.prev
		"""
		if(self.label!=None):
			if(LNs[0].label==None):
				LNs[0].label = self.label
			else:
				LNs[0].label = str(self.label) + ":" + str(LNs[0].label)
		"""
		#LNs[0].label = self.label
		LNs[0].label += self.label
		for LN in LNs:
			current.next = LN
			LN.prev = current
			current = LN
		current.next = temp
		temp.prev = current
		his = self.prev.next
		del self
		return his
	def replace(self, LM, *LNs):
		temp = self.next
		current = self.prev
		"""
		if(self.label!=None):
			if(LNs[0].label==None):
				LNs[0].label = self.label
			else:
				LNs[0].label = str(self.label) + ":" + str(LNs[0].label)
		"""
		#LNs[0].label = self.label
		LNs[0].label += self.label
		for LN in LNs:
			current.next = LN
			LN.prev = current
			current = LN
		current.next = temp
		temp.prev = current
		his = self.prev.next
		del self
		return his
	#def prepend(self, *LNs):
	def remove(self):
		self.prev.next = self.next
		self.next.prev = self.prev
		self.next.label += self.label
		#print "test:"+str(self)+":::"+str(self.label)+"::::"+str(self.next.label)
		del self
	def label_string(self):
		if len(self.label) == 0:
			return None
		return ":".join([str(x) for x in self.label])
	def getALabel(self):
		if len(self.label) != 0:
			return self.label[0]

	def addLabel(self, label):
		self.label.append(label)
		
	def labelStringArray(self):
		return [x.name if type(x)==Label else x for x in self.label]
	def __repr__(self):
		return str(self.label_string()) + ":\t" + str(self.ins) if not self.sys else "// sys: "+str(self.ins)+"\t"+str(self.opt)