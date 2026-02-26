// N-Queens: count all solutions for 8-queens problem
// Expected: 92
#define N 8

int safe(int *board, int row, int col) {
    int i, diff;
    for (i = 0; i < row; i++) {
        if (board[i] == col) return 0;
        diff = row - i;
        if (board[i] - col == diff) return 0;
        if (col - board[i] == diff) return 0;
    }
    return 1;
}

int solve(int *board, int row) {
    int col, total;
    if (row == N) return 1;
    total = 0;
    for (col = 0; col < N; col++) {
        if (safe(board, row, col)) {
            board[row] = col;
            total = total + solve(board, row + 1);
        }
    }
    return total;
}

int main() {
    int board[N];
    return solve(board, 0); // 92
}
