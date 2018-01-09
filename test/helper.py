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
commands.getoutput("clang --target=nvptx -S -emit-llvm -O2 -o %s.ll %s "%(filename,argvs[1]))
commands.getoutput("clang --target=nvptx -c -emit-llvm -O2 -o %s.bc %s "%(filename,argvs[1]))
commands.getoutput("clang --target=nvptx -S -emit-llvm -O0 -o %s.o0.ll %s "%(filename,argvs[1]))
commands.getoutput("clang --target=nvptx -c -emit-llvm -O0 -o %s.o0.bc %s "%(filename,argvs[1]))
o2 = commands.getoutput("%s/../../reader %s.bc"%(path,filename))
o0 = commands.getoutput("%s/../../reader %s.o0.bc"%(path,filename))
o2xml = commands.getoutput("%s/../../output %s.bc"%(path,filename))
o0xml = commands.getoutput("%s/../../output %s.o0.bc"%(path,filename))

f2 = open("%s.parse"%filename,"w")
f0 = open("%s.o0.parse"%filename,"w")
f2xml = open("%s.xml"%filename,"w")
f0xml = open("%s.o0.xml"%filename,"w")
print o2
f2.write(o2)
f2.close()
f0.write(o0)
f0.close()
f2xml.write(o2xml)
f2xml.close()
f0xml.write(o0xml)
f0xml.close()