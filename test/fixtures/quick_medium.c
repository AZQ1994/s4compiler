int data[20] = {85, 24, 63, 45, 17, 31, 96, 50, 78, 12, 67, 39, 54, 88, 21, 73, 42, 60, 35, 9};

int quick(int left, int right)
{
    if (left >= right)
        return 0;

    int pivotIdx = left;
    int pivot = data[pivotIdx];

    int l_cursor = left;
    int r_cursor = right;
    int temp;
    while (1)
    {
        while (data[l_cursor] < pivot)
            l_cursor++;
        while (data[r_cursor] > pivot)
            r_cursor--;
        if (l_cursor >= r_cursor)
            break;
        temp = data[l_cursor];
        data[l_cursor] = data[r_cursor];
        data[r_cursor] = temp;
        l_cursor++;
        r_cursor--;
    }

    quick(left, l_cursor - 1);
    quick(r_cursor + 1, right);
    return 0;
}

int main() {
    quick(0, 19);
    // After sort: {9,12,17,21,24,31,35,39,42,45,50,54,60,63,67,73,78,85,88,96}
    // data[0]=9, data[19]=96 → 9+96=105
    return data[0] + data[19];
}
