#include <stdio.h>

int main(void){
  int data[128] = {0};
  int i = 0, j = 0;
  int size = 128;
  int str1[128] = {107,105,116,116,101,110,0,0,107,105,116,116,101,110,0,0,107,105,116,116,101,110,0,0,107,105,116,116,101,110,0,0,107,105,116,116,101,110,0,0,107,105,116,116,101,110,0,0,107,105,116,116,101,110,0,0,107,105,116,116,101,110,0,0,107,105,116,116,101,110,0,0,107,105,116,116,101,110,0,0,107,105,116,116,101,110,0,0,107,105,116,116,101,110,0,0,107,105,116,116,101,110,0,0,107,105,116,116,101,110,0,0,107,105,116,116,101,110,0,0,107,105,116,116,101,110,0,0
};
  int str2[128] = {115,105,116,116,105,110,103,0,115,105,116,116,105,110,103,0,115,105,116,116,105,110,103,0,115,105,116,116,105,110,103,0,115,105,116,116,105,110,103,0,115,105,116,116,105,110,103,0,115,105,116,116,105,110,103,0,115,105,116,116,105,110,103,0,115,105,116,116,105,110,103,0,115,105,116,116,105,110,103,0,115,105,116,116,105,110,103,0,115,105,116,116,105,110,103,0,115,105,116,116,105,110,103,0,115,105,116,116,105,110,103,0,115,105,116,116,105,110,103,0,115,105,116,116,105,110,103,0
};
  int left = 0;
  int left_top = 0;
  int temp;
  while(i < size){
    data[i] = i+1;
    i++;
  }
  j = 0;
  while(j<size){
    left_top = j;
    left = j+1;
    for(i=0;i<size;i++){
      if(str1[i]==str2[j]){
        if(left_top <= left){
          if(data[i]+1 < left_top){
            left_top = data[i];
            left = data[i]+1;
            data[i] = left;
          }else{ // left_top is min
            left = left_top;
            left_top = data[i];
            data[i] = left;
          }
        }else{ // left
          if(data[i] < left){
            left = data[i]+1;
            left_top = data[i];
            data[i] = left;
          }else{ // left is min
            left = left+1;
            left_top = data[i];
            data[i] = left;
          }
        }
      }else{
        if(left_top <= left){
          if(data[i] < left_top){
            left_top = data[i];
            left = data[i]+1;
            data[i] = left;
          }else{ // left_top is min
            left = left_top+1;
            left_top = data[i];
            data[i] = left;
          }
        }else{ // left
          if(data[i] < left){
            left = data[i]+1;
            left_top = data[i];
            data[i] = left;
          }else{ // left is min
            left = left+1;
            left_top = data[i];
            data[i] = left;
          }
        }
      }
    }
    for(i=0;i<size;i++){
      printf("%d ",data[i]);
    }
    printf("\n");
    j++;
  }
  return 0;
}
