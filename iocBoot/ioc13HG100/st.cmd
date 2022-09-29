errlogInit(5000)
< envPaths

epicsEnvSet(PREFIX, 13HG100:)

# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in this build from CARS
dbLoadDatabase("../../dbd/CARSLinux.dbd")
CARSLinux_registerRecordDeviceDriver(pdbbase)

# Set up serial port on Moxa terminal server
# Must be set for 9600, 8, 1, None.
#drvAsynIPPortConfigure("serial1", "GSETS8:2101", 0, 0, 1)
drvAsynIPPortConfigure("serial1", "GSETS11:4001 COM", 0, 0, 1)
asynSetOption(serial1, 0, baud, 9600)
asynSetOption(serial1, 0, bits, 8)
asynSetOption(serial1, 0, stop, 1)
asynSetOption(serial1, 0, parity, none)


# Load asyn record
dbLoadRecords("$(ASYN)/db/asynRecord.db", "P=$(PREFIX), R=HG100:Asyn, PORT=serial1, ADDR=0, OMAX=80, IMAX=80")

dbLoadRecords("$(IP)/db/HG-100.db", "P=$(PREFIX), R=HG100:, PORT=serial1")

asynSetTraceIOMask(serial1, 0, 4)
asynSetTraceMask(serial1, 0, 9)

<../calc_GSECARS.iocsh

#PID slow
#dbLoadTemplate "pid_slow.substitutions"

< ../save_restore_IOCSH.cmd
save_restoreSet_status_prefix("$(PREFIX)")
dbLoadRecords("$(AUTOSAVE)/db/save_restoreStatus.db", "P=$(PREFIX)")

# devIocStats
epicsEnvSet("ENGINEER", "Mark Rivers")
epicsEnvSet("LOCATION","HG-100 humidity controller")
epicsEnvSet("GROUP","GSECARS")
dbLoadRecords("$(DEVIOCSTATS)/db/iocAdminSoft.db","IOC=$(PREFIX)")

epicsEnvSet(STREAM_PROTOCOL_PATH, $(IP)/db)

iocInit

### Start up the autosave task and tell it what to do.
# The task is actually named "save_restore".
# (See also, 'initHooks' above, which is the means by which the values that
# will be saved by the task we're starting here are going to be restored.
#
# save other things every thirty seconds
create_monitor_set("auto_settings.req", 30, "P=$(PREFIX)")
