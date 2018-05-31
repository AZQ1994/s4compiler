#!/usr/bin/env python

import commands
import sys
argvs = sys.argv
print argvs
if (len(argvs) != 2):   
    print 'Usage: # python %s filename' % argvs[0]
    quit()
path = "/".join(("./"+argvs[1]).split("/")[:-1])
filename = ".".join(argvs[1].split(".")[:-1])
print argvs[0], path, filename

f = open(argvs[1],"r")
lines = f.readlines()
import re
p1 = re.compile("#.*?$")
mem = [int(re.sub(p1,"",x).strip()) for x in lines]
print zip(range(300),mem[:300])
pc = 0
count = 0
while pc >= 0:
	a = mem[pc]
	b = mem[pc+1]
	c = mem[pc+2]
	d = mem[pc+3]
	#print pc, a,b,c,d
	mem_a = mem[a]
	mem_b = mem[b]
	mem_c = mem[c]

	res = (mem_b-mem_a)&0xffffffff
	if res > 0x7fffffff:
		res = res - 0x100000000
	mem[c] = res
	count += 1
	#print "count:",count,"\tpc:",pc,"\ta:",mem_a,"\tb:",mem_b,"\tc:",mem_c,"\td:",d, "\tres:",res
	if res < 0:
		pc = d
	else:
		pc = pc + 4
	#if count >= 10000000:
	#	break
print "cycles: ",count
for i,m in enumerate(mem):
	print i,":\t",m
