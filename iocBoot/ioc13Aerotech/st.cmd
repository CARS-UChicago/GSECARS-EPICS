errlogInit(5000)
< envPaths
# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in this build from CARS
dbLoadDatabase("../../dbd/CARSLinux.dbd")
CARSLinux_registerRecordDeviceDriver(pdbbase)

###########################################################
# Configure asyn device
#
#!EnsemblePort = "tcp1"
drvAsynIPPortConfigure(EnsemblePort,"164.54.160.249:8000", 0, 0, 0)
#asynSetTraceMask("EnsemblePort",-1,0xFF)
asynSetTraceIOMask("EnsemblePort",-1,0x1)
# The Ensemble driver does not set end of string (EOS).
asynOctetSetInputEos(EnsemblePort,0,"\n")
asynOctetSetOutputEos(EnsemblePort,0,"\n")

EnsembleAsynSetup(1)

#     (1) Controller number being configured
#     (2) ASYN port name
#     (3) ASYN address (GPIB only)
#     (4) Number of axes this controller supports
#     (5) Time to poll (msec) when an axis is in motion
#     (6) Time to poll (msec) when an axis is idle. 0 for no polling
EnsembleAsynConfig(0, EnsemblePort, 0, 1, 100, 1000)

# Asyn-based Motor Record support
#   (1) Asyn port
#   (2) Driver name
#   (3) Controller index
#   (4) Max. number of axes
drvAsynMotorConfigure("AeroE1","motorEnsemble",0,1)

### Motors
dbLoadTemplate  "motors.template"

# A set of scan parameters for each positioner.  This is a convenience
# for the user.  It can contain an entry for each scannable thing in the
# crate.
dbLoadTemplate "scanParms.template"

### Allstop, alldone
dbLoadRecords("$(MOTOR)/db/motorUtil.db","P=13AERO1:")

### Scan-support software
# crate-resident scan.  This executes 1D, 2D, 3D, and 4D scans, and caches
# 1D data, but it doesn't store anything to disk.  (You need the data catcher
# or the equivalent for that.)  This database is configured to use the
# "alldone" database (above) to figure out when motors have stopped moving
# and it's time to trigger detectors.
dbLoadRecords("$(SSCAN)/sscanApp/Db/scan.db", "P=13AERO1:,MAXPTS1=2000,MAXPTS2=200,MAXPTS3=20,MAXPTS4=10,MAXPTSH=10")

# Free-standing user string/number calculations (sCalcout records)
dbLoadRecords("$(CALC)/calcApp/Db/userStringCalcs10.db", "P=13AERO1:")

# Free-standing user transforms (transform records)
dbLoadRecords("$(CALC)/calcApp/Db/userTransforms10.db", "P=13AERO1:")

# Miscellaneous PV's, such as burtResult
dbLoadRecords("$(STD)/db/misc.db", "P=13AERO1:")

< ../save_restore_IOCSH.cmd
save_restoreSet_status_prefix("13AERO1:")
dbLoadRecords("$(AUTOSAVE)/asApp/Db/save_restoreStatus.db", "P=13AERO1:")

dbLoadRecords("$(ASYN)/db/asynRecord.db", "P=13AERO1:,R=asyn1,PORT=EnsemblePort,ADDR=0,OMAX=256,IMAX=256")
dbLoadRecords("$(ASYN)/db/asynRecord.db", "P=13AERO1:,R=asyn2,PORT=AeroE1,ADDR=0,OMAX=256,IMAX=256")

iocInit

### Start up the autosave task and tell it what to do.
# The task is actually named "save_restore".
# (See also, 'initHooks' above, which is the means by which the values that
# will be saved by the task we're starting here are going to be restored.
#
# save positions every five seconds
create_monitor_set("auto_positions.req", 5, "P=13AERO1:")
# save other things every thirty seconds
create_monitor_set("auto_settings.req", 30, "P=13AERO1:")
