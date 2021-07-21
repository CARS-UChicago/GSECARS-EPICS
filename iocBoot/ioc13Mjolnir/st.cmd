errlogInit(5000)
< envPaths
# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in this build from CARS
dbLoadDatabase("../../dbd/CARSLinux.dbd")
CARSLinux_registerRecordDeviceDriver(pdbbase)

epicsEnvSet(PREFIX, 13MNIR:)
epicsEnvSet(E1608_PREFIX,  $(PREFIX)E1608:)
epicsEnvSet(ISCO_PREFIX,   $(PREFIX)ISCO:)
epicsEnvSet(VINDUM_PREFIX, $(PREFIX)VINDUM:)

# E1608 used for pressure transducers, LVDT, and strain gauge
< E1608.cmd

# ISCO pumps
< ISCO.cmd

# Vindum pump, used for fluid flow
< Vindum.cmd

< ../calc_GSECARS.iocsh

### Scan-support software
dbLoadRecords("$(SSCAN)/db/scan.db", "P=$(PREFIX),MAXPTS1=2000,MAXPTS2=200,MAXPTS3=20,MAXPTS4=10,MAXPTSH=10")

# Load an asyn record for debugging
dbLoadRecords("$(ASYN)/db/asynRecord.db", "P=$(PREFIX), R=asyn1, PORT=$(PORT), ADDR=0, IMAX=256, OMAX=256")

< ../save_restore_IOCSH.cmd
save_restoreSet_status_prefix("$(PREFIX)")
dbLoadRecords("$(AUTOSAVE)/db/save_restoreStatus.db", "P=$(PREFIX)")

# devIocStats
epicsEnvSet("ENGINEER", "Mark Rivers")
epicsEnvSet("LOCATION","Sector 13 portable")
epicsEnvSet("GROUP","GSECARS")
dbLoadRecords("$(DEVIOCSTATS)/db/iocAdminSoft.db","IOC=$(PREFIX)")

iocInit

### Start up the autosave task and tell it what to do.
# The task is actually named "save_restore".
# (See also, 'initHooks' above, which is the means by which the values that
# will be saved by the task we're starting here are going to be restored.
#
# Save things every thirty seconds
create_monitor_set("auto_settings.req", 30, "E1608_PREFIX=$(E1608_PREFIX), ISCO_PREFIX=$(ISCO_PREFIX), VINDUM_PREFIX=$(VINDUM_PREFIX)")

# Need to force the time arrays to process because the records are scan=I/O Intr
# but asynPortDriver does not do array callbacks before iocInit.

dbpf $(E1608_PREFIX)WaveDigDwell.PROC 1

