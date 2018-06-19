# Subneg4 compiler/

## Overview
### folders
/test: test codes for compiling

/sim: simulator

/x: JavaScript simulating tool

### compiler
0. For environment, you need clang. For development, you need LLVM libraries.
Compile the LLVM_IR_to_XML tool first
``` clang++ output.cpp -o output `llvm-config --cxxflags --libs --ldflags --system-libs` ```
1. To compile, you need the llvm ir bitcode file. 
Then use the LLVM_IR_to_XML tool to convert llvm ir bitcode file to xml file.
You can use helper.py in __test/__ to do this
2. set the xml file in main.py
3. Run python main.py
```
$ python main.py
```

## Notes
1. Still in progress, so not much instructions are supported
2. 

