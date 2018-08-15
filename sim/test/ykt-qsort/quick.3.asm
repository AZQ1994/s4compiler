
#{10000, RESULT, 0}#
#{5000, INPUT, 0}#

SIZE:5000
HALF_SIZE:2500
QUAD_SIZE:1250
INVQUAD_SIZE:3750
#{20000, RESULT2, 0}#

RESULT_REF:&RESULT
INPUT_REF:&INPUT
RESULT2_REF:&RESULT2
left:0
right:0


stack:&stack_start


#{1000, stack_start2, 0}#
#{1000, stack_start, 0}#
Z: 0
DEC: 1
INC: -1


	return_quick_ref:&return_quick 


rx_count:0
temp:0

	//sng4 DEC,QUAD_SIZE,rx_count 
 QUAD_SIZE,Z,rx_count	  
 Z,INPUT_REF,transfer_address 
rx_loop:
 Z,SHARED_IN,transfer_address:temp 
	//sng4 DEC,rx_count,rx_count,rx_end	     
 INC,transfer_address,transfer_address 
	//sng4 Z,INC,INC,rx_loop			   
 INC,rx_count,rx_count,rx_loop 
//rx_end:
	//sng4 Z,Z,Z		

	
	//quick sort	
 Z,stack,stack_p	
 Z,return_quick_ref,stack_p:stack 
 DEC,stack,stack	      
	
 Z,Z,left	
 DEC,QUAD_SIZE,right	
 Z,INC,INC,quick	

return_quick:	
 Z,Z,Z		


marge_temp:0
temp:0
input_count:0
marge_count:0

	//sng4 DEC,SIZE,loop_count 
// SIZE,Z,loop_count	
	
 Z,RESULT_REF,result_address00 
 Z,RESULT_REF,result_address10 
 Z,INPUT_REF,input_address00	 
 Z,INPUT_REF,input_address10  

	//sng4 DEC,HALF_SIZE,input_count 
	//sng4 DEC,HALF_SIZE,marge_count 
 QUAD_SIZE,Z,input_count 
 QUAD_SIZE,Z,marge_count 

	
receive_data:
 Z,SHARED_IN,marge_temp 
comp_data:
 marge_temp,input_address00:temp,temp,marge_temp_bigger0 

input_bigger: //marge -> result
 Z,marge_temp,result_address00:temp 
	//sng4 DEC,loop_count,loop_count,HALT    
 INC,result_address00,result_address00 
 INC,result_address10,result_address10 
	//sng4 DEC,marge_count,marge_count,all_marge_used0 
	//sng4 Z,INC,INC,receive_data	       
 INC,marge_count,marge_count,receive_data 
 Z,INC,INC,all_marge_used0		      
	
marge_temp_bigger0: //input -> result
 Z,input_address10:temp,result_address10:temp 
	//sng4 DEC,loop_count,loop_count,HALT		
 INC,result_address00,result_address00 
 INC,result_address10,result_address10 
 INC,input_address00,input_address00	 
 INC,input_address10,input_address10	 
	//sng4 DEC,input_count,input_count,all_input_used0	 
	//sng4 Z,INC,INC,comp_data		 
 INC,input_count,input_count,comp_data 
 Z,INC,INC,all_input_used0		   
	
all_input_used0:
 Z,result_address00,result_address30 
 Z,marge_temp,result_address30:temp 
 INC,marge_count,marge_count,next10 
 Z,INC,INC,marge2		       
next10:	
 INC,result_address30,result_address20 
all_input_used0_loop:
 Z,SHARED_IN,result_address20:temp 
	//sng4 DEC,loop_count,loop_count,HALT 
 INC,result_address20,result_address20 
 INC,marge_count,marge_count,all_input_used0_loop 
 Z,INC,INC,marge2				     
	//sng4 Z,INC,INC,all_input_used0_loop	 

all_marge_used0:
 Z,result_address00,result_address40 
 Z,input_address00,input_address30   
all_marge_used0_loop:
 Z,input_address30:temp,result_address40:temp 
	//sng4 DEC,loop_count,loop_count,HALT		
 INC,result_address40,result_address40	
 INC,input_address30,input_address30		
 INC,input_count,input_count,all_marge_used0_loop 
 Z,INC,INC,marge2				     
	//sng4 Z,INC,INC,all_marge_used0_loop		
	




	//.variable loop_count	
marge_temp:0
temp:0
input_count:0
marge_count:0
marge2:
	//sng4 DEC,SIZE,loop_count 
// SIZE,Z,loop_count	
	
 Z,RESULT_REF,result_address0 
 Z,RESULT_REF,result_address1 
 Z,INPUT_REF,input_address0	 
 Z,INPUT_REF,input_address1  

	//sng4 DEC,HALF_SIZE,input_count 
	//sng4 DEC,HALF_SIZE,marge_count 
 HALF_SIZE,Z,input_count 
 HALF_SIZE,Z,marge_count 

	
receive_data1:
 Z,SHARED_IN,marge_temp 
comp_data1:
 marge_temp,input_address0:temp,temp,marge_temp_bigger 

input_bigger1: //marge -> result
 Z,marge_temp,result_address0:temp 
	//sng4 DEC,loop_count,loop_count,HALT    
 INC,result_address0,result_address0 
 INC,result_address1,result_address1 
	//sng4 DEC,marge_count,marge_count,all_marge_used 
	//sng4 Z,INC,INC,receive_data1	       
 INC,marge_count,marge_count,receive_data1 
 Z,INC,INC,all_marge_used		      
	
marge_temp_bigger: //input -> result
 Z,input_address1:temp,result_address1:temp 
	//sng4 DEC,loop_count,loop_count,HALT		
 INC,result_address0,result_address0 
 INC,result_address1,result_address1 
 INC,input_address0,input_address0	 
 INC,input_address1,input_address1	 
	//sng4 DEC,input_count,input_count,all_input_used	 
	//sng4 Z,INC,INC,comp_data1		 
 INC,input_count,input_count,comp_data1 
 Z,INC,INC,all_input_used		   
	
all_input_used:
 Z,result_address0,result_address3 
 Z,marge_temp,result_address3:temp 
 INC,marge_count,marge_count,next1 
 Z,INC,INC,HALT		       
next1:	
 INC,result_address3,result_address2 
all_input_used_loop:
 Z,SHARED_IN,result_address2:temp 
	//sng4 DEC,loop_count,loop_count,HALT 
 INC,result_address2,result_address2 
 INC,marge_count,marge_count,all_input_used_loop 
 Z,INC,INC,HALT				     
	//sng4 Z,INC,INC,all_input_used_loop	 

all_marge_used:
 Z,result_address0,result_address4 
 Z,input_address0,input_address3   
all_marge_used_loop:
 Z,input_address3:temp,result_address4:temp 
	//sng4 DEC,loop_count,loop_count,HALT		
 INC,result_address4,result_address4	
 INC,input_address3,input_address3		
 INC,input_count,input_count,all_marge_used_loop 
 Z,INC,INC,HALT				     
	//sng4 Z,INC,INC,all_marge_used_loop		
	

	
	
HALT:
 Z,INC,INC,HALT 
	
	

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
	//sng4 DEC,loop_count,loop_count,end 
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
	
// Z,left,left	
 DEC,last,right	
 Z,INC,INC,quick	 //quick(data,left,last-1)
	
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
// Z,right,right	
 Z,INC,INC,quick	 //quick(data,last+1,right)		

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
	

