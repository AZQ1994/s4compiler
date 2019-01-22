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
print commands.getoutput("clang --target=ppc32 -S -emit-llvm -O3 -o %s.ll %s "%(filename,argvs[1]))
print commands.getoutput("clang --target=ppc32 -c -emit-llvm -O3 -o %s.bc %s "%(filename,argvs[1]))
print commands.getoutput("clang --target=ppc32 -S -emit-llvm -O0 -o %s.o0.ll %s "%(filename,argvs[1]))
print commands.getoutput("clang --target=ppc32 -c -emit-llvm -O0 -o %s.o0.bc %s "%(filename,argvs[1]))
print commands.getoutput("clang --target=ppc32 -S -emit-llvm -O2 -o %s.o2.ll %s "%(filename,argvs[1]))
print commands.getoutput("clang --target=ppc32 -c -emit-llvm -O2 -o %s.o2.bc %s "%(filename,argvs[1]))
#o2 = commands.getoutput("%s/../../reader %s.bc"%(path,filename))
#o0 = commands.getoutput("%s/../../reader %s.o0.bc"%(path,filename))
#o3 = commands.getoutput("%s/../../reader %s.o3.bc"%(path,filename))




o2xml = commands.getoutput("%s/../../output %s.bc"%(path,filename))
o0xml = commands.getoutput("%s/../../output %s.o0.bc"%(path,filename))
o3xml = commands.getoutput("%s/../../output %s.o2.bc"%(path,filename))

#f2 = open("%s.parse"%filename,"w")
#f0 = open("%s.o0.parse"%filename,"w")
f2xml = open("%s.xml"%filename,"w")
f0xml = open("%s.o0.xml"%filename,"w")
f3xml = open("%s.o2.xml"%filename,"w")
#print o2xml
#f2.write(o2)
#f2.close()
#f0.write(o0)
#f0.close()
f2xml.write(o2xml)
f2xml.close()
f0xml.write(o0xml)
f0xml.close()
f3xml.write(o3xml)
f3xml.close()

#print commands.getoutput("opt -reg2mem -o %s.a.bc %s.bc "%(filename,filename))
#print commands.getoutput("opt -reg2mem -S -o %s.a.ll %s.bc "%(filename,filename))

#o2axml = commands.getoutput("%s/../../output %s.a.bc"%(path,filename))
#f2axml = open("%s.a.xml"%filename,"w")
#f2axml.write(o2axml)
#f2axml.close()
