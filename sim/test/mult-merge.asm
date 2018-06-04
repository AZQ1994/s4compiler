
// CORE 1

// A    B
// OP1, OP2
OP1: 0
OP2: 0

// default
0, A_NOW, READ_01
0, READ_01: 0, OP1

// b_changed
B_CHANGED:
0, B_NOW, READ_02
0, READ_02: 0, OP2

OP1, OP2, temp, L_2 // if op2 - op1 < 0 : goto L
// op1 < op2
L_1:
0, OP1, AB
-1, A_NOW, A_NOW
goto L_Achanged_got


// op1 > op2
L_2:
0, OP2, AB
-1, B_NOW, B_NOW


L_Bchanged_got:
CD, AB, temp, B_CHANGED

L_CD:
0, WRITE, WRITE_CD
0, CD, WRITE_AB: 0
-1, WRITE, WRITE
//***** need check another pair of cores
goto L_got







// a_changed
A_CHANGED:
0, A_NOW, READ_01
0, READ_01: 0, OP1

/*
OP1, OP2, temp, L_2 // if op2 - op1 < 0 : goto L
// op1 < op2
L_1:
0, OP1, AB
-1, A_NOW, A_NOW
goto L_Achanged_got
// next = A_CHANGED

// op1 > op2
L_2:
0, OP2, AB
-1, B_NOW, B_NOW
// next = B_CHANGED
*/

OP2, OP1, temp, L_21
// op1 > op2
L_22:
0, OP2, AB
-1, B_NOW, B_NOW
// next = B_CHANGED
goto L_Bchanged_got

// op1 < op2
L_21:
0, OP1, AB
-1, A_NOW, A_NOW


L_Achanged_got:
CD, AB, temp, A_CHANGED
L_CD:
0, WRITE, WRITE_AB
0, CD, WRITE_AB: 0
-1, WRITE, WRITE
//***** need check another pair of cores
//***** need check 
goto L_got