< envPaths
# Start errlog Task before any possible error messsage to prevent
# erroneous "Interrupted system call" message on Linux OS.
errlogInit(0)
#
dbLoadDatabase("$(CARS)/dbd/CARSLinux.dbd")
CARSLinux_registerRecordDeviceDriver(pdbbase)

# For areaDetector and quadEM
epicsEnvSet(EPICS_DB_INCLUDE_PATH,"$(ADCORE)/db:$(QUADEM)/db")

################################################################################
# TetrAMM setup
< TetrAMM.cmd
################################################################################

# Feedback for C/D Mono
dbLoadTemplate("mono_pid.template")

# XPS Setup

# asyn port, IP address, IP port, number of axes, 
# active poll period (ms), idle poll period (ms), 
# enable set position, set position settling time (ms)
XPSCreateController("XPS1", "164.54.160.14", 5001, 8, 10, 500, 0, 500)
asynSetTraceIOMask("XPS1", 0, 2)
#asynSetTraceMask("XPS1", 0, 255)

# asynPort, IP address, IP port, poll period (ms)
XPSAuxConfig("XPS_AUX1", "164.54.160.14", 5001, 50)
#asynSetTraceIOMask("XPS_AUX1", 0, 2)
#asynSetTraceMask("XPS_AUX1", 0, 255)

# XPS asyn port,  axis, groupName.positionerName, stepSize
XPSCreateAxis("XPS1",0,"GROUP1.THETA",  "87466.6667")  
XPSCreateAxis("XPS1",1,"GROUP2.HEIGHT", "5000")  
XPSCreateAxis("XPS1",2,"GROUP3.PITCH",  "5600")  
XPSCreateAxis("XPS1",3,"GROUP4.ROLL",   "5600")  
XPSCreateAxis("XPS1",4,"GROUP5.HEIGHT", "56500")  
XPSCreateAxis("XPS1",5,"GROUP6.P",      "56500")  
XPSCreateAxis("XPS1",6,"GROUP7.P",      "56500")  
XPSCreateAxis("XPS1",7,"GROUP8.P",      "56500")  

# XPS asyn port,  max points, FTP username, FTP password
# Note: this must be done after configuring axes
XPSCreateProfile("XPS1", 10010, "Administrator", "Administrator")

# Disable setting position from motor record
XPSEnableSetPosition(0) 

################################################################################
# Motor records
dbLoadTemplate("motors.template")

dbLoadTemplate  "mono_energy.template"
dbLoadTemplate  "mono_position.template"

# Auxillary I/O records
dbLoadTemplate("XPSAux.substitutions")

# asyn record for debugging
drvAsynIPPortConfigure("xps", "164.54.160.14:5001", 0, 0, 0)
asynSetTraceIOMask("xps",0,2)
asynSetTraceMask("xps",0,9)
dbLoadRecords("$(ASYN)/db/asynRecord.db", "P=13IDA:, R=trajAsyn1, PORT=xps, ADDR=0, OMAX=300, IMAX=32000")

< ../save_restore_IOCSH.cmd

save_restoreSet_status_prefix("13IDA_CDMONO:")
dbLoadRecords("$(AUTOSAVE)/asApp/Db/save_restoreStatus.db", "P=13IDA_CDMONO:")

# A set of scan parameters for each positioner.  This is a convenience
# for the user.  It can contain an entry for each scannable thing in the
# crate.
dbLoadTemplate "scanParms.template"

### motorUtil - for allstop, moving, etc.
dbLoadRecords("$(MOTOR)/motorApp/Db/motorUtil.db","P=13IDA_CDMONO:")

# devIocStats
epicsEnvSet("ENGINEER", "Mark Rivers")
epicsEnvSet("LOCATION","13-ID-A roof")
epicsEnvSet("GROUP","GSECARS")
dbLoadRecords("$(DEVIOCSTATS)/db/iocAdminSoft.db","IOC=13IDA_CDMONO:")

iocInit

### Start up the autosave task and tell it what to do.
# The task is actually named "save_restore".
# (See also, 'initHooks' above, which is the means by which the values that
# will be saved by the task we're starting here are going to be restored.
#
# save positions every five seconds
create_monitor_set("auto_positions.req",5,"P=13IDA:")
# save other things every thirty seconds
create_monitor_set("auto_settings.req",30,"P=13IDA:")

seq(&GSE_MonoEnergy, "MONO=13IDA:CDEn, ID=ID13ds:, MTH=13IDA:m57, MY=13IDA:m58, FB=13IDA:mono_pid1")

# Set the NTM fields of the XPS motors to 0 (NO) so they don't get stopped when the motor changes direction due to PID
dbpf("13IDA:m57.NTM","0")
dbpf("13IDA:m58.NTM","0")
dbpf("13IDA:m59.NTM","0")
dbpf("13IDA:m60.NTM","0")

motorUtilInit("13IDA_CDMONO:")
