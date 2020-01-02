errlogInit(5000)
< envPaths
# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in this build from CARS
dbLoadDatabase("../../dbd/CARSLinux.dbd")
CARSLinux_registerRecordDeviceDriver(pdbbase)

epicsEnvSet("PREFIX", "13TEST:")

dbLoadRecords("$(STD)/db/yySseq.db", "P=13TEST:, S=SSEQ1")

< ../save_restore_IOCSH.cmd
save_restoreSet_status_prefix("13TEST:")
dbLoadRecords("$(AUTOSAVE)/asApp/Db/save_restoreStatus.db", "P=13TEST:")

<../calc_GSECARS.iocsh

iocInit

### Start up the autosave task and tell it what to do.
# The task is actually named "save_restore".
# (See also, 'initHooks' above, which is the means by which the values that
# will be saved by the task we're starting here are going to be restored.
#
# save other things every thirty seconds
create_monitor_set("auto_settings.req", 30, "P=13TEST:")

