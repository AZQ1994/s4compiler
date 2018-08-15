// core 3 ABCD

// in shared:
// RES_0
// SHARED_IN->

count: -800
AB: 0
CD: 0
temp: 0

0: 0
-1: -1


LOOP:
0, SHARED_IN, WRITE :RES_0
-1, WRITE, WRITE
-1, count, count, LOOP

0, -1, -1, HALT







