#!/usr/bin/env python
# assembler for subneg4 ring arch with a mem at the center

shared_start = 1024
cores = 8
shared_in_addr = shared_start-1
shared_out_addr = shared_start-2
import commands
import sys
argvs = sys.argv
print argvs
if (len(argvs) not in [2,3]):   
    print 'Usage: # python %s filename [-e]' % argvs[0]
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

p8 = re.compile("\%\{\s*\[\s*(\S.*?)\s*\]\s*")
p9 = re.compile("\}\%")
f = open(argvs[1]+".shared.asm","r")
lines = re.sub(p1 ,"" ,f.read()).split("\n") # remove all occurance streamed comments (/*COMMENT */) from string
f.close()

shared_mem_dict = {
	# "label" : ["where? prog or data", index]
}

shared_prog_mem = []
shared_data_mem = []
shared_block_mem = []

namespace = []

connect = ""
for l in lines:
	m = re.match(p7, l)
	if m != None:
		#print m.groups()
		shared_block_mem.append(m.groups())
		continue

	m = re.match(p8, l)
	if m != None:
		namespace.append(m.group(1))
		l = re.sub(p8 ,"" ,l)
	m = re.match(p9, l)
	if m != None:
		namespace.pop()
		l = re.sub(p9 ,"" ,l)

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
			shared_data_mem.append(["ptr","%".join(namespace+[s[-1][1:]]),["%".join(namespace+[x]) for x in s[:-1]]])
		else:
			shared_data_mem.append(["data",int(s[-1]),["%".join(namespace+[x]) for x in s[:-1]]])
		for label in s[:-1]:
			name = "%".join(namespace+[label])
			if name in shared_mem_dict:
				print "[Warning] Label stated before", '"',name,'"'
			shared_mem_dict[name] = ["shared",index]
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

	namespace = []

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

		m = re.match(p8, l)
		if m != None:
			namespace.append(m.group(1))
			l = re.sub(p8 ,"" ,l)
		m = re.match(p9, l)
		if m != None:
			namespace.pop()
			l = re.sub(p9 ,"" ,l)

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
				data_mem[i].append(["ptr","%".join(namespace+[s[-1][1:]]),["%".join(namespace+[x]) for x in s[:-1]]])
			else:
				data_mem[i].append(["data",int(s[-1]),["%".join(namespace+[x]) for x in s[:-1]]])
			for label in s[:-1]:
				name = "%".join(namespace+[label])
				if name in mem_dict[i]:
					print "[Warning] Label stated before", '"',name,'"'
				mem_dict[i][name] = ["data",index]
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
			elif s[-1] in ["NEXT","HALT","SHARED_IN","SHARED_OUT"]:
				prog_mem[i].append(["ptr",s[-1],["%".join(namespace+[x]) for x in s[:-1]]])
			else:
				prog_mem[i].append(["ptr","%".join(namespace+[s[-1]]),["%".join(namespace+[x]) for x in s[:-1]]])
			for label in s[:-1]:
				name = "%".join(namespace+[label])
				if name in mem_dict[i]:
					print "ERROR !! label used", '"',name,'"'
				mem_dict[i][name] = ["prog",index]



	#print items

#print prog_mem, data_mem
#print shared_data_mem, shared_mem_dict
#sys.exit()

if shared_out_addr < max([len(
	prog_mem[x])+len(data_mem[x])+sum([int(b[0]) for b in block_mem[x]]) for x in range(cores)]):
	print "ERROR!!"
	sys.exit()

file = open(argvs[1]+".shared.hex","w")
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
			split = item[1].split("%")

			for i in range(2,len(split)+1):
				name = "%".join(split[:-i]+[split[-1]])

				if name in shared_mem_dict:
					item[1] = name
					break
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
	mem_text.append( format(item[0]&0xffffffff,"08X") )
file.write("\n".join(mem_text))
file.close()


mem = []
for i in range(cores):

	t = shared_mem_dict.copy()
	t.update(mem_dict[i])
	mem_dict[i] = t

	file = open(argvs[1]+"."+str(i)+".hex","w")

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
				split = item[1].split("%")
				for j in range(2,len(split)+1):
					name = "%".join(split[:-j]+[split[-1]])
					if name in mem_dict[i]:
						item[1] = name
						break
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
		mem_text.append( format(item[0]&0xffffffff,"08X") )
	file.write("\n".join(mem_text))
	file.close()
#print mem

if len(argvs)!=3 or argvs[2]!="-e":
	sys.exit(0)


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

