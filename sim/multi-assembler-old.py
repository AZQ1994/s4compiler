#!/usr/bin/env python
# assembler for subneg4 ring arch with a mem at the center

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

p1 = re.compile("/\*.*?\*/",re.DOTALL )
p2 = re.compile("//.*?$")
p3 = re.compile(">>>.*?$")
p3_1 = re.compile("!!!")
p4 = re.compile("\s*,\s*")
p5 = re.compile("\s*:\s*")

p6 = re.compile("\s+")

p7 = re.compile("\#\{\s*?(\d*)\s*?,\s*?(\S*)\s*?,\s*?(\d*)\s*?\}\#")


f = open(argvs[1]+".shared.asm","r")
lines = re.sub(p1 ,"" ,f.read()).split("\n") # remove all occurance streamed comments (/*COMMENT */) from string
f.close()

shared_mem_dict = {
	# "label" : ["where? prog or data", index]
}

shared_prog_mem = []
shared_data_mem = []
shared_block_mem = []

connect = ""
for l in lines:
	m = re.match(p7, l)
	if m != None:
		#print m.groups()
		shared_block_mem.append(m.groups())
		continue

	if connect != "":
		l = connect + l
		connect = ""
	
	
	l = re.sub(p2 ,"" ,l) # remove all occurance singleline comments (//COMMENT\n ) from string
	l = re.sub(p3 ,"" ,l) # remove >>>
	l = re.sub(p3_1 ,"" ,l) # remove !!!
	
	l = re.sub(p4 ," " ,l) # remove extra ','
	l = re.sub(p5 ,":" ,l) # remove extra ':'

	l = l.strip()
	if l == "":
		continue
	if l[-1] == ":":
		connect = l
	items = re.split(p6, l)
	if len(items) == 1:
		s = re.split(p5,items[0])
		index = len(shared_data_mem)
		if s[-1][0] == "&":
			shared_data_mem.append(["ptr",s[-1][1:],s[:-1]])
		else:
			shared_data_mem.append(["data",int(s[-1]),s[:-1]])
		for label in s[:-1]:
			if label in shared_mem_dict:
				print "[Warning] Label stated before", '"',label,'"'
			shared_mem_dict[label] = ["shared",index]
	else:
		print "[Warning] Shared mem error line!"
		print l


mem_dict = [#{
	# "label" : ["where? prog or data", index]
#}
]
prog_mem = []
data_mem = []
block_mem = []



for i in range(cores):
	print shared_in_addr, shared_out_addr
	mem_dict.append({
	})
	prog_mem.append([])
	data_mem.append([])
	block_mem.append([])

	f = open(argvs[1]+"."+str(i)+".asm","r")
	lines = re.sub(p1 ,"" ,f.read()).split("\n")
	f.close()

	connect = ""
	for l in lines:
		m = re.match(p7, l)
		if m != None:
			#print m.groups()
			block_mem[i].append(m.groups())
			continue

		if connect != "":
			l = connect + l
			connect = ""
		
		l = re.sub(p2 ,"" ,l) # remove all occurance singleline comments (//COMMENT\n ) from string
		l = re.sub(p3 ,"" ,l) # remove >>>
		l = re.sub(p3_1 ,"" ,l) # remove !!!
		
		l = re.sub(p4 ," " ,l) # remove extra ','
		l = re.sub(p5 ,":" ,l) # remove extra ':'

		l = l.strip()
		#print '"',l,'"'
		if l == "":
			continue
		if l[-1] == ":":
			connect = l
			continue
		items = re.split(p6, l)
		if len(items) == 3:
			items.append("NEXT")
		elif len(items) == 1:
			s = re.split(p5,items[0])
			index = len(data_mem[i])
			if s[-1][0] == "&":
				data_mem[i].append(["ptr",s[-1][1:],s[:-1]])
			else:
				data_mem[i].append(["data",int(s[-1]),s[:-1]])
			for label in s[:-1]:
				if label in mem_dict[i]:
					print "[Warning] Label stated before", '"',label,'"'
				mem_dict[i][label] = ["data",index]
			continue

		if len(items) != 4:
			print "PROGRAM ERROR"
			print l
			sys.exit()
		for j in range(4):
			s = re.split(p5,items[j])
			index = len(prog_mem[i])
			if s[-1][0] == "@":
				prog_mem[i].append(["data",int(s[-1][1:]),s[:-1]])
			else:
				prog_mem[i].append(["ptr",s[-1],s[:-1]])
			for label in s[:-1]:
				if label in mem_dict[i]:
					print "ERROR !! label used", '"',label,'"'
				mem_dict[i][label] = ["prog",index]



	#print items

#print prog_mem, data_mem
#print shared_data_mem, shared_mem_dict
#sys.exit()

if shared_out_addr < max([len(
	prog_mem[x])+len(data_mem[x])+sum([int(b[0]) for b in block_mem[x]]) for x in range(cores)]):
	print "ERROR!!"
	sys.exit()

file = open(argvs[1]+".shared.mem","w")
mem_shared = []

c = 0
for item in shared_block_mem:
	shared_mem_dict[item[1]] = ["block", c]
	c += int(item[0])
for item in shared_data_mem:
	if item[0] == "data":
		mem_shared.append([item[1],item[2],item[1]])
	elif item[0] == "ptr":
		if item[1] == "NEXT":
			mem_shared.append([len(mem_shared)+1+shared_start,[],"NEXT"])
			continue
		if item[1] == "HALT":
			mem_shared.append([-1,[],"HALT"])
			continue
		if item[1] not in shared_mem_dict:
			print "[warning]",item[1],"is not in memory"
			shared_mem_dict[item[1]] = ["prog",0]
		d = shared_mem_dict[item[1]]
		if d[0] == 'block':
			mem_shared.append([d[1]+len(shared_data_mem)+shared_start,item[2],item[1]])
		elif d[0] == 'shared':
			mem_shared.append([d[1]+shared_start,item[2],item[1]])
		else:
			print "[Warning]", d
for item in shared_block_mem:
	a = int(item[2])
	mem_shared.append([a,[item[1]],item[2]])
	mem_shared.extend([[a,[],item[2]] for _ in range(int(item[0])-1)])
mem_text = []
for j,item in enumerate(mem_shared):
	#print item
	mem_text.append( str(item[0])+"\t#"+str(item[2])+"\t@"+str(j+shared_start)+"\t"+":\t".join(item[1]+[""]) )
file.write("\n".join(mem_text))
file.close()


mem = []
for i in range(cores):

	t = shared_mem_dict.copy()
	t.update(mem_dict[i])
	mem_dict[i] = t

	file = open(argvs[1]+"."+str(i)+".mem","w")

	mem.append([])
	prog_mem_len = len(prog_mem[i])
	data_mem_len = len(data_mem[i])
	print i,":",prog_mem_len, data_mem_len
	c = 0
	for item in block_mem[i]:
		mem_dict[i][item[1]] = ["block", c]
		c += int(item[0])
	for item in prog_mem[i] + data_mem[i]:
		if item[0] == "data":
			mem[i].append([item[1],item[2],item[1]])
		elif item[0] == "ptr":
			if item[1] == "NEXT":
				mem[i].append([len(mem[i])+1,[],"NEXT"])
				continue
			if item[1] == "HALT":
				mem[i].append([-1,[],"HALT"])
				continue
			if item[1] == "SHARED_IN":
				mem[i].append([shared_in_addr, item[2], item[1]])
				continue
			if item[1] == "SHARED_OUT":
				mem[i].append([shared_out_addr, item[2], item[1]])
				continue
			if item[1] not in mem_dict[i]:
				print "[warning]",item[1],"is not in memory"
				mem_dict[i][item[1]] = ["prog",0]
			d = mem_dict[i][item[1]]
			if d[0] == "prog":
				mem[i].append([d[1],item[2],item[1]])
			elif d[0] == "data":
				mem[i].append([d[1]+prog_mem_len,item[2],item[1]])
			elif d[0] == 'block':
				mem[i].append([d[1]+prog_mem_len+data_mem_len,item[2],item[1]])
			elif d[0] == 'shared':
				mem[i].append([d[1]+shared_start,item[2],item[1]])
			else:
				print d[0]
	for item in block_mem[i]:
		a = int(item[2])
		mem[i].append([a,[item[1]],item[2]])
		mem[i].extend([[a,[],item[2]] for _ in range(int(item[0])-1)])
	mem[i].extend([[0,[],"0"] for _ in range(len(mem[i]),shared_start-2)])
	mem[i].extend([[0,["SHARED_OUT"],"0"],[0,["SHARED_IN"],"0"]])
	mem_text = []
	for j,item in enumerate(mem[i]):
		#print item
		mem_text.append( str(item[0])+"\t#"+str(item[2])+"\t@"+str(j)+"\t"+":\t".join(item[1]+[""]) )
	file.write("\n".join(mem_text))
	file.close()
#print mem

go = True
flags = [False]*cores # in flags True: have data , False: no data
pc = [0]*cores

count = [0]*cores
stall = [0]*cores
while go:
	for i in range(cores):
		#if i == 3 and pc[3] == 432:
		#	for k,x in enumerate(mem_shared):
		#		print k,":",x[0]
		if pc[i] < 0:
			continue;
		a = mem[i][pc[i]][0]
		b = mem[i][pc[i]+1][0]
		c = mem[i][pc[i]+2][0]
		d = mem[i][pc[i]+3][0]
		#print flags
		in_flag_change = False
		out_flag_change = False
		#print i," (",count[i],")",": ", pc[i], a,b,c,d
		if a == shared_in_addr:
			if flags[i]:
				in_flag_change = True
			else:
				stall[i] += 1
				continue
		if b == shared_in_addr:
			if flags[i]:
				in_flag_change = True
			else:
				stall[i] += 1
				continue
		if c == shared_out_addr:
			if not flags[(i+1)%cores]:
				out_flag_change = True
			else:
				stall[i] += 1
				continue

		if in_flag_change:
			flags[i] = False
		if out_flag_change:
			flags[(i+1)%cores] = True

		if a < shared_start:
			mem_a = mem[i][a][0]
		else:
			mem_a = mem_shared[a - shared_start][0]

		if b < shared_start:
			mem_b = mem[i][b][0]
		else:
			mem_b = mem_shared[b - shared_start][0]
		
		if c < shared_start:
			mem_c = mem[i][c][0]
		else:
			mem_c = mem_shared[c - shared_start][0]
		

		res = (mem_b-mem_a)&0xffffffff
		if res > 0x7fffffff:
			res = res - 0x100000000
		if c == shared_out_addr:
			mem[(i+1)%cores][shared_in_addr][0] = res

		if c < shared_start:
			mem[i][c][0] = res
		else:
			mem_shared[c - shared_start][0] = res
		
		#print i," (",count[i],")",": ", pc[i], a,b,c,d, mem_a, mem_b, mem_c, res
		if i == 2:
			print "a=%d, m[a]=%d, b=%d, m[b]=%d, c=%d, res=%d, d=%d, pc=%d, flag=%d, stage=%d"%(a,mem_a,b,mem_b,c,res,d,pc[i],flags[2],4)
		count[i] += 1
		#print "[core"+str(i)+"] "+"count:",count[i],"\tpc:",pc[i],"\ta:",mem_a,"\tb:",mem_b,"\tc:",mem_c,"\td:",d, "\tres:",res
		if res < 0:
			pc[i] = d
		else:
			pc[i] = pc[i] + 4
	if max(pc) < 0:
		break;
print count, stall

for k,x in enumerate(mem_shared):
	print k,":",x[0]
#print [x[0] for x in mem_shared]
