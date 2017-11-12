#include <stdio.h>
int fib(int a){
  switch(a){
  case 0: return 0;
  case 1: return 1;
  default: return fib(a-2)+fib(a-1);
  }
}

int main(void){
  int a = 10;
  printf("%d\n", fib(a));
  return 0;
}
