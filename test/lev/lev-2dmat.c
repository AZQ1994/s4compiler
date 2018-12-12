//#include <stdio.h>
#define MIN3(a, b, c) ((a) < (b) ? ((a) < (c) ? (a) : (c)) : ((b) < (c) ? (b) : (c)))
int data[129][129] = {0};
int main(void){
  int i = 0, j = 0;
  int size = 128;
  char str1[128] = "kitten  kitten  kitten  kitten  kitten  kitten  kitten  kitten  kitten  kitten  kitten  kitten  kitten  kitten  kitten  kitten  ";
  char str2[128] = "sitting sitting sitting sitting sitting sitting sitting sitting sitting sitting sitting sitting sitting sitting sitting sitting ";
  int left = 0;
  int left_top = 0;
  int temp;
  for(i=0;i<=size;i++){
    data[i][0] = i;
    data[0][i] = i;
  }
  for(i=1;i<=size;i++){
    for(j=1;j<=size;j++){
      data[i][j] = MIN3(data[i-1][j] + 1, data[i][j-1] + 1, data[i-1][j-1] + (str1[j-1] == str2[i-1] ? 0 : 1));
    }
  }
  return 0;
}
