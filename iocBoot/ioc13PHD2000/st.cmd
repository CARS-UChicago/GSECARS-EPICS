errlogInit(5000)
< envPaths
# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in this build from CARS
dbLoadDatabase("../../dbd/CARSLinux.dbd")
CARSLinux_registerRecordDeviceDriver(pdbbase)

epicsEnvSet PORT L0
epicsEnvSet PREFIX 13PHD2000:

# The Digi terminal server needs to be configured with baud=9600, 8 data bits, 2 stop bits, parity=None
drvAsynIPPortConfigure("$(PORT)","gsets9:2101",0,0,0)
# We don't set terminators here, we let StreamDevice take care of it
asynSetTraceIOMask("$(PORT)",0,2)
#asynSetTraceMask("$(PORT)",0,0x9)
# The GSETS9 terminal server must be configured for 9600, 8, 2, None

dbLoadRecords("$(IP)/db/PHD2000.db", "P=$(PREFIX), R=S1:, PORT=$(PORT), PREC=4")
dbLoadRecords("$(ASYN)/db/asynRecord.db", "P=$(PREFIX), R=asyn1, PORT=$(PORT), ADDR=0, IMAX=80, OMAX=80")

#var streamDebug 1

< ../save_restore_IOCSH.cmd
save_restoreSet_status_prefix("$(PREFIX)")
dbLoadRecords("$(AUTOSAVE)/asApp/Db/save_restoreStatus.db", "P=$(PREFIX)")

epicsEnvSet(STREAM_PROTOCOL_PATH, $(IP)/db)

date

# devIocStats
epicsEnvSet("ENGINEER", "Mark Rivers")
epicsEnvSet("LOCATION","Sector 13 portable")
epicsEnvSet("GROUP","GSECARS")
dbLoadRecords("$(DEVIOCSTATS)/db/iocAdminSoft.db","IOC=$(PREFIX)")

iocInit

### Start up the autosave task and tell it what to do.
# The task is actually named "save_restore".
# (See also, 'initHooks' above, which is the means by which the values that
# will be saved by the task we're starting here are going to be restored.
#
# save other things every thirty seconds
create_monitor_set("auto_settings.req", 30, "P=$(PREFIX), R=S1:")

