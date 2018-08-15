import random
"""
data = range(800)

random.shuffle(data)

d1 = data[:200]
d2 = data[200:400]
d3 = data[400:600]
d4 = data[600:]
#print data
d1.sort()
d2.sort()
d3.sort()
d4.sort()

c = 0

for k, x in enumerate(d1+d2+d3+d4):
	print "data-"+str(k),":",x
for k in range(800):
	print "res-"+str(k),": 0"
"""
for k in range(20000):
	#print "buf-"+str(k),": 0"
	print "res-"+str(k),": 0"