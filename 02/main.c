#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef enum
{
    OPCODE_ADD = 1,
    OPCODE_MULTIPLY,
    OPCODE_HALT = 99,
} Opcode;

typedef struct
{
    long* init_source;
    long* source;
    size_t len;
    size_t pos;
    bool is_halt;
} Machine;

Machine machine_from_string(const char* string)
{
    size_t source_len = 1;
    const char* ptr = string;
    while (*ptr)
    {
        if (*ptr++ == ',')
        {
            ++source_len;
        }
    }

    long* source = malloc(sizeof(long) * source_len);
    long* init_source = malloc(sizeof(long) * source_len);

    ptr = string;
    size_t idx = 0;
    while (*ptr)
    {
        while (*ptr != ',' && *ptr != '\0') { ++ptr; }
        if (*ptr == '\0')
        {
            break;
        }
        source[idx++] = strtol(string, (char**)&ptr, 10);
        string = ++ptr;
    }

    memcpy(init_source, source, sizeof(long) * source_len);

    return (Machine){init_source, source, .len = source_len, .pos = 0, .is_halt = false};
}

void reset_machine(Machine* machine)
{
    memcpy(machine->source, machine->init_source, sizeof(long) * machine->len);
    machine->pos = 0;
    machine->is_halt = false;
}

void free_machine(Machine* machine)
{
    if (!machine) return;

    free(machine->init_source);
    free(machine->source);
}

void dump_machine(const Machine* machine)
{
    if (!machine) return;

    printf("[ ");
    for (size_t i = 0; i < machine->len; ++i)
    {
        if (i == machine->pos)
        {
            printf("\x1b[30;107m%ld\x1b[0m ", machine->source[i]);
        }
        else
        {
            printf("%ld ", machine->source[i]);
        }
    }
    printf("]\n");
}

bool run_machine_once(Machine* mach)
{
    int store_pos;
    size_t pos1, pos2;
    switch (mach->source[mach->pos])
    {
    case OPCODE_ADD:
        store_pos = mach->source[mach->pos + 3];
        pos1 = mach->source[mach->pos + 1];
        pos2 = mach->source[mach->pos + 2];
        mach->source[store_pos] = mach->source[pos1] + mach->source[pos2];
        mach->pos += 4;
        break;

    case OPCODE_MULTIPLY:
        store_pos = mach->source[mach->pos + 3];
        pos1 = mach->source[mach->pos + 1];
        pos2 = mach->source[mach->pos + 2];
        mach->source[store_pos] = mach->source[pos1] * mach->source[pos2];
        mach->pos += 4;
        break;

    case OPCODE_HALT:
        mach->is_halt = true;
        break;

    default:
        return false;
    }

    return true;
}

bool run_machine(Machine* mach)
{
    while (!mach->is_halt)
    {
        if (!run_machine_once(mach))
        {
            return false;
        }
    }

    return true;
}

long solve1(const char* source)
{
    long output;
    Machine machine = machine_from_string(source);

    // Initial Values
    machine.source[1] = 12;
    machine.source[2] = 2;

    if (!run_machine(&machine))
    {
        return -1;
    }

    output = machine.source[0];
    free_machine(&machine);

    return output;
}

int solve2(const char* source)
{
    Machine machine = machine_from_string(source);

    for (int noun = 0; noun < 100; ++noun)
    {
        for (int verb = 0; verb < 100; ++verb)
        {
            reset_machine(&machine);
            machine.source[1] = noun;
            machine.source[2] = verb;

            if (!run_machine(&machine))
            {
                return -1;
            }

            if (machine.source[0] == 19690720)
            {
                free_machine(&machine);
                return 100 * noun + verb;
            }
        }
    }

    free_machine(&machine);
    return -2;
}

int main(void)
{
    FILE* fs = fopen("./input.txt", "rb");
    fseek(fs, 0, SEEK_END);
    long len = ftell(fs);
    rewind(fs);

    char* source = malloc(len + 1);
    fread(source, 1, len, fs);
    source[len] = '\0';

    printf("Answer1: %ld\n", solve1(source));
    printf("Answer2: %d\n", solve2(source));

    free(source);
    fclose(fs);
    return 0;
}
