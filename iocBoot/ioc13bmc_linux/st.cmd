# Linux startup script for 13-BM-C
< envPaths

dbLoadDatabase("$(CARS)/dbd/CARSLinux.dbd")
CARSLinux_registerRecordDeviceDriver(pdbbase)

epicsEnvSet("PREFIX", "13BMC:")
epicsEnvSet("LINUX_PREFIX", "13BMC_Linux:")

iocshLoad("serial.cmd",     "P=$(PREFIX), TS=gsets1")
iocshLoad("MeasComp.cmd",   "P=$(PREFIX)")

### Scan-support software
# crate-resident scan.  This executes 1D, 2D, 3D, and 4D scans, and caches
# 1D data, but it doesn't store anything to disk.  (You need the data catcher
# or the equivalent for that.)  This database is configured to use the
# "alldone" database (above) to figure out when motors have stopped moving
# and it's time to trigger detectors.
dbLoadRecords("$(SSCAN)/db/scan.db","P=$(PREFIX),MAXPTS1=2000,MAXPTS2=2000,MAXPTS3=100,MAXPTS4=100,MAXPTSH=2048")

# User calc stuff
iocshLoad("../calc_GSECARS.iocsh", "P=$(PREFIX)")

< ../save_restore_IOCSH.cmd
save_restoreSet_status_prefix("$(PREFIX)")
dbLoadRecords("$(AUTOSAVE)/db/save_restoreStatus.db", "P=$(LINUX_PREFIX)")

# devIocStats
epicsEnvSet("ENGINEER", "Mark Rivers")
epicsEnvSet("LOCATION","13BMC roof")
epicsEnvSet("GROUP","GSECARS")
dbLoadRecords("$(DEVIOCSTATS)/db/iocAdminSoft.db","IOC=$(LINUX_PREFIX)")

iocInit

### Start up the autosave task and tell it what to do.
# The task is actually named "save_restore".
# (See also, 'initHooks' above, which is the means by which the values that
# will be saved by the task we're starting here are going to be restored.
#
# save positions every five seconds
create_monitor_set("auto_positions.req", 5, "P=$(PREFIX)")
# save other things every thirty seconds
create_monitor_set("auto_settings.req", 30, "P=$(PREFIX),P3104=$(USB3104_PREFIX),P1808=$(USB1808_PREFIX),PEDIO24_1=$(EDIO24_1_PREFIX),PEDIO24_2=$(EDIO24_2_PREFIX),PCTR=$(USBCTR_PREFIX), MP=$(MCS_PREFIX), SP=$(SCALER_PREFIX)"

