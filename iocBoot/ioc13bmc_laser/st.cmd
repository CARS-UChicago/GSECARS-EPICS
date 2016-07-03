< envPaths

# Start errlog Task before any possible error messsage to prevent
# erroneous "Interrupted system call" message on Linux OS.
errlogInit(0)

epicsEnvSet(STREAM_PROTOCOL_PATH, $(IP)/ipApp/Db:$(CARS)/CARSApp/Db)

dbLoadDatabase("$(CARS)/dbd/CARSWin32.dbd")
CARSWin32_registerRecordDeviceDriver(pdbbase)

#dbLoadDatabase("$(CARS)/dbd/CARSLinux.dbd")
#CARSLinux_registerRecordDeviceDriver(pdbbase)

epicsEnvSet("PREFIX", "13BMC_Laser:")

# Create serial ports 1-4 on COM4-7
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

# Load asyn records on each of these ports
dbLoadTemplate("asynRecord.template")

#var streamDebug 1

# Laser Quantum Excel lasers on serial 1
dbLoadRecords("$(CARS)/CARSApp/Db/LQVentus.db", "P=$(PREFIX),R=LQE1,PORT=serial1")

# IPG laser is serial 2
dbLoadRecords("$(CARS)/CARSApp/Db/IPG_YLR_laser.db","P=$(PREFIX),R=IPG1,PORT=serial2")

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

