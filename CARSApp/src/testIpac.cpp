/* Simple IPAC test program
*/

#include <drvIpac.h>
#include <iocsh.h>
#include <epicsExport.h>


int testIpac(int carrier, int slot, int offset) {

    unsigned short *reg;
    int i;
    unsigned short value;
    
    if (ipmCheck(carrier, slot) != 0) {
       printf("Did not find an IP module at carrier=%d slot=%d\n", carrier, slot);
       return -1;
    } else {
        reg = (unsigned short *) ipmBaseAddr(carrier, slot, ipac_addrIO) + offset;
    }
    for (i=0; i<8; i++) {
        printf("\n");
        printf("Current value of register %p = 0x%x\n", reg, *reg);
        value = 0x100 * i;
        *reg = value;
        printf("        Write to register %p = 0x%x\n", reg, value);
        printf("    New value of register %p = 0x%x\n", reg, *reg);
    }
    return 0;
}

/** Configuration command, called directly or from iocsh */
static const iocshArg initArg0 = { "Carrier",iocshArgInt};
static const iocshArg initArg1 = { "Slot",iocshArgInt};
static const iocshArg initArg2 = { "Offset",iocshArgInt};
static const iocshArg * const initArgs[3] = {&initArg0,
                                             &initArg1,
                                             &initArg2};
static const iocshFuncDef initFuncDef = {"testIpac",3,initArgs};
static void initCallFunc(const iocshArgBuf *args)
{
    testIpac(args[0].ival, args[1].ival, args[2].ival);
}

void testIpacRegister(void)
{
    iocshRegister(&initFuncDef,initCallFunc);
}

extern "C" {
epicsExportRegistrar(testIpacRegister);
}
