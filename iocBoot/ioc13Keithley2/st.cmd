errlogInit(5000)
< envPaths
# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in this build from CARS
dbLoadDatabase("../../dbd/CARSLinux.dbd")
CARSLinux_registerRecordDeviceDriver(pdbbase)

< serial.cmd

### Scan-support software
# crate-resident scan.  This executes 1D, 2D, 3D, and 4D scans, and caches
# 1D data, but it doesn't store anything to disk.  (You need the data catcher
# or the equivalent for that.)  This database is configured to use the
# "alldone" database (above) to figure out when motors have stopped moving
# and it's time to trigger detectors.
dbLoadRecords("$(SSCAN)/db/scan.db", "P=13Keithley2:,MAXPTS1=2000,MAXPTS2=200,MAXPTS3=20,MAXPTS4=10,MAXPTSH=10")

# Free-standing user string/number calculations (sCalcout records)
dbLoadRecords("$(CALC)/db/userStringCalcs10.db", "P=13Keithley2:")

# Free-standing user transforms (transform records)
dbLoadRecords("$(CALC)/db/userTransforms10.db", "P=13Keithley2:")

# Miscellaneous PV's, such as burtResult
dbLoadRecords("$(STD)/db/misc.db", "P=13Keithley2:")

< ../save_restore_IOCSH.cmd
save_restoreSet_status_prefix("13Keithley2:")
dbLoadRecords("$(AUTOSAVE)/db/save_restoreStatus.db", "P=13Keithley2:")

# devIocStats
epicsEnvSet("ENGINEER", "Mark Rivers")
epicsEnvSet("LOCATION","Gas loading system")
epicsEnvSet("GROUP","GSECARS")
dbLoadRecords("$(DEVIOCSTATS)/db/iocAdminSoft.db","IOC=13Keithley2:")

iocInit

# save positions every five seconds
#create_monitor_set("auto_positions.req", 5, "P=13Keithley2:")
# save other things every thirty seconds
create_monitor_set("auto_settings.req", 30, "P=13Keithley2:")

seq &Keithley2kDMM, "P=13Keithley2:, Dmm=DMM1, channels=22, model=2700, stack=10000"

