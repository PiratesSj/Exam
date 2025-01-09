[09/01, 15:33] Sj: #include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <semaphore.h>
#include <fcntl.h>
#include <math.h>

// Function to check if a number is prime
int isPrime(int n) {
    if (n <= 1) return 0;
    for (int i = 2; i <= sqrt(n); i++) {
        if (n % i == 0) return 0;
    }
    return 1;
}

// Function to print primes in a range
void printPrimes(int start, int end, sem_t *sem_current, sem_t *sem_next) {
    sem_wait(sem_current); // Wait for semaphore
    printf("Primes in range %d-%d:\n", start, end);
    for (int i = start; i <= end; i++) {
        if (isPrime(i)) {
            printf("%d ", i);
        }
    }
    printf("\n");
    sem_post(sem_next); // Signal the next process
    exit(0);
}

int main() {
    // Create named semaphores
    sem_t *sem1 = sem_open("/sem1", O_CREAT | O_EXCL, 0644, 1);
    sem_t *sem2 = sem_open("/sem2", O_CREAT | O_EXCL, 0644, 0);
    sem_t *sem3 = sem_open("/sem3", O_CREAT | O_EXCL, 0644, 0);

    if (fork() == 0) {
        printPrimes(1, 100, sem1, sem2);
    }

    if (fork() == 0) {
        printPrimes(101, 200, sem2, sem3);
    }

    if (fork() == 0) {
        printPrimes(201, 300, sem3, sem1);
    }

    // Parent process waits for all children
    wait(NULL);
    wait(NULL);
    wait(NULL);

    // Clean up semaphores
    sem_unlink("/sem1");
    sem_unlink("/sem2");
    sem_unlink("/sem3");

    sem_close(sem1);
    sem_close(sem2);
    sem_close(sem3);

    return 0;
}
[09/01, 15:33] Sj: #include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>

int main() {
    pid_t pid;
    int numbers[5], i, sum = 0;

    // Parent Process
    pid = fork();

    if (pid > 0) {
        // Parent writes to file
        FILE *file = fopen("data.txt", "w");
        if (file == NULL) {
            printf("Error opening file!\n");
            exit(1);
        }

        printf("Enter 5 integers: ");
        for (i = 0; i < 5; i++) {
            scanf("%d", &numbers[i]);
            fprintf(file, "%d\n", numbers[i]);
        }

        fclose(file);
        wait(NULL); // Wait for child to complete
    } 

    else if (pid == 0) {
        // Child reads from file
        FILE *file = fopen("data.txt", "r");
        if (file == NULL) {
            printf("Error opening file!\n");
            exit(1);
        }

        printf("Numbers read from file:\n");
        while (fscanf(file, "%d", &i) != EOF) {
            printf("%d ", i);
            sum += i;
        }

        printf("\nSum = %d\n", sum);
        fclose(file);
    } 

    else {
        printf("Fork failed!\n");
    }

    return 0;
}
[09/01, 15:33] Sj: #include <stdio.h>

int main() {
    int amount, i;
    int denominations[] = {2000, 500, 200, 100, 50, 20, 10, 5, 2, 1};
    int count[10] = {0}; // To store count of each denomination

    // Input withdrawal amount
    printf("Enter the amount to withdraw: ");
    scanf("%d", &amount);

    int total = amount;

    // Calculate the count of notes/coins
    for (i = 0; i < 10; i++) {
        if (amount >= denominations[i]) {
            count[i] = amount / denominations[i];
            amount %= denominations[i];
        }
    }

    // Display results
    printf("\nDenomination   Count   Total\n");
    printf("----------------------------\n");

    for (i = 0; i < 10; i++) {
        if (count[i] > 0) {
            printf("%d            %3d     %d\n", denominations[i], count[i], denominations[i] * count[i]);
        }
    }

    printf("----------------------------\n");
    printf("Sum: %d\n", total);

    return 0;
}