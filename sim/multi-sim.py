#!/usr/bin/env python

shared_start = 4096
cores = 4
shared_in_addr = shared_start-1
shared_out_addr = shared_start-2

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

import re
p1 = re.compile("#.*?$")

f = open(argvs[1]+".shared.mem","r")
lines = f.readlines()
f.close()

mem_shared = [int(re.sub(p1,"",x).strip()) for x in lines]
mem = []
for i in range(cores):
	f = open(argvs[1]+".%d.mem"%i,"r")
	lines = f.readlines()
	f.close()
	mem.append([int(re.sub(p1,"",x).strip()) for x in lines])
go = True
flags = [False]*cores # in flags True: have data , False: no data
pc = [0]*cores

i=0
a = [0]*cores
b = [0]*cores
mem_a = [0]*cores
mem_b = [0]*cores
c = [0]*cores
d = [0]*cores
res = [0]*cores
stage=[1]*cores
cycle = 0
stall = [0]*cores
while True:
	cycle += 1
	#stage1
	core = i%4
	if pc[core] < 0:
		stage[core] = 0
	if stage[core] != 1:
		stall[core] += 1
	while stage[core]==1:
		a[core] = mem[core][pc[core]]
		b[core] = mem[core][pc[core]+1]
		if a[core] == shared_in_addr or b[core] == shared_in_addr:
			if flags[core]:
				flags[core]=False
			else:
				# again
				stall[core] += 1
				break
		stage[core]=2
		break

	#stage2
	core = (i-1)%4
	if stage[core] != 2:
		stall[core] += 1
	if stage[core]==2:
		if a[core] < shared_start:
			mem_a[core] = mem[core][a[core]]
		else:
			mem_a[core] = mem_shared[a[core] - shared_start]

		if b[core] < shared_start:
			mem_b[core] = mem[core][b[core]]
		else:
			mem_b[core] = mem_shared[b[core] - shared_start]
		stage[core] = 3

	#stage3
	core = (i-2)%4
	if stage[core] != 3:
		stall[core] += 1
	while stage[core]==3:
		res[core] = (mem_b[core] - mem_a[core])&0xffffffff
		if res[core] > 0x7fffffff:
			res[core] = res[core] - 0x100000000

		c[core] = mem[core][pc[core]+2]
		d[core] = mem[core][pc[core]+3]

		if c[core] == shared_out_addr:
			if not flags[(core+1)%cores]:
				flags[(core+1)%cores] = True
				mem[(core+1)%cores][shared_in_addr] = res[core]
			else:
				stage[core] = 3
				stall[core] += 1
				break
			

		stage[core] = 4
		break
	#stage4
	core = (i-3)%4
	if stage[core] != 4:
		stall[core] += 1
	if stage[core]==4:
		
		if c[core] < shared_start:
			mem[core][c[core]] = res[core]
		else:
			mem_shared[c[core] - shared_start] = res[core]
		

		if res[core] < 0:
			pc[core] = d[core]
		else:
			pc[core] += 4

		if pc[core] < 0:
			stage[core] = 0
		else:
			stage[core] = 1
	i += 1
	

	
	if max(pc) < 0:
		break
	if max(stage) == 0:
		print "stage break"
		break
print i
print stall
for k,x in enumerate(mem_shared):
	print k,":",x
