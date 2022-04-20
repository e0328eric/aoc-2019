#include <stdio.h>
#include <stdlib.h>

int solve1(const char* fuel)
{
    return atoi(fuel) / 3 - 2;
}

int solve2(const char* fuel)
{
    int init_fuel = atoi(fuel);
    int output = 0;

    while (init_fuel > 0)
    {
        init_fuel = init_fuel / 3 - 2;
        init_fuel = (init_fuel > 0) * init_fuel;
        output += init_fuel;
    }

    return output;
}

int main(void)
{
    FILE* fs = fopen("./input.txt", "rb");

    char* source = NULL;
    size_t len;

    int answer1 = 0, answer2 = 0;
    while (getline(&source, &len, fs) >= 0)
    {
        answer1 += solve1(source);
        answer2 += solve2(source);
    }

    printf("Answer1: %d\n", answer1);
    printf("Answer2: %d\n", answer2);

    fclose(fs);
    return 0;
}
