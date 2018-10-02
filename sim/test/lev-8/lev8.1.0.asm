// This is the program for levenshtein distance

// Variables
left: 0
left_top: 0
top: 0
top_p1: 0

// index
column: 0
line: 0

// temp
char1: 0
char2: 0

str1_end_addr: 0
str2_end_addr: 0
trans_end_addr: 0

m_length1: 0
m_length2: 0

// const
0: 0
-1: -1
1: 1
4: 4
interval: 8

temp: 0
c: 0

// caculation
length1, 0, m_length1
length2, 0, m_length2
4, 0, column

LOOP0_START:
/*
 * This is for each loop of column
 */
// left = 0
0, 0, line
column, 1, left
column, 0, top
// char1
column, str1_addr, CHAR1_ADDR
0, CHAR1_ADDR: str1, char1

LOOP_START:
// Loop {
// prep
0, top, left_top
// read
line, str2_addr, CHAR2_ADDR
0, CHAR2_ADDR: str2, char2

// read trans

0, CLEFT_IN, top

-1, left, left
-1, top, top_p1

// comp
char1, char2, temp, NEQ
char2, char1, temp, NEQ
0, -1, temp, WO3
NEQ:
-1, left_top, left_top
WO3:
// worst of 3
top_p1, left_top, temp, L0
// top_p1 <= left_top
top_p1, left, temp, L2
// 
0, top_p1, left
0, -1, temp, L2
// left_top < top
L0: left_top, left, temp, L2
0, left_top, left

L2: // left < left_top or left < top

0, left, SHARED_OUT

-1, c, c

1, line, line
line, m_length2, temp, LOOP_START
// }

interval, column, column
column, m_length1, temp, LOOP0_START
/*
 * End
 */
0, -1, temp, HALT

// arguments
length1: 128
length2: 128
// str1: kitten__
str1:
107
105
116
116
101
110
0
0
107
105
116
116
101
110
0
0
107
105
116
116
101
110
0
0
107
105
116
116
101
110
0
0
107
105
116
116
101
110
0
0
107
105
116
116
101
110
0
0
107
105
116
116
101
110
0
0
107
105
116
116
101
110
0
0
107
105
116
116
101
110
0
0
107
105
116
116
101
110
0
0
107
105
116
116
101
110
0
0
107
105
116
116
101
110
0
0
107
105
116
116
101
110
0
0
107
105
116
116
101
110
0
0
107
105
116
116
101
110
0
0
107
105
116
116
101
110
0
0
str1_addr: &str1
// str2: sitting_
str2:
115
105
116
116
105
110
103
0
115
105
116
116
105
110
103
0
115
105
116
116
105
110
103
0
115
105
116
116
105
110
103
0
115
105
116
116
105
110
103
0
115
105
116
116
105
110
103
0
115
105
116
116
105
110
103
0
115
105
116
116
105
110
103
0
115
105
116
116
105
110
103
0
115
105
116
116
105
110
103
0
115
105
116
116
105
110
103
0
115
105
116
116
105
110
103
0
115
105
116
116
105
110
103
0
115
105
116
116
105
110
103
0
115
105
116
116
105
110
103
0
115
105
116
116
105
110
103
0
str2_addr: &str2

trans_addr: &trans
