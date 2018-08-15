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

f = open(argvs[1],"r")
lines = re.sub(p1 ,"" ,f.read()).split("\n")
f.close()


mem_dict = {
	# "label" : ["where? prog or data", index]
}
prog_mem = []
data_mem = []
block_mem = []

namespace = []

connect = ""
for l in lines:
	m = re.match(p7, l)
	if m != None:
		#print m.groups()
		block_mem.append(m.groups())
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
	
	l = re.sub(p1 ,"" ,l) # remove all occurance streamed comments (/*COMMENT */) from string
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
		continue
	items = re.split(p6, l)
	if len(items) == 3:
		items.append("NEXT")
	elif len(items) == 1:
		s = re.split(p5,items[0])
		index = len(data_mem)
		if s[-1][0] == "&":
			data_mem.append(["ptr","%".join(namespace+[s[-1][1:]]),["%".join(namespace+[x]) for x in s[:-1]]])
		else:
			data_mem.append(["data",int(s[-1]),["%".join(namespace+[x]) for x in s[:-1]]])
		for label in s[:-1]:
			name = "%".join(namespace+[label])
			if name in mem_dict:
				print "ERROR !! label used", '"',name,'"'
			mem_dict[name] = ["data",index]
		continue

	if len(items) != 4:
		print "PROGRAM ERROR"
		print l
		sys.exit()
	for i in range(4):
		s = re.split(p5,items[i])
		index = len(prog_mem)
		if s[-1][0] == "@":
			prog_mem.append(["data",int(s[-1][1:]),["%".join(namespace+[x]) for x in s[:-1]]])
		elif s[-1] in ["NEXT","HALT"]:
			prog_mem.append(["ptr",s[-1],["%".join(namespace+[x]) for x in s[:-1]]])	
		else:
			prog_mem.append(["ptr","%".join(namespace+[s[-1]]),["%".join(namespace+[x]) for x in s[:-1]]])
		for label in s[:-1]:
			name = "%".join(namespace+[label])
			if name in mem_dict:
				print "ERROR !! label used", '"',name,'"'
			mem_dict[name] = ["prog",index]



	#print items

print prog_mem, data_mem
file = open(argvs[1]+".mem","w")

mem = []
prog_mem_len = len(prog_mem)
data_mem_len = len(data_mem)
print prog_mem_len, data_mem_len
c = 0
for item in block_mem:
	mem_dict[item[1]] = ["block", c]
	c += int(item[0])
for item in prog_mem + data_mem:
	if item[0] == "data":
		mem.append([item[1],item[2],item[1]])
	elif item[0] == "ptr":
		if item[1] == "NEXT":
			mem.append([len(mem)+1,[],"NEXT"])
			continue
		if item[1] == "HALT":
			mem.append([-1,[],"HALT"])
			continue
		#print item
		
		if item[1] not in mem_dict:
			split = item[1].split("%")

			for i in range(1,len(split)):
				name = "%".join(split[:-i]+[split[-1]])

				if name in mem_dict:
					item[1] = name
					break
			if item[1] not in mem_dict:
				print "[warning]",item[1],"is not in memory"
				mem_dict[item[1]] = ["prog",0]
		d = mem_dict[item[1]]
		if d[0] == "prog":
			mem.append([d[1],item[2],item[1]])
		elif d[0] == "data":
			mem.append([d[1]+prog_mem_len,item[2],item[1]])
		elif d[0] == 'block':
			mem.append([d[1]+prog_mem_len+data_mem_len,item[2],item[1]])
		else:
			print d[0]
for item in block_mem:
	a = int(item[2])
	mem.append([a,[item[1]],item[2]])
	mem.extend([[a,[],item[2]] for _ in range(int(item[0])-1)])
mem_text = []
for i,item in enumerate(mem):
	#print item
	mem_text.append( str(item[0])+"\t#"+str(item[2])+"\t@"+str(i)+"\t"+":\t".join(item[1]+[""]) )
file.write("\n".join(mem_text))
file.close()
