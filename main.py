
from backend import Backend

"""
MEMO
clang++ output.cpp -o output `llvm-config --cxxflags --libs --ldflags --system-libs`

"""

backend = Backend("test/test_code_quick/mips-quick.xml")
#backend = Backend("test/test_code_quick_new/main.o3.xml")
#backend = Backend("test/test_code_quick/mips-quick-test.o3.xml")
#backend = Backend("test/test_code_quick/quick.xml")
backend.buildPass()
#backend.printNodes(True)
#print " ################################################# "
backend.transformPass()
backend.optimizePass()
backend.convertPass()
backend.printNodes(True)

backend.WM.dataMem()
backend.WM.stackMem()
"""
for x in a.WM.wordDataDict:
	print x 

"""
