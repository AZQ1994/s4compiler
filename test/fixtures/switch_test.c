// Switch statement test
int classify(int x) {
    switch (x) {
        case 1: return 10;
        case 2: return 20;
        case 3: return 30;
        case 5: return 50;
        default: return -1;
    }
}

int main() {
    // classify(1) + classify(3) + classify(5) + classify(99)
    // = 10 + 30 + 50 + (-1) = 89
    return classify(1) + classify(3) + classify(5) + classify(99);
}
