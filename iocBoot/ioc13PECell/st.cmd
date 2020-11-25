errlogInit(5000)
< envPaths
# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in this build from CARS
dbLoadDatabase("../../dbd/CARSLinux.dbd")
CARSLinux_registerRecordDeviceDriver(pdbbase)

epicsEnvSet(PREFIX, "13PECELL:")
# serial support
< serial.cmd

# Slow feedback
dbLoadTemplate "heater_control.template"

### Scan-support software
# crate-resident scan.  This executes 1D, 2D, 3D, and 4D scans, and caches
# 1D data, but it doesn't store anything to disk.  (See 'saveData' below for that.)
dbLoadRecords("$(SSCAN)/db/scan.db","P=$(PREFIX),MAXPTS1=8000,MAXPTS2=1000,MAXPTS3=100,MAXPTS4=100,MAXPTSH=8000")

< ../save_restore_IOCSH.cmd
save_restoreSet_status_prefix("$(PREFIX)")
dbLoadRecords("$(AUTOSAVE)/db/save_restoreStatus.db", "P=$(PREFIX)")

# devIocStats
epicsEnvSet("ENGINEER", "Mark Rivers")
epicsEnvSet("LOCATION","Sector 13 portable")
epicsEnvSet("GROUP","GSECARS")
dbLoadRecords("$(DEVIOCSTATS)/db/iocAdminSoft.db","IOC=$(PREFIX)")

asynSetTraceMask("serial2",0,9)

###############################################################################
iocInit

asynSetTraceMask("serial2",0,9)

# Keithley 2700 series DMM
# channels: 10, 20, or 22;  model: 2000 or 2700
seq &Keithley2kDMM,("P=$(PREFIX), Dmm=DMM1:, channels=22, model=2700")

### Start up the autosave task and tell it what to do.
# The task is actually named "save_restore".
# Note that you can reload these sets after creating them: e.g., 
# reload_monitor_set("auto_settings.req",30,"P=$(PREFIX)")
#save_restoreDebug=20
#
# save other things every thirty seconds
create_monitor_set("auto_settings.req",30,"P=$(PREFIX)")

dbcar(0,1)


