int data[128] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127};
int main(void){
  int i = 0, j = 0;
  int size = 128;
  int str1[128] = {107,105,116,116,101,110,0,0,107,105,116,116,101,110,0,0,107,105,116,116,101,110,0,0,107,105,116,116,101,110,0,0,107,105,116,116,101,110,0,0,107,105,116,116,101,110,0,0,107,105,116,116,101,110,0,0,107,105,116,116,101,110,0,0,107,105,116,116,101,110,0,0,107,105,116,116,101,110,0,0,107,105,116,116,101,110,0,0,107,105,116,116,101,110,0,0,107,105,116,116,101,110,0,0,107,105,116,116,101,110,0,0,107,105,116,116,101,110,0,0,107,105,116,116,101,110,0,0
};
  int str2[128] = {115,105,116,116,105,110,103,0,115,105,116,116,105,110,103,0,115,105,116,116,105,110,103,0,115,105,116,116,105,110,103,0,115,105,116,116,105,110,103,0,115,105,116,116,105,110,103,0,115,105,116,116,105,110,103,0,115,105,116,116,105,110,103,0,115,105,116,116,105,110,103,0,115,105,116,116,105,110,103,0,115,105,116,116,105,110,103,0,115,105,116,116,105,110,103,0,115,105,116,116,105,110,103,0,115,105,116,116,105,110,103,0,115,105,116,116,105,110,103,0,115,105,116,116,105,110,103,0
};
  int left = 0;
  int left_top = 0;
  int temp;
  /*while(i < size){
    data[i] = i+1;
    i++;
  }*/
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
    j++;
  }
  return 0;
}
