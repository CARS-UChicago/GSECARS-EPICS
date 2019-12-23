errlogInit(5000)
< envPaths
# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in this build from CARS
dbLoadDatabase("../../dbd/CARSLinux.dbd")
CARSLinux_registerRecordDeviceDriver(pdbbase)

### Motors
dbLoadTemplate  "motors.template"

################################################################################
# XPS Setup

# asyn port, IP address, IP port, number of axes, 
# active poll period (ms), idle poll period (ms), 
# enable set position, set position settling time (ms)
# This is newport-xps9
XPSCreateController("XPS1", "newport-xps16", 5001, 1, 10, 200, 0, 500)
asynSetTraceIOMask("XPS1", 0, 2)
#asynSetTraceMask("XPS1", 0, 255)

# asynPort, IP address, IP port, poll period (ms)
#XPSAuxConfig("XPS_AUX1", "newport-xps16", 5001, 50)
#asynSetTraceIOMask("XPS_AUX1", 0, 2)
#asynSetTraceMask("XPS_AUX1", 0, 255)

# XPS asyn port,  axis, groupName.positionerName, stepSize
XPSCreateAxis("XPS1",0,"GROUP1.GPD_Z",  "10000")   

# XPS asyn port,  max points, FTP username, FTP password
# Note: this must be done after configuring axes
XPSCreateProfile("XPS1", 2000, "Administrator", "Administrator")

# A set of scan parameters for each positioner.  This is a convenience
# for the user.  It can contain an entry for each scannable thing in the
# crate.
dbLoadTemplate "scanParms.template"

### Allstop, alldone
dbLoadRecords("$(MOTOR)/motorApp/Db/motorUtil.db","P=13XPS:")

### Scan-support software
# crate-resident scan.  This executes 1D, 2D, 3D, and 4D scans, and caches
# 1D data, but it doesn't store anything to disk.  (You need the data catcher
# or the equivalent for that.)  This database is configured to use the
# "alldone" database (above) to figure out when motors have stopped moving
# and it's time to trigger detectors.
dbLoadRecords("$(SSCAN)/sscanApp/Db/scan.db", "P=13XPS:,MAXPTS1=2000,MAXPTS2=200,MAXPTS3=20,MAXPTS4=10,MAXPTSH=10")

# Free-standing user string/number calculations (sCalcout records)
dbLoadRecords("$(CALC)/calcApp/Db/userStringCalcs10.db", "P=13XPS:")

# Free-standing user transforms (transform records)
dbLoadRecords("$(CALC)/calcApp/Db/userTransforms10.db", "P=13XPS:")

# Miscellaneous PV's, such as burtResult
dbLoadRecords("$(STD)/stdApp/Db/misc.db", "P=13XPS:")

< ../save_restore_IOCSH.cmd
save_restoreSet_status_prefix("13XPS:")
dbLoadRecords("$(AUTOSAVE)/asApp/Db/save_restoreStatus.db", "P=13XPS:")

dbLoadRecords("$(ASYN)/db/asynRecord.db", "P=13XPS:,R=asyn1,PORT=XPS1,ADDR=0,IMAX=256,OMAX=256")

asynSetTraceIOMask("XPS1",0,2)
#asynSetTraceMask("XPS1",0,255)
asynSetTraceIOTruncateSize("XPS1",0,200)
iocInit

# save positions every five seconds
create_monitor_set("auto_positions.req", 5, "P=13XPS:")
# save other things every thirty seconds
create_monitor_set("auto_settings.req", 30, "P=13XPS:")

