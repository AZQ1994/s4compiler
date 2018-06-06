#{5000, INPUT, 0}#
SIZE:20000
HALF_SIZE:10000
QUAD_SIZE:5000
INVQUAD_SIZE:15000
INPUT_REF:&INPUT
left:0
right:0

stack:&stack_start

#{1000, stack_start2, 0}#
#{1000, stack_start, 0}#
Z: 0
DEC: 1
INC: -1



	return_quick_ref:&return_quick 

//rx:0.5+0.25 tx:0.25	

rx_count:0
tx_count:0
temp:0
transfer:
	//sng4 DEC,QUAD_SIZE,rx_count 
	//sng4 DEC,QUAD_SIZE,tx_count	 
 QUAD_SIZE,Z,rx_count 
 QUAD_SIZE,Z,tx_count	 
 Z,INPUT_REF,transfer_address0 
tx_loop:
 Z,SHARED_IN,temp
 Z,temp,SHARED_OUT		  
	//sng4 DEC,tx_count,tx_count,tx_end 
	//sng4 Z,INC,INC,tx_loop		    
 INC,tx_count,tx_count,tx_loop 
tx_end:
rx_loop:
 Z,SHARED_IN,transfer_address0:temp 
	//sng4 DEC,rx_count,rx_count,rx_end    
 INC,transfer_address0,transfer_address0 
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


loop_count0:0 
marge:
	//sng4 DEC,QUAD_SIZE,loop_count0  //0.25 times
 QUAD_SIZE,Z,loop_count0  //0.25 times
 Z,INPUT_REF,transfer_address 
transfer_loop:
 Z,transfer_address:Z,SHARED_OUT 
	//sng4 DEC,loop_count0,loop_count0,end_transfer 
 INC,transfer_address,transfer_address  
	//sng4 Z,INC,INC,transfer_loop		    
 INC,loop_count0,loop_count0,transfer_loop 



 //tx,rx
tx_count1:0
temp:0
end_transfer:
	//sng4 DEC,HALF_SIZE,tx_count1 
 HALF_SIZE,Z,tx_count1 
tx_loop1:
 Z,SHARED_IN,temp	
 Z,temp,SHARED_OUT	
	//sng4 DEC,tx_count1,tx_count1,HALT 
	//sng4 Z,INC,INC,tx_loop1		
 INC,tx_count1,tx_count1,tx_loop1 


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
	

