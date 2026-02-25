// Tower of Hanoi: count number of moves for n disks
// hanoi(n) = 2^n - 1 moves
int move_count;

int hanoi(int n, int from, int to, int aux) {
    if (n == 1) {
        move_count = move_count + 1;
        return 0;
    }
    hanoi(n - 1, from, aux, to);
    move_count = move_count + 1;
    hanoi(n - 1, aux, to, from);
    return 0;
}

int main() {
    move_count = 0;
    hanoi(4, 1, 3, 2);  // 2^4 - 1 = 15 moves
    return move_count;   // expected: 15
}
