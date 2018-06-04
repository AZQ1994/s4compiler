

// calculate finish address
data_each, 0, temp, NEXT
temp, data_start, data_finish_local, NEXT
0, data_start, data_start_local

// transfer finish
0, data_finish_local, SHARED_OUT

//////////////////


0, dis_list_base, dis_list_now, NEXT

0, 1, distance, NEXT

// goto Lstart
data_each, distance, temp, Lstart_core



Lcores:
0, dis_list_now, dis_list_pointer

cores_dis: 0
Lcores_start:
0, dis_list_pointer, cores_READ
cores_READ: 0, 0, -dis_now

0, data_start, start
distance, 0, c, NEXT

//while: start-all < 0
Lcores_while:
0, -dis_now, i
-core_start, start, s, NEXT

Lcores_block1:
Lcores_comp1:
0, s, cores_LOAD_A
0, cores_LOAD_A: 0, A
-dis_now, s, cores_LOAD_B
cores_LOAD_B: 0, A, temp, Lcores_comp1_fin
0, s, cores_STORE_A
-dis_now, s, cores_LOAD_B2
0, cores_LOAD_B2:0, cores_STORE_A:0
-dis_now, s, cores_STORE_B
0, A, cores_STORE_B:0

Lcores_comp1_fin:
-4, s, s
-4, i, i, Lcores_block1

Lcores_block1_fin:
-dis_now, c, c, Lcores_next
distance, 0, c, Lcores_next2

Lcores_next:
-dis_now, start, start
-dis_now, start, start
data_finish, start, temp, Lcores_while
0, -1, temp, Lcores_while_fin


Lcores_while2:
0, -dis_now, i
-core_start, start, s, NEXT

Lcores_block2:
Lcores_comp2:
0, s, cores_LOAD2_A
0, cores_LOAD2_A: 0, A
-dis_now, s, cores_LOAD2_B
A, cores_LOAD2_B: 0, temp, Lcores_comp2_fin
0, s, cores_STORE2_A
-dis_now, s, cores_LOAD2_B2
0, cores_LOAD2_B2:0, cores_STORE2_A:0
-dis_now, s, cores_STORE2_B
0, A, cores_STORE2_B:0

Lcores_comp2_fin:

-4, s, s
-4, i, i, Lcores_block2

Lcores_block2_fin:
-dis_now, c, c, Lcores_next2
distance, 0, c, Lcores_next

Lcores_next2:
-dis_now, start, start
-dis_now, start, start
data_finish, start, temp, Lcores_while2


Lcores_while_fin:
0, 0, SHARED_OUT
0, SHARED_IN, SHARED_OUT
1, dis_list_pointer, dis_list_pointer, NEXT
-dis_now, 0, temp
temp, data_each, temp, Lcores_start

//0, 1, direction
0, -1, temp, Lfor_start


Lstart_core: // for starting from the very beginning
// while distance < local_all: distance - local_all < 0

// for d in dis_list:
0, dis_list_now, dis_list_pointer, NEXT


Lfor_start:
dis_list_base, dis_list_pointer, temp, Lfor_end
// read from dis_list
0, dis_list_pointer, dis_READ, NEXT
dis_READ:0, 0, -dis_now, NEXT

0, data_start_local, start
distance, 0, c, NEXT

0, direction, temp, Lwhile2

//while: start-all < 0
Lwhile:
0, -dis_now, i
0, start, s, NEXT

Lblock1:
Lcomp1:
0, s, LOAD_A
0, LOAD_A: 0, A
-dis_now, s, LOAD_B
LOAD_B: 0, A, temp, Lcomp1_fin
0, s, STORE_A
-dis_now, s, LOAD_B2
0, LOAD_B2:0, STORE_A:0
-dis_now, s, STORE_B
0, A, STORE_B:0

Lcomp1_fin:
-1, s, s
-1, i, i, Lblock1

Lblock1_fin:
-dis_now, c, c, Lnext
distance, 0, c, Lnext2

Lnext:
-dis_now, start, start
-dis_now, start, start
data_finish_local, start, temp, Lwhile
0, -1, temp, Lwhile_fin


Lwhile2:
0, -dis_now, i
0, start, s, NEXT

Lblock2:
Lcomp2:
0, s, LOAD2_A
0, LOAD2_A: 0, A
-dis_now, s, LOAD2_B
A, LOAD2_B: 0, temp, Lcomp2_fin
0, s, STORE2_A
-dis_now, s, LOAD2_B2
0, LOAD2_B2:0, STORE2_A:0
-dis_now, s, STORE2_B
0, A, STORE2_B:0

Lcomp2_fin:

-1, s, s
-1, i, i, Lblock2

Lblock2_fin:
-dis_now, c, c, Lnext2
distance, 0, c, Lnext

Lnext2:
-dis_now, start, start
-dis_now, start, start
data_finish_local, start, temp, Lwhile2


Lwhile_fin:
1, dis_list_pointer, dis_list_pointer, NEXT
0, -1, temp, Lfor_start
Lfor_end:!!!
// distance *= 2
distance, 0, temp, NEXT
temp, distance, distance, NEXT
// push
-1, dis_list_now, dis_list_now
0, dis_list_now, dis_list_STORE, NEXT
0, distance, dis_list_STORE:0, NEXT
!!!
data_each, distance, temp, Lstart_core


////////////////////
Lfin: 0, 0, SHARED_OUT
0, SHARED_IN, SHARED_OUT
////////////////////
// Lfin: 0, SHARED_IN, SHARED_OUT
// 0, SHARED_IN, SHARED_OUT

data_len, distance, temp, Lcores

0, -1, temp, HALT


1: 1
-1: -1
0: 0
temp: 0
-4:-4

// comp
A: 0
B: 0

// index for block
i: 0
s: 0

// counter for direction
c: 0
direction: 1

distance: 1
-dis_now: 0


dis_list_base: &dis_list
dis_list_pointer: &dis_list
dis_list_now: &dis_list
dis_list: 1
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0

start: &data

data_finish_local: &data_last
-core_start: 0
data_start_local: &data