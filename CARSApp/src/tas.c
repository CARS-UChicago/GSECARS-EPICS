/* tas.c - a soak test for sysBusTas
   by Andrew Johnson <anj@aps.anl.gov>

To use: compile and load this code on each vxWorks target (change the value of
NUM_CPUS as required).  Secondary CPUs don't have to use the sm network to
boot, but all must have different processor numbers in their boot parameter
settings.  The TAS location can either be on the master (cpu 0) or some
external location (currently this must be in  the short VME address space).

On the master, run initTest(0) from the vxWorks shell to use an onboard TAS
location, or initTest(0x28cc) for example to use location A16:28CC. This will
print a command line to be used subsequently to initialize the slave boards.
Finally execute runTest on all CPUs simultaneously.  Each cpu will print a line
of counts every 65536 successful TAS operations, and all should be incrementing
although the rates may vary between different CPUs.  The test has failed if any
CPU stops and diplays an error message, although other cpus may  continue to
run without error. */

#include <vxWorks.h>
#include <stdio.h>
#include <sysLib.h>
#include <tickLib.h>
#include <cacheLib.h>
#include <vme.h>

#define NUM_CPUS 2

#if (CPU_FAMILY == PPC)
    /* This stuff may not all be necessary, but who knows? */
    #define EIEIO_SYNC __asm__ volatile ("eieio;sync")
    void sysBusTasClear (volatile char *);
    #define TAS_CLEAR(loc) sysBusTasClear(loc)
#else
    #define EIEIO_SYNC
    #define TAS_CLEAR(loc)	*loc = 0
#endif


volatile struct ttest {
    int lock;		/* TAS location used when on master */
    int space;		/* Address space of the TAS location */
    char *plock;	/* VMEbus address of the TAS location */
    int winner;		/* Who won the TAS? */
    int count[NUM_CPUS];/* Success counters for each CPU */
} master, *ptest;

char *plock;

int initTest(void *pmaster) {
    int cpu = sysProcNumGet();

    if (cpu == 0) {
	/* I'm the master CPU, create a struct ttest */
	int i;

	ptest = &master;
	/* ptest = cacheDmaMalloc(sizeof (struct ttest));
	if (ptest == NULL) {
	    printf("cacheDmaMalloc returned NULL\n");
	    return -1;
	} */
	ptest->lock = 0;	/* 32-bit, if needed for PPC */
	ptest->winner = 0;
	for (i=0; i<NUM_CPUS; i++) ptest->count[i] = 0;
	
	if (pmaster == NULL) {
	    /* Use ptest->lock as the TAS location */
	    plock = (char *) &ptest->lock;
	    ptest->space = VME_AM_EXT_SUP_DATA;
	    if (sysLocalToBusAdrs(ptest->space, plock, &ptest->plock)) {
	    	printf("sysLocalToBusAdrs(%#x, %p) failed\n", 
			ptest->space, plock);
		return -1;
	    }
	} else {
	    /* TAS location is at short VMEbus address pmaster */
	    ptest->plock = (char *) pmaster;
	    ptest->space = VME_AM_SUP_SHORT_IO;
	    if (sysBusToLocalAdrs(ptest->space, ptest->plock, &plock)) {
	    	printf("sysBusToLocalAdrs(%#x, %p) failed\n",
			ptest->space, ptest->plock);
		return -1;
	    }
	}
	*plock = 0;	/* 8-bit, off-board */
	
	/* Convert ptest to a VMEbus address to print it */
	if (sysLocalToBusAdrs(VME_AM_EXT_SUP_DATA, (char *) ptest, 
			      (char **) &pmaster)) {
	    printf("sysLocalToBusAdrs(%#x, %p) failed\n", 
	    	    VME_AM_EXT_SUP_DATA, ptest);
	    return -1;
	}
	printf("Master initialized, init slave using\n");
	printf("\tinitTest(%p)\n", pmaster);
    } else {
	/* Slave CPU, ptest is given by arg */
	ptest = (struct ttest *) pmaster;
	if (sysBusToLocalAdrs(VME_AM_EXT_SUP_DATA, (char *) pmaster, 
				(char **) &ptest)) {
	    printf("sysBusToLocalAdrs(%#x, %p) failed\n",
	    	    VME_AM_EXT_SUP_DATA, pmaster);
	    return -1;
	}
	if (sysBusToLocalAdrs(ptest->space, ptest->plock, &plock)) {
	    printf("sysBusToLocalAdrs(%#x, %p) failed\n",
	    	    ptest->space, ptest->plock);
	    return -1;
	}
    }
    EIEIO_SYNC;
    CACHE_DMA_FLUSH(ptest, sizeof (struct ttest));
    printf("ptest = %p, plock = %p\n", ptest, plock);

    return 0;
}

static void doNothing(int i) {
    volatile int j=i;
    j++;
}

int runTest(void) {
    int cpu = sysProcNumGet();
    ULONG startTick = tickGet();
    int tickRate = sysClkRateGet();
    int i;

    for (;;) {
	while (!sysBusTas(plock)) ;
	
	/* We've won control now */
	EIEIO_SYNC;
	CACHE_DMA_INVALIDATE(ptest, sizeof (struct ttest));
	if (ptest->winner != 0) {
	    printf("Successful claim (cpu %d) pre-empted by cpu %d\n", 
		   cpu, ptest->winner - 1);
	    return -1;
	}

	ptest->winner = cpu + 1;
	ptest->count[cpu]++;
	EIEIO_SYNC;
	CACHE_DMA_FLUSH(ptest, sizeof (struct ttest));

	if ((ptest->count[cpu] & 0xffff) == 0) {
	    printf("counts = ");
	    for (i=0; i<NUM_CPUS; i++) printf("%d ", ptest->count[i]);
	    printf(" rate = %ld/second\n", 
	    	    (ptest->count[cpu] * tickRate) / (tickGet() - startTick));
	}

	for (i=0; i<10; i++) doNothing(i);

	EIEIO_SYNC;
	CACHE_DMA_INVALIDATE(ptest, sizeof (struct ttest));
	if (ptest->winner != cpu + 1) {
	    printf("Successful claim (cpu %d) stolen by cpu %d\n", 
		   cpu, ptest->winner - 1);
	    return -1;
	}

	ptest->winner = 0;
	EIEIO_SYNC;
	CACHE_DMA_FLUSH(ptest, sizeof (struct ttest));
	
	TAS_CLEAR(plock);
	EIEIO_SYNC;
	CACHE_DMA_FLUSH(ptest, sizeof (struct ttest));

	for (i=0; i<7; i++) doNothing(i);
    }

    return 0;
}
