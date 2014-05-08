errlogInit(5000)
< envPaths

epicsEnvSet(STREAM_PROTOCOL_PATH, $(IP)/ipApp/Db:$(DELAYGEN)/delayGenApp/Db)

# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in this build from CARS
dbLoadDatabase("../../dbd/CARS.dbd")
CARSWin32_registerRecordDeviceDriver(pdbbase)

# For Windows

drvAsynSerialPortConfigure("serial1", "COM3", 0, 0, 0)
asynOctetSetInputEos("serial1",0,"\r\n")
asynOctetSetOutputEos("serial1",0,"\r\n")
asynSetOption("serial1",0,"baud","921600")
#asynSetOption("serial1",0,"baud","9600")
asynSetOption("serial1",0,"bits","8")
asynSetOption("serial1",0,"stop","1")
asynSetOption("serial1",0,"parity","none")
asynSetOption("serial1",0,"clocal","Y")
asynSetOption("serial1",0,"crtscts","N")
asynSetTraceIOMask("serial1", 0, 2)
#asynSetTraceMask("serial1", 0, 9)

drvAsynSerialPortConfigure("serial2", "COM4", 0, 0, 0)
asynOctetSetInputEos("serial2",0,"\r\n")
asynOctetSetOutputEos("serial2",0,"\r\n")
asynSetOption("serial2",0,"baud","921600")
#asynSetOption("serial2",0,"baud","9600")
asynSetOption("serial2",0,"bits","8")
asynSetOption("serial2",0,"stop","1")
asynSetOption("serial2",0,"parity","none")
asynSetOption("serial2",0,"clocal","Y")
asynSetOption("serial2",0,"crtscts","N")
asynSetTraceIOMask("serial2", 0, 2)
#asynSetTraceMask("serial2", 0, 9)

drvAsynSerialPortConfigure("serial3", "COM5", 0, 0, 0)
asynOctetSetInputEos("serial3",0,"\r\n")
asynOctetSetOutputEos("serial3",0,"\r\n")
asynSetOption("serial3",0,"baud","921600")
#asynSetOption("serial3",0,"baud","9600")
asynSetOption("serial3",0,"bits","8")
asynSetOption("serial3",0,"stop","1")
asynSetOption("serial3",0,"parity","none")
asynSetOption("serial3",0,"clocal","Y")
asynSetOption("serial3",0,"crtscts","N")
asynSetTraceIOMask("serial3", 0, 2)
#asynSetTraceMask("serial3", 0, 0x19)

# AG_CONEXCreateController(asyn port, serial port, controllerID, 
#                          active poll period (ms), idle poll period (ms)) 
AG_CONEXCreateController("CONEX1", "serial1", 1, 50, 500)
asynSetTraceIOMask("CONEX1", 0, 2)
#asynSetTraceMask("CONEX1", 0, 255)

AG_CONEXCreateController("CONEX2", "serial2", 1, 50, 500)
asynSetTraceIOMask("CONEX2", 0, 2)
#asynSetTraceMask("CONEX2", 0, 255)

# AG_UCCreateController(asyn port, serial port, number of axes, 
#                        active poll period (ms), idle poll period (ms)) 
AG_UCCreateController("Agilis1", "serial3", 5, 50, 500)
asynSetTraceIOMask("Agilis1", 0, 2)
#asynSetTraceMask("Agilis1", 0, 255)

# AG_UCCreateAxis((AG_UC controller port,  axis, hasLimits, forwardAmplitude, reverseAmplitude)
AG_UCCreateAxis("Agilis1", 0, 1, 50, -50)
AG_UCCreateAxis("Agilis1", 1, 1, 50, -50)
AG_UCCreateAxis("Agilis1", 2, 1, 50, -50)
AG_UCCreateAxis("Agilis1", 3, 1, 50, -50)
AG_UCCreateAxis("Agilis1", 4, 0, 50, -50)

# Load asyn records on each of these ports
dbLoadTemplate("asynRecord.template")

### Motors
dbLoadTemplate  "motors.template"

# IPG laser
drvAsynIPPortConfigure("serial4", "164.54.160.13:10001", 0, 0, 0) 
asynOctetSetInputEos("serial4",0,"\r")
asynOctetSetOutputEos("serial4",0,"\r")
dbLoadRecords("$(CARS)/CARSApp/Db/IPG_YLR_laser.db","P=13LU:,R=Laser1,PORT=serial4")

# A set of scan parameters for each positioner.  This is a convenience
# for the user.  It can contain an entry for each scannable thing in the
# crate.
dbLoadTemplate "scanParms.template"

### Scan-support software
# crate-resident scan.  This executes 1D, 2D, 3D, and 4D scans, and caches
# 1D data, but it doesn't store anything to disk.  (You need the data catcher
# or the equivalent for that.)  This database is configured to use the
# "alldone" database (above) to figure out when motors have stopped moving
# and it's time to trigger detectors.
dbLoadRecords("$(SSCAN)/sscanApp/Db/scan.db", "P=13LU:,MAXPTS1=2000,MAXPTS2=200,MAXPTS3=20,MAXPTS4=10,MAXPTSH=10")

# Free-standing user string/number calculations (sCalcout records)
dbLoadRecords("$(CALC)/calcApp/Db/userStringCalcs10.db", "P=13LU:")

# Free-standing user transforms (transform records)
dbLoadRecords("$(CALC)/calcApp/Db/userTransforms10.db", "P=13LU:")

# Miscellaneous PV's, such as burtResult
dbLoadRecords("$(STD)/stdApp/Db/misc.db", "P=13LU:")

< ../save_restore_IOCSH.cmd
save_restoreSet_status_prefix("13LU:")
dbLoadRecords("$(AUTOSAVE)/asApp/Db/save_restoreStatus.db", "P=13LU:")

iocInit

### Start up the autosave task and tell it what to do.
# The task is actually named "save_restore".
# (See also, 'initHooks' above, which is the means by which the values that
# will be saved by the task we're starting here are going to be restored.
#
# save positions every five seconds
create_monitor_set("auto_positions.req", 5, "P=13LU:")
# save other things every thirty seconds
create_monitor_set("auto_settings.req", 30, "P=13LU:")

