errlogInit(5000)
< envPaths

epicsEnvSet(STREAM_PROTOCOL_PATH, $(IP)/ipApp/Db:$(DELAYGEN)/delayGenApp/Db)

cd $(TOP)/iocBoot/$(IOC)

# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in this build from CARS
dbLoadDatabase("../../dbd/CARS.dbd")
CARS_registerRecordDeviceDriver(pdbbase)

# Set up serial ports on Moxa box
drvAsynIPPortConfigure("serial1", "gsets3:4001", 0, 0)
drvAsynIPPortConfigure("serial2", "gsets3:4002", 0, 0)
drvAsynIPPortConfigure("serial3", "gsets3:4003", 0, 0)
drvAsynIPPortConfigure("serial4", "gsets3:4004", 0, 0)

# Make these ports available from the iocsh command line
asynOctetConnect("serial1", "serial1", 0, 1, 80)
asynOctetConnect("serial2", "serial2", 0, 1, 80)
asynOctetConnect("serial3", "serial3", 0, 1, 80)
asynOctetConnect("serial4", "serial4", 0, 1, 80)
asynOctetSetInputEos("serial1",0,"\r")
asynOctetSetOutputEos("serial1",0,"\r")
asynOctetSetInputEos("serial2",0,"\r")
asynOctetSetOutputEos("serial2",0,"\r")
asynOctetSetInputEos("serial3",0,"\r")
asynOctetSetOutputEos("serial3",0,"\r")
asynOctetSetInputEos("serial4",0,"\r\n")
asynOctetSetOutputEos("serial4",0,"\r\n")

#asynSetTraceIOMask("serial1", 0, 2)
#asynSetTraceIOMask("serial2", 0, 2)
#asynSetTraceMask("serial1", 0, 255)
#asynSetTraceMask("serial2", 0, 255)

# Load asyn records on each of these ports
dbLoadTemplate("asynRecord.template")

### Motors
dbLoadTemplate  "motors.template"

# IPG laser
dbLoadRecords("$(CARS)/CARSApp/Db/IPG_YLR_laser.db","P=13Laser:,R=Laser1,PORT=serial3")

# BNC-505 Pulse/Delay Generator
dbLoadTemplate("BNC_505.substitutions")

# A set of scan parameters for each positioner.  This is a convenience
# for the user.  It can contain an entry for each scannable thing in the
# crate.
dbLoadTemplate "scanParms.template"

### Allstop, alldone
# This database must agree with the motors you've actually loaded.
# Several versions (e.g., all_com_32.db) are in stdApp/Db
dbLoadRecords("$(STD)/stdApp/Db/all_com_4.db", "P=13Laser:")

### Scan-support software
# crate-resident scan.  This executes 1D, 2D, 3D, and 4D scans, and caches
# 1D data, but it doesn't store anything to disk.  (You need the data catcher
# or the equivalent for that.)  This database is configured to use the
# "alldone" database (above) to figure out when motors have stopped moving
# and it's time to trigger detectors.
dbLoadRecords("$(SSCAN)/sscanApp/Db/scan.db", "P=13Laser:,MAXPTS1=2000,MAXPTS2=200,MAXPTS3=20,MAXPTS4=10,MAXPTSH=10")

# Free-standing user string/number calculations (sCalcout records)
dbLoadRecords("$(CALC)/calcApp/Db/userStringCalcs10.db", "P=13Laser:")

# Free-standing user transforms (transform records)
dbLoadRecords("$(CALC)/calcApp/Db/userTransforms10.db", "P=13Laser:")

# Miscellaneous PV's, such as burtResult
dbLoadRecords("$(STD)/stdApp/Db/misc.db", "P=13Laser:")

# MCB-4B driver setup parameters:
#     (1) maximum # of controllers,
#     (2) maximum # axis per controller
#     (3) motor task polling rate (min=1Hz, max=60Hz)
MCB4BSetup(2, 4, 10)

# MCB-4B driver configuration parameters:
#     (1) controller
#     (2) asyn port name (e.g. serial1)
MCB4BConfig(0, "serial1")
MCB4BConfig(1, "serial2")

< ../save_restore_IOCSH.cmd
save_restoreSet_status_prefix("13Laser:")
dbLoadRecords("$(AUTOSAVE)/asApp/Db/save_restoreStatus.db", "P=13Laser:")

iocInit

### Start up the autosave task and tell it what to do.
# The task is actually named "save_restore".
# (See also, 'initHooks' above, which is the means by which the values that
# will be saved by the task we're starting here are going to be restored.
#
# save positions every five seconds
create_monitor_set("auto_positions.req", 5, "P=13Laser:")
# save other things every thirty seconds
create_monitor_set("auto_settings.req", 30, "P=13Laser:")

