errlogInit(5000)
< envPaths
# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in this build from CARS
dbLoadDatabase("../../dbd/CARSLinux.dbd")
CARSLinux_registerRecordDeviceDriver(pdbbase)

# Serial port settings for pump
# Baud Rate: 9600
#drvAsynIPPortConfigure("L0","gsets4:2001",0,0,0)
drvAsynIPPortConfigure("serial1", "GSETS11:4001 COM", 0, 0, 1)
# We don't set terminators here, we let StreamDevice take care of it
#asynSetTraceIOMask("L0",0,2)
asynSetTraceIOMask("serial1", 0, 4)
##asynSetTraceMask("L0",0,0x9)

#dbLoadRecords("$(IP)/db/CPSyringe.db", "P=13Syringe2:, R=S1:, PORT=L0")
dbLoadRecords("$(IP)/db/CPSyringe.db", "P=13Syringe2:, R=S1:, PORT=serial1")
#dbLoadRecords("$(ASYN)/db/asynRecord.db", "P=13Syringe2:, R=asyn1, PORT=L0, ADDR=0, IMAX=80, OMAX=80")
dbLoadRecords("$(ASYN)/db/asynRecord.db", "P=13Syringe2:, R=asyn1, PORT=serial1, ADDR=0, IMAX=80, OMAX=80")
#var streamDebug 1

< ../save_restore_IOCSH.cmd
save_restoreSet_status_prefix("13Syringe2:")
dbLoadRecords("$(AUTOSAVE)/db/save_restoreStatus.db", "P=13Syringe2:")

epicsEnvSet(STREAM_PROTOCOL_PATH, $(IP)/db)

date

# devIocStats
epicsEnvSet("ENGINEER", "Mark Rivers")
epicsEnvSet("LOCATION","Sector 13 portable")
epicsEnvSet("GROUP","GSECARS")
dbLoadRecords("$(DEVIOCSTATS)/db/iocAdminSoft.db","IOC=13Syringe2:")

iocInit

### Start up the autosave task and tell it what to do.
# The task is actually named "save_restore".
# (See also, 'initHooks' above, which is the means by which the values that
# will be saved by the task we're starting here are going to be restored.
#
# save other things every thirty seconds
create_monitor_set("auto_settings.req", 30, "P=13Syringe2:, R=S1:")

