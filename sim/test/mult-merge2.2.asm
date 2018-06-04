// core 1: AB
// core 2: CD
// core 3: ABCD
// core 4: WRITE

-10000: -10000

0, -10000, C1
0, -10000, C2

L0: FLAG1, -1, temp, L0
0, OUTPUT1, A
0, 0, FLAG1
-1 ,C1, C1
-1 ,C1, C1
-1 ,C2, C2

B_changed:

FLAG2, -1, temp, B_changed
0, OUTPUT2, B
0, 0, FLAG2

A, B, temp, L_B_A

0, A, SHARED_OUT
0, -1, temp, A_changed_fin

L_B_A:
0, B, SHARED_OUT

B_changed_fin:
-1 ,C2, C2, B_changed
0, -1, temp, B_FINISHED



A_changed:
FLAG1, -1, temp, A_changed
0, OUTPUT1, A
0, 0, FLAG1

B, A, temp, L_A_B

0, B, SHARED_OUT
0, -1, temp, B_changed_fin

L_A_B:
0, A, SHARED_OUT

A_changed_fin:
-1 ,C1, C1, A_changed




A_FINISHED:
FLAG2, -1, temp, A_FINISHED
0, OUTPUT2, SHARED_OUT
0, 0, FLAG2
-1 ,C2, C2, A_FINISHED
0, -1, temp, HALT

B_FINISHED:
FLAG1, -1, temp, B_FINISHED
0, OUTPUT1, SHARED_OUT
0, 0, FLAG1
-1 ,C1, C1, B_FINISHED
0, -1, temp, HALT

A:0
B:0
C1:0
C2:0

-1: -1
0: 0
1: 1
temp: 0


