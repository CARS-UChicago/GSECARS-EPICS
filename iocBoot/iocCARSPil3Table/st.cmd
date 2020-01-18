errlogInit(5000)
< envPaths

# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in this build from CARS
dbLoadDatabase("../../dbd/CARSLinux.dbd")
CARSLinux_registerRecordDeviceDriver(pdbbase)

# Set up serial port on Moxa box
# This should have the IP name pil3-mcb4b on either sector 13 or 15 subnet
# The DNS can take a while to update when the detector is moved so these addresses can be used 
# instead of the IP name in the following command if necessary
# Sector 13: 164.54.160.125
# Sector 15: 164.54.162.26
drvAsynIPPortConfigure("serial1", "pil3-mcb4b:4001", 0, 0)

# Make these ports available from the iocsh command line
asynOctetConnect("serial1", "serial1", 0, 1, 80)
asynOctetSetInputEos("serial1",0,"\r")
asynOctetSetOutputEos("serial1",0,"\r")

asynSetTraceIOMask("serial1", 0, 2)
#asynSetTraceMask("serial1", 0, 255)

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
dbLoadRecords("$(STD)/db/all_com_4.db", "P=CARSPil3Table:")

### Scan-support software
# crate-resident scan.  This executes 1D, 2D, 3D, and 4D scans, and caches
# 1D data, but it doesn't store anything to disk.  (You need the data catcher
# or the equivalent for that.)  This database is configured to use the
# "alldone" database (above) to figure out when motors have stopped moving
# and it's time to trigger detectors.
dbLoadRecords("$(SSCAN)/db/scan.db", "P=CARSPil3Table:,MAXPTS1=2000,MAXPTS2=200,MAXPTS3=20,MAXPTS4=10,MAXPTSH=10")

# Free-standing user string/number calculations (sCalcout records)
dbLoadRecords("$(CALC)/db/userStringCalcs10.db", "P=CARSPil3Table:")

# Free-standing user transforms (transform records)
dbLoadRecords("$(CALC)/db/userTransforms10.db", "P=CARSPil3Table:")

# Miscellaneous PV's, such as burtResult
dbLoadRecords("$(STD)/db/misc.db", "P=CARSPil3Table:")

# MCB-4B driver setup parameters:
#     (1) port name
#     (2) serial port name
#     (3) maximum # axis per controller
#     (4) moving poll period ms
#     (5) idle poll period ms
MCB4BCreateController("MCB4B_1", "serial1", 4, 100, 1000)

< ../save_restore_IOCSH.cmd
save_restoreSet_status_prefix("CARSPil3Table:")
dbLoadRecords("$(AUTOSAVE)/db/save_restoreStatus.db", "P=CARSPil3Table:")

# devIocStats
epicsEnvSet("ENGINEER", "Mark Rivers")
epicsEnvSet("LOCATION","GSE DAC lab")
epicsEnvSet("GROUP","GSECARS")
dbLoadRecords("$(DEVIOCSTATS)/db/iocAdminSoft.db","IOC=CARSPil3Table:")

iocInit

### Start up the autosave task and tell it what to do.
# The task is actually named "save_restore".
# (See also, 'initHooks' above, which is the means by which the values that
# will be saved by the task we're starting here are going to be restored.
#
# save positions every five seconds
create_monitor_set("auto_positions.req", 5, "P=CARSPil3Table:")
# save other things every thirty seconds
create_monitor_set("auto_settings.req", 30, "P=CARSPil3Table:")

