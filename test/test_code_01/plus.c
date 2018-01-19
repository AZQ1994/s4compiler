
int plus(int a){
	int res = 0;
	for (int i = 0; a >= i; ++i)
	{
		res += i;
	}
	return res;
}
int main(){
	plus(100);
	return 0;
}