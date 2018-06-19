# Subneg4 compiler/

## Overview
### folders
/test: test codes for compiling

/sim: simulator

/x: JavaScript simulating tool

### compiler
0. For environment, you need clang. For development, you need LLVM libraries.
Compile the LLVM_IR_to_XML tool first
```
$ clang++ output.cpp -o output `llvm-config --cxxflags --libs --ldflags --system-libs` 
```
The tool is already compiled for x86-linux environment

1. To compile, you need the llvm ir bitcode file. 
Then use the LLVM_IR_to_XML tool to convert llvm ir bitcode file to xml file.
You can use helper.py in __test/__ to do this
```
$ test/helper.py test/test_code_your_code/your.c
```
2. set the xml file in main.py
```
backend = Backend("test/test_code_your_code/your.xml")
```
3. Run python main.py
```
$ python main.py > test/test_code_your_code/your.subneg4
```
4. Run assembler
```
$ sim/assembler.py test/test_code_your_code/your.subneg4
```
5. Run simulator
```
$ sim/simulator.py test/test_code_your_code/your.subneg4.mem
```
## Notes
1. Still in progress, so not much instructions are supported
2. 

