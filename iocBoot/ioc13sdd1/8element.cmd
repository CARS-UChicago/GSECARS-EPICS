< envPaths

# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in this build from dxpApp
dbLoadDatabase("../../dbd/CARS.dbd")
CARS_registerRecordDeviceDriver(pdbbase)

# Setup for save_restore
< ../save_restore.cmd
save_restoreSet_status_prefix("13SDD1:")
dbLoadRecords("$(AUTOSAVE)/db/save_restoreStatus.db", "P=13SDD1:")
set_pass0_restoreFile("auto_settings8.sav")
set_pass1_restoreFile("auto_settings8.sav")

# Set logging level (1=ERROR, 2=WARNING, 3=INFO, 4=DEBUG)
xiaSetLogLevel(2)
xiaInit("xmap8.ini")
xiaStartSystem

# DXPConfig(serverName, ndetectors, maxBuffers, maxMemory)
NDDxpConfig("DXP1",  8, -1, -1)

dbLoadTemplate("8element.substitutions")

# Need to include commonPlugins.cmd here if we want to use this file

#xiaSetLogLevel(4)
#asynSetTraceMask DXP1 0 255
asynSetTraceIOMask DXP1 0 2

### Scan-support software
# crate-resident scan.  This executes 1D, 2D, 3D, and 4D scans, and caches
# 1D data, but it doesn't store anything to disk.  (See 'saveData' below for that.)
dbLoadRecords("$(SSCAN)/db/scan.db","P=13SDD1:,MAXPTS1=2000,MAXPTS2=1000,MAXPTS3=10,MAXPTS4=10,MAXPTSH=2048")

iocInit

seq dxpMED, "P=13SDD1:, DXP=dxp, MCA=mca, N_DETECTORS=8, N_SCAS=16"

### Start up the autosave task and tell it what to do.
# Save settings every thirty seconds
create_monitor_set("auto_settings8.req", 30, "P=13SDD1:")

### Start the saveData task.
saveData_Init("saveData.req", "P=13SDD1:")

# Sleep for 10 seconds to let initialization complete and then turn on AutoApply and do Apply manually once
epicsThreadSleep(10.)
dbpf("13SDD1:AutoApply", "1")
dbpf("13SDD1:Apply", "1")
# Seems to be necessary to write mapping mode parameters, otherwise initial values are wrong?
dbpf("13SDD1:PixelsPerRun.PROC", "1");

