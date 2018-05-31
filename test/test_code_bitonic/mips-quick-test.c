//#include<stdio.h>

#define SIZE 16

int a[16]={23002, 13359, 11466, 64118, 32403, 44024, 63253, 51654, 60960, 45232, 28137, 40242, 27545, 10747, 18543, 32541};

void compAndSwap(int a[], int i, int j, int dir)
{
    
}
 
/*It recursively sorts a bitonic sequence in ascending order,
  if dir = 1, and in descending order otherwise (means dir=0).
  The sequence to be sorted starts at index position low,
  the parameter cnt is the number of elements to be sorted.*/
void bitonicMerge(int low, int cnt, int dir)
{
    if (cnt>1)
    {
        int k = cnt/2;
        for (int i=low; i<low+k; i++)
        	int j = i+k;
            if (dir==(a[i]>a[j]))
        		swap(a[i],a[j]);
        bitonicMerge(a, low, k, dir);
        bitonicMerge(a, low+k, k, dir);
    }
}
 
/* This function first produces a bitonic sequence by recursively
    sorting its two halves in opposite sorting orders, and then
    calls bitonicMerge to make them in the same order */
void bitonicSort(int a[],int low, int cnt, int dir)
{
    if (cnt>1)
    {
        int k = cnt/2;
 
        // sort in ascending order since dir here is 1
        bitonicSort(low, k, 1);
 
        // sort in descending order since dir here is 0
        bitonicSort(low+k, k, 0);
 
        // Will merge wole sequence in ascending order
        // since dir=1.
        bitonicMerge(low, cnt, dir);
    }
}


// Driver code
int main()
{
    int up = 1;   // means sort in ascending order
    bitonicSort(0, N, up);
    return 0;
}
