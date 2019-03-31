# Compiler new

### design

__Pass__ is the parent class for pass, which is a proccess of transforming. Several tools are provided.  
Currently there are 4 passes.
1. build pass: the pass for building the structure of instructions and memory
2. pre_transform pass: the pass for preparing transforming
3. transform pass: the pass for transforming instruction nodes
4. assemble_pass: the pass for outputing assembly


__Word__ is a basic element in memory. A Subneg4 instruction is made of 4 words. All data memory element is a word.

__WordManager__ is the manager for words. Operations of words is done by this class

__Instruction_node__ is the class for instructions. A program is a linked list, each node is an instruction.


