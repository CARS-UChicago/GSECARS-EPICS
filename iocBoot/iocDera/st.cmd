errlogInit(5000)
< envPaths
# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in this build from CARS
dbLoadDatabase("../../dbd/CARSWin32.dbd")
CARSWin32_registerRecordDeviceDriver(pdbbase)

drvAsynSerialPortConfigure("serial1", "COM1", 0, 0, 0)
asynSetOption("serial1", 0, baud, 9600)
asynSetOption("serial1", 0, parity, none)
asynSetOption("serial1", 0, bits, 8)
asynSetOption("serial1", 0, stop, 2)
asynOctetSetInputEos("serial1",0,"\r")
asynOctetSetOutputEos("serial1",0,"\r")

epicsEnvSet(INPUT_POINTS, "1048576")
epicsEnvSet(OUTPUT_POINTS, "0")
epicsEnvSet(PREFIX, "Dera:")

## Configure Measurement Computing port driver
# USB1608GConfig(portName,        # The name to give to this asyn port driver
#                boardNum,        # The number of this board assigned by the Measurement Computing Instacal program 
#                maxInputPoints,  # Maximum number of input points for waveform digitizer
#                maxOutputPoints) # Maximum number of output points for waveform generator
MultiFunctionConfig("1608G", 0, $(INPUT_POINTS), $(OUTPUT_POINTS))

dbLoadTemplate("1608G.substitutions")

## SR570 database
dbLoadRecords("$(IP)/ipApp/Db/SR570.db", "P=$(PREFIX),A=A1,PORT=serial1")

# Newport CONEX-PP controllers
# For Windows
drvAsynSerialPortConfigure("serial2", "COM8", 0, 0, 0)
asynOctetSetInputEos("serial2",0,"\r\n")
asynOctetSetOutputEos("serial2",0,"\r\n")
asynSetOption("serial2",0,"baud","115200")
asynSetOption("serial2",0,"bits","8")
asynSetOption("serial2",0,"stop","1")
asynSetOption("serial2",0,"parity","none")
asynSetOption("serial2",0,"clocal","Y")
asynSetOption("serial2",0,"crtscts","N")

asynSetTraceIOMask("serial2", 0, 2)
#asynSetTraceMask("serial2", 0, 9)

# AG_CONEXCreateController(asyn port, serial port, controllerID, 
#                          active poll period (ms), idle poll period (ms)) 
AG_CONEXCreateController("CONEX1", "serial2", 1, 50, 500)
asynSetTraceIOMask("CONEX1", 0, 2)
#asynSetTraceMask("CONEX1", 0, 255)
AG_CONEXCreateController("CONEX2", "serial2", 2, 50, 500)
asynSetTraceIOMask("CONEX2", 0, 2)
#asynSetTraceMask("CONEX2", 0, 255)
AG_CONEXCreateController("CONEX3", "serial2", 3, 50, 500)
asynSetTraceIOMask("CONEX3", 0, 2)
#asynSetTraceMask("CONEX3", 0, 255)
dbLoadTemplate("motor.substitutions")

### Allstop, alldone
dbLoadRecords("$(MOTOR)/db/motorUtil.db","P=Dera:")

# Load asynRecords
dbLoadRecords("$(ASYN)/db/asynRecord.db","P=$(PREFIX),R=serial1,PORT=serial1,ADDR=0,OMAX=80,IMAX=80")
dbLoadRecords("$(ASYN)/db/asynRecord.db","P=$(PREFIX),R=serial2,PORT=serial2,ADDR=0,OMAX=80,IMAX=80")

### Scan-support software
# crate-resident scan.  This executes 1D, 2D, 3D, and 4D scans, and caches
# 1D data, but it doesn't store anything to disk.  (You need the data catcher
# or the equivalent for that.)  This database is configured to use the
# "alldone" database (above) to figure out when motors have stopped moving
# and it's time to trigger detectors.
dbLoadRecords("$(SSCAN)/db/scan.db", "P=$(PREFIX),MAXPTS1=2000,MAXPTS2=200,MAXPTS3=20,MAXPTS4=10,MAXPTSH=10")
dbLoadTemplate("scanParms.template")

<../calc_GSECARS.iocsh

# Miscellaneous PV's, such as burtResult
dbLoadRecords("$(STD)/db/misc.db", "P=$(PREFIX)")

< ../save_restore_IOCSH.cmd
save_restoreSet_status_prefix("$(PREFIX)")
dbLoadRecords("$(AUTOSAVE)/asApp/Db/save_restoreStatus.db", "P=$(PREFIX)")

# devIocStats
epicsEnvSet("ENGINEER", "Przemek Dera")
epicsEnvSet("LOCATION","Hawaii DAC lab")
epicsEnvSet("GROUP","Univ. of Hawaii")
dbLoadRecords("$(DEVIOCSTATS)/db/iocAdminSoft.db","IOC=$(PREFIX)")


iocInit

# Need to force the time arrays to process because the records are scan=I/O Intr
# but asynPortDriver does not do array callbacks before iocInit.

dbpf 1608G:WaveDigDwell.PROC 1

# save things every thirty seconds
create_monitor_set("auto_settings.req", 30, "P=$(PREFIX)")

## Start the saveData task.
# saveData_MessagePolicy
# 0: wait forever for space in message queue, then send message
# 1: send message only if queue is not full
# 2: send message only if queue is not full and specified time has passed (SetCptWait()
#    sets this time.)
# 3: if specified time has passed, wait for space in queue, then send message
# else: don't send message
#debug_saveData = 2
saveData_MessagePolicy = 2
saveData_SetCptWait_ms(100)
saveData_Init("saveDataExtraPVs.req", "P=$(PREFIX)")
#saveData_PrintScanInfo("$(PREFIX)scan1")

