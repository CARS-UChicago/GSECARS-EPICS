errlogInit(5000)
< envPaths
# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in this build from CARS
dbLoadDatabase("../../dbd/CARSLinux.dbd")
CARSLinux_registerRecordDeviceDriver(pdbbase)

epicsEnvSet(PREFIX, 13GalilTest:)

# Configure controller
< galil.cmd

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

dbLoadTemplate("scanParms.template")

< ../save_restore_IOCSH.cmd

# Start the IOC
iocInit()

# Initialize saveData for step scans
saveData_Init("saveData.req", "P=$(PREFIX)")

# Save positions every 5 seconds
create_monitor_set("auto_positions.req", 5, "P=$(PREFIX)")
# Save other things every 30 seconds
create_monitor_set("auto_settings.req", 30, "P=$(PREFIX)")


