/* @(#)SNC Version 1.9.0(3.12.1): Fri Nov 17 22:04:46 CST 1995: XAFS.st */


/* Event flags */
#define abort_mon	1
#define abort_all_mon	2
#define begin_mon	3
#define energy_mon	4
#define time_mon	5
#define use_mon	6
#define region_mon	7
/* Program "XAFS_scan" */
#define ANSI
#include "seqCom.h"

#define NUM_SS 1
#define NUM_CHANNELS 22
#define NUM_EVENTS 7
#define MAX_STRING_SIZE 40
#define ASYNC_OPT FALSE
#define CONN_OPT TRUE
#define DEBUG_OPT FALSE
#define REENT_OPT FALSE


extern struct seqProgram XAFS_scan;
extern struct seqChan seqChan[];

/* Variable declarations */
static double	energy;
static double	time[5];
static int	use[3];
static double	region[10];
static int	begin_scan;
static int	abort_scan;
static int	abort_all;

	/* C code definitions */
# line 12 "XAFS.st"
#include <math.h>
/* Code for state "init" in state set "Energy" */

/* Delay function for state "init" in state set "Energy" */
static D_Energy_init(ssId, pVar)
SS_ID	ssId;
struct UserVar	*pVar;
{
# line 56 "XAFS.st"
}

/* Event function for state "init" in state set "Energy" */
static E_Energy_init(ssId, pVar, pTransNum, pNextState)
SS_ID	ssId;
struct UserVar	*pVar;
short	*pTransNum, *pNextState;
{
# line 56 "XAFS.st"
	if (TRUE)
	{
		*pNextState = 1;
		*pTransNum = 0;
		return TRUE;
	}
	return FALSE;
}

/* Action function for state "init" in state set "Energy" */
static A_Energy_init(ssId, pVar, transNum)
SS_ID	ssId;
struct UserVar	*pVar;
short	transNum;
{
	switch(transNum)
	{
	case 0:
# line 49 "XAFS.st"
		printf("XAFS_scan init\n") ;
		seq_efClear(ssId, abort_mon);
		seq_efClear(ssId, abort_all_mon);
		seq_efClear(ssId, begin_mon);
		seq_efClear(ssId, time_mon);
		seq_efClear(ssId, use_mon);
		seq_efClear(ssId, region_mon);
		return;
	}
}
/* Code for state "monitor_changes" in state set "Energy" */

/* Delay function for state "monitor_changes" in state set "Energy" */
static D_Energy_monitor_changes(ssId, pVar)
SS_ID	ssId;
struct UserVar	*pVar;
{
# line 65 "XAFS.st"
# line 69 "XAFS.st"
}

/* Event function for state "monitor_changes" in state set "Energy" */
static E_Energy_monitor_changes(ssId, pVar, pTransNum, pNextState)
SS_ID	ssId;
struct UserVar	*pVar;
short	*pTransNum, *pNextState;
{
# line 65 "XAFS.st"
	if (seq_efTestAndClear(ssId, begin_mon))
	{
		*pNextState = 1;
		*pTransNum = 0;
		return TRUE;
	}
# line 69 "XAFS.st"
	if (seq_efTestAndClear(ssId, region_mon) || seq_efTestAndClear(ssId, time_mon) || seq_efTestAndClear(ssId, use_mon))
	{
		*pNextState = 1;
		*pTransNum = 1;
		return TRUE;
	}
	return FALSE;
}

/* Action function for state "monitor_changes" in state set "Energy" */
static A_Energy_monitor_changes(ssId, pVar, transNum)
SS_ID	ssId;
struct UserVar	*pVar;
short	transNum;
{
	switch(transNum)
	{
	case 0:
# line 64 "XAFS.st"
		printf("XAFS_scan:: begin scan!\n") ;
		return;
	case 1:
# line 68 "XAFS.st"
		printf("XAFS_scan:: region changed!\n") ;
		return;
	}
}
/* Exit handler */
static exit_handler(ssId, pVar)
int	ssId;
struct UserVar	*pVar;
{
}

/************************ Tables ***********************/

/* Database Blocks */
static struct seqChan seqChan[NUM_CHANNELS] = {
  "{P}{ENERGY}", (void *)&energy, "energy", 
    "double", 1, 8, 4, 1,

  "{P}{XAFS}time0", (void *)&time[0], "time[0]", 
    "double", 1, 9, 5, 1,

  "{P}{XAFS}time1", (void *)&time[1], "time[1]", 
    "double", 1, 10, 5, 1,

  "{P}{XAFS}time2", (void *)&time[2], "time[2]", 
    "double", 1, 11, 5, 1,

  "{P}{XAFS}time3", (void *)&time[3], "time[3]", 
    "double", 1, 12, 5, 1,

  "{P}{XAFS}time4", (void *)&time[4], "time[4]", 
    "double", 1, 13, 5, 1,

  "{P}{XAFS}use0", (void *)&use[0], "use[0]", 
    "int", 1, 14, 6, 1,

  "{P}{XAFS}use1", (void *)&use[1], "use[1]", 
    "int", 1, 15, 6, 1,

  "{P}{XAFS}use2", (void *)&use[2], "use[2]", 
    "int", 1, 16, 6, 1,

  "{P}{XAFS}region0", (void *)&region[0], "region[0]", 
    "double", 1, 17, 7, 1,

  "{P}{XAFS}region1", (void *)&region[1], "region[1]", 
    "double", 1, 18, 7, 1,

  "{P}{XAFS}region2", (void *)&region[2], "region[2]", 
    "double", 1, 19, 7, 1,

  "{P}{XAFS}region3", (void *)&region[3], "region[3]", 
    "double", 1, 20, 7, 1,

  "{P}{XAFS}region4", (void *)&region[4], "region[4]", 
    "double", 1, 21, 7, 1,

  "{P}{XAFS}region5", (void *)&region[5], "region[5]", 
    "double", 1, 22, 7, 1,

  "{P}{XAFS}region6", (void *)&region[6], "region[6]", 
    "double", 1, 23, 7, 1,

  "{P}{XAFS}region7", (void *)&region[7], "region[7]", 
    "double", 1, 24, 7, 1,

  "{P}{XAFS}region8", (void *)&region[8], "region[8]", 
    "double", 1, 25, 7, 1,

  "{P}{XAFS}region9", (void *)&region[9], "region[9]", 
    "double", 1, 26, 7, 1,

  "{P}{XAFS}BeginScan", (void *)&begin_scan, "begin_scan", 
    "int", 1, 27, 3, 1,

  "{P}{XAFS}AbortScan", (void *)&abort_scan, "abort_scan", 
    "int", 1, 28, 1, 1,

  "{P}{XAFS}AbortAll", (void *)&abort_all, "abort_all", 
    "int", 1, 29, 2, 1,

};

/* Event masks for state set Energy */
	/* Event mask for state init: */
static bitMask	EM_Energy_init[] = {
	0x00000000,
};
	/* Event mask for state monitor_changes: */
static bitMask	EM_Energy_monitor_changes[] = {
	0x000000e8,
};

/* State Blocks */

static struct seqState state_Energy[] = {
	/* State "init"*/
	/* state name */       "init",
	/* action function */  A_Energy_init,
	/* event function */   E_Energy_init,
	/* delay function */   D_Energy_init,
	/* event mask array */ EM_Energy_init,

	/* State "monitor_changes"*/
	/* state name */       "monitor_changes",
	/* action function */  A_Energy_monitor_changes,
	/* event function */   E_Energy_monitor_changes,
	/* delay function */   D_Energy_monitor_changes,
	/* event mask array */ EM_Energy_monitor_changes,


};

/* State Set Blocks */
static struct seqSS seqSS[NUM_SS] = {
	/* State set "Energy"*/
	/* ss name */            "Energy",
	/* ptr to state block */ state_Energy,
	/* number of states */   2,
	/* error state */        -1,
};

/* Program parameter list */
static char prog_param[] = "P=13IDC:,IDXX=ID13:,ENERGY=EN, XAFS=XAFS:,SCAN=scan1";

/* State Program table (global) */
struct seqProgram XAFS_scan = {
	/* magic number */       940501,
	/* *name */              "XAFS_scan",
	/* *pChannels */         seqChan,
	/* numChans */           NUM_CHANNELS,
	/* *pSS */               seqSS,
	/* numSS */              NUM_SS,
	/* user variable size */ 0,
	/* *pParams */           prog_param,
	/* numEvents */          NUM_EVENTS,
	/* encoded options */    (0 | OPT_CONN | OPT_NEWEF | OPT_VXWORKS),
	/* exit handler */       exit_handler,
};
