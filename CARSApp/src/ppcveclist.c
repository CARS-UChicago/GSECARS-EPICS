/*
 *	$Id$
 *	@(#)veclist.c	1.10
 *
 *	list fuctions attached to the interrupt vector table
 *
 *	Created 28Mar89	Jeffrey O. Hill
 *	johill@lanl.gov
 *	(505) 665 1831
 *
 *	.01 010393 Applied fix for zero C ISR param causes incorrect 
 *		   identification as MACRO ISR problem. 
 *	.02 022195 Compiler warnings fixed
 *	$Log$
 *	Revision 1.1  2003/05/20 04:30:09  epics
 *	Files needed for IK320?
 *	
 *	Revision 1.1.1.2  2000/04/05 07:33:37  janousch
 *	Import of EPICS/base R3.13.2
 *	
 *	Revision 1.16  1998/06/04 19:24:30  wlupton
 *	avoided intHandlerCreate() for PPC
 *	
 *	Revision 1.15  1998/03/16 17:01:27  mrk
 *	include string.h
 *
 *	Revision 1.14  1996/09/04 22:08:50  jhill
 *	fixed gcc warnings
 *
 * Revision 1.13  1995/08/12  01:12:37  jhill
 * doc
 *
 */

/*
 * 
 *	makefile
 *
 *
 * V5VW = /.../vx/v502b
 *
 * veclist.o:
 *	cc68k -c -DCPU_FAMILY=MC680X0 -I$(V5VW)/h veclist.c
 * 
 *
 */

#include "vxWorks.h"
#include "stdio.h"
#include "string.h"
#include "intLib.h"
#include "vxLib.h"
#include "iv.h"
#include "ctype.h"
#include "sysSymTbl.h"

static char *sccsID = 
	"@(#) $Id$";

/*
 *
 * VME bus dependent
 *
 */
#define NVEC 0x100

static char *ignore_list[] = {"_excStub","_excIntStub"};

int		veclist(int);
int		cISRTest(FUNCPTR proutine, FUNCPTR *ppisr, void **pparam);
static void 	*fetch_pointer(unsigned char *);


/*
 *
 * veclist()
 *
 */
int veclist(int all)
{
  	int		vec;
	int		value;
	SYM_TYPE	type;
	char		name[MAX_SYS_SYM_LEN];
	char		function_type[10];
	FUNCPTR		proutine;
	FUNCPTR		pCISR;
	int		cRoutine;
	void		*pparam;
	int		status;
	unsigned	i;

  	for(vec=0; vec<NVEC; vec++){
#if (CPU == PPC604)
         	proutine = ppcIntVecGet((FUNCPTR *)INUM_TO_IVEC(vec));
		if(!all && proutine == NULL) continue; 
#else
	        proutine = intVecGet((FUNCPTR *)INUM_TO_IVEC(vec));
#endif
		status = cISRTest(proutine, &pCISR, &pparam);
		if(status == OK){
			cRoutine = TRUE;
			proutine = pCISR;
			strcpy(function_type, "C");
		}
		else{
			cRoutine = FALSE;
			strcpy(function_type, "MACRO");
			pCISR = NULL;
		}
 
		status = symFindByValue(
				sysSymTbl, 
				(int)proutine, 
				name,
				&value,
				&type);
		if(status<0 || value != (int)proutine){
#ifdef MV2306
		  cRoutine = FALSE;
		  strcpy(function_type, "MACRO");
#endif
		  sprintf(name, "0x%X", (unsigned int) proutine);
		}
		else if(!all){
			int	match = FALSE;

			for(i=0; i<NELEMENTS(ignore_list); i++){
				if(!strcmp(ignore_list[i],name)){
					match = TRUE;
					break;
				}
			}
			if(match){
				continue;
			}
		}
       		printf(	"vec 0x%02X %5s ISR %s", 
			vec, 
			function_type,
			name);
		if(cRoutine){
#if (CPU == PPC604)
		  pparam = ppcIntVecArg(vec); 
		  /* works when only one routine/vector */
		  status = symFindByValue(
					  sysSymTbl, 
					  (int)pparam, 
					  name,
					  &value,
					  &type);
		  if(status!=OK || value != pparam){
#endif
			printf("(0x%X)", (unsigned int) pparam);
#if (CPU == PPC604)
		  } else {
		    printf(" (%s)",name);
		  }
#endif
		}
		printf("\n");
	}

	return OK;
}



/*
 * cISRTest()
 *
 * test to see if a C routine is attached
 * to this interrupt vector
 */
#define ISR_PATTERN	0xaaaaaaaa
#define PARAM_PATTERN	0x55555555 
int	cISRTest(FUNCPTR proutine, FUNCPTR *ppisr, void **pparam)
{
	static FUNCPTR	handler = NULL;
	STATUS		status;
	unsigned char	*pchk;
	unsigned char	*pref;
	unsigned char	val;
#if CPU_FAMILY != PPC
	int		found_isr;
	int		found_param;
#endif
#if CPU_FAMILY != PPC
	if(handler == NULL){
		handler = (FUNCPTR) intHandlerCreate(
				(FUNCPTR) ISR_PATTERN, 
				PARAM_PATTERN);
		if(handler == NULL){
			return ERROR;
		}
	}
#endif

#if CPU_FAMILY == PPC
	if(proutine == NULL) {
	  return ERROR;
	}
	pchk = (unsigned char *) proutine;
	status = vxMemProbe(	
			    (char *) pchk,
			    READ,
			    sizeof(val),
			    (char *) &val);
	if(status < 0){
	  return ERROR;
	}
	*ppisr = proutine ; /* silly but should be ok! */
	*pparam = ppcIntHandlerArgByPointer(proutine);
#else
	found_isr = FALSE;
	found_param = FALSE;
	pchk = (unsigned char *) proutine;
	pref = (unsigned char *) handler; 
	for(	;
		found_isr==FALSE || found_param==FALSE;
		pchk++, pref++){

		status = vxMemProbe(	
				(char *) pchk,
				READ,
				sizeof(val),
				(char *) &val);
		if(status < 0){
			return ERROR;
		}

		if(val != *pref){
			if(*pref == (unsigned char) ISR_PATTERN){
				*ppisr = (FUNCPTR) fetch_pointer(pchk);
				pref += sizeof(*ppisr)-1;
				pchk += sizeof(*ppisr)-1;
				found_isr = TRUE;	
			}
			else if(*pref == (unsigned char) PARAM_PATTERN){
				*pparam = fetch_pointer(pchk);
				pref += sizeof(*pparam)-1;
				pchk += sizeof(*pparam)-1;
				found_param = TRUE;
			}
			else{	
				return ERROR;
			}
		}
	}
#endif
	return OK;
}



/*
 * fetch_pointer()
 *
 * fetch pointer given low byte with correct byte ordering
 *
 */
struct char_array{
	unsigned char byte[4];
};
union pointer{
	void 			*ptr_overlay;
	struct char_array 	char_overlay;
};

LOCAL
void *fetch_pointer(unsigned char *plow_byte)
{
	union pointer	p;
	size_t		i;

	for(i=0; i < sizeof(p); i++){
		p.char_overlay.byte[i] = plow_byte[i];
	}

	return p.ptr_overlay;
}
