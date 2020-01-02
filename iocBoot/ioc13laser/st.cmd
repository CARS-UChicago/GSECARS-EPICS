errlogInit(5000)
< envPaths

epicsEnvSet(STREAM_PROTOCOL_PATH, $(IP)/db:$(DELAYGEN)/delayGenApp/Db)

cd $(TOP)/iocBoot/$(IOC)

# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in this build from CARS
dbLoadDatabase("../../dbd/CARSWin32.dbd")
CARSWin32_registerRecordDeviceDriver(pdbbase)

# Set up serial ports on Moxa box
drvAsynIPPortConfigure("serial1", "gsets3:4001", 0, 0)
drvAsynIPPortConfigure("serial2", "gsets3:4002", 0, 0)
drvAsynIPPortConfigure("serial3", "gsets3:4003", 0, 0)
drvAsynIPPortConfigure("serial4", "gsets3:4004", 0, 0)
drvAsynSerialPortConfigure("serial5", "COM5", 0, 0, 0)


# Make these ports available from the iocsh command line
asynOctetConnect("serial1", "serial1", 0, 1, 80)
asynOctetConnect("serial2", "serial2", 0, 1, 80)
asynOctetConnect("serial3", "serial3", 0, 1, 80)
asynOctetConnect("serial4", "serial4", 0, 1, 80)
asynOctetConnect("serial5", "serial5", 0, 1, 80)
asynOctetSetInputEos("serial1",0,"\r")
asynOctetSetOutputEos("serial1",0,"\r")
asynOctetSetInputEos("serial2",0,"\r")
asynOctetSetOutputEos("serial2",0,"\r")
asynOctetSetInputEos("serial3",0,"\r")
asynOctetSetOutputEos("serial3",0,"\r")
asynOctetSetInputEos("serial4",0,"\r\n")
asynOctetSetOutputEos("serial4",0,"\r\n")
asynOctetSetInputEos("serial5",0,"\r\n")
asynOctetSetOutputEos("serial5",0,"\r\n")
asynSetOption("serial5",0,"baud","921600")
asynSetOption("serial5",0,"bits","8")
asynSetOption("serial5",0,"stop","1")
asynSetOption("serial5",0,"parity","none")
asynSetOption("serial5",0,"clocal","Y")
asynSetOption("serial5",0,"crtscts","N")

#asynSetTraceIOMask("serial1", 0, 2)
#asynSetTraceIOMask("serial2", 0, 2)
#asynSetTraceMask("serial1", 0, 255)
#asynSetTraceMask("serial2", 0, 255)

# Load asyn records on each of these ports
dbLoadTemplate("asynRecord.template")

### Motors
dbLoadTemplate  "motors.template"

# IPG laser
#drvAsynIPPortConfigure("serial5", "164.54.160.13:10001", 0, 0, 0)
#asynOctetSetInputEos("serial5",0,"\r")
#asynOctetSetOutputEos("serial5",0,"\r")
#dbLoadRecords("$(CARS)/db/IPG_YLR_laser.db","P=13Laser:,R=Laser1,PORT=serial5")
dbLoadRecords("$(CARS)/db/IPG_YLR_laser.db","P=13Laser:,R=Laser1,PORT=serial3")

# BNC-505 Pulse/Delay Generator
dbLoadTemplate("BNC_505.substitutions")

# A set of scan parameters for each positioner.  This is a convenience
# for the user.  It can contain an entry for each scannable thing in the
# crate.
dbLoadTemplate "scanParms.template"

### Allstop, alldone
# This database must agree with the motors you've actually loaded.
# Several versions (e.g., all_com_32.db) are in stdApp/Db
# dbLoadRecords("$(STD)/db/all_com_8.db", "P=13Laser:")
### motorUtil - for allstop, moving, etc.
dbLoadRecords("$(MOTOR)/db/motorUtil.db","P=13Laser:")


### Scan-support software
# crate-resident scan.  This executes 1D, 2D, 3D, and 4D scans, and caches
# 1D data, but it doesn't store anything to disk.  (You need the data catcher
# or the equivalent for that.)  This database is configured to use the
# "alldone" database (above) to figure out when motors have stopped moving
# and it's time to trigger detectors.
dbLoadRecords("$(SSCAN)/db/scan.db", "P=13Laser:,MAXPTS1=2000,MAXPTS2=200,MAXPTS3=20,MAXPTS4=10,MAXPTSH=10")

# Free-standing user string/number calculations (sCalcout records)
dbLoadRecords("$(CALC)/db/userStringCalcs10.db", "P=13Laser:")

# Free-standing user transforms (transform records)
dbLoadRecords("$(CALC)/db/userTransforms10.db", "P=13Laser:")
# Free-standing user string sequence records (sseq records)
dbLoadRecords("$(CALC)/db/userStringSeqs10.db", "P=13Laser:")

# Miscellaneous PV's, such as burtResult
dbLoadRecords("$(STD)/db/misc.db", "P=13Laser:")

# MCB-4B driver setup parameters:
#     (1) port name
#     (2) serial port name
#     (3) maximum # axis per controller
#     (4) moving poll period ms
#     (5) idle poll period ms
MCB4BCreateController("MCB4B_1", "serial1", 4, 100, 0)
MCB4BCreateController("MCB4B_2", "serial2", 4, 100, 0)

# AG_CONEXCreateController(asyn port, serial port, controllerID, 
#                          active poll period (ms), idle poll period (ms)) 
AG_CONEXCreateController("Agilis1", "serial5", 1, 50, 500)
asynSetTraceIOMask("Agilis1", 0, 2)
#asynSetTraceMask("Agilis1", 0, 255)

< ../save_restore_IOCSH.cmd
save_restoreSet_status_prefix("13Laser:")
dbLoadRecords("$(AUTOSAVE)/asApp/Db/save_restoreStatus.db", "P=13Laser:")

# devIocStats
epicsEnvSet("ENGINEER", "Mark Rivers")
epicsEnvSet("LOCATION","GSE DAC lab")
epicsEnvSet("GROUP","GSECARS")
dbLoadRecords("$(DEVIOCSTATS)/db/iocAdminSoft.db","IOC=13Laser:")

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

dbpf 13Laser1:m5.RTRY 0
dbpf 13Laser1:m5.NTM 0
motorUtilInit("13Laser:")
