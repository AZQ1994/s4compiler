#!/usr/bin/env python
# assembler for subneg4 ring arch with a mem at the center

shared_start = 1024
core_per_cluster = 4
clusters = 2 # designed for only 2 # need fix
cores = core_per_cluster * clusters

shared_in_addr = shared_start-1
shared_out_addr = shared_start-2

cluster_shared_left_in_addr = shared_start-3
cluster_shared_left_out_addr = shared_start-4
cluster_shared_right_in_addr = shared_start-3
cluster_shared_right_out_addr = shared_start-4

local_end = shared_start-4

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

### read mem
f = open(argvs[1]+".shared.asm","r")
lines = re.sub(p1 ,"" ,f.read()).split("\n") # remove all occurance streamed comments (/*COMMENT */) from string
f.close()
print "-- Reading shared memory"

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


for cluster in range(clusters):
	print "-- Reading cluster", cluster
	mem_dict.append([])
	prog_mem.append([])
	data_mem.append([])
	block_mem.append([])
	for i in range(core_per_cluster):
		print "-- Reading local memory of core", i
		#print shared_in_addr, shared_out_addr
		mem_dict[cluster].append({
		})
		prog_mem[cluster].append([])
		data_mem[cluster].append([])
		block_mem[cluster].append([])

		namespace = []

		f = open(argvs[1]+"."+str(cluster)+"."+str(i)+".asm","r")
		lines = re.sub(p1 ,"" ,f.read()).split("\n")
		f.close()

		connect = ""
		for l in lines:
			m = re.match(p7, l)
			if m != None:
				#print m.groups()
				block_mem[cluster][i].append(m.groups())
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
				index = len(data_mem[cluster][i])
				if s[-1][0] == "&":
					data_mem[cluster][i].append(["ptr","%".join(namespace+[s[-1][1:]]),["%".join(namespace+[x]) for x in s[:-1]]])
				else:
					data_mem[cluster][i].append(["data",int(s[-1]),["%".join(namespace+[x]) for x in s[:-1]]])
				for label in s[:-1]:
					name = "%".join(namespace+[label])
					if name in mem_dict[cluster][i]:
						print "[Warning] Label stated before", '"',name,'"'
					mem_dict[cluster][i][name] = ["data",index]
				continue

			if len(items) != 4:
				print "PROGRAM ERROR"
				print l
				sys.exit()
			for k in range(4):
				s = re.split(p5,items[k])
				index = len(prog_mem[cluster][i])
				if s[-1][0] == "@":
					prog_mem[cluster][i].append(["data",int(s[-1][1:]),s[:-1]])
				elif s[-1] in ["NEXT","HALT","SHARED_IN","SHARED_OUT","CLEFT_IN","CLEFT_OUT","CRIGHT_IN","CRIGHT_OUT"]:
					prog_mem[cluster][i].append(["ptr",s[-1],["%".join(namespace+[x]) for x in s[:-1]]])
				else:
					prog_mem[cluster][i].append(["ptr","%".join(namespace+[s[-1]]),["%".join(namespace+[x]) for x in s[:-1]]])
				for label in s[:-1]:
					name = "%".join(namespace+[label])
					if name in mem_dict[cluster][i]:
						print "ERROR !! label used", '"',name,'"'
					mem_dict[cluster][i][name] = ["prog",index]


	#print items

#print prog_mem[0][0]#, data_mem
#print shared_data_mem, shared_mem_dict
#sys.exit()

if local_end < max([len(
	prog_mem[y][x])+len(data_mem[y][x])+sum([int(b[0]) for b in block_mem[y][x]]) for x in range(core_per_cluster) for y in range(clusters)]):
	print "ERROR!! too big local mem"
	print [len(
	prog_mem[y][x])+len(data_mem[y][x])+sum([int(b[0]) for b in block_mem[y][x]]) for x in range(core_per_cluster) for y in range(clusters)]
	sys.exit()

file = open(argvs[1]+".shared.mem","w")
file2 = open(argvs[1]+".shared.hex","w")
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
	mem_text.append( str(item[0])+"\t#"+str(item[2])+"\t@"+str(j+shared_start)+"\t"+":\t".join(item[1]+[""]) )
file.write("\n".join(mem_text))
file.close()

