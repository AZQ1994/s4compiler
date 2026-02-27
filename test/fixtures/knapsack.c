// 0/1 Knapsack: 6 items, capacity 15
// Optimal: items 0,1,2,4,5 → weight 2+3+5+1+4=15, value 10+5+15+6+18=54
int weights[6] = {2, 3, 5, 7, 1, 4};
int values[6]  = {10, 5, 15, 7, 6, 18};

int main() {
    int dp[16]; // capacity 0..15
    int i, w, take;

    for (w = 0; w < 16; w++) {
        dp[w] = 0;
    }

    for (i = 0; i < 6; i++) {
        for (w = 15; w >= weights[i]; w--) {
            take = dp[w - weights[i]] + values[i];
            if (take > dp[w]) {
                dp[w] = take;
            }
        }
    }

    return dp[15]; // 54
}
