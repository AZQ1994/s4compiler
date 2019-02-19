%{[quick]

//(SYS) start
L_7696545564944: data C_0 7696576223504 NEXT // 
//(SYS) call
L_7696545338320: C_0 sys_stack 7696545501072 NEXT // 
L_7696545338448: C_0 7696576221648 7696545501072: 0 NEXT // 
L_7696545338512: C_-1 sys_stack sys_stack NEXT // 
L_7696545562768: C_0 C_-1 temp_0 L_7696576276432 // 
L_7696576221456:
L_7696545563792: C_0 main _ret NEXT // 
L_7696545563856: C_0 C_-1 temp_0 HALT // 
L_7696576276240: // quick
//(SYS) function quick(left,right):
L_7696545841360: // entry
//(SYS) arg
//(SYS) arg
L_7696545843472: right left temp_0 L_7696545841744 // 
L_7696545564752: C_0 C_-1 temp_0 L_7696545844816 // 

L_7696545841744: // if.end.preheader

L_7696545842064: // if.end
L_7696545565136: 7696576223504 left arrayidx NEXT // 
L_7696545565264: C_0 arrayidx: 0 r-0 NEXT // 
L_7696545565392: C_0 left inc NEXT // 
L_7696545565584: C_0 right dec NEXT // 

L_7696545842448: // while.cond
L_7696545565776: C_0 inc l_cursor.1 NEXT // 

L_7696545842768: // while.cond1
L_7696545565968: 7696576223504 l_cursor.1 arrayidx2 NEXT // 
L_7696545566096: C_0 arrayidx2: 0 r-1 NEXT // 
L_7696545566288: C_-1 l_cursor.1 inc NEXT // 
L_7696545952464: r-0 r-1 temp_0 L_7696545953232 // 
L_7696545566544: C_0 C_-1 temp_0 L_7696545843024 // 
L_7696545953232:
L_7696545566672: C_0 inc l_cursor.1 NEXT // 
L_7696545702096: C_0 C_-1 temp_0 L_7696545842768 // 

L_7696545843024: // while.cond5.preheader
L_7696545702224: C_0 dec r_cursor.1 NEXT // 

L_7696545843344: // while.cond5
L_7696545702416: 7696576223504 r_cursor.1 arrayidx6 NEXT // 
L_7696545702544: C_0 arrayidx6: 0 r-2 NEXT // 
L_7696545702736: C_1 r_cursor.1 dec NEXT // 
L_7696545498064: r-2 r-0 temp_0 L_7696545498640 // 
L_7696545702992: C_0 C_-1 temp_0 L_7696545843600 // 
L_7696545498640:
L_7696545703120: C_0 dec r_cursor.1 NEXT // 
L_7696545703312: C_0 C_-1 temp_0 L_7696545843344 // 

L_7696545843600: // while.end9
L_7696545499472: r_cursor.1 l_cursor.1 temp_0 L_7696545843920 // 
L_7696545703504: C_0 C_-1 temp_0 L_7696545844304 // 

L_7696545843920: // if.end12
L_7696545703632: C_0 arrayidx2 7696545955280 NEXT // 
L_7696545703760: C_0 r-2 7696545955280: 0 NEXT // 
L_7696545703952: C_0 arrayidx6 7696545501136 NEXT // 
L_7696545704144: C_0 r-1 7696545501136: 0 NEXT // 
L_7696545704400: C_0 C_-1 temp_0 L_7696545842448 // 

L_7696545844304: // while.end19
L_7696545704592: C_1 l_cursor.1 sub NEXT // 
//(SYS) call
L_7696545338640: C_0 sys_stack 7696545704656 NEXT // 
L_7696545338768: C_0 r_cursor.1 7696545704656: 0 NEXT // 
L_7696545338832: C_-1 7696545704656 7696545705040 NEXT // 
L_7696545338960: C_0 right 7696545705040: 0 NEXT // 
L_7696545339024: C_-1 7696545705040 7696545705488 NEXT // 
L_7696545339152: C_0 7696576222736 7696545705488: 0 NEXT // 
L_7696545339216: C_-1 7696545705488 sys_stack NEXT // 
L_7696545259728: C_0 sub right NEXT // 
L_7696545259920: C_0 C_-1 temp_0 L_7696576276240 // 
L_7696576222544:
L_7696545260048: C_0 quick call NEXT // 
L_7696545339280: C_1 sys_stack 7696545260112 NEXT // 
L_7696545339408: C_0 7696545260112: 0 right NEXT // 
L_7696545339472: C_1 7696545260112 7696545260560 NEXT // 
L_7696545339600: C_0 7696545260560: 0 r_cursor.1 NEXT // 
L_7696545339728: C_0 7696545260560 sys_stack NEXT // 
L_7696545261264: C_-1 r_cursor.1 left NEXT // 
L_7696576274896: right left temp_0 L_7696545842064 // 

L_7696545844560: // return.loopexit

L_7696545844816: // return
L_7696545261328: C_0 C_0 quick NEXT // 
L_7696545339856: C_1 sys_stack sys_stack NEXT // 
L_7696545339984: C_0 sys_stack 7696576223632 NEXT // 
L_7696545340112: C_0 7696576223632: 0 7696576223696 NEXT // 
L_7696545262096: C_0 C_-1 temp_0 7696576223696: 0 // 


L_7696576276432: // main
//(SYS) function main():
L_7696545563536: // entry
//(SYS) call
L_7696545340240: C_0 sys_stack 7696576223888 NEXT // 
L_7696545340368: C_0 7696576224080 7696576223888: 0 NEXT // 
L_7696545340432: C_-1 sys_stack sys_stack NEXT // 
L_7696545262800: C_0 C_0 left NEXT // 
L_7696545262928: C_0 C_4999 right NEXT // 
L_7696545263120: C_0 C_-1 temp_0 L_7696576276240 // 
L_7696576224016: C_0 C_0 C_0


//(SYS) end
dec: 0
cmp3: 0
data: &f_f_data-0
cmp44: 0
7696576224080: &L_7696576224016
C_0: 0
cmp7: 0
left.tr45: 0
l_cursor.1: 0
sys_stack: &stack_start2
add: 0
quick: 0
cmp: 0
temp_0: 0
7696576223504: 0
r_cursor.1: 0
call: 0
r_cursor.0: 0
r-1: 0
r-2: 0
right: 0
_ret: 0
C_1: 1
C_-1: -1
left: 0
r-0: 0
cmp10: 0
7696576222736: &L_7696576222544
C_4999: 4999
l_cursor.0: 0
7696576221648: &L_7696576221456
inc: 0
call: 0
sub: 0
main: 0



}%

0: 0
MERGE_1:
0, 0, SHARED_OUT
0, SHARED_IN, SHARED_OUT

%{[merge-1]

// merge from two side

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
0, -1, temp, MERGE_2



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
0, -1, temp, MERGE_2

A:0
B:0

-1: -1
0: 0
1: 1
temp: 0

}%

MERGE_2:
0, 0, SHARED_OUT
0, SHARED_IN, SHARED_OUT


%{[merge-2]
-10000: -10000
bp1: &buf1_start
C: -10000

0, bp1, A_POINTER
-10000, bp1, B_POINTER


0, A_POINTER, READ_A_1
0, READ_A_1:0, A


B_changed:
0, B_POINTER:0 , B

A, B, temp, L_B_A
0, A, SHARED_OUT
-1, A_POINTER, A_POINTER
-1, C, C, A_changed
0, -1, temp, HALT

L_B_A:
0, B, SHARED_OUT

B_changed_fin:
-1, B_POINTER, B_POINTER
-1, C, C, B_changed
0, -1, temp, HALT



A_changed:
0, A_POINTER:0 , A

B, A, temp, L_A_B
0, B, SHARED_OUT
-1, B_POINTER, B_POINTER
-1, C, C, B_changed
0, -1, temp, HALT

L_A_B:
0, A, SHARED_OUT

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
}%

#{100, stack_start2, 0}#
#{100, stack_start, 0}#