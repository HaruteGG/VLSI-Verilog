#include <stdio.h>
int mod_inverse(int a, int b) {
	// TODO 
    int m0 = b; // 儲存原始模數 b
    if (b <= 0) { // 模數必須為正
        return -1; 
    }
    if (a == 0) { // 0 模 m 的反元素是未定義的 (除非 m=1)
        if (m0 == 1) return 0; // 0 * 0 = 0 = 1 (mod 1) 是空泛的真
        return -1;
    }
    a = a % m0;
    if (a < 0) {
        a += m0;
    }

    int s0 = 1, s1 = 0; // x 係數

    int cur_a = a;      // 歐幾里得演算法中的當前 'a'
    int cur_b = m0;     // 歐幾里得演算法中的當前 'b' (模數)

    while (cur_b != 0) {
        int quotient = cur_a / cur_b;

        int temp_r = cur_a % cur_b; // 計算餘數
        cur_a = cur_b;             // 新的 'a' 是舊的 'b'
        cur_b = temp_r;                // 新的 'b' 是餘數

        // 更新 s (x 係數)
        int temp_s = s0 - quotient * s1;
        s0 = s1; // 將 s1 移到 s0
        s1 = temp_s; // 新的 s 成為 s1

    }

    if (cur_a != 1) {
        return -1; // 模反元素不存在
    } else {
        return (s0 % m0 + m0) % m0;
    }
}

int main() {
    int a, b;
    printf("Enter the number: ");
    scanf("%d", &a);
    printf("Enter the modulo: ");
    scanf("%d", &b);

    int inv = mod_inverse(a, b);
    if (inv == -1) {
        printf("Inverse not exist.\n");
    } else {
        printf("Result: %d\n", inv);
    }

    return 0;
}
