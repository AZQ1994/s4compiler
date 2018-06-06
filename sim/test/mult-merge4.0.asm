// core 1: AB CD
// core 2: AB CD

-5000: -5000
-10000: -10000
buf1: &data//&buf1_start
bp1: &write_start

C: -5000//-10000

temp : 0
-1 : -1
1: 1
0: 0

0, buf1, A_POINTER
// read from buf1

NEW_A:
0 ,A_POINTER: 0, SHARED_OUT
-1, A_POINTER, A_POINTER

// wait B
0, SHARED_OUT, SHARED_OUT
COMP:
SHARED_OUT, B_12, temp, L_B_less
L_A_less:
// new A

// count
-1, C, C, NEW_A
0, -1, temp, HALT

L_B_less:
// WRITE B
write_offset1, bp1, W01
0, B_12, W01: 0
// count
-1, C, C, skip1
0, -1, temp, HALT
skip1: 1, write_offset1, write_offset1, COMP

