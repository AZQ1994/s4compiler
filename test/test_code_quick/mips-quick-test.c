//#include<stdio.h>

#define SIZE 20

int data[20]={23002, 13359, 11466, 64118, 32403, 44024, 63253, 51654, 60960, 45232, 28137, 40242, 27545, 10747, 18543, 32541, 9632, 59878, 43528, 6841};

int quick(int left,int right){
  
    int pivot = data[left];
    int i,temp;
    int last=left;
    
    if(left - right >= 0){
        return 0;
    }
    i = left+1;
    while(i - right <= 0){
      if(data[i] - pivot < 0){
        last++;
        temp = data[i];
        data[i] = data[last];
        data[last] = temp;
      }
      i++;
    }
    /*for(i=left+1;i<=right;i++){
        if(data[i] < pivot){
            last++;
            temp = data[i];
            data[i] = data[last];
            data[last] = temp;
        }
    }*/

    temp = data[left];
    data[left] = data[last];
    data[last] = temp;

    quick(left,last-1);
    quick(last+1,right);
    return 0;
    
}

int main(){
  
  quick(0,SIZE-1);
  /*int i;
  for (i = 0; i < SIZE; i++){
  	printf("%d\n",data[i]);
  }*/
  return 0;

}
