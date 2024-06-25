/*
 * Driver for writing and reading device parameters for ifm efector AL1342.
 * Process data is read using normal Modbus drivers and records.
 * However, reading and writing device parameters is more complex,
 * so it needs a dedicated driver.
 *
 * Author: Mark Rivers
 *
 * Created April 18, 2024
 */

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <string>

#include <epicsTypes.h>
#include <epicsTime.h>
#include <epicsThread.h>
#include <shareLib.h>
#include <iocsh.h>

#include <asynPortDriver.h>
#include <drvModbusAsyn.h>
#include <epicsExport.h>

/* These are the drvInfo strings that are used to identify the parameters.
 * They are used by asyn clients, including standard asyn device support */
#define P_Flow2SetString           "FLOW2_SET"                  /* asynInt32,    r/w */
#define P_Flow2ResetString         "FLOW2_RESET"                /* asynInt32,    r/o */

#define FLOW2_SET_INDEX   593
#define FLOW2_RESET_INDEX 594
#define READ_COMMAND      1
#define WRITE_COMMAND     2
#define SLEEP_TIME        0.1
#define MAX_WAIT_TIME     3.0 
#define MAX_RETRIES       (MAX_WAIT_TIME/SLEEP_TIME)

#pragma pack(push, 1)
typedef struct {
    epicsInt16 portNumber;
    epicsInt16 index;
    epicsInt16 subIndex;
    epicsInt8  userID;
    epicsInt8  command;
    epicsInt16 dataLength;
    epicsInt8  data[34];
} IFMRequestChannel;

typedef struct {
    epicsInt16 portNumber;
    epicsInt16 index;
    epicsInt16 subIndex;
    epicsUInt8 userID;
    epicsInt8  command;
    epicsInt16 result;
    epicsInt16 dataLength;
    epicsInt8  data[32];
} IFMResponseChannel;
#pragma pack(pop)

static const char *driverName="drvIFM_AL1342";

class drvIFM_AL1342 : public asynPortDriver {
public:
    drvIFM_AL1342(const char *portName, const char *ipDriver);

    virtual asynStatus readInt32(asynUser *pasynUser, epicsInt32 *value);
    virtual asynStatus writeInt32(asynUser *pasynUser, epicsInt32 value);

protected:
    /** Values used for pasynUser->reason, and indexes into the parameter library. */
    int P_Flow2Set;
    int P_Flow2Reset;

private:
    drvModbusAsyn *pModbus_;
    epicsUInt8 transactionID_;
    asynStatus doAcyclicCommand(int index, int address, void *value, int length, int direction);
};

drvIFM_AL1342::drvIFM_AL1342(const char *portName, const char *ipDriver)
   : asynPortDriver(portName,
                    9, /* maxAddr */
                    asynInt32Mask | asynFloat64Mask | asynDrvUserMask, /* Interface mask */
                    asynInt32Mask | asynFloat64Mask,  /* Interrupt mask */
                    ASYN_CANBLOCK | ASYN_MULTIDEVICE, /* asynFlags */
                    1, /* Autoconnect */
                    0, /* Default priority */
                    0), /* Default stack size*/
      transactionID_(0)
{
    createParam(P_Flow2SetString,   asynParamInt32, &P_Flow2Set);
    createParam(P_Flow2ResetString, asynParamInt32, &P_Flow2Reset);

    /* drvModbusAsyn(const char *portName, const char *octetPortName, 
     *               int modbusSlave, int modbusFunction, 
     *               int modbusStartAddress, int modbusLength,
     *               modbusDataType_t dataType,
     *               int pollMsec, 
     *               const char *plcType); */
     // Use absolute addressing, modbusStartAddress = -1
    std::string pname = std::string(portName)+"_modbus";
    pModbus_ = new drvModbusAsyn(pname.c_str(), ipDriver, 0, MODBUS_READ_HOLDING_REGISTERS, -1, 64, dataTypeUInt16, 0, "AL1342");
}

asynStatus drvIFM_AL1342::writeInt32(asynUser *pasynUser, epicsInt32 value)
{
    int function = pasynUser->reason;
    asynStatus status = asynSuccess;
    int address;
    const char *paramName;
    epicsInt16 i16val = (epicsInt16) value;
    static const char* functionName = "writeInt32";

    this->getAddress(pasynUser, &address);
    /* Set the parameter in the parameter library. */
    setIntegerParam(function, value);

    /* Fetch the parameter string name for possible use in debugging */
    getParamName(function, &paramName);

    if (function == P_Flow2Set) {
       status = doAcyclicCommand(FLOW2_SET_INDEX, address, (void *)&i16val, 2, WRITE_COMMAND);
    } else if (function == P_Flow2Reset) {
       status = doAcyclicCommand(FLOW2_RESET_INDEX, address, (void *)&i16val, 2, WRITE_COMMAND);
    } else {
        status = asynPortDriver::writeInt32(pasynUser, value);
    }

    /* Do callbacks so higher layers see any changes */
    callParamCallbacks();

    if (status)
        epicsSnprintf(pasynUser->errorMessage, pasynUser->errorMessageSize,
                  "%s:%s: status=%d, function=%d, name=%s, value=%d",
                  driverName, functionName, status, function, paramName, value);
    else
        asynPrint(pasynUser, ASYN_TRACEIO_DRIVER,
              "%s:%s: function=%d, name=%s, value=%d\n",
              driverName, functionName, function, paramName, value);
    return status;
}

