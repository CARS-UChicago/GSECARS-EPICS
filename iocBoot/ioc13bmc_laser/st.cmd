< envPaths

# Start errlog Task before any possible error messsage to prevent
# erroneous "Interrupted system call" message on Linux OS.
errlogInit(0)

epicsEnvSet(STREAM_PROTOCOL_PATH, $(IP)/ipApp/Db:$(CARS)/db)

dbLoadDatabase("$(CARS)/dbd/CARSWin32.dbd")
CARSWin32_registerRecordDeviceDriver(pdbbase)

#dbLoadDatabase("$(CARS)/dbd/CARSLinux.dbd")
#CARSLinux_registerRecordDeviceDriver(pdbbase)

epicsEnvSet("PREFIX", "13BMC_Laser:")


# Serial 1 is Laser Quantum laser
drvAsynIPPortConfigure("serial1", "164.54.160.53:4001", 0, 0, 0)
asynOctetSetInputEos("serial1",0,"\r\n")
asynOctetSetOutputEos("serial1",0,"\r\n")
asynSetTraceIOMask("serial1", 0, 2)
#asynSetTraceMask("serial1", 0, 9)

# Serial 2 is IPG-YLR laser over Ethernet
drvAsynIPPortConfigure("serial2", "164.54.160.107:10001", 0, 0, 0) 
asynOctetSetInputEos("serial2",0,"\r")
asynOctetSetOutputEos("serial2",0,"\r")


# Serial 4 is AG-UC8 8-axis AGILIS controller

# Following section from serial.cmd on computer:lightfield
drvAsynSerialPortConfigure("serial4", "COM4", 0, 0, 0)
asynOctetSetInputEos("serial4",0,"\r\n")
asynOctetSetOutputEos("serial4",0,"\r\n")
asynSetOption("serial4",0,"baud","921600")
#asynSetOption("serial4",0,"baud","9600")
asynSetOption("serial4",0,"bits","8")
asynSetOption("serial4",0,"stop","1")
asynSetOption("serial4",0,"parity","none")
asynSetOption("serial4",0,"clocal","Y")
asynSetOption("serial4",0,"crtscts","N")
asynSetTraceIOMask("serial4", 0, 2)
#asynSetTraceMask("serial4", 0, 0x19)

# Load asynRecord records on all ports
dbLoadTemplate("asynRecord.substitutions")

# Following section from st.cmd on computer:lightfield

# AG_UCCreateController(asyn port, serial port, number of axes, 
#                        active poll period (ms), idle poll period (ms)) 
AG_UCCreateController("Agilis1", "serial4", 6, 50, 500)
asynSetTraceIOMask("Agilis1", 0, 2)
#asynSetTraceMask("Agilis1", 0, 255)

# AG_UCCreateAxis((AG_UC controller port,  axis, hasLimits, forwardAmplitude, reverseAmplitude)
AG_UCCreateAxis("Agilis1", 0, 1, 50, -50)
AG_UCCreateAxis("Agilis1", 1, 1, 50, -50)
AG_UCCreateAxis("Agilis1", 2, 1, 50, -50)
AG_UCCreateAxis("Agilis1", 3, 1, 50, -50)
AG_UCCreateAxis("Agilis1", 4, 1, 50, -50)
AG_UCCreateAxis("Agilis1", 5, 1, 50, -50)

### Motors
dbLoadTemplate  "motors.template"
####################################################
# Load asyn records on each of these ports
dbLoadTemplate("asynRecord.template")

#var streamDebug 1

# Laser Quantum Excel lasers on serial 1
dbLoadRecords("$(CARS)/db/LQVentus.db", "P=$(PREFIX),R=LQE1,PORT=serial1")

# IPG laser is serial 2
dbLoadRecords("$(CARS)/db/IPG_YLR_laser.db","P=$(PREFIX),R=IPG1,PORT=serial2")

# Laser PLC Modbus connection
< Click.cmd

### Scan-support software
# crate-resident scan.  This executes 1D, 2D, 3D, and 4D scans, and caches
# 1D data, but it doesn't store anything to disk.  (You need the data catcher
# or the equivalent for that.)  This database is configured to use the
# "alldone" database (above) to figure out when motors have stopped moving
# and it's time to trigger detectors.
dbLoadRecords("$(SSCAN)/sscanApp/Db/scan.db", "P=$(PREFIX),MAXPTS1=2000,MAXPTS2=200,MAXPTS3=20,MAXPTS4=10,MAXPTSH=10")


# Free-standing user array calculations (aCalcout records)
dbLoadRecords("$(CALC)/calcApp/Db/userArrayCalcs10.db", "P=$(PREFIX),N=10")

# Free-standing user calcOuts (calcOut records)
dbLoadRecords("$(CALC)/calcApp/Db/userCalcOuts10.db", "P=$(PREFIX)")

# Free-standing user string/number calculations (sCalcout records)
dbLoadRecords("$(CALC)/calcApp/Db/userStringCalcs10.db", "P=$(PREFIX)")

# Free-standing user string sequence records (sseq records)
dbLoadRecords("$(CALC)/calcApp/Db/userStringSeqs10.db", "P=$(PREFIX)")

# Free-standing user transforms (transform records)
dbLoadRecords("$(CALC)/calcApp/Db/userTransforms10.db", "P=$(PREFIX)")

< ../save_restore_IOCSH.cmd
save_restoreSet_status_prefix("$(PREFIX)")
dbLoadRecords("$(AUTOSAVE)/asApp/Db/save_restoreStatus.db", "P=$(PREFIX)")

# devIocStats
epicsEnvSet("ENGINEER", "Mark Rivers")
epicsEnvSet("LOCATION","corvette")
epicsEnvSet("GROUP","GSECARS")
dbLoadRecords("$(DEVIOCSTATS)/db/iocAdminSoft.db","IOC=$(PREFIX)")

iocInit

### Start up the autosave task and tell it what to do.
# The task is actually named "save_restore".
# (See also, 'initHooks' above, which is the means by which the values that
# will be saved by the task we're starting here are going to be restored.
#
# save other things every thirty seconds
create_monitor_set("auto_settings.req",30,"P=$(PREFIX)")

