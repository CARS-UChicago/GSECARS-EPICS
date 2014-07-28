< envPaths
dbLoadDatabase("$(CARS)/dbd/CARSLinux.dbd")
CARSLinux_registerRecordDeviceDriver(pdbbase)

# Records
dbLoadRecords("$(CARS)/CARSApp/Db/TomoCollect.template", "P=13BMDTC:,R=TC:")

< ../save_restore_IOCSH.cmd
save_restoreSet_status_prefix("13BMDTC:")
dbLoadRecords("$(AUTOSAVE)/asApp/Db/save_restoreStatus.db", "P=13BMDTC:")

iocInit

### Start up the autosave task and tell it what to do.
# The task is actually named "save_restore".
# (See also, 'initHooks' above, which is the means by which the values that
# will be saved by the task we're starting here are going to be restored.
#
# save other things every thirty seconds
create_monitor_set("auto_settings.req",30,"P=13BMDTC:")