mem_text = []
for j,item in enumerate(mem_shared):
	#print item
	mem_text.append( format(item[0]&0xffffffff,"08X") )
file2.write("\n".join(mem_text))
file2.close()


mem = []
for j in range(clusters):
	mem.append([])
	for i in range(core_per_cluster):

		t = shared_mem_dict.copy()
		t.update(mem_dict[j][i])
		mem_dict[j][i] = t

		file = open(argvs[1]+"."+str(j)+"."+str(i)+".mem","w")
		file2 = open(argvs[1]+"."+str(j)+"."+str(i)+".hex","w")

		mem[j].append([])
		prog_mem_len = len(prog_mem[j][i])
		data_mem_len = len(data_mem[j][i])
		print "cluster", j, "core", i,":","prog_mem_len:", prog_mem_len, "data_mem_len:", data_mem_len
		c = 0
		for item in block_mem[j][i]:
			mem_dict[j][i][item[1]] = ["block", c]
			c += int(item[0])

		for item in prog_mem[j][i] + data_mem[j][i]:
			if item[0] == "data":
				mem[j][i].append([item[1],item[2],item[1]])
			elif item[0] == "ptr":
				if item[1] == "NEXT":
					mem[j][i].append([len(mem[j][i])+1,[],"NEXT"])
					continue
				if item[1] == "HALT":
					mem[j][i].append([-1,[],"HALT"])
					continue
				if item[1] == "SHARED_IN":
					mem[j][i].append([shared_in_addr, item[2], item[1]])
					continue
				if item[1] == "SHARED_OUT":
					mem[j][i].append([shared_out_addr, item[2], item[1]])
					continue
				if item[1] == "CLEFT_IN":
					mem[j][i].append([cluster_shared_left_in_addr, item[2], item[1]])
					continue
				if item[1] == "CRIGHT_IN":
					mem[j][i].append([cluster_shared_right_in_addr, item[2], item[1]])
					continue
				if item[1] == "CLEFT_OUT":
					mem[j][i].append([cluster_shared_left_out_addr, item[2], item[1]])
					continue
				if item[1] == "CRIGHT_OUT":
					mem[j][i].append([cluster_shared_right_out_addr, item[2], item[1]])
					continue

				if item[1] not in mem_dict[j][i]:
					split = item[1].split("%")
					for k in range(2,len(split)+1):
						name = "%".join(split[:-k]+[split[-1]])
						if name in mem_dict[j][i]:
							item[1] = name
							break
					if item[1] not in mem_dict[j][i]:
						print "[warning]",item[1],"is not in memory"
						mem_dict[j][i][item[1]] = ["prog",0]

				d = mem_dict[j][i][item[1]]
				if d[0] == "prog":
					mem[j][i].append([d[1],item[2],item[1]])
				elif d[0] == "data":
					mem[j][i].append([d[1]+prog_mem_len,item[2],item[1]])
				elif d[0] == 'block':
					mem[j][i].append([d[1]+prog_mem_len+data_mem_len,item[2],item[1]])
				elif d[0] == 'shared':
					mem[j][i].append([d[1]+shared_start,item[2],item[1]])
				else:
					print d[0]
		for item in block_mem[j][i]:
			a = int(item[2])
			mem[j][i].append([a,[item[1]],item[2]])
			mem[j][i].extend([[a,[],item[2]] for _ in range(int(item[0])-1)])
		
		mem[j][i].extend([[0,[],"0"] for _ in range(len(mem[j][i]),local_end)])
		mem[j][i].extend([[0,["CRIGHT_OUT","CLEFT_OUT"],"0"],[0,["CRIGHT_IN","CLEFT_IN"],"0"],[0,["SHARED_OUT"],"0"],[0,["SHARED_IN"],"0"]])
		
		mem_text = []
		for k,item in enumerate(mem[j][i]):
			#print item
			mem_text.append( str(item[0])+"\t#"+str(item[2])+"\t@"+str(k)+"\t"+":\t".join(item[1]+[""]) )
		file.write("\n".join(mem_text))
		file.close()

		mem_text = []
		for k,item in enumerate(mem[j][i]):
			#print item
			mem_text.append( format(item[0]&0xffffffff,"08X") )
		file2.write("\n".join(mem_text))
		file2.close()
#print mem

if len(argvs)!=3 or argvs[2]!="-e":
	sys.exit(0)


