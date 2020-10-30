< envPaths
# Start errlog Task before any possible error messsage to prevent
# erroneous "Interrupted system call" message on Linux OS.
errlogInit(0)
#
dbLoadDatabase("../../dbd/CARSLinux.dbd")
CARSLinux_registerRecordDeviceDriver(pdbbase)


################################################################################
# XPS Setup

# asyn port, IP address, IP port, number of axes, 
# active poll period (ms), idle poll period (ms), 
# enable set position, set position settling time (ms)
XPSCreateController("XPS1", "newport-xps3", 5001, 8, 10, 500, 1, 500)
asynSetTraceIOMask("XPS1", 0, 2)
#asynSetTraceMask("XPS1", 0, 255)

# asynPort, IP address, IP port, poll period (ms)
XPSAuxConfig("XPS_AUX1", "newport-xps3", 5001, 50)
#asynSetTraceIOMask("XPS_AUX1", 0, 2)
#asynSetTraceMask("XPS_AUX1", 0, 255)

# XPS asyn port,  axis, groupName.positionerName, stepSize
XPSCreateAxis("XPS1",0,"G1.STX",  "10000")  
XPSCreateAxis("XPS1",1,"G1.STZ",  "10000")  
XPSCreateAxis("XPS1",2,"G1.STY",  "50000")  
XPSCreateAxis("XPS1",3,"G1.OM",    "2000")  
XPSCreateAxis("XPS1",4,"G2.SLX",  "10000")  
# Share XPS axis 5 with "GPD X" PE Cell "Soller Z"
# (In 13IDC use DB25 connector labled "m94 - Soller Z")
# To change:
# 1) Edit motor.template swap setup for m94
# 2) Edit lines below, swap setup for axis 5
# 3) FTP to the XPS the corresponding system.ini file
#    a. copy to system.ini either:
#        "system - Standard DAC and LVP Setup.ini" or
#        "system Plug5 used for GPD X Stage.ini"
#    b. from a corvette command prompt in the ioc13idd_DAC_XPS directory
#         type: ftp_put_xps        
# 4) Connect via web browser to "newport-xps3.cars.aps.anl.gov" and
#      reboot the xps
# 5) Under the DAC table switch the XPS connector A/B box with the
#     yellow tape to output B
#     
# Used for normal DAC and LVP Setup
XPSCreateAxis("XPS1",5,"G2.SLZ",  "10000")
  
# used when xps plug 5 is setup for gpd x stage
#XPSCreateAxis("XPS1",5,"G4.GPD_X",  "10000")
 
# used when xps plug 5 is setup for gpd z stage
#XPSCreateAxis("XPS1",5,"G4.GPD_Z",  "10000") 

XPSCreateAxis("XPS1",6,"G2.SLT",  "10000")  
XPSCreateAxis("XPS1",7,"G3.CZ",    "1000")  

# XPS asyn port,  max points, FTP username, FTP password
# Note: this must be done after configuring axes
XPSCreateProfile("XPS1", 2048, "Administrator", "Administrator")

# Disable setting position from motor record
XPSEnableSetPosition(0) 

################################################################################
# Motor records
dbLoadTemplate("motors.template")

# Auxillary I/O records
dbLoadTemplate("XPSAux.substitutions")

# asyn record for debugging
drvAsynIPPortConfigure("xps", "newport-xps3:5001", 0, 0, 0)
asynSetTraceIOMask("xps",0,2)
asynSetTraceMask("xps",0,9)
dbLoadRecords("$(ASYN)/db/asynRecord.db", "P=13IDD:, R=trajAsyn1, PORT=xps, ADDR=0, OMAX=300, IMAX=32000")

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

save_restoreSet_status_prefix("13IDD_XPS:")
dbLoadRecords("$(AUTOSAVE)/db/save_restoreStatus.db", "P=13IDD_XPS:")

# A set of scan parameters for each positioner.  This is a convenience
# for the user.  It can contain an entry for each scannable thing in the
# crate.
dbLoadTemplate "scanParms.template"

### motorUtil - for allstop, moving, etc.
dbLoadRecords("$(MOTOR)/db/motorUtil.db","P=13IDD_XPS:")

# User calc stuff
epicsEnvSet("PREFIX", "13IDD:")
< ../calc_GSECARS.iocsh

# devIocStats
epicsEnvSet("ENGINEER", "Mark Rivers")
epicsEnvSet("LOCATION","corvette")
epicsEnvSet("GROUP","GSECARS")
dbLoadRecords("$(DEVIOCSTATS)/db/iocAdminSoft.db","IOC=13IDD_XPS:")

iocInit

### Start up the autosave task and tell it what to do.
# The task is actually named "save_restore".
# (See also, 'initHooks' above, which is the means by which the values that
# will be saved by the task we're starting here are going to be restored.
#
# save positions every five seconds
create_monitor_set("auto_positions.req",5,"P=13IDD:")
# save other things every thirty seconds
create_monitor_set("auto_settings.req",30,"P=13IDD:")

# Enable user string calcs and user transforms
dbpf "13IDD:EnableUserTrans.PROC","1"
dbpf "13IDD:EnableUserSCalcs.PROC","1"
dbpf "13IDD:EnableUserACalcs.PROC","1"
dbpf "13IDD:EnableUserCalcOuts.PROC","1"
dbpf "13IDD:userStringSeqEnable","1"

# Set the NTM fields of the XPS motors to 0 (NO) so they don't get stopped when the motor changes direction due to PID
dbpf("13IDD:m81.NTM","0")
dbpf("13IDD:m82.NTM","0")
dbpf("13IDD:m83.NTM","0")
dbpf("13IDD:m84.NTM","0")
dbpf("13IDD:m93.NTM","0")
dbpf("13IDD:m94.NTM","0")
dbpf("13IDD:m95.NTM","0")
dbpf("13IDD:m96.NTM","0")

motorUtilInit("13IDD_XPS:")

# Enable the mode where the XPS determines axis move complete by socket response, 
# not GroupStatusGet()
XPSEnableMovingMode XPS1
