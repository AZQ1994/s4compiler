# SIM/

## Overview
This folder is for tools.
Use assembler. py to convert assembly code to DEC mem (text) file
```
$ ./assembler.py test
```
Use simulator. py to run simulations using the data text file generated above
```
$ ./simulator.py test.mem
```

multi-assembler and multi-sim are tools for 4 core subneg4s.

## Notes
1. 


## Assembly code

__subneg4 a,b,c,d__ do:
```
	mem[c] = mem[b] - mem[a]
	if mem[c] < 0: goto d
	else: goto next
```
The assembler can read like this:
```[Label:]a(, or white_spaces)[Label:]b(, or white_spaces)[Label:]c(, or white_spaces)[Label:]d```
for example:```L1_1: a, L1_2:b, c   L1_4:d```

The 4th operand has two reserved words: __NEXT__, __HALT__
__NEXT__ is a pointer to the next instruction
__HALT__ is pointing to the HALT address

when the 4th operand is __NEXT__, it can be omitted.
a, b, c, NEXT => a, b, c

Comment is in C form: "//" and "/*"+"*/"

## Ja

ニモニックは下記のようです。
(命令はsubneg4だけなので省略)
命令は4つのオペランドで：
a, b, c, dで
mem[c] = mem[b] - mem[a];
if mem[c] < 0: goto d
else: goto next
という動作をします。
書き方はこの仕様では、
(Label:)a(__カンマ__|__スペース__) (Label:)b(,| ) (Label:)c(,| ) (Label:)d
となっています。
ｄは２種類の特殊ケースがあり、NEXTとHALTです。（大文字）
ｄがNEXTの場合は、次の命令の番地となります。
ｄがHALTの場合は、（分岐した場合）プログラムが停止します。
NEXTの場合は、オペランド４は省略できます。

また、コメントはC形式で、"//"と"/*"+"*/"です。
