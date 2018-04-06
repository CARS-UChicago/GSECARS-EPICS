< envPaths

# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in this build from dxpApp
dbLoadDatabase("$(DXP)/dbd/dxp.dbd")
dxp_registerRecordDeviceDriver(pdbbase)

# The search path for database files
epicsEnvSet("EPICS_DB_INCLUDE_PATH", "$(ADCORE)/db")

# The default callback queue in EPICS base is only 2000 bytes. 
# The dxp detector system needs this to be larger to avoid the error message: 
# "callbackRequest: cbLow ring buffer full" 
# right after the epicsThreadSleep at the end of this script
callbackSetQueueSize(4000)

# Setup for save_restore
< ../save_restore_IOCSH.cmd
save_restoreSet_status_prefix("13SDD1:")
dbLoadRecords("$(AUTOSAVE)/asApp/Db/save_restoreStatus.db", "P=13SDD1:")
set_pass0_restoreFile("auto_settings4.sav")
set_pass1_restoreFile("auto_settings4.sav")

# Set logging level (1=ERROR, 2=WARNING, 3=INFO, 4=DEBUG)
xiaSetLogLevel(2)
xiaInit("xmap4.ini")
xiaStartSystem

# DXPConfig(serverName, ndetectors, maxBuffers, maxMemory)
NDDxpConfig("DXP1",  4, -1, -1)

dbLoadTemplate("4element.substitutions")

# Create a netCDF file saving plugin
NDFileNetCDFConfigure("DXP1NetCDF", 100, 0, "DXP1", 0)
dbLoadRecords("$(ADCORE)/db/NDFileNetCDF.template","P=13SDD1:,R=netCDF1:,PORT=DXP1NetCDF,ADDR=0,TIMEOUT=1")

#asynSetTraceMask DXP1 0 255
asynSetTraceIOMask DXP1 0 2

### Scan-support software
# crate-resident scan.  This executes 1D, 2D, 3D, and 4D scans, and caches
# 1D data, but it doesn't store anything to disk.  (See 'saveData' below for that.)
dbLoadRecords("$(SSCAN)/sscanApp/Db/scan.db","P=13SDD1:,MAXPTS1=2000,MAXPTS2=1000,MAXPTS3=10,MAXPTS4=10,MAXPTSH=2048")

iocInit

seq dxpMED, "P=13SDD1:, DXP=dxp, MCA=mca, N_DETECTORS=4, N_SCAS=16"

### Start up the autosave task and tell it what to do.
# Save settings every thirty seconds
create_monitor_set("auto_settings4.req", 30, "P=13SDD1:")

### Start the saveData task.
saveData_Init("saveData.req", "P=13SDD1:")

# Sleep for 10 seconds to let initialization complete and then turn on AutoApply and do Apply manually once
epicsThreadSleep(10.)
dbpf("13SDD1:AutoApply", "Yes")
dbpf("13SDD1:Apply", "1")
