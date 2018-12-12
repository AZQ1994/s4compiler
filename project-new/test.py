from word import Word, DataWord, PointerWord
from word_manager import WordManager
from instruction_node import InstructionNode, SystemNode, Subneg4InstructionNode, PseudoInstructionNode, P_SUB, P_GOTO
from passes import Pass
class TestPass(Pass):
	def test_01(self):
		# instructions
		WM = self.WM
		start = self.startNode

		self.debug_log("Test start !", 2)

		namespace = ["test01","test02"]
		WM.add_namespace(namespace)

		A = WM.new_dataword("A", 10, namespace)
		B = WM.new_dataword("B", 5, namespace)
		C = WM.new_dataword("C", 0, namespace)

		A.new_ptr("A_PTR")

		namespace = ["test01","test02","test03"]
		WM.add_namespace(namespace)

		A1 = WM.get_word("A", namespace)
		A2 = WM.get_word("A_PTR", namespace)
		print A1, A2

		D = WM.get_HALT()

		n1 = P_SUB(A.new_ptr(), B.new_ptr(), C.new_ptr())
		n2 = P_GOTO(D)
		#n3 = Subneg4InstructionNode("A","B","C","D")

		start.append(n1, n2)#, n3)

		self.printIN(start)


	def test_02(self):
		WM = self.WM
		start = self.startNode

		A = WM.new_dataword("A", 10)
		B = WM.new_dataword("B", 5)
		C = WM.new_dataword("C", 0)

	def printIN(self, start):
		WM = self.WM
		book = WM.book.copy()

		current = start

		while current != None:
			for p in current.params:
				book.pop(id(p))
			self.debug_log( current )
			current = current.next

		for item in book.values():
			self.debug_log( item )

	def do(self):
		self.test_01()
		#self.test_02()

start = SystemNode([],"start")
end = SystemNode([],"end")
start.set_next(end)

WM = WordManager()
tp = TestPass(WM, start, end)
tp.debug_execute()