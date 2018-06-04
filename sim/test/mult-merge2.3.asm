// core 1: AB
// core 2: CD
// core 3: ABCD
// core 4: WRITE

start: &write_start

C:-20000
0, start, WRITE

L0:
0, SHARED_IN, WRITE: 0
-1, WRITE, WRITE
-1, C, C, L0
0, -1, temp, HALT


-1: -1
0: 0
1: 1
temp: 0