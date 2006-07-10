#include <tickLib.h>
#include <stdio.h>

void printf_test()
{
    int i;
    long int start;

    start = tickGet();
    for (i=0; i<100; i++) printf("This is line %d\n", i);
    printf("Total ticks=%ld\n", tickGet()-start);
}