go = True
flags = [] # in flags True: have data , False: no data
flags_c = [] # 0, 1
pc = []

i=0
a = []
b = []
mem_a = []
mem_b = []
c = []
d = []
res = []
stage=[]
cycle = 0
stall = []

shared_count = 0
shared_count_read = 0
shared_count_write = 0
shared_debug = [[[],[],[],[]],[[],[],[],[]]]
c_shared_debug = [[],[]]
# cluster
for cluster in range(clusters):
	flags.append([False]*core_per_cluster)
	flags_c.append([False,False])
	pc.append([0]*core_per_cluster)
	a.append([0]*core_per_cluster)
	b.append([0]*core_per_cluster)
	mem_a.append([0]*core_per_cluster)
	mem_b.append([0]*core_per_cluster)
	c.append([0]*core_per_cluster)
	d.append([0]*core_per_cluster)
	res.append([0]*core_per_cluster)
	stage.append([1]*core_per_cluster)
	stall.append([0]*core_per_cluster)

shared_access_more_than_two = 0
shared_access_more_than_one_read = 0
shared_access_more_than_one_write = 0
try:
	while True:
		cycle += 1
		shared_access_count1 = 0
		shared_access_count2 = 0
		cluster = 0
		for cluster in range(clusters):
			#stage1
			core = i%4
			will_stall = False
			core_flag = False
			c_l_flag = False
			c_r_flag = False
			if pc[cluster][core] < 0:
				stage[cluster][core] = 0
			if stage[cluster][core] != 1:
				stall[cluster][core] += 1
			while stage[cluster][core]==1:
				a[cluster][core] = mem[cluster][core][pc[cluster][core]][0]
				b[cluster][core] = mem[cluster][core][pc[cluster][core]+1][0]
				if a[cluster][core] == shared_in_addr or b[cluster][core] == shared_in_addr:
					if flags[cluster][core]:
						core_flag = True
					else:
						# again
						will_stall = True
				
				if a[cluster][core] == cluster_shared_left_in_addr or b[cluster][core] == cluster_shared_left_in_addr:
					if flags_c[cluster][0]:
						c_l_flag = True
					else:
						# again
						will_stall = True
				if cluster_shared_right_in_addr!=cluster_shared_left_in_addr and (a[cluster][core] == cluster_shared_right_in_addr or b[cluster][core] == cluster_shared_right_in_addr):
					if flags_c[cluster][1]:
						c_r_flag = True
					else:
						# again
						will_stall = True	
				if will_stall:
					stall[cluster][core] += 1
					break
				if core_flag:
					flags[cluster][core]=False
				if c_l_flag:
					#if cluster==1 : print "c_l", mem[cluster][core][cluster_shared_left_in_addr][0], pc
					flags_c[cluster][0]=False
				if c_r_flag:
					#print "c_r", mem[cluster][core][cluster_shared_left_in_addr][0]
					flags_c[cluster][1]=False
				stage[cluster][core]=2
				break

			#stage2
			core = (i-1)%4
			if stage[cluster][core] != 2:
				stall[cluster][core] += 1
			if stage[cluster][core]==2:
				count = 0
				if a[cluster][core] < shared_start:
					mem_a[cluster][core] = mem[cluster][core][a[cluster][core]][0]
				else:
					mem_a[cluster][core] = mem_shared[a[cluster][core] - shared_start][0]
					count += 1
					shared_access_count1 += 1

				if b[cluster][core] < shared_start:
					mem_b[cluster][core] = mem[cluster][core][b[cluster][core]][0]
				else:
					mem_b[cluster][core] = mem_shared[b[cluster][core] - shared_start][0]
					count += 1
					shared_access_count1 += 1
				if count > 1:
					print "WARNING: more than one access to shared memory"
				stage[cluster][core] = 3
				shared_count += count
				shared_count_read += count
			#stage3
			core = (i-2)%4
			if stage[cluster][core] != 3:
				stall[cluster][core] += 1
			while stage[cluster][core]==3:
				res[cluster][core] = (mem_b[cluster][core] - mem_a[cluster][core])&0xffffffff
				if res[cluster][core] > 0x7fffffff:
					res[cluster][core] = res[cluster][core] - 0x100000000

				c[cluster][core] = mem[cluster][core][pc[cluster][core]+2][0]
				d[cluster][core] = mem[cluster][core][pc[cluster][core]+3][0]

				if c[cluster][core] == shared_out_addr:
					if not flags[cluster][(core+1)%core_per_cluster]:
						flags[cluster][(core+1)%core_per_cluster] = True
						mem[cluster][(core+1)%core_per_cluster][shared_in_addr][0] = res[cluster][core]
						shared_debug[cluster][core].append(res[cluster][core])
					else:
						stage[cluster][core] = 3
						stall[cluster][core] += 1
						break
				elif c[cluster][core] == cluster_shared_left_out_addr:
					if not flags_c[(cluster+1)%clusters][0]:
						flags_c[(cluster+1)%clusters][0] = True
						for j in range(core_per_cluster):
							mem[(cluster+1)%clusters][j][cluster_shared_right_in_addr][0] = res[cluster][core]
						c_shared_debug[cluster].append(res[cluster][core])
					else:
						stage[cluster][core] = 3
						stall[cluster][core] += 1
						break
				elif c[cluster][core] == cluster_shared_right_out_addr:
					if not flags_c[(cluster+1)%clusters][1]:
						flags_c[(cluster+1)%clusters][1] = True
						for j in range(core_per_cluster):
							mem[(cluster+1)%clusters][j][cluster_shared_left_in_addr][0] = res[cluster][core]
						c_shared_debug[cluster].append(res[cluster][core])
					else:
						stage[cluster][core] = 3
						stall[cluster][core] += 1
						break
				stage[cluster][core] = 4
				break
			#stage4
			core = (i-3)%4
			if stage[cluster][core] != 4:
				stall[cluster][core] += 1
			if stage[cluster][core]==4:
				
				if c[cluster][core] < shared_start:
					mem[cluster][core][c[cluster][core]][0] = res[cluster][core]
				else:
					mem_shared[c[cluster][core] - shared_start][0] = res[cluster][core]
					shared_count += 1
					shared_count_write += 1
					shared_access_count2 += 1
					print c[cluster][core], res[cluster][core]

				if res[cluster][core] < 0:
					pc[cluster][core] = d[cluster][core]
				else:
					pc[cluster][core] += 4

				if pc[cluster][core] < 0:
					stage[cluster][core] = 0
				else:
					stage[cluster][core] = 1
		if (shared_access_count1 > 1):
			shared_access_more_than_one_read += 1
		if (shared_access_count2 > 2):
			shared_access_more_than_one_write += 1
		if (shared_access_count1 + shared_access_count2 > 2):
			shared_access_more_than_two += 1
		i += 1
		#print i, a[0][1],b[0][1],c[0][1],mem_a[0][1],mem_b[0][1],res[0][1],pc,flags,stage[0][1]
		#if i == 130000: break
		if max(sum(pc,[])) < 0:
			break
		if max(sum(stage,[])) == 0:
			print "stage break"
			break


