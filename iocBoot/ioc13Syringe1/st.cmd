errlogInit(5000)
< envPaths
# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in this build from CARS
dbLoadDatabase("../../dbd/CARSLinux.dbd")
CARSLinux_registerRecordDeviceDriver(pdbbase)
#CARSWin32_registerRecordDeviceDriver(pdbbase)

#vxi11Configure("L0","164.54.160.16",0,"0.0","COM1",0,0)
drvAsynSerialPortConfigure("L0","/dev/ttyS1",0,0,0)
# We don't set terminators here, we let StreamDevice take care of it
asynSetTraceIOMask("L0",0,2)
#asynSetTraceMask("L0",0,0x9)

dbLoadRecords("$(IP)/ipApp/Db/CPSyringe.db", "P=13Syringe1:, R=S1:, PORT=L0")
dbLoadRecords("$(ASYN)/db/asynRecord.db", "P=13Syringe1:, R=asyn1, PORT=L0, ADDR=0, IMAX=80, OMAX=80")

#var streamDebug 1

< ../save_restore_IOCSH.cmd
save_restoreSet_status_prefix("13Syringe1:")
dbLoadRecords("$(AUTOSAVE)/asApp/Db/save_restoreStatus.db", "P=13Syringe1:")

epicsEnvSet(STREAM_PROTOCOL_PATH, $(IP)/ipApp/Db)

date
iocInit

### Start up the autosave task and tell it what to do.
# The task is actually named "save_restore".
# (See also, 'initHooks' above, which is the means by which the values that
# will be saved by the task we're starting here are going to be restored.
#
# save other things every thirty seconds
create_monitor_set("auto_settings.req", 30, "P=13Syringe1:, R=S1:")

