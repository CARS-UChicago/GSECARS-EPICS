< envPaths

# Start errlog Task before any possible error messsage to prevent
# erroneous "Interrupted system call" message on Linux OS.
errlogInit(0)

epicsEnvSet(STREAM_PROTOCOL_PATH, $(IP)/ipApp/Db:$(CARS)/CARSApp/Db)

dbLoadDatabase("$(CARS)/dbd/CARSLinux.dbd")
CARSWin32_registerRecordDeviceDriver(pdbbase)

# Create serial ports 1-4 on COM4-7
# Serial 1 is Laser Quantum laser
drvAsynSerialPortConfigure("serial1", "COM4", 0, 0, 0)
asynOctetSetInputEos("serial1",0,"\r\n")
asynOctetSetOutputEos("serial1",0,"\r\n")
asynSetOption("serial1",0,"baud","19200")
asynSetOption("serial1",0,"bits","8")
asynSetOption("serial1",0,"stop","1")
asynSetOption("serial1",0,"parity","none")
asynSetOption("serial1",0,"clocal","Y")
asynSetOption("serial1",0,"crtscts","N")
asynSetTraceIOMask("serial1", 0, 2)
#asynSetTraceMask("serial1", 0, 9)

# Serial 1 is Laser Quantum laser
drvAsynSerialPortConfigure("serial2", "COM5", 0, 0, 0)
asynOctetSetInputEos("serial2",0,"\r\n")
asynOctetSetOutputEos("serial2",0,"\r\n")
asynSetOption("serial2",0,"baud","19200")
asynSetOption("serial2",0,"bits","8")
asynSetOption("serial2",0,"stop","1")
asynSetOption("serial2",0,"parity","none")
asynSetOption("serial2",0,"clocal","Y")
asynSetOption("serial2",0,"crtscts","N")
asynSetTraceIOMask("serial2", 0, 2)
#asynSetTraceMask("serial2", 0, 9)

# Serial 3 is Verdi laser
drvAsynSerialPortConfigure("serial3", "COM6", 0, 0, 0)
asynOctetSetInputEos("serial3",0,"\r\n")
asynOctetSetOutputEos("serial3",0,"\r\n")
asynSetOption("serial3",0,"baud","19200")
asynSetOption("serial3",0,"bits","8")
asynSetOption("serial3",0,"stop","1")
asynSetOption("serial3",0,"parity","none")
asynSetOption("serial3",0,"clocal","Y")
asynSetOption("serial3",0,"crtscts","N")
asynSetTraceIOMask("serial3", 0, 2)
#asynSetTraceMask("serial3", 0, 0x19)

# Serial 4 is XXX laser
drvAsynSerialPortConfigure("serial4", "COM7", 0, 0, 0)
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

# Serial 5 is Newport AG-UC8 motor controller
drvAsynSerialPortConfigure("serial5", "COM9", 0, 0, 0)
asynOctetSetInputEos("serial5",0,"\r\n")
asynOctetSetOutputEos("serial5",0,"\r\n")
asynSetOption("serial5",0,"baud","921600")
#asynSetOption("serial5",0,"baud","9600")
asynSetOption("serial5",0,"bits","8")
asynSetOption("serial5",0,"stop","1")
asynSetOption("serial5",0,"parity","none")
asynSetOption("serial5",0,"clocal","Y")
asynSetOption("serial5",0,"crtscts","N")
asynSetTraceIOMask("serial5", 0, 2)
#asynSetTraceMask("serial5", 0, 0x19)

# Serial 6 is IPG-YLR laser over Ethernet
drvAsynIPPortConfigure("serial6", "164.54.160.112:10001", 0, 0, 0) 
asynOctetSetInputEos("serial6",0,"\r")
asynOctetSetOutputEos("serial6",0,"\r")

# AG_UCCreateController(asyn port, serial port, number of axes, 
#                        active poll period (ms), idle poll period (ms)) 
AG_UCCreateController("Agilis1", "serial5", 5, 50, 5000)
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

# Laser Quantum Excel lasers on serial 1 and 2
dbLoadRecords("$(CARS)/CARSApp/Db/LQVentus.db", "P=13RAMAN2:,R=LQE1,PORT=serial1")
dbLoadRecords("$(CARS)/CARSApp/Db/LQVentus.db", "P=13RAMAN2:,R=LQE2,PORT=serial2")

# Serial 3 is Verdi Laser
dbLoadRecords("$(CARS)/CARSApp/Db/VerdiLaser.db", "P=13RAMAN2:,R=Verdi1:,PORT=serial3")

# IPG laser is serial 6
dbLoadRecords("$(CARS)/CARSApp/Db/IPG_YLR_laser.db","P=13RAMAN2:,R=IPG1,PORT=serial6")

################################################################################
# XPS Setup

# asyn port, IP address, IP port, number of axes, 
# active poll period (ms), idle poll period (ms), 
# enable set position, set position settling time (ms)
XPSCreateController("XPS1", "164.54.160.147", 5001, 6, 10, 500, 1, 500)
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
XPSCreateAxis("XPS1",5,"Group6.Pos",  "800") 

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
dbpf("13RAMAN2:m6.NTM","0")

motorUtilInit("13RAMAN2:")
