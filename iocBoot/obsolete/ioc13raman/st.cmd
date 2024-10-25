errlogInit(5000)
< envPaths
# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in this build from CARS
dbLoadDatabase("../../dbd/CARSWin32.dbd")
CARSWin32_registerRecordDeviceDriver(pdbbase)

# Set up 2 local serial ports
# COM1 is for spectrometer, not EPICS
#drvAsynSerialPortConfigure("serial1", "/dev/ttyS0", 0, 0, 0)
#asynSetOption(serial1,0,baud,19200)
#asynSetOption(serial1,0,parity,none)
drvAsynSerialPortConfigure("serial2", "COM2", 0, 0, 0)
asynSetTraceIOMask("serial2",0,2)
#asynSetTraceMask("serial2",0,255)
asynSetOption(serial2,0,baud,19200)
asynSetOption(serial2,0,parity,none)
asynSetOption(serial2,0,bits,8)
asynSetOption(serial2,0,stop,1)
asynOctetSetInputEos("serial2",0,"\r")
asynOctetSetOutputEos("serial2",0,"\r")
# Make these ports available from the iocsh command line
#asynOctetConnect("serial1", "serial1")
asynOctetConnect("serial2", "serial2")


# Load asyn records on each of these ports
dbLoadTemplate("asynRecord.template")

### Motors
dbLoadTemplate  "motors.template"

# A set of scan parameters for each positioner.  This is a convenience
# for the user.  It can contain an entry for each scannable thing in the
# crate.
dbLoadTemplate "scanParms.template"

### Allstop, alldone
# This database must agree with the motors you've actually loaded.
# Several versions (e.g., all_com_32.db) are in stdApp/Db
#dbLoadRecords("$(STD)/db/all_com_4.db", "P=13Raman:")
### motorUtil - for allstop, moving, etc.
dbLoadRecords("$(MOTOR)/db/motorUtil.db","P=13Raman:")

### Scan-support software
# crate-resident scan.  This executes 1D, 2D, 3D, and 4D scans, and caches
# 1D data, but it doesn't store anything to disk.  (You need the data catcher
# or the equivalent for that.)  This database is configured to use the
# "alldone" database (above) to figure out when motors have stopped moving
# and it's time to trigger detectors.
dbLoadRecords("$(SSCAN)/db/scan.db", "P=13Raman:,MAXPTS1=2000,MAXPTS2=200,MAXPTS3=20,MAXPTS4=10,MAXPTSH=10")

# Free-standing user string/number calculations (sCalcout records)
dbLoadRecords("$(CALC)/db/userStringCalcs10.db", "P=13Raman:")

# Free-standing user transforms (transform records)
dbLoadRecords("$(CALC)/db/userTransforms10.db", "P=13Raman:")

# Miscellaneous PV's, such as burtResult
dbLoadRecords("$(STD)/db/misc.db", "P=13Raman:")

# MCB-4B driver setup parameters:
#     (1) maximum # of controllers,
#     (2) maximum # axis per controller
#     (3) motor task polling rate (min=1Hz, max=60Hz)
MCB4BSetup(1, 4, 10)

# MCB-4B driver configuration parameters:
#     (1) controller
#     (2) asyn port name (e.g. serial1)
MCB4BConfig(0, "serial2")

< ../save_restore_IOCSH.cmd
save_restoreSet_status_prefix("13Raman:")
dbLoadRecords("$(AUTOSAVE)/db/save_restoreStatus.db", "P=13Raman:")

# devIocStats
epicsEnvSet("ENGINEER", "Mark Rivers")
epicsEnvSet("LOCATION","GSE laser lab")
epicsEnvSet("GROUP","GSECARS")
dbLoadRecords("$(DEVIOCSTATS)/db/iocAdminSoft.db","IOC=13Raman:")

iocInit

### Start up the autosave task and tell it what to do.
# The task is actually named "save_restore".
# (See also, 'initHooks' above, which is the means by which the values that
# will be saved by the task we're starting here are going to be restored.
#
# save positions every five seconds
create_monitor_set("auto_positions.req", 5, "P=13Raman:")
# save other things every thirty seconds
create_monitor_set("auto_settings.req", 30, "P=13Raman:")

