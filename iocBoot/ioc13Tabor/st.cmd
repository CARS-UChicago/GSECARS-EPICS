errlogInit(5000)
< envPaths
# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in this build from CARS
dbLoadDatabase("../../dbd/CARSLinux.dbd")
CARSLinux_registerRecordDeviceDriver(pdbbase)

vxi11Configure("L0","164.54.160.16",0,"0.0","gpib0",0,0)
asynOctetSetInputEos("L0",0,"\n")
asynSetTraceIOMask("L0",0,2)
#asynSetTraceMask("L0",0,0x9)

dbLoadRecords("$(IP)/db/Tabor8024.db", "P=13Tabor1:, R=AWG:, NELM=64536, PORT=L0, ADDR=0")

#var streamDebug 1

< ../save_restore_IOCSH.cmd
save_restoreSet_status_prefix("13Tabor1:")
dbLoadRecords("$(AUTOSAVE)/asApp/Db/save_restoreStatus.db", "P=13Tabor1:")

epicsEnvSet(STREAM_PROTOCOL_PATH, $(IP)/db)

date

# devIocStats
epicsEnvSet("ENGINEER", "Mark Rivers")
epicsEnvSet("LOCATION","Sector 13 portable")
epicsEnvSet("GROUP","GSECARS")
dbLoadRecords("$(DEVIOCSTATS)/db/iocAdminSoft.db","IOC=13Tabor1:")

iocInit

### Start up the autosave task and tell it what to do.
# The task is actually named "save_restore".
# (See also, 'initHooks' above, which is the means by which the values that
# will be saved by the task we're starting here are going to be restored.
#
# save other things every thirty seconds
create_monitor_set("auto_settings.req", 30, "P=13Tabor1:, R=AWG:")



