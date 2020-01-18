< envPaths
dbLoadDatabase("$(CARS)/dbd/CARSLinux.dbd")
CARSLinux_registerRecordDeviceDriver(pdbbase)

epicsEnvSet("PREFIX", "13LABTC:"

# Records
dbLoadRecords("$(CARS)/db/TomoCollect.template", "P=$(PREFIX),R=TC:")

< ../save_restore_IOCSH.cmd
save_restoreSet_status_prefix("13BMDTC:")
dbLoadRecords("$(AUTOSAVE)/db/save_restoreStatus.db", "P=$(PREFIX)")

iocInit

### Start up the autosave task and tell it what to do.
# The task is actually named "save_restore".
# (See also, 'initHooks' above, which is the means by which the values that
# will be saved by the task we're starting here are going to be restored.
#
# save other things every thirty seconds
create_monitor_set("auto_settings.req",30,"P=$(PREFIX)")

seq(tomoCollect, "P=13LABTC:,R=TC:")
