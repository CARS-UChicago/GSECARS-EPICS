< envPaths
# Start errlog Task before any possible error messsage to prevent
# erroneous "Interrupted system call" message on Linux OS.
errlogInit(0)
#
dbLoadDatabase("../../dbd/CARSLinux.dbd")
CARSLinux_registerRecordDeviceDriver(pdbbase)

################################################################################
# XPS Setup
drvAsynIPPortConfigure("tcp1","164.54.160.55:5001 tcp", 0, 0, 1)
drvAsynIPPortConfigure("tcp2","164.54.160.56:5001 tcp", 0, 0, 1)

# cards (total controllers)
XPSSetup(2)

# Setup the XPS for the Rotation
# card, IP, PORT, number of axes, active poll period (ms), idle poll period (ms)
XPSConfig(0, "164.54.160.55", 5001, 6, 10, 500)
# asyn port, driver name, controller index, max. axes)
drvAsynMotorConfigure("XPS1", "motorXPS", 0, 6)

# Setup the XPS for the Base and X, Y and Z
# card, IP, PORT, number of axes, active poll period (ms), idle poll period (ms)
XPSConfig(1, "164.54.160.56", 5001, 8, 10, 500)
# asyn port, driver name, controller index, max. axes)
drvAsynMotorConfigure("XPS2", "motorXPS", 1, 8)

# Define the group names and the steps per unit.  This must match values defined
# in the XPS system.ini ([group.names]) and stages.ini (1/EncoderResolution)
 
# XPS for the Rotations
# card,  axis, groupName.positionerName, stepsPerUnit
XPSConfigAxis(0,0,"GROUP.PHI",      1000)
XPSConfigAxis(0,1,"GROUP.KAPPA",   10000)
XPSConfigAxis(0,2,"GROUP.OMEGA",   10000)
XPSConfigAxis(0,3,"GROUP.PSI",      4000)
XPSConfigAxis(0,4,"GROUP.THETA",   10000)
XPSConfigAxis(0,5,"GROUP.NU",       4000)
 
# XPS for the Base and X, Y and Z 
# card,  axis, groupName.positionerName, stepsPerUnit
# This is the config for the Y1-3 is grouped together in "Y_Base"
#XPSConfigAxis(1,0,"Y_Base.Y1",     10000)
#XPSConfigAxis(1,1,"Y_Base.Y2",     10000)
#XPSConfigAxis(1,2,"Y_Base.Y3",     10000)
#XPSConfigAxis(1,3,"GROUP4.THETAY",   200)
#XPSConfigAxis(1,4,"GROUP5.TRX",      200)
#XPSConfigAxis(1,5,"GROUP6.X",      74627)
#XPSConfigAxis(1,6,"GROUP7.Y",      74627)
#XPSConfigAxis(1,7,"GROUP8.Z",     100000)

# XPS for the Base and X, Y and Z 
# card,  axis, groupName.positionerName, stepsPerUnit
# This is the config for the Y1-3 in single axis groups
XPSConfigAxis(1,0,"GROUP1.Y1_BASE", 10000)
XPSConfigAxis(1,1,"GROUP2.Y2_BASE", 10000)
XPSConfigAxis(1,2,"GROUP3.Y3_BASE", 10000)
XPSConfigAxis(1,3,"GROUP4.THETAY",    200)
XPSConfigAxis(1,4,"GROUP5.TRX",       200)
XPSConfigAxis(1,5,"GROUP6.X",       74627)
XPSConfigAxis(1,6,"GROUP7.Y",       74627)
XPSConfigAxis(1,7,"GROUP8.Z",      100000)

# Disable setting position from motor record
XPSEnableSetPosition(0) 

################################################################################
# Motor records
dbLoadTemplate("motors_xps.template")

################################################################################
# XPS trajectoryScan records

# Database for trajectory scanning with the XPS

dbLoadRecords("$(MOTOR)/motorApp/Db/trajectoryScan.db", "P=13IDC:,R=traj1,NAXES=6,NELM=2000,NPULSE=2000,PORT=5001")

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
set_pass0_restoreFile("auto_positions_xps.sav")
set_pass0_restoreFile("auto_settings_xps.sav")
set_pass1_restoreFile("auto_settings_xps.sav")

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

save_restoreSet_status_prefix("13IDC_XPS:")
dbLoadRecords("$(AUTOSAVE)/asApp/Db/save_restoreStatus.db", "P=13IDC_XPS:")

# A set of scan parameters for each positioner.  This is a convenience
# for the user.  It can contain an entry for each scannable thing in the
# crate.
dbLoadTemplate "scanParms_xps.template"

iocInit

### Start up the autosave task and tell it what to do.
# The task is actually named "save_restore".
# (See also, 'initHooks' above, which is the means by which the values that
# will be saved by the task we're starting here are going to be restored.
#
< ../requestFileCommands
# save positions every five seconds
create_monitor_set("auto_positions_xps.req",5,"P=13IDC:")
# save other things every thirty seconds
create_monitor_set("auto_settings_xps.req",30,"P=13IDC:")

dbpf("13IDC:traj1DebugLevel","1")

# Trajectory scanning with XPS
seq(XPS_trajectoryScan, "P=13IDC:,R=traj1,M1=m25,M2=m26,M3=m27,M4=m28,M5=m29,M6=m30,IPADDR=164.54.160.55,PORT=5001,GROUP=GROUP,P1=PHI,P2=KAPPA,P3=OMEGA,P4=PSI,P5=THETA,P6=NU")

# Set the NTM fields of the XPS motors to 0 (NO) so they don't get stopped when the motor changes direction due to PID
dbpf("13IDC:m25.NTM","0")
dbpf("13IDC:m26.NTM","0")
dbpf("13IDC:m27.NTM","0")
dbpf("13IDC:m28.NTM","0")
dbpf("13IDC:m29.NTM","0")
dbpf("13IDC:m30.NTM","0")
dbpf("13IDC:m33.NTM","0")
dbpf("13IDC:m34.NTM","0")
dbpf("13IDC:m35.NTM","0")
dbpf("13IDC:m36.NTM","0")
dbpf("13IDC:m37.NTM","0")
dbpf("13IDC:m38.NTM","0")
dbpf("13IDC:m39.NTM","0")
dbpf("13IDC:m40.NTM","0")

motorUtilInit("13IDC_XPS:")
