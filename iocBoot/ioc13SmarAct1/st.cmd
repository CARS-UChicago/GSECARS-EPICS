errlogInit(5000)
< envPaths
# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in this build from CARS
dbLoadDatabase("../../dbd/CARSLinux.dbd")
CARSLinux_registerRecordDeviceDriver(pdbbase)

epicsEnvSet(PREFIX, 13SA1:)

### Motors
dbLoadTemplate  "motors.template"

drvAsynIPPortConfigure("MCS2_ETH", "gse-smaract1:55551", 0, 0, 0)

dbLoadRecords("$(ASYN)/db/asynRecord.db", "P=$(PREFIX), R=asyn1, PORT=MCS2_ETH, ADDR=0, OMAX=256, IMAX=256")

# PORT, MCS_PORT, number of axes, active poll period (ms), idle poll period (ms)
MCS2CreateController("MCS2", "MCS2_ETH", 2, 100, 100)

#asynSetTraceMask("MCS2_ETH", 0, ERROR|DRIVER)
asynSetTraceIOMask("MCS2_ETH", -1, ESCAPE)

# A set of scan parameters for each positioner.  This is a convenience
# for the user.  It can contain an entry for each scannable thing in the
# crate.
dbLoadTemplate "scanParms.template"

### Allstop, alldone
dbLoadRecords("$(MOTOR)/db/motorUtil.db","P=$(PREFIX)")

### Scan-support software
# crate-resident scan.  This executes 1D, 2D, 3D, and 4D scans, and caches
# 1D data, but it doesn't store anything to disk.  (You need the data catcher
# or the equivalent for that.)  This database is configured to use the
# "alldone" database (above) to figure out when motors have stopped moving
# and it's time to trigger detectors.
dbLoadRecords("$(SSCAN)/db/scan.db", "P=$(PREFIX),MAXPTS1=2000,MAXPTS2=200,MAXPTS3=20,MAXPTS4=10,MAXPTSH=10")

< ../calc_GSECARS.iocsh
< ../save_restore_IOCSH.cmd
save_restoreSet_status_prefix("$(PREFIX)")
dbLoadRecords("$(AUTOSAVE)/db/save_restoreStatus.db", "P=$(PREFIX)")

iocInit

# save positions every five seconds
create_monitor_set("auto_positions.req", 5, "P=$(PREFIX)")
# save other things every thirty seconds
create_monitor_set("auto_settings.req", 30, "P=$(PREFIX)")

