def check_int(s):
    if s[0] in ('-', '+'):
        return s[1:].isdigit()
    return s.isdigit()

def terminal_info(string):
	return bcolors.OKBLUE + string + bcolors.ENDC

class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'



class NamespaceTree(object):
	def __init__(self):
		self.root = NameTreeNode("ROOT")
		pass

	def add_word(self, word, currentNamespace):
		node = self.get_namespace(currentNamespace)
		if type(node) == NoneNode:
			raise Exception
		node.add_word(word)
		word.namespace = currentNamespace
		return word

	def get_namespace(self, namespace):
		return self.root.search_leaf_list(namespace)

	def add_namespace(self, namespace):
		return self.root.add_or_search_leaf_list(namespace)

	def search_name(self, name, namespace):
		node = self.get_namespace(namespace)
		if type(node) == NoneNode:
			raise Exception
		return node.search_word(name)

class NameTreeNode(object):
	def __init__(self, name, parent=None):
		self.content = {} # id => word
		self.name_dict = {} # name => word
		self.leaves = {} # "name" => TreeNode
		self.parent = parent
		if parent != None:
			parent.leaves[name] = self
	
	def add_word(self, word):
		self.content[word] = word
		self.name_dict[word.name] = word

	def search_word(self, name):
		if self.name_dict.has_key(name):
			return self.name_dict[name]
		elif self.parent == None:
			return None
		else:
			return self.parent.search_word(name)

	def get_leaf(self, name):
		if name in self.leaves:
			return self.leaves[name]
		else:
			return NoneNode("None", parent = self)
	def add_leaf(self, name):
		if name in self.leaves:
			raise Exception
		else:
			return NameTreeNode(name, self)

	### namespace list operations: search, addOrSearch
	def add_or_search_leaf_list(self, _list):
		if len(_list) == 0:
			return self
		else:
			node = self.get_leaf(_list[0])
			if type(node) != NoneNode:
				return node.add_or_search_leaf_list(_list[1:])
			else:
				node = self.add_leaf(_list[0])
				return node.add_or_search_leaf_list(_list[1:])

	def search_leaf_list(self, _list):
		if len(_list) == 0:
			return self
		else:
			node = self.get_leaf(_list[0])
			if type(node) != NoneNode:
				return node.search_leaf_list(_list[1:])
			else:
				return node


class NoneNode(NameTreeNode):
	def get_leaf(self, name):
		return NoneNode("None", parent = self)
	def __repr__(self):
		return "NoneNode"
	def __str__(self):
		return "NoneNode"