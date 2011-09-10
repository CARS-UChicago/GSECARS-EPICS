< envPaths
# Start errlog Task before any possible error messsage to prevent
# erroneous "Interrupted system call" message on Linux OS.
errlogInit(0)
#
dbLoadDatabase("../../dbd/CARSLinux.dbd")
CARSLinux_registerRecordDeviceDriver(pdbbase)

################################################################################
# XPS Setup
#drvAsynIPPortConfigure("tcp1","164.54.160.124:5001 tcp", 0, 0, 1)
#asynOctetSetInputEos("tcp1",0,"")
#asynOctetSetOutputEos("tcp1",0,"")
#drvAsynIPPortConfigure("tcp2","164.54.160.131:5001 tcp", 0, 0, 1)
#asynOctetSetInputEos("tcp2",0,"")
#asynOctetSetOutputEos("tcp2",0,"")

# cards (total controllers)
XPSSetup(2)

# card, IP, PORT, number of axes, active poll period (ms), idle poll period (ms)
XPSConfig(0, "164.54.160.124", 5001, 6, 10, 500)
# asyn port, driver name, controller index, max. axes)
drvAsynMotorConfigure("XPS1", "motorXPS", 0, 6)
# card, IP, PORT, number of axes, active poll period (ms), idle poll period (ms)
XPSConfig(1, "164.54.160.131", 5001, 8, 10, 500)
# asyn port, driver name, controller index, max. axes)
drvAsynMotorConfigure("XPS2", "motorXPS", 1, 8)

# card,  axis, groupName.positionerName, stepsPerUnit
XPSConfigAxis(0,0,"GROUP1.PHI",     1000)
XPSConfigAxis(0,1,"GROUP1.KAPPA",   5000)
XPSConfigAxis(0,2,"GROUP1.OMEGA",   5000)
XPSConfigAxis(0,3,"GROUP1.PSI",     4000)
XPSConfigAxis(0,4,"GROUP1.2THETA", 10000)
XPSConfigAxis(0,5,"GROUP1.NU",      4000)

# card,  axis, groupnumber, groupsize,axis in group, group, positioner
XPSConfigAxis(1,0,"GROUP1.Y1_BASE",    10000)
XPSConfigAxis(1,1,"GROUP2.Y2_BASE",    10000)
XPSConfigAxis(1,2,"GROUP3.Y3_BASE",    10000)
XPSConfigAxis(1,3,"GROUP4.TRX_BASE",     200)
XPSConfigAxis(1,4,"GROUP5.THETA-Y_BASE", 200)
XPSConfigAxis(1,5,"GROUP6.X_SAMPLE",    3816)
XPSConfigAxis(1,6,"GROUP7.Y_SAMPLE",    3816)
XPSConfigAxis(1,7,"GROUP8.Z_SAMPLE",    3816)

# Disable setting position from motor record
XPSEnableSetPosition(0)

# Turn on debugging for the Omega axis
#asynSetTraceMask("XPS1",2,255)
#asynSetTraceIOMask("XPS1",2,2)

################################################################################

# Motor records
dbLoadTemplate("motors_xps.template")

################################################################################
# XPS trajectoryScan records

# Database for trajectory scanning with the XPS

dbLoadRecords("$(MOTOR)/motorApp/Db/trajectoryScan.db", "P=13BMC:,R=traj1,NAXES=6,NELM=2000,NPULSE=2000,PORT=5001,DONPV=13BMC:str:EraseStart,DONV=1,DOFFPV=13BMC:str:StopAll,DOFFV=1")

# asyn record for debugging
drvAsynIPPortConfigure("xps", "164.54.160.124:5001", 0, 0, 0)
asynSetTraceIOMask("xps",0,2)
asynSetTraceMask("xps",0,9)
dbLoadRecords("$(ASYN)/db/asynRecord.db", "P=13BMC:, R=trajAsyn1, PORT=xps, ADDR=0, OMAX=300, IMAX=32000")

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

save_restoreSet_status_prefix("13BMC_XPS:")
dbLoadRecords("$(AUTOSAVE)/asApp/Db/save_restoreStatus.db", "P=13BMC_XPS:")

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
create_monitor_set("auto_positions_xps.req",5,"P=13BMC:")
# save other things every thirty seconds
create_monitor_set("auto_settings_xps.req",30,"P=13BMC:")

dbpf("13BMC:traj1DebugLevel","1")

# Trajectory scanning with XPS
seq(XPS_trajectoryScan, "P=13BMC:,R=traj1,M1=m33,M2=m34,M3=m35,M4=m36,M5=m37,M6=m38,IPADDR=164.54.160.124,PORT=5001,GROUP=GROUP1,P1=PHI,P2=KAPPA,P3=OMEGA,P4=PSI,P5=2THETA,P6=NU")

dbpf("13BMC:trajAsyn1.IFMT","Binary")
dbpf("13BMC:trajAsyn1.OFMT","Binary")

epicsThreadSleep(2)
asynSetTraceIOMask(164.54.160.124:5001:0,0,2)
asynSetTraceIOMask(164.54.160.124:5001:1,0,2)
asynSetTraceIOMask(164.54.160.124:5001:2,0,2)
#asynSetTraceMask(164.54.160.124:5001:0,0,9)
#asynSetTraceMask(164.54.160.124:5001:1,0,9)
#asynSetTraceMask(164.54.160.124:5001:2,0,9)

# Set the NTM fields of the XPS motors to 0 (NO) so they don't get stopped when the motor changes direction due to PID
dbpf("13BMC:m33.NTM","0")
dbpf("13BMC:m34.NTM","0")
dbpf("13BMC:m35.NTM","0")
dbpf("13BMC:m36.NTM","0")
dbpf("13BMC:m37.NTM","0")
dbpf("13BMC:m38.NTM","0")
dbpf("13BMC:m39.NTM","0")
dbpf("13BMC:m40.NTM","0")
dbpf("13BMC:m41.NTM","0")
dbpf("13BMC:m42.NTM","0")
dbpf("13BMC:m43.NTM","0")
dbpf("13BMC:m44.NTM","0")
dbpf("13BMC:m45.NTM","0")
dbpf("13BMC:m46.NTM","0")

