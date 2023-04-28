# Linux startup script for 13-ID-C
< envPaths

#dbLoadDatabase("$(CARS)/dbd/CARSWin32.dbd")
#CARSWin32_registerRecordDeviceDriver(pdbbase)
dbLoadDatabase("$(CARS)/dbd/CARSLinux.dbd")
CARSLinux_registerRecordDeviceDriver(pdbbase)

epicsEnvSet("PREFIX", "13IDC_TEST:")

#iocshLoad("serial.cmd",     "P=$(PREFIX), TS=gsets19")
iocshLoad("MeasComp.cmd",   "P=$(PREFIX)")


#dbLoadTemplate("motors.template")

< ../save_restore_IOCSH.cmd
save_restoreSet_status_prefix("$(PREFIX)")
dbLoadRecords("$(AUTOSAVE)/db/save_restoreStatus.db", "P=$(PREFIX)")

# devIocStats
epicsEnvSet("ENGINEER", "Mark Rivers")
epicsEnvSet("LOCATION","Gas loading system")
epicsEnvSet("GROUP","GSECARS")
dbLoadRecords("$(DEVIOCSTATS)/db/iocAdminSoft.db","IOC=$(PREFIX)")

iocInit

### Start up the autosave task and tell it what to do.
# The task is actually named "save_restore".
# (See also, 'initHooks' above, which is the means by which the values that
# will be saved by the task we're starting here are going to be restored.
#
# save positions every five seconds
#create_monitor_set("auto_positions.req", 5, "P=$(PREFIX)")
# save other things every thirty seconds
create_monitor_set("auto_settings.req", 30, "USB3104_PREFIX=$(USB3104_PREFIX), USB1808_PREFIX=$(USB1808_PREFIX),USBCTR_PREFIX=$(USBCTR_PREFIX), MCS_PREFIX=$(MCS_PREFIX)")

