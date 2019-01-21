int upto = 25;
int data[10] = {1,2,3,4,5,6,7,8,9,10};
int main(void){
	int i=0, result = 0;
	while(result < upto){
		result += data[i++];
	}
	return result;
}
