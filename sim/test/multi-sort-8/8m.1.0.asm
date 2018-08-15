// core 3 ABCD

// in shared:
// res-0
// SHARED_IN->

count: -400
AB: 0
CD: 0
temp: 0

0: 0
-1: -1
1: 1

LOOP:
0, SHARED_IN, WRITE :res-799
1, WRITE, WRITE
-1, count, count, LOOP

0, -1, -1, HALT







