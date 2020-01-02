errlogInit(5000)
< envPaths
# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in this build from CARS
dbLoadDatabase("../../dbd/CARSLinux.dbd")
CARSLinux_registerRecordDeviceDriver(pdbbase)

###########################################################
# Configure asyn device
#
pmacAsynIPConfigure("PMAC_IP","164.54.160.54:1025",0,0,0)
#asynSetTraceMask("PMAC_IP",-1,0xFF)
asynSetTraceIOMask("PMAC_IP",-1,0x1)
#asynSetTraceMask("PMAC_IP",-1,0x1)
#asynSetTraceIOMask("PMAC_IP",-1,0x0)

pmacAsynMotorCreate("PMAC_IP", 0, 0, 9);

# Setup the motor Asyn layer (portname, low-level driver drvet name, card, number of axes on card)
drvAsynMotorConfigure("PMAC1", "pmacAsynMotor", 0, 9)

### Motors
dbLoadTemplate  "motors.template"

# A set of scan parameters for each positioner.  This is a convenience
# for the user.  It can contain an entry for each scannable thing in the
# crate.
dbLoadTemplate "scanParms.template"

### Allstop, alldone
dbLoadRecords("$(MOTOR)/db/motorUtil.db","P=13PMAC1:")

### Scan-support software
# crate-resident scan.  This executes 1D, 2D, 3D, and 4D scans, and caches
# 1D data, but it doesn't store anything to disk.  (You need the data catcher
# or the equivalent for that.)  This database is configured to use the
# "alldone" database (above) to figure out when motors have stopped moving
# and it's time to trigger detectors.
dbLoadRecords("$(SSCAN)/sscanApp/Db/scan.db", "P=13PMAC1:,MAXPTS1=2000,MAXPTS2=200,MAXPTS3=20,MAXPTS4=10,MAXPTSH=10")

# Free-standing user string/number calculations (sCalcout records)
dbLoadRecords("$(CALC)/db/userStringCalcs10.db", "P=13PMAC1:")

# Free-standing user transforms (transform records)
dbLoadRecords("$(CALC)/db/userTransforms10.db", "P=13PMAC1:")

# Miscellaneous PV's, such as burtResult
dbLoadRecords("$(STD)/db/misc.db", "P=13PMAC1:")

< ../save_restore_IOCSH.cmd
save_restoreSet_status_prefix("13PMAC1:")
dbLoadRecords("$(AUTOSAVE)/asApp/Db/save_restoreStatus.db", "P=13PMAC1:")

dbLoadRecords("$(ASYN)/db/asynRecord.db", "P=13PMAC1:,R=asyn1,PORT=PMAC_IP,ADDR=0,OMAX=256,IMAX=256")
dbLoadRecords("$(ASYN)/db/asynRecord.db", "P=13PMAC1:,R=asyn2,PORT=PMAC1,ADDR=0,OMAX=256,IMAX=256")

iocInit

### Start up the autosave task and tell it what to do.
# The task is actually named "save_restore".
# (See also, 'initHooks' above, which is the means by which the values that
# will be saved by the task we're starting here are going to be restored.
#
# save positions every five seconds
create_monitor_set("auto_positions.req", 5, "P=13PMAC1:")
# save other things every thirty seconds
create_monitor_set("auto_settings.req", 30, "P=13PMAC1:")
