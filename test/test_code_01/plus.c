#include <stdio.h>
int plus(int a){
	int res = 0;
	for (int i = 0; i < a; ++i)
	{
		res += i;
	}
	return res;
}
int main(){
	printf("%d",plus(100));
	return 0;
}