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

XPSCreateController("XPS1", "newport-xps13", 5001, 8, 10, 500, 0, 500)

asynSetTraceIOMask("XPS1", 0, 2)
#asynSetTraceMask("XPS1", 0, 255)

# asynPort, IP address, IP port, poll period (ms)
#XPSAuxConfig("XPS_AUX1", "newport-xps13", 5001, 50)
#asynSetTraceIOMask("XPS_AUX1", 0, 2)
#asynSetTraceMask("XPS_AUX1", 0, 255)

# XPS asyn port,  axis, groupName.positionerName, stepSize
#XPSCreateAxis("XPS1",0,"GROUP1.THETA",   "87466.66667")  
XPSCreateAxis("XPS1",0,"MONO.THETA",   "131111.111111111")  
XPSCreateAxis("XPS1",1,"MONO.HEIGHT",      "5000")  
XPSCreateAxis("XPS1",2,"PITCH.POSITIONER", "5600")  
XPSCreateAxis("XPS1",3,"ROLL.POSITIONER",  "5600")  
XPSCreateAxis("XPS1",4,"HPOS.POSITIONER",  "5000")
XPSCreateAxis("XPS1",5,"HWID.POSITIONER",  "5000")
XPSCreateAxis("XPS1",6,"VPOS.POSITIONER",  "5000")
XPSCreateAxis("XPS1",7,"VWID.POSITIONER",  "5000")


# XPS asyn port,  max points, FTP username, FTP password
# Note: this must be done after configuring axes
XPSCreateProfile("XPS1", 5000, "Administrator", "Administrator")

# Disable setting position from motor record
XPSEnableSetPosition(0) 

################################################################################
# Motor records
dbLoadTemplate("motors.template")

# Auxillary I/O records
#dbLoadTemplate("XPSAux.substitutions")

# asyn record for debugging
drvAsynIPPortConfigure("xps", "newport-xps13:5001", 0, 0, 0)
asynSetTraceIOMask("xps",0,2)
asynSetTraceMask("xps",0,9)
dbLoadRecords("$(ASYN)/db/asynRecord.db", "P=13IDA:, R=trajAsyn2, PORT=xps, ADDR=0, OMAX=300, IMAX=32000")

# Debug-output level
save_restoreSet_Debug(0)

# Ok to save/restore save sets with missing values (no CA connection to PV)?
save_restoreSet_IncompleteSetsOk(1)
# Save dated backup files?
save_restoreSet_DatedBackupFiles(1)

# Number of sequenced backup files to write
save_restoreSet_NumSeqFiles(3)
# Time interval between sequenced backups
save_restoreSet_SeqPeriodInSeconds(300)

# specify where save files should be
set_savefile_path(".", "autosave")

###
# specify what save files should be restored.  Note these files must be
# in the directory specified in set_savefile_path(), or, if that function
# has not been called, from the directory current when iocInit is invoked
set_pass0_restoreFile("auto_positions.sav")
set_pass0_restoreFile("auto_settings.sav")
set_pass1_restoreFile("auto_settings.sav")

###
# specify directories in which to to search for included request files
set_requestfile_path("./")
set_requestfile_path("$(CARS)",     "CARSApp/Db")
set_requestfile_path("$(AREA_DETECTOR)", "ADApp/Db")
set_requestfile_path("$(AUTOSAVE)", "asApp/Db")
set_requestfile_path("$(CALC)",     "calcApp/Db")
set_requestfile_path("$(CAMAC)",    "camacApp/Db")
set_requestfile_path("$(DAC128V)",  "dac128VApp/Db")
set_requestfile_path("$(DXP)",      "dxpApp/Db")
set_requestfile_path("$(IP)",       "ipApp/Db")
set_requestfile_path("$(MCA)",      "mcaApp/Db")
set_requestfile_path("$(MOTOR)",    "motorApp/Db")
set_requestfile_path("$(OPTICS)",   "opticsApp/Db")
set_requestfile_path("$(QUADEM)",   "quadEMApp/Db")
set_requestfile_path("$(SSCAN)",    "sscanApp/Db")
set_requestfile_path("$(STD)",      "stdApp/Db")
set_requestfile_path("$(VME)",      "vmeApp/Db")

save_restoreSet_status_prefix("13IDA_EMONO:")
dbLoadRecords("$(AUTOSAVE)/db/save_restoreStatus.db", "P=13IDA_EMONO:")

# A set of scan parameters for each positioner.  This is a convenience
# for the user.  It can contain an entry for each scannable thing in the
# crate.
dbLoadTemplate "scanParms.template"

### motorUtil - for allstop, moving, etc.
dbLoadRecords("$(MOTOR)/db/motorUtil.db","P=13IDA_EMONO:")

dbLoadTemplate  "mono_energy.template"

# Free-standing user string/number calculations (sCalcout records)
dbLoadRecords("$(CALC)/db/userStringCalcs10.db", "P=13IDA_EMONO:")

# Free-standing user transforms (transform records)
dbLoadRecords("$(CALC)/db/userTransforms10.db", "P=13IDA_EMONO:")

# devIocStats
epicsEnvSet("ENGINEER", "Mark Rivers")
epicsEnvSet("LOCATION","13-ID-A roof")
epicsEnvSet("GROUP","GSECARS")
dbLoadRecords("$(DEVIOCSTATS)/db/iocAdminSoft.db","IOC=13IDA_EMONO:")

iocInit
# MN 12-Nov-2012  run MonoEnergy sequence program here
seq(&GSE_MonoEnergy, "MONO=13IDE:En, ID=ID13us:, MTH=13IDA:m65, MY=13IDA:m66, FB=13XRM:pitch_pid, CAL=13ID_US_UndCalibration.xml")

### Start up the autosave task and tell it what to do.
# The task is actually named "save_restore".
# (See also, 'initHooks' above, which is the means by which the values that
# will be saved by the task we're starting here are going to be restored.
#
# save positions every five seconds
create_monitor_set("auto_positions.req",5,"P=13IDA:")
# save other things every thirty seconds
create_monitor_set("auto_settings.req",30,"P=13IDA:")

# Set the NTM fields of the XPS motors to 0 (NO) so they don't get stopped when the motor changes direction due to PID
dbpf("13IDA:m65.NTM","0")
dbpf("13IDA:m66.NTM","0")
dbpf("13IDA:m67.NTM","0")
dbpf("13IDA:m68.NTM","0")
dbpf("13IDA:m69.NTM","0")
dbpf("13IDA:m70.NTM","0")
dbpf("13IDA:m71.NTM","0")
dbpf("13IDA:m72.NTM","0")

motorUtilInit("13IDA_EMONO:")

