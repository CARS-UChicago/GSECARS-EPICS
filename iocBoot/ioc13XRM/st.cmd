< envPaths
errlogInit(5000)

# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in this build from CARS
dbLoadDatabase("../../dbd/CARSLinux.dbd")
CARSLinux_registerRecordDeviceDriver(pdbbase)

### Motors
dbLoadTemplate  "motors.template"

################################################################################
# XPS Setup
< XPSD.cmd

< XPSC.cmd

dbLoadTemplate("scanParms.template")
dbLoadRecords("$(MOTOR)/db/motorUtil.db","P=13XRM:")

# Monochromator slow PID
dbLoadTemplate("mono_pid.template")


### Scan-support software
# crate-resident scan.  This executes 1D, 2D, 3D, and 4D scans, and caches
# 1D data, but it doesn't store anything to disk.  (You need the data catcher
# or the equivalent for that.)  This database is configured to use the
# "alldone" database (above) to figure out when motors have stopped moving
# and it's time to trigger detectors.
dbLoadRecords("$(SSCAN)/db/scan.db", "P=13XRM:,MAXPTS1=2000,MAXPTS2=500,MAXPTS3=50,MAXPTS4=10,MAXPTSH=10")

# Free-standing user string/number calculations (sCalcout records)
dbLoadRecords("$(CALC)/db/userStringCalcs10.db", "P=13XRM:")

# Free-standing user transforms (transform records)
dbLoadRecords("$(CALC)/db/userTransforms10.db", "P=13XRM:")
# dbLoadRecords("$(CARS)/db/auto_shutter.db","P=13IDE:,SHUT=ShutterA:")

# Miscellaneous PV's, such as burtResult
dbLoadRecords("$(STD)/db/misc.db", "P=13XRM:")

< ../save_restore_IOCSH.cmd
save_restoreSet_status_prefix("13XRM:")
dbLoadRecords("$(AUTOSAVE)/db/save_restoreStatus.db", "P=13XRM:")

dbLoadRecords("$(ASYN)/db/asynRecord.db", "P=13XRM:,R=asyn1,PORT=XPSD,ADDR=0,IMAX=256,OMAX=256")

< MattsStuff.cmd

#dbLoadRecords("$(CARS)/db/zeromotors.db","P=13XRM:,DEV=Stage,M1=13XRM:m1.VAL,M2=13XRM:m2.VAL,M3=13XRM:m4.VAL,M4=13XRM:m6.VAL")


# devIocStats
epicsEnvSet("ENGINEER", "Matt Newville")
epicsEnvSet("LOCATION","corvette")
epicsEnvSet("GROUP","GSECARS")
dbLoadRecords("$(DEVIOCSTATS)/db/iocAdminSoft.db","IOC=13XRM:")

# AH501 electrometer for E branch
epicsEnvSet("EPICS_DB_INCLUDE_PATH", $(ADCORE)/db:$(QUADEM)/db)
< AH501.cmd

iocInit

motorUtilInit("13XRM:")

# save positions every five seconds
create_monitor_set("auto_positions.req", 5, "P=13XRM:")
# save other things every thirty seconds
create_monitor_set("auto_settings.req", 30, "P=13XRM:")

dbpf("13XRM:m1.NTM","0")
dbpf("13XRM:m2.NTM","0")
dbpf("13XRM:m3.NTM","0")
dbpf("13XRM:m4.NTM","0")
dbpf("13XRM:m5.NTM","0")
dbpf("13XRM:m6.NTM","0")
dbpf("13XRM:m7.NTM","0")
dbpf("13XRM:m8.NTM","0")
# dbpf("13XRM:pm1C1","0.70710678")
# dbpf("13XRM:pm1C2","0.70710678")
# dbpf("13XRM:pm2C1","0.70710678")
# dbpf("13XRM:pm2C2","0.70710678")

