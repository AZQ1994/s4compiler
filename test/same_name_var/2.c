int a = 1;
int b = 2;
int c;
int main(void){
	int i;
	i = a;
	{
	int i;
	i = b;
	}
	
	c = i + a;
	return i;
}
