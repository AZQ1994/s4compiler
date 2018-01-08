int arr[5] = {1,2,3,4,5};
int test(){
  int i;
  int* p = arr;
  for(i=0;i<5;i++){
    *p += 1;
    p++;
  }
  return 0;
}