asynStatus drvIFM_AL1342::readInt32(asynUser *pasynUser, epicsInt32 *value)
{
    int function = pasynUser->reason;
    asynStatus status = asynSuccess;
    int address;
    epicsInt16 shortVal;
    const char *paramName;
    static const char* functionName = "readInt32";

    this->getAddress(pasynUser, &address);

    /* Fetch the parameter string name for possible use in debugging */
    getParamName(function, &paramName);

    if (function == P_Flow2Set) {
       status = doAcyclicCommand(FLOW2_SET_INDEX, address, (void *)&shortVal, 2, READ_COMMAND);
       *value = shortVal;
    } else if (function == P_Flow2Reset) {
       status = doAcyclicCommand(FLOW2_RESET_INDEX, address, (void *)&shortVal, 2, READ_COMMAND);
       *value = shortVal;
    } else {
        status = asynPortDriver::readInt32(pasynUser, value);
    }

    /* Do callbacks so higher layers see any changes */
    callParamCallbacks();

    if (status)
        epicsSnprintf(pasynUser->errorMessage, pasynUser->errorMessageSize,
                  "%s:%s: status=%d, function=%d, name=%s, value=%d",
                  driverName, functionName, status, function, paramName, *value);
    else
        asynPrint(pasynUser, ASYN_TRACEIO_DRIVER,
              "%s:%s: function=%d, name=%s, value=%d\n",
              driverName, functionName, function, paramName, *value);
    return status;
}

asynStatus drvIFM_AL1342::doAcyclicCommand(int index, int address, void* value, int length, int direction)
{
    IFMRequestChannel req;
    IFMResponseChannel resp;
    static const char *functionName = "doAcyclicCommand";

    req.portNumber = address;
    req.index      = index;
    req.subIndex   = 0;
    req.userID     = transactionID_++;
    req.command    = direction;
    req.dataLength = length;
    if (direction == WRITE_COMMAND) {
        memcpy(req.data, value, length);
        printf("Writing %d to port %d index %d\n", req.data[0]+255*req.data[1], req.portNumber, req.index);
    }
    pModbus_->doModbusIO(0, MODBUS_WRITE_MULTIPLE_REGISTERS, 500, (epicsUInt16*) &req, 5+length/2);
    for (int i=0; i<MAX_RETRIES; i++) {
        pModbus_->doModbusIO(0, MODBUS_READ_HOLDING_REGISTERS, 0, (epicsUInt16*) &resp, sizeof(resp)/2);
        if (resp.command != 0) break;
        printf("Sleeping for %f second\n", SLEEP_TIME);
        epicsThreadSleep(SLEEP_TIME);
    }
    if (resp.result != 0) {
        asynPrint(pasynUserSelf, ASYN_TRACE_ERROR, 
                  "%s::%s port=%d, index=%d, command=%d, userID=%d, result=0x%x, length=%d, error code=0x%x, additional code=0x%x\n",
                  driverName, functionName, resp.portNumber, resp.index, resp.command, resp.userID, resp.result, resp.dataLength, resp.data[1], resp.data[0]);
        return asynError;
    }
    asynPrint(pasynUserSelf, ASYN_TRACEIO_DRIVER, 
              "%s::%s port=%d, index=%d, command=%d, userID=%d, length=%d, value=%d\n",
              driverName, functionName, resp.portNumber, resp.index, resp.command, resp.userID, resp.dataLength, resp.data[0]+255*resp.data[1]);
    if (direction == READ_COMMAND) {
        memcpy(value, resp.data, length);
    }
    return asynSuccess;
}

/* Configuration routine.  Called directly, or from the iocsh function below */

extern "C" {

/** EPICS iocsh callable function to call constructor for the drvIFM_AL1342 class.
  * \param[in] portName The name of the asyn port driver to be created.
  * \param[in] ipDriver The name of the underlying IP Port driver */
int drvIFM_AL1342Configure(const char *portName, const char *ipDriver)
{
    new drvIFM_AL1342(portName, ipDriver);
    return(asynSuccess);
}


/* EPICS iocsh shell commands */

static const iocshArg initArg0 = { "portName",iocshArgString};
static const iocshArg initArg1 = { "ipDriver",iocshArgString};
static const iocshArg * const initArgs[] = {&initArg0,
                                            &initArg1};
static const iocshFuncDef initFuncDef = {"drvIFM_AL1342Configure",2,initArgs};
static void initCallFunc(const iocshArgBuf *args)
{
    drvIFM_AL1342Configure(args[0].sval, args[1].sval);
}

void drvIFM_AL1342Register(void)
{
    iocshRegister(&initFuncDef,initCallFunc);
}

epicsExportRegistrar(drvIFM_AL1342Register);

}

