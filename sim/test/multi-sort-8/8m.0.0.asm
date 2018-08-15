// core 1 AB

// in shared:
// data-0, data-200

C_A: -200
C_B: -200
temp: 0

A: 0
B: 0

0: 0
-1:-1

0, data-0, A

B_changed:
0, POINTER_2: data-200, B
B, A, temp, output_A  // temp = A - B, if temp < 0 (B>A): A change, output A
output_B:
0, B, SHARED_OUT
// p++
-1, POINTER_2, POINTER_2
// c++ goto B_changed
INC, C_B, C_B, B_changed

// B finished
// send all A

B_finished:

0, A, SHARED_OUT
-1, POINTER_1, POINTER_1_FIN
INC, C_A, C_A, B_finished_iter
0, -1, -1, HALT

B_finished_iter:
0, POINTER_1_FIN: 0, SHARED_OUT
-1, POINTER_1_FIN, POINTER_1_FIN
INC, C_A, C_A, B_finished_iter

0, -1, -1, HALT




A_changed:
0, POINTER_1: data-0, A
A, B, temp, output_B

output_A:
0, A, SHARED_OUT
// p++
-1, POINTER_1, POINTER_1
// c++ goto A_changed
INC, C_A, C_A, A_changed

// A finished
// send all B

A_finished:

0, B, SHARED_OUT
-1, POINTER_2, POINTER_2_FIN
INC, C_B, C_B, A_finished_iter
0, -1, -1, HALT

A_finished_iter:
0, POINTER_2_FIN: 0, SHARED_OUT
-1, POINTER_2_FIN, POINTER_2_FIN
INC, C_B, C_B, A_finished_iter

0, -1, -1, HALT





