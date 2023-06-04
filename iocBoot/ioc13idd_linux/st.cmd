# Linux startup script for 13-ID-D
< envPaths

dbLoadDatabase("$(CARS)/dbd/CARSLinux.dbd")
CARSLinux_registerRecordDeviceDriver(pdbbase)

epicsEnvSet("PREFIX", "13IDD:")
epicsEnvSet("P", "13IDD:")
epicsEnvSet("LINUX_PREFIX", "13IDD_Linux:")

# Tell StreamDevice where to find protocol files
iocshCmd("epicsEnvSet(STREAM_PROTOCOL_PATH, $(IP)/db:$(DELAYGEN)/db:$(CARS)/db)")

iocshLoad("serial.cmd",          "P=$(PREFIX), TS=gsets19")
iocshLoad("MeasComp_EDIO24.cmd", "P=$(PREFIX)")
iocshLoad("Koyo.cmd",            "P=$(PREFIX)LaserPLC:")
iocshLoad("motors.cmd",          "P=$(PREFIX)")

# User calc stuff
iocshLoad("../calc_GSECARS.iocsh", "P=$(PREFIX))

< ../save_restore_IOCSH.cmd
save_restoreSet_status_prefix("$(PREFIX)")
dbLoadRecords("$(AUTOSAVE)/db/save_restoreStatus.db", "P=$(LINUX_PREFIX)")

# devIocStats
epicsEnvSet("ENGINEER", "Mark Rivers")
epicsEnvSet("LOCATION","13IDD roof")
epicsEnvSet("GROUP","GSECARS")
dbLoadRecords("$(DEVIOCSTATS)/db/iocAdminSoft.db","IOC=$(LINUX_PREFIX)")

iocInit

### Start up the autosave task and tell it what to do.
# The task is actually named "save_restore".
# (See also, 'initHooks' above, which is the means by which the values that
# will be saved by the task we're starting here are going to be restored.
#
# save positions every five seconds
create_monitor_set("auto_positions.req",5,"P=$(PREFIX)")
# save other things every thirty seconds
create_monitor_set("auto_settings.req",30,"P=$(PREFIX), EDIO24_PREFIX=$(EDIO24_PREFIX)")

