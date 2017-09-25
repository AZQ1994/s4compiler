class ListNode:
	def __init__(self, ins, label = None, sys = False):
		self.ins = ins
		self.next = None
		self.prev = None
		self.sys = sys
		self.label = label
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
		LNs[0].label = self.label

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
		LNs[0].label = self.label

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
		del self
	def __repr__(self):
		return str(self.label) + ":\t" + str(self.ins) if not self.sys else ""