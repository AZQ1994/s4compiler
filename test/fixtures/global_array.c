int data[5] = {50, 20, 40, 10, 30};

int sum_array(int n) {
    int s = 0;
    int i;
    for (i = 0; i < n; i++) {
        s = s + data[i];
    }
    return s;
}

int main() {
    return sum_array(5);  // 50+20+40+10+30 = 150
}