except KeyboardInterrupt:
	print "cycle:", i
	print "a:", a
	print "b:", b
	print "c:", c
	print "mem_a:", mem_a
	print "mem_b:", mem_b
	print "res:", res
	print "pc:", pc
	print "flags:", flags
	print "flags_bt_clusters:", flags_c
	print "stage:", stage
except IndexError:
	print "cycle:", i
	print "a:", a
	print "b:", b
	print "c:", c
	print "mem_a:", mem_a
	print "mem_b:", mem_b
	print "res:", res
	print "pc:", pc
	print "flags:", flags
	print "flags_bt_clusters:", flags_c
	print "stage:", stage
finally:
	print "cycle:", i
	print "stall:", stall
	print "Access on shared", shared_count
	print "More than 2 Access on shared:", shared_access_more_than_two
	print "More than 1 write on shared:", shared_access_more_than_one_write
	print "More than 1 read on shared:", shared_access_more_than_one_read
	print "shared_write:", shared_count_write, "shared_read:", shared_count_read
	for c in range(clusters):
		for k in range(core_per_cluster):
			print "//////////////////", c, k, "//////////////////"
			for j in shared_debug[c][k]:
				print j
		print "////////////////// cluster", c, "//////////////////"
		for j in c_shared_debug[c]:
			print j
	for k,x in enumerate(mem_shared):
		print k,":",x[0]