shared_count = 0
shared_count_read = 0
shared_count_write = 0
try:
	while True:
		cycle += 1
		#stage1
		core = i%8
		if pc[core] < 0:
			stage[core] = 0
		if stage[core] != 1:
			stall[core] += 1
		while stage[core]==1:
			a[core] = mem[core][pc[core]][0]
			b[core] = mem[core][pc[core]+1][0]
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
		core = (i-1)%8
		if stage[core] != 2:
			stall[core] += 1
		if stage[core]==2:
			count = 0
			if a[core] < shared_start:
				mem_a[core] = mem[core][a[core]][0]
			else:
				mem_a[core] = mem_shared[a[core] - shared_start][0]
				count += 1

			if b[core] < shared_start:
				mem_b[core] = mem[core][b[core]][0]
			else:
				mem_b[core] = mem_shared[b[core] - shared_start][0]
				count += 1
			if count > 1:
				print "WARNING: more than one access to shared memory"
			stage[core] = 3
			shared_count += count
			shared_count_read += count
		#stage3
		core = (i-2)%8
		if stage[core] != 3:
			stall[core] += 1
		while stage[core]==3:
			res[core] = (mem_b[core] - mem_a[core])&0xffffffff
			if res[core] > 0x7fffffff:
				res[core] = res[core] - 0x100000000

			c[core] = mem[core][pc[core]+2][0]
			d[core] = mem[core][pc[core]+3][0]

			if c[core] == shared_out_addr:
				if not flags[(core+1)%cores]:
					flags[(core+1)%cores] = True
					mem[(core+1)%cores][shared_in_addr][0] = res[core]
				else:
					stage[core] = 3
					stall[core] += 1
					break
			stage[core] = 4
			break
		#stage4
		core = (i-3)%8
		if stage[core] != 4:
			stall[core] += 1
		if stage[core]==4:
			
			if c[core] < shared_start:
				mem[core][c[core]][0] = res[core]
			else:
				mem_shared[c[core] - shared_start][0] = res[core]
				shared_count += 1
				shared_count_write += 1

			if res[core] < 0:
				pc[core] = d[core]
			else:
				pc[core] += 4

			if pc[core] < 0:
				stage[core] = 0
			else:
				stage[core] = 1


		#stage1
		core = (i-4)%8
		if pc[core] < 0:
			stage[core] = 0
		if stage[core] != 1:
			stall[core] += 1
		while stage[core]==1:
			a[core] = mem[core][pc[core]][0]
			b[core] = mem[core][pc[core]+1][0]
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
		core = (i-5)%8
		if stage[core] != 2:
			stall[core] += 1
		if stage[core]==2:
			count = 0
			if a[core] < shared_start:
				mem_a[core] = mem[core][a[core]][0]
			else:
				mem_a[core] = mem_shared[a[core] - shared_start][0]
				count += 1

			if b[core] < shared_start:
				mem_b[core] = mem[core][b[core]][0]
			else:
				mem_b[core] = mem_shared[b[core] - shared_start][0]
				count += 1
			if count > 1:
				print "WARNING: more than one access to shared memory"
			stage[core] = 3
			shared_count += count
			shared_count_read += count
		#stage3
		core = (i-6)%8
		if stage[core] != 3:
			stall[core] += 1
		while stage[core]==3:
			res[core] = (mem_b[core] - mem_a[core])&0xffffffff
			if res[core] > 0x7fffffff:
				res[core] = res[core] - 0x100000000

			c[core] = mem[core][pc[core]+2][0]
			d[core] = mem[core][pc[core]+3][0]

			if c[core] == shared_out_addr:
				if not flags[(core+1)%cores]:
					flags[(core+1)%cores] = True
					mem[(core+1)%cores][shared_in_addr][0] = res[core]
				else:
					stage[core] = 3
					stall[core] += 1
					break
			stage[core] = 4
			break
		#stage4
		core = (i-7)%8
		if stage[core] != 4:
			stall[core] += 1
		if stage[core]==4:
			
			if c[core] < shared_start:
				mem[core][c[core]][0] = res[core]
			else:
				mem_shared[c[core] - shared_start][0] = res[core]
				shared_count += 1
				shared_count_write += 1

			if res[core] < 0:
				pc[core] = d[core]
			else:
				pc[core] += 4

			if pc[core] < 0:
				stage[core] = 0
			else:
				stage[core] = 1
		i += 1
		#print i, a[1],b[1],c[1],mem_a[1],mem_b[1],res[1],pc,flags,stage[1]
		#if i == 130000: break
		if max(pc) < 0:
			break
		if max(stage) == 0:
			print "stage break"
			break

except KeyboardInterrupt:
	print pc, i
finally:
	print i
	print stall
	for k,x in enumerate(mem_shared):
		print k,":",x[0]