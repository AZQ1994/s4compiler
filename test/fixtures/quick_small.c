int data[5] = {50, 20, 40, 10, 30};

int quick(int left, int right) {
    if (left >= right)
        return 0;

    int pivot = data[right];
    int l_cursor = left;
    int r_cursor = right;
    int temp;

    while (1) {
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
    quick(0, 4);
    // After sort: {10, 20, 30, 40, 50}
    // Return data[0] + data[4] = 10 + 50 = 60
    return data[0] + data[4];
}
