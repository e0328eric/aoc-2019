#include <limits.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#define MIN(x, y) (((x) < (y)) ? (x) : (y))
#define MAX(x, y) (((x) > (y)) ? (x) : (y))

typedef enum
{
    SEG_TYPE_HORIZONTAL,
    SEG_TYPE_VERTICAL,
} SegmentType;

typedef struct
{
    SegmentType type;
    int base_pos;
    int start;
    int end;
} Segment;

typedef struct
{
    Segment* inner;
    size_t len;
} SegmentArray;

typedef struct
{
    int x;
    int y;
} Point;

typedef struct
{
    Point* inner;
    size_t len;
} Path;

typedef char Direction;

Path parse_input(const char* input)
{
    Path output;

    size_t len = 1;
    const char* ptr = input;
    while (*ptr && *ptr != '\n')
    {
        if (*ptr++ == ',')
        {
            ++len;
        }
    }

    output.len = len + 1;
    output.inner = malloc(sizeof(Segment) * (len + 1));

    // Add origin
    output.inner[0].x = 0;
    output.inner[0].y = 0;

    Direction dir;
    int offset;
    ptr = input;
    for (size_t i = 1; i <= len; ++i)
    {
        dir = *ptr++, ++input;
        while (*ptr != ',' && *ptr != '\n') { ++ptr; }
        offset = strtol(input, (char**)&ptr, 10);
        switch (dir)
        {
        case 'U':
            output.inner[i].x = output.inner[i - 1].x;
            output.inner[i].y = output.inner[i - 1].y + offset;
            break;
        case 'D':
            output.inner[i].x = output.inner[i - 1].x;
            output.inner[i].y = output.inner[i - 1].y - offset;
            break;
        case 'L':
            output.inner[i].x = output.inner[i - 1].x - offset;
            output.inner[i].y = output.inner[i - 1].y;
            break;
        case 'R':
            output.inner[i].x = output.inner[i - 1].x + offset;
            output.inner[i].y = output.inner[i - 1].y;
            break;
        }
        input = ++ptr;
    }

    return output;
}

void free_path(Path* path)
{
    free(path->inner);
    path->inner = NULL;
    path->len = 0;
}

SegmentArray path_to_segments(const Path* path)
{
    SegmentArray output;

    output.len = path->len - 1;
    output.inner = malloc(sizeof(Segment) * output.len);

    for (size_t i = 0; i < output.len; ++i)
    {
        if (path->inner[i].x == path->inner[i + 1].x)
        {
            output.inner[i].type = SEG_TYPE_VERTICAL;
            output.inner[i].base_pos = path->inner[i].x;
            output.inner[i].start = path->inner[i].y;
            output.inner[i].end = path->inner[i + 1].y;
        }
        else if (path->inner[i].y == path->inner[i + 1].y)
        {
            output.inner[i].type = SEG_TYPE_HORIZONTAL;
            output.inner[i].base_pos = path->inner[i].y;
            output.inner[i].start = path->inner[i].x;
            output.inner[i].end = path->inner[i + 1].x;
        }
    }

    return output;
}

void free_segarray(SegmentArray* seg)
{
    free(seg->inner);
    seg->inner = NULL;
    seg->len = 0;
}

int solve1(const SegmentArray* seg1, const SegmentArray* seg2)
{
    Path container;
    int answer = INT_MAX;

    container.inner = (Point*)malloc(sizeof(Point) * seg1->len * 2);
    container.len = 0;

#define I seg1->inner[i]
#define J seg2->inner[j]
    for (size_t i = 0; i < seg1->len; ++i)
    {
        for (size_t j = 0; j < seg2->len; ++j)
        {
            if (I.type == J.type)
            {
                continue;
            }

            if (I.base_pos == 0 && J.base_pos == 0)
            {
                continue;
            }

#define MIN_POS(P) (MIN(P.start, P.end))
#define MAX_POS(P) (MAX(P.start, P.end))
            if ((I.base_pos >= MIN_POS(J) && I.base_pos <= MAX_POS(J)) && (J.base_pos >= MIN_POS(I) && J.base_pos <= MAX_POS(I)))
            {
                container.inner[container.len++] = (Point){I.base_pos, J.base_pos};
            }
        }
    }
#undef I
#undef J
#undef MIN_POS
#undef MAX_POS

    int tmp;
    for (size_t i = 0; i < container.len; ++i)
    {
        tmp = abs(container.inner[i].x) + abs(container.inner[i].y);
        answer = tmp <= answer ? tmp : answer;
    }

    free_path(&container);
    return answer;
}

int solve2(const SegmentArray* seg1, const SegmentArray* seg2)
{
    int tmp;
    int answer = INT_MAX;

#define I seg1->inner[i]
#define J seg2->inner[j]
    for (size_t i = 0; i < seg1->len; ++i)
    {
        for (size_t j = 0; j < seg2->len; ++j)
        {
            tmp = 0;
            if (I.type == J.type)
            {
                continue;
            }

            if (I.base_pos == 0 && J.base_pos == 0)
            {
                continue;
            }

#define MIN_POS(P) (MIN(P.start, P.end))
#define MAX_POS(P) (MAX(P.start, P.end))
            if ((I.base_pos >= MIN_POS(J) && I.base_pos <= MAX_POS(J)) && (J.base_pos >= MIN_POS(I) && J.base_pos <= MAX_POS(I)))
            {
                for (size_t k = 0; k < i; ++k)
                {
                    tmp += abs(seg1->inner[k].end - seg1->inner[k].start);
                }
                for (size_t k = 0; k < j; ++k)
                {
                    tmp += abs(seg2->inner[k].end - seg2->inner[k].start);
                }
                tmp += abs(I.base_pos - J.start);
                tmp += abs(J.base_pos - I.start);

                answer = tmp <= answer ? tmp : answer;
            }
        }
    }
#undef I
#undef J
#undef MIN_POS
#undef MAX_POS

    return answer;
}

int main(void)
{
    FILE* fs = fopen("./input.txt", "rb");

    char* source = NULL;
    size_t len;

    getline(&source, &len, fs);
    Path path1 = parse_input(source);

    getline(&source, &len, fs);
    Path path2 = parse_input(source);

    SegmentArray seg1 = path_to_segments(&path1);
    SegmentArray seg2 = path_to_segments(&path2);

    printf("Part1: %d\n", solve1(&seg1, &seg2));
    printf("Part2: %d\n", solve2(&seg1, &seg2));

    free_segarray(&seg1);
    free_segarray(&seg2);
    free_path(&path1);
    free_path(&path2);
    fclose(fs);
    return 0;
}
