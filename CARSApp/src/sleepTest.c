#include <epicsThread.h>
#include <epicsTime.h>
#include <iocsh.h>
#include <epicsExport.h>
#include <stdio.h>

void sleepTest(int milliseconds)
{
   epicsTimeStamp start, end;
   double requestedTime = milliseconds / 1000.;
   double actualTime;

   epicsTimeGetCurrent(&start);
   epicsThreadSleep(requestedTime);
   epicsTimeGetCurrent(&end);
   actualTime = epicsTimeDiffInSeconds(&end, &start);
   printf("Requested sleep time = %f, actual=%f\n", requestedTime, actualTime);
}

static const iocshArg sleepTestArg0 = { "sleep time (msec)", iocshArgInt};
static const iocshArg * const sleepTestArgs[1] = {&sleepTestArg0};
static const iocshFuncDef sleepTestFuncDef = {"sleepTest",1,sleepTestArgs};
static void sleepTestCallFunc(const iocshArgBuf *args)
{
    sleepTest(args[0].ival);
}

void sleepTestRegister(void)
{
    iocshRegister(&sleepTestFuncDef,sleepTestCallFunc);
}

epicsExportRegistrar(sleepTestRegister);

