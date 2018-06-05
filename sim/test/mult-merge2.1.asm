// core 1: AB
// core 2: CD
// core 3: ABCD
// core 4: WRITE

-5000: -5000
-10000: -10000
-10000, data_start, A_POINTER
-5000, A_POINTER, A_FINISH_POINTER
0, A_FINISH_POINTER, B_POINTER
-5000, B_POINTER, B_FINISH_POINTER

0, A_POINTER, READ_A_1
0, READ_A_1:0, A


B_changed:
0, B_POINTER:0 , B

A, B, temp, L_B_A
L_A1:0, FLAG2, temp, L_A1
0, A, OUTPUT2
0, -1, FLAG2, A_changed_fin

L_B_A:
L_B1:0, FLAG2, temp, L_B1
0, B, OUTPUT2
0, -1, FLAG2

B_changed_fin:
-1, B_POINTER, B_POINTER
B_FINISH_POINTER ,B_POINTER, temp, B_changed
0, -1, temp, B_FINISHED



A_changed:
0, A_POINTER:0 , A

B, A, temp, L_A_B
L_B2:0, FLAG2, temp, L_B2
0, B, OUTPUT2
0, -1, FLAG2, B_changed_fin

L_A_B:
L_A2:0, FLAG2, temp, L_A2
0, A, OUTPUT2
0, -1, FLAG2

A_changed_fin:
-1, A_POINTER, A_POINTER
A_FINISH_POINTER ,A_POINTER, temp, A_changed
0, -1, temp, A_FINISHED



A_FINISHED:
0, B_POINTER, READ_B_5
L_B3:0, FLAG2, temp, L_B3
0, READ_B_5: 0, OUTPUT2
0, -1, FLAG2
-1, B_POINTER, B_POINTER
B_FINISH_POINTER ,B_POINTER, temp, A_FINISHED
0, -1, temp, HALT

B_FINISHED:
0, A_POINTER, READ_A_5
L_A3:0, FLAG2, temp, L_A3
0, READ_A_5: 0, OUTPUT2
0, -1, FLAG2
-1, A_POINTER, A_POINTER
A_FINISH_POINTER ,A_POINTER, temp, B_FINISHED
0, -1, temp, HALT

A_FINISH_POINTER:0
B_FINISH_POINTER:0
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