%{[quick]
SIZE:625	
INPUT_REF:&f_f_data-3125		      

left:0
right:0
	
stack:&stack_start

Z: 0
DEC: 1
INC: -1

HALT_ref:&MERGE_1
	
Z,stack,stack_p	// stack pointer
Z,HALT_ref,stack_p:stack // return address = HALT
DEC,stack,stack	      // stack --

Z,Z,left	//left = 0
DEC,SIZE,right	//right = size - 1 
Z,INC,INC,quick	//goto quick

	

return_left_ref:&return_left 
return_right_ref:&return_right 
	
pivot:0
loop_count:0
temp:0
last:0		

quick:
Z,left,last
	//
left,right,loop_count,stack_pop
DEC,loop_count,loop_count,stack_pop
	//

loop_count,INC,loop_count
	
left,Z,temp
temp,INPUT_REF,pivot_ref
Z,pivot_ref,pivot_ref1  
Z,pivot_ref:temp,pivot  	
	
INC,pivot_ref,cmp0
Z,cmp0,cmp1
Z,cmp0,cmp2
	
Z,pivot_ref,last0 
Z,last0,last1
Z,last0,last2
Z,last0,last3
	
loop:
cmp0:temp,pivot,temp,cmp_bigger_than_pivot
INC,last,last			
INC,last0,last0
INC,last1,last1
INC,last2,last2
INC,last3,last3
	
Z,cmp1:temp,temp
Z,last0:temp,cmp2:temp
Z,temp,last1:temp	   

cmp_bigger_than_pivot:
INC,cmp0,cmp0
INC,cmp1,cmp1
INC,cmp2,cmp2

INC,loop_count,loop_count,loop
	//sng4 Z,INC,INC,loop		  

end:
Z,last2:temp,pivot_ref1:temp
Z,pivot,last3:temp	   

stack_push:
	//push right->last->return
Z,stack,stack_p0
Z,right,stack_p0:stack
	
DEC,stack_p0,stack_p1
Z,last,stack_p1:stack

DEC,stack_p1,stack_p2
Z,return_left_ref,stack_p2:stack

DEC,stack_p2,stack
	//finish push
	
//Z,left,left
DEC,last,right
Z,INC,INC,quick //quick(data,left,last-1)
	
return_left:
	//push right->last->return
Z,stack,stack_p3
Z,right,stack_p3:stack
	
DEC,stack_p3,stack_p4
Z,last,stack_p4:stack

DEC,stack_p4,stack_p5
Z,return_right_ref,stack_p5:stack

DEC,stack_p5,stack
	//finsih push
	
INC,last,left
//Z,right,right
Z,INC,INC,quick //quick(data,last+1,right)		

return_right:
stack_pop:
	//pop return -> last -> right
INC,stack,stack_p6
Z,stack_p6:stack,return_address

INC,stack_p6,stack_p7
Z,stack_p7:stack,last

INC,stack_p7,stack_p8
Z,stack_p8:stack,right

Z,stack_p8,stack

Z,INC,INC,return_address:HALT



}%


0: 0
MERGE_1:
0, SHARED_IN, SHARED_OUT
0, SHARED_IN, SHARED_OUT

%{[merge-1]

-3124: -3124
-3749:-3749
buf1_offset2: -1249

bp1: &buf3_start
data_start: &INPUT
C: -625

-3124, data_start, A_POINTER
-3749, data_start, B_POINTER


0, A_POINTER, READ_A_1
0, READ_A_1:0, A


B_changed:
0, B_POINTER:0 , B

B, A, temp, L_B_A
buf1_offset2, bp1, W1
0, A, W1:0
-1, buf1_offset2, buf1_offset2, A_changed_fin

L_B_A:
buf1_offset2, bp1, W2
0, B, W2:0
-1, buf1_offset2, buf1_offset2

B_changed_fin:
1, B_POINTER, B_POINTER
-1, C, C, B_changed
0, -1, temp, MERGE_2



A_changed:
0, A_POINTER:0 , A

A, B, temp, L_A_B
buf1_offset2, bp1, W3
0, B, W3:0
-1, buf1_offset2, buf1_offset2, B_changed_fin

L_A_B:
buf1_offset2, bp1, W4
0, A, W4:0
-1, buf1_offset2, buf1_offset2

A_changed_fin:
1, A_POINTER, A_POINTER
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
0, SHARED_IN, SHARED_OUT
0, SHARED_IN, SHARED_OUT
0, SHARED_IN, SHARED_OUT

%{[merge-2]
// core 2 C->(A) D->(B)

// in shared:
// DATA_0, DATA_1, DATA_n

C_A: -1250
C_B: -1250
temp: 0

A: 0
B: 0

0: 0
-1:-1

0, buf-2500, A

B_changed:
0, POINTER_2: buf-3750, B
B, A, temp, output_A  // temp = A - B, if temp < 0 (B>A): A change, output A
output_B:
0, B, CRIGHT_OUT
// p++
-1, POINTER_2, POINTER_2
// c++ goto B_changed
INC, C_B, C_B, B_changed

// B finished
// send all A

B_finished:

0, A, CRIGHT_OUT
-1, POINTER_1, POINTER_1_FIN
INC, C_A, C_A, B_finished_iter
0, -1, -1, HALT

B_finished_iter:
0, POINTER_1_FIN: 0, CRIGHT_OUT
-1, POINTER_1_FIN, POINTER_1_FIN
INC, C_A, C_A, B_finished_iter

0, -1, -1, HALT




A_changed:
0, POINTER_1: buf-2500, A
A, B, temp, output_B

output_A:
0, A, CRIGHT_OUT
// p++
-1, POINTER_1, POINTER_1
// c++ goto A_changed
INC, C_A, C_A, A_changed

// A finished
// send all B

A_finished:

0, B, CRIGHT_OUT
-1, POINTER_2, POINTER_2_FIN
INC, C_B, C_B, A_finished_iter
0, -1, -1, HALT

A_finished_iter:
0, POINTER_2_FIN: 0, CRIGHT_OUT
-1, POINTER_2_FIN, POINTER_2_FIN
INC, C_B, C_B, A_finished_iter

0, -1, -1, HALT
}%

#{300, stack_start2, 0}#
#{1, stack_start, 0}#