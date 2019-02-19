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
interval: 1

temp: 0
c: 0

// caculation
length1, 0, m_length1
length2, 0, m_length2
0, 0, column

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
line, trans_addr, TRANS_ADDR
0, TRANS_ADDR: trans, top

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
line, trans_addr, TRANS_ADDR2
0, left, TRANS_ADDR2: trans

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
// trans: 000000
trans: 1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
31
32
33
34
35
36
37
38
39
40
41
42
43
44
45
46
47
48
49
50
51
52
53
54
55
56
57
58
59
60
61
62
63
64
65
66
67
68
69
70
71
72
73
74
75
76
77
78
79
80
81
82
83
84
85
86
87
88
89
90
91
92
93
94
95
96
97
98
99
100
101
102
103
104
105
106
107
108
109
110
111
112
113
114
115
116
117
118
119
120
121
122
123
124
125
126
127
128