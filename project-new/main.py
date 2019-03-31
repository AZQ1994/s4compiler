
from backend import Backend

"""
MEMO
clang++ output.cpp -o output `llvm-config --cxxflags --libs --ldflags --system-libs`

"""

b = Backend("../test/lev/lev-modified.xml")
b.build_pass()

b.pre_transform_pass()
b.transform_pass()
b.assemble_pass()
