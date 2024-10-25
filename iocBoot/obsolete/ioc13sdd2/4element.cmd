< envPaths

# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in this build from dxpApp
dbLoadDatabase("$(DXP)/dbd/dxp.dbd")
dxp_registerRecordDeviceDriver(pdbbase)

# Setup for save_restore
< ../save_restore_IOCSH.cmd
save_restoreSet_status_prefix("13SDD2:")
dbLoadRecords("$(AUTOSAVE)/db/save_restoreStatus.db", "P=13SDD2:")
set_pass0_restoreFile("auto_settings4.sav")
set_pass1_restoreFile("auto_settings4.sav")

# Set logging level (1=ERROR, 2=WARNING, 3=XXX, 4=DEBUG)
xiaSetLogLevel(2)
xiaInit("xmap4.ini")
xiaStartSystem

# DXPConfig(serverName, ndetectors, ngroups, pollFrequency)
DXPConfig("DXP1",  4, 1, 100)

dbLoadTemplate("4element.template")

#xiaSetLogLevel(4)
#asynSetTraceMask DXP1 0 255
#asynSetTraceIOMask DXP1 0 2
#var dxpRecordDebug 10

### Scan-support software
# crate-resident scan.  This executes 1D, 2D, 3D, and 4D scans, and caches
# 1D data, but it doesn't store anything to disk.  (See 'saveData' below for that.)
dbLoadRecords("$(SSCAN)/db/scan.db","P=13SDD2:,MAXPTS1=2000,MAXPTS2=1000,MAXPTS3=10,MAXPTS4=10,MAXPTSH=2048")

#var "debug_saveData" 2
#var "debug_saveDataMsg" 2

iocInit

seq dxpMED, "P=13SDD2:, DXP=dxp, MCA=mca, N_DETECTORS=4"

### Start up the autosave task and tell it what to do.
# Save settings every thirty seconds
create_monitor_set("auto_settings4.req", 30, "P=13SDD2:")

### Start the saveData task.
saveData_Init("saveData.req", "P=13SDD2:")

