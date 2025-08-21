#include <stdio.h>

int reverseNumber(int n) {
    // TODO
    int reversednum = 0;
    while(n > 0) {
        int d = n % 10;
        reversednum = reversednum * 10 + d;
        n = n / 10;
    }
    return reversednum;
}

int main() {
    int n;
    printf("Enter a number: ");
    scanf("%d", &n);

    int result = reverseNumber(n);
    printf("Reversed number: %d\n", result);

    return 0;
}
