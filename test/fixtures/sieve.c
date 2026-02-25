// Count primes up to 30 using Sieve of Eratosthenes
// Primes up to 30: 2,3,5,7,11,13,17,19,23,29 = 10 primes
int main() {
    int is_prime[31]; // 0..30
    int i;
    int j;

    // Initialize: all are prime candidates
    for (i = 0; i < 31; i++) {
        is_prime[i] = 1;
    }
    is_prime[0] = 0;
    is_prime[1] = 0;

    // Sieve
    for (i = 2; i < 6; i++) { // sqrt(30) < 6
        if (is_prime[i]) {
            for (j = i * i; j < 31; j = j + i) {
                is_prime[j] = 0;
            }
        }
    }

    // Count primes
    int count = 0;
    for (i = 2; i < 31; i++) {
        if (is_prime[i]) {
            count = count + 1;
        }
    }
    return count; // expected: 10
}
