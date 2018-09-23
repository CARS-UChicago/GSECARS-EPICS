errlogInit(5000)
< envPaths

#epicsEnvSet(STREAM_PROTOCOL_PATH, $(IP)/ipApp/Db:$(DELAYGEN)/delayGenApp/Db)
epicsEnvSet(STREAM_PROTOCOL_PATH, $(IP)/ipApp/Db:$(CARS)/CARSApp/Db)
epicsEnvSet(PREFIX, "13Mirror:")
#cd $(TOP)/iocBoot/$(IOC)

# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in this build from CARS
dbLoadDatabase("../../dbd/CARSWin32.dbd")
CARSWin32_registerRecordDeviceDriver(pdbbase)

#dbLoadDatabase("$(CARS)/dbd/CARSLinux.dbd")
#CARSWin32_registerRecordDeviceDriver(pdbbase)

# Set up serial ports on Moxa box
drvAsynSerialPortConfigure("serial4", "COM4", 0, 0, 0)
drvAsynSerialPortConfigure("serial5", "COM5", 0, 0, 0)
drvAsynSerialPortConfigure("serial6", "COM6", 0, 0, 0)
drvAsynSerialPortConfigure("serial7", "COM7", 0, 0, 0)

# Make these ports available from the iocsh command line
asynOctetConnect("serial4", "serial4", 0, 1, 80)
asynOctetConnect("serial5", "serial5", 0, 1, 80)
asynOctetConnect("serial6", "serial6", 0, 1, 80)
asynOctetConnect("serial7", "serial7", 0, 1, 80)

asynOctetSetInputEos("serial4",0,"\r\n")
asynOctetSetOutputEos("serial4",0,"\r\n")
asynSetOption("serial4",0,"baud","921600")
asynSetOption("serial4",0,"bits","8")
asynSetOption("serial4",0,"stop","1")
asynSetOption("serial4",0,"parity","none")
asynSetOption("serial4",0,"clocal","Y")
asynSetOption("serial4",0,"crtscts","N")

asynOctetSetInputEos("serial5",0,"\r\n")
asynOctetSetOutputEos("serial5",0,"\r\n")
asynSetOption("serial5",0,"baud","921600")
asynSetOption("serial5",0,"bits","8")
asynSetOption("serial5",0,"stop","1")
asynSetOption("serial5",0,"parity","none")
asynSetOption("serial5",0,"clocal","Y")
asynSetOption("serial5",0,"crtscts","N")

asynOctetSetInputEos("serial6",0,"\r\n")
asynOctetSetOutputEos("serial6",0,"\r\n")
asynSetOption("serial6",0,"baud","921600")
asynSetOption("serial6",0,"bits","8")
asynSetOption("serial6",0,"stop","1")
asynSetOption("serial6",0,"parity","none")
asynSetOption("serial6",0,"clocal","Y")
asynSetOption("serial6",0,"crtscts","N")

asynOctetSetInputEos("serial7",0,"\r\n")
asynOctetSetOutputEos("serial7",0,"\r\n")
asynSetOption("serial7",0,"baud","921600")
asynSetOption("serial7",0,"bits","8")
asynSetOption("serial7",0,"stop","1")
asynSetOption("serial7",0,"parity","none")
asynSetOption("serial7",0,"clocal","Y")
asynSetOption("serial7",0,"crtscts","N")

# Load asyn records on each of these ports
dbLoadTemplate("asynRecord.template")

### Motors
dbLoadTemplate  "motors.template"

# A set of scan parameters for each positioner.  This is a convenience
# for the user.  It can contain an entry for each scannable thing in the
# crate.
dbLoadTemplate "scanParms.template"

### Allstop, alldone
### motorUtil - for allstop, moving, etc.
dbLoadRecords("$(MOTOR)/motorApp/Db/motorUtil.db","P=13Mirror:")


### Scan-support software
# crate-resident scan.  This executes 1D, 2D, 3D, and 4D scans, and caches
# 1D data, but it doesn't store anything to disk.  (You need the data catcher
# or the equivalent for that.)  This database is configured to use the
# "alldone" database (above) to figure out when motors have stopped moving
# and it's time to trigger detectors.
dbLoadRecords("$(SSCAN)/sscanApp/Db/scan.db", "P=13Mirror:,MAXPTS1=2000,MAXPTS2=200,MAXPTS3=20,MAXPTS4=10,MAXPTSH=10")

# Free-standing user string/number calculations (sCalcout records)
dbLoadRecords("$(CALC)/calcApp/Db/userStringCalcs10.db", "P=13Mirror:")

# Free-standing user transforms (transform records)
dbLoadRecords("$(CALC)/calcApp/Db/userTransforms10.db", "P=13Mirror:")
# Free-standing user string sequence records (sseq records)
dbLoadRecords("$(CALC)/calcApp/Db/userStringSeqs10.db", "P=13Mirror:")

# Miscellaneous PV's, such as burtResult
dbLoadRecords("$(STD)/stdApp/Db/misc.db", "P=13Mirror:")

# AG_CONEXCreateController(asyn port, serial port, controllerID, 
#                          active poll period (ms), idle poll period (ms)) 
AG_CONEXCreateController("Agilis1", "serial4", 1, 50, 500)
asynSetTraceIOMask("Agilis1", 0, 2)
#asynSetTraceMask("Agilis1", 0, 255)

AG_CONEXCreateController("Agilis2", "serial5", 1, 50, 500)
asynSetTraceIOMask("Agilis2", 0, 2)
#asynSetTraceMask("Agilis2", 0, 255)

AG_CONEXCreateController("Agilis3", "serial6", 1, 50, 500)
asynSetTraceIOMask("Agilis3", 0, 2)
#asynSetTraceMask("Agilis3", 0, 255)

AG_CONEXCreateController("Agilis4", "serial7", 1, 50, 500)
asynSetTraceIOMask("Agilis4", 0, 2)
#asynSetTraceMask("Agilis4", 0, 255)

< ../save_restore_IOCSH.cmd
save_restoreSet_status_prefix("13Mirror:")
dbLoadRecords("$(AUTOSAVE)/asApp/Db/save_restoreStatus.db", "P=13Mirror:")

# devIocStats
epicsEnvSet("ENGINEER", "Mark Rivers")
epicsEnvSet("LOCATION","GSE DAC lab")
epicsEnvSet("GROUP","GSECARS")
dbLoadRecords("$(DEVIOCSTATS)/db/iocAdminSoft.db","IOC=13Mirror:")

iocInit

### Start up the autosave task and tell it what to do.
# The task is actually named "save_restore".
# (See also, 'initHooks' above, which is the means by which the values that
# will be saved by the task we're starting here are going to be restored.
#
# save positions every five seconds
create_monitor_set("auto_positions.req", 5, "P=13Mirror:")
# save other things every thirty seconds
create_monitor_set("auto_settings.req", 30, "P=13Mirror:")

dbpf 13Mirror:m1.RTRY 0
dbpf 13Mirror:m1.NTM 0
#motorUtilInit("13Mirror:")

dbpf 13Mirror:m2.RTRY 0
dbpf 13Mirror:m2.NTM 0
#motorUtilInit("13Mirror:")

dbpf 13Mirror:m3.RTRY 0
dbpf 13Mirror:m3.NTM 0
#motorUtilInit("13Mirror:")

dbpf 13Mirror:m4.RTRY 0
dbpf 13Mirror:m4.NTM 0
#motorUtilInit("13Mirror:")
