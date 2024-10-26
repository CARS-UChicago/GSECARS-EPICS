# Linux startup script for 13-ID-D
< envPaths

dbLoadDatabase("$(CARS)/dbd/CARSLinux.dbd")
CARSLinux_registerRecordDeviceDriver(pdbbase)

epicsEnvSet("PREFIX", "13BMD:")
epicsEnvSet("P", "13BMD:")

# Tell StreamDevice where to find protocol files
iocshCmd("epicsEnvSet(STREAM_PROTOCOL_PATH, $(IP)/db:$(DELAYGEN)/db:$(CARS)/db)")

iocshLoad("serial.cmd",          "P=$(PREFIX), TS=gsets18")
iocshLoad("MeasComp.cmd",        "P=$(PREFIX)")
iocshLoad("Koyo.cmd",            "P=$(PREFIX)")
iocshLoad("motors.cmd",          "P=$(PREFIX)")

dbLoadTemplate "DAC_ExternalHeating.template"
dbLoadTemplate "DAC_SparePID.template"
dbLoadTemplate "LVP_furnace_control.template"

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
dbLoadRecords("$(AUTOSAVE)/db/save_restoreStatus.db", "P=$(PREFIX)")

# devIocStats
epicsEnvSet("ENGINEER", "Mark Rivers")
epicsEnvSet("LOCATION","13BMD roof")
epicsEnvSet("GROUP","GSECARS")
dbLoadRecords("$(DEVIOCSTATS)/db/iocAdminSoft.db","IOC=$(PREFIX)")

iocInit

### Start up the autosave task and tell it what to do.
# The task is actually named "save_restore".
# (See also, 'initHooks' above, which is the means by which the values that
# will be saved by the task we're starting here are going to be restored.
#
# save positions every five seconds
create_monitor_set("auto_positions.req",5,"P=$(PREFIX)")
# save other things every thirty seconds
create_monitor_set("auto_settings.req", 30, "P=$(PREFIX),P3104=$(USB3104_PREFIX),P1808=$(USB1808_PREFIX),PEDIO24=$(EDIO24_PREFIX),PCTR=$(USBCTR_PREFIX), MP=$(MCS_PREFIX), SP=$(SCALER_PREFIX)"
