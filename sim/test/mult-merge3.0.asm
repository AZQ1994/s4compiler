// core 1: AB
// core 2: CD
// core 3: ABCD
// core 4: WRITE

-5000: -5000
bp1: &buf1_start
C: -5000

0, data_start, A_POINTER
-5000, data_start, B_POINTER


0, A_POINTER, READ_A_1
0, READ_A_1:0, A


B_changed:
0, B_POINTER:0 , B

A, B, temp, L_B_A
buf1_offset, bp1, W1
0, A, W1:0
1, buf1_offset, buf1_offset, A_changed_fin

L_B_A:
buf1_offset, bp1, W2
0, B, W2:0
1, buf1_offset, buf1_offset

B_changed_fin:
-1, B_POINTER, B_POINTER
-1, C, C, B_changed
0, -1, temp, HALT



A_changed:
0, A_POINTER:0 , A

B, A, temp, L_A_B
buf1_offset, bp1, W3
0, B, W3:0
1, buf1_offset, buf1_offset, B_changed_fin

L_A_B:
buf1_offset, bp1, W4
0, A, W4:0
1, buf1_offset, buf1_offset

A_changed_fin:
-1, A_POINTER, A_POINTER
-1, C, C, A_changed
0, -1, temp, HALT

A:0
B:0

-1: -1
0: 0
1: 1
temp: 0




/*

0, A_POINTER, READ_A_1
0, READ_A_1:0, A



B_changed:
0, B_POINTER, READ_B_2
0, READ_B_2:0 , B

A, B, temp, L_B_A
0, A, OUTPUT
0, -1, temp, A_changed_fin

L_B_A:
0, B, OUTPUT

B_changed_fin:
-1, B_POINTER, B_POINTER
B_FINISH_POINTER ,B_POINTER, temp, B_changed




A_changed:
0, A_POINTER, READ_A_2
0, READ_A_2:0 , A

B, A, temp, L_A_B

0, B, OUTPUT
0, -1, temp, B_changed_fin

L_A_B:
0, A, OUTPUT

A_changed_fin:
-1, A_POINTER, A_POINTER
A_FINISH_POINTER ,A_POINTER, temp, A_changed




A_FINISHED:
0, B_POINTER, READ_B_5
0, READ_B_5: 0, OUTPUT
-1, B_POINTER, B_POINTER
B_FINISH_POINTER ,B_POINTER, temp, A_FINISHED
0, -1, temp, HALT

B_FINISHED:
0, A_POINTER, READ_A_5
0, READ_A_5: 0, OUTPUT
-1, A_POINTER, A_POINTER
A_FINISH_POINTER ,A_POINTER, temp, B_FINISHED
0, -1, temp, HALT


*/