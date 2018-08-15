// core 2 AB->(A) CD->(B)

// in shared:
// DATA_0, DATA_1, DATA_n
// SHARED_IN1->AB, SHARED_IN2->CD
C_AB: -200
C_CD: -200
count: -400
AB: 0
CD: 0
temp: 0

0: 0
-1: -1
-1000000: -1000000

0, SHARED_IN1, AB

CD_changed:
0, SHARED_IN2, CD
CD, AB, temp, output_AB  // temp = AB - CD, if temp < 0 (CD>AB): AB change, output CD
output_CD:
0, CD, SHARED_OUT
// c++ goto CD_changed
//-1, C_CD, C_CD, CD_changed
INC, count, count, CD_changed

/*
// CD finished
// send all AB

CD_finished:

0, AB, SHARED_OUT
-1, C_AB, C_AB, CD_finished_iter
0, -1, -1, HALT

CD_finished_iter:
0, SHARED_IN1, SHARED_OUT
-1, C_AB, C_AB, CD_finished_iter
*/
0, -1000000, INC
0, SHARED_IN1, temp
0, SHARED_IN2, temp
0, SHARED_IN2, temp
0, -1, -1, HALT




AB_changed:
0, SHARED_IN1, AB
AB, CD, temp, output_CD  // temp = CD - AB, if temp < 0 (AB>CD): CD change, output AB
output_AB:
0, AB, SHARED_OUT
// c++ goto AB_changed
// -1, C_AB, C_AB, AB_changed
-1, count, count, AB_changed
/*
// AB finished
// send all CD

AB_finished:

0, CD, SHARED_OUT
-1, C_CD, C_CD, AB_finished_iter
0, -1, -1, HALT

AB_finished_iter:
0, SHARED_IN1, SHARED_OUT
-1, C_CD, C_CD, AB_finished_iter
*/
0, -1000000, INC
0, SHARED_IN1, temp
0, SHARED_IN1, temp
0, SHARED_IN2, temp
0, -1, -1, HALT





