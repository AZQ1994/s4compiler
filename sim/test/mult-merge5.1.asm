// merge from two side

-5000: -5000
wp: &write_start
C: -5000



-1: -1
0: 0
1: 1
temp: 0

0, wp, W
write:
0, SHARED_IN, W: write_start
-1, W, W
-1, C, C, write
0, -1, temp, HALT