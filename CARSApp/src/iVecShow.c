/* $Author$ */ 
/* $Date$ */ 
/* $Id$ */  
/* $Name$ */ 
/* $Revision$ */ 
/* $Log$
/* Revision 1.1  2003/05/20 04:29:31  epics
/* Files needed for IK320?
/*
 * */ 

#define INCLUDE_MPIC
#include <vxWorks.h>
/* #include <config.h> */
#include <vxLib.h>
#include <stdlib.h>

/* this is from target/config/mv2306/sl82565IntrCtl.h 
 * this should be incorporated into the build structure!
 * (but I just copied it here )
*/
typedef struct intHandlerDesc           /* interrupt handler desciption */
    {
    VOIDFUNCPTR                 vec;    /* interrupt vector */
    int                         arg;    /* interrupt handler argument */
    struct intHandlerDesc *     next;   /* next interrupt handler & argument */
    } INT_HANDLER_DESC;

/*#include <ravenMpic.h>*/

extern INT_HANDLER_DESC * sysIntTbl [256];
INT_HANDLER_DESC * ppcShowIvecChain(INT_HANDLER_DESC *vector);


/* 
   Debugging aid to print out handlers & parameters connected to
   a vector
*/
int ppcIvecShow(int vecnum) {
  if(sysIntTbl[vecnum] == NULL) {
    printf("vector is NULL\n");
  } else {
    ppcShowIvecChain(sysIntTbl[vecnum]);
  }
  return (0);
}

/* helper routine for the above */

INT_HANDLER_DESC * ppcShowIvecChain(INT_HANDLER_DESC *vector){
  if(vector == NULL) return NULL;
  if(vector->next==NULL) {
    printf("Next vector %d argument %d\n ", (int)vector->vec, vector->arg);
  }else {
    printf("Next vector %d argument %d next %d\n ",(int)vector->vec,
	 vector->arg,(int)vector->next);
  }
  ppcShowIvecChain(vector->next);
  return NULL;
}
  
/* return the function attached to this vector. NULL if none */

VOIDFUNCPTR ppcIntVecGet(int vecnum) {
  if(sysIntTbl[vecnum] == NULL) {
    return(NULL);
  } else {
    return(sysIntTbl[vecnum]->vec);
  }
}

/* return the argument for the attached function. NULL if none */
 
int ppcIntVecArg(int vecnum) {
  if(sysIntTbl[vecnum] == NULL) {
    return(NULL);
  } else {
    return(sysIntTbl[vecnum]->arg);
  }
}

/* search the argument for the function pointer given as a parameter.
   NULL if none */

int ppcIntHandlerArgByPointer(VOIDFUNCPTR func) {
  int i;
  for(i=0;i<256;i++)
    if(sysIntTbl[i]!=NULL) {
      if(sysIntTbl[i]->vec == func) return(sysIntTbl[i]->arg);
    }
    return(NULL);
}
/* number of interrupt handlers connected to this vector */
int ppcIntVecCount(int vecnum) {
  int count =0;
  INT_HANDLER_DESC * tempptr;
  if(sysIntTbl[vecnum] == NULL) {
    return (0);
  } else {
    count++;
    tempptr = sysIntTbl[vecnum]->next;
    while(tempptr != NULL) {
      count ++; 
      tempptr = tempptr-> next;
    }
    
    return(count);
  }
}

int ppcIsConnected(int vecnum, VOIDFUNCPTR func) {
  INT_HANDLER_DESC * tempptr;
  if(vecnum<0 || vecnum > 255) return 0;
  tempptr= sysIntTbl[vecnum];
  while(tempptr != NULL) {
    if(tempptr->vec==func) return(1);
    tempptr = tempptr-> next;
  }
  return(0);
}

int ppcDisconnectVec(int vecnum, VOIDFUNCPTR func) {
  INT_HANDLER_DESC * vecptr;
  if(vecnum<0 || vecnum > 255) return -1;
  if(sysIntTbl[vecnum]==NULL) return 0;
  vecptr= sysIntTbl[vecnum];    
  if(vecptr->vec==func) {
    free(vecptr); /* free memory */
    sysIntTbl[vecnum] = vecptr->next;
    return(1);
  } else {
    INT_HANDLER_DESC * prevptr;
    prevptr = vecptr;
    vecptr = vecptr-> next;
    while(vecptr != NULL) {
      if(vecptr->vec==func) {
	prevptr->next = vecptr->next;
	free(vecptr); /* free memory */
	return(1);
      } 
      prevptr = vecptr;
      vecptr = vecptr-> next;
    }
  }
  return(0);
}

int ppcDisconnectVecArg(int vecnum, VOIDFUNCPTR func, int myarg) {
  INT_HANDLER_DESC * vecptr;
  if(vecnum<0 || vecnum > 255) return -1;
  if(sysIntTbl[vecnum]==NULL) return 0;
  vecptr= sysIntTbl[vecnum];    
  if(vecptr->vec==func && vecptr->arg==myarg) {
    free(vecptr); /* free memory */
    sysIntTbl[vecnum] = vecptr->next;
    return(1);
  } else {
    INT_HANDLER_DESC * prevptr;
    prevptr = vecptr;
    vecptr = vecptr-> next;
    while(vecptr != NULL) {
      if(vecptr->vec==func && vecptr->arg==myarg) {
	prevptr->next = vecptr->next;
	free(vecptr); /* free memory */
	return(1);
      } 
      prevptr = vecptr;
      vecptr = vecptr-> next;
    }
  }
  return(0);
}

  
