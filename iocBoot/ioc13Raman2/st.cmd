< envPaths
# Start errlog Task before any possible error messsage to prevent
# erroneous "Interrupted system call" message on Linux OS.
errlogInit(0)
#
dbLoadDatabase("$(CARS)/dbd/CARSLinux.dbd")
CARSLinux_registerRecordDeviceDriver(pdbbase)


################################################################################
# XPS Setup

# asyn port, IP address, IP port, number of axes, 
# active poll period (ms), idle poll period (ms), 
# enable set position, set position settling time (ms)
XPSCreateController("XPS1", "164.54.160.147", 5001, 5, 10, 500, 1, 500)
asynSetTraceIOMask("XPS1", 0, 2)
#asynSetTraceMask("XPS1", 0, 255)

# asynPort, IP address, IP port, poll period (ms)
XPSAuxConfig("XPS_AUX1", "164.54.160.147", 5001, 50)
#asynSetTraceIOMask("XPS_AUX1", 0, 2)
#asynSetTraceMask("XPS_AUX1", 0, 255)

# XPS asyn port,  axis, groupName.positionerName, stepSize
XPSCreateAxis("XPS1",0,"Group1.Pos",  "50000")  
XPSCreateAxis("XPS1",1,"Group2.Pos",  "50000")  
XPSCreateAxis("XPS1",2,"Group3.Pos",  "10000")  
XPSCreateAxis("XPS1",3,"Group4.Pos",  "50")  
XPSCreateAxis("XPS1",4,"Group5.Pos",  "50")  

# XPS asyn port,  max points, FTP username, FTP password
# Note: this must be done after configuring axes
XPSCreateProfile("XPS1", 10010, "Administrator", "Administrator")

# Disable setting position from motor record
XPSEnableSetPosition(0) 

################################################################################
# Motor records
dbLoadTemplate("motors.template")

# Auxillary I/O records
dbLoadTemplate("XPSAux.substitutions")

# asyn record for debugging
drvAsynIPPortConfigure("xps", "164.54.160.147:5001", 0, 0, 0)
asynSetTraceIOMask("xps",0,2)
asynSetTraceMask("xps",0,9)
dbLoadRecords("$(ASYN)/db/asynRecord.db", "P=13RAMAN2:, R=trajAsyn1, PORT=xps, ADDR=0, OMAX=300, IMAX=32000")

### Scan-support software
# crate-resident scan.  This executes 1D, 2D, 3D, and 4D scans, and caches
# 1D data, but it doesn't store anything to disk.  (You need the data catcher
# or the equivalent for that.)  This database is configured to use the
# "alldone" database (above) to figure out when motors have stopped moving
# and it's time to trigger detectors.
dbLoadRecords("$(SSCAN)/sscanApp/Db/scan.db", "P=13RAMAN2:,MAXPTS1=2000,MAXPTS2=200,MAXPTS3=20,MAXPTS4=10,MAXPTSH=10")

# A set of scan parameters for each positioner.  This is a convenience
# for the user.  It can contain an entry for each scannable thing in the
# crate.
dbLoadTemplate("scanParms.template")

# Miscellaneous PV's
dbLoadRecords("$(STD)/stdApp/Db/misc.db","P=13RAMAN2:", std)

# Free-standing user array calculations (aCalcout records)
dbLoadRecords("$(CALC)/calcApp/Db/userArrayCalcs10.db", "P=13RAMAN2:,N=10")

# Free-standing user calcOuts (calcOut records)
dbLoadRecords("$(CALC)/calcApp/Db/userCalcOuts10.db", "P=13RAMAN2:")

# Free-standing user string/number calculations (sCalcout records)
dbLoadRecords("$(CALC)/calcApp/Db/userStringCalcs10.db", "P=13RAMAN2:")

# Free-standing user string sequence records (sseq records)
dbLoadRecords("$(CALC)/calcApp/Db/userStringSeqs10.db", "P=13RAMAN2:")

# Free-standing user transforms (transform records)
dbLoadRecords("$(CALC)/calcApp/Db/userTransforms10.db", "P=13RAMAN2:")

< ../save_restore_IOCSH.cmd
save_restoreSet_status_prefix("13RAMAN2:")
dbLoadRecords("$(AUTOSAVE)/asApp/Db/save_restoreStatus.db", "P=13RAMAN2:")

### motorUtil - for allstop, moving, etc.
dbLoadRecords("$(MOTOR)/motorApp/Db/motorUtil.db","P=13RAMAN2:")

# devIocStats
epicsEnvSet("ENGINEER", "Mark Rivers")
epicsEnvSet("LOCATION","corvette")
epicsEnvSet("GROUP","GSECARS")
dbLoadRecords("$(DEVIOCSTATS)/db/iocAdminSoft.db","IOC=13RAMAN2:")

iocInit

### Start up the autosave task and tell it what to do.
# The task is actually named "save_restore".
# (See also, 'initHooks' above, which is the means by which the values that
# will be saved by the task we're starting here are going to be restored.
#
# save positions every five seconds
create_monitor_set("auto_positions.req",5,"P=13RAMAN2:")
# save other things every thirty seconds
create_monitor_set("auto_settings.req",30,"P=13RAMAN2:")

# Set the NTM fields of the XPS motors to 0 (NO) so they don't get stopped when the motor changes direction due to PID
dbpf("13RAMAN2:m1.NTM","0")
dbpf("13RAMAN2:m2.NTM","0")
dbpf("13RAMAN2:m3.NTM","0")
dbpf("13RAMAN2:m4.NTM","0")
dbpf("13RAMAN2:m5.NTM","0")

motorUtilInit("13RAMAN2:")
