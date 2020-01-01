errlogInit(5000)
< envPaths
epicsEnvSet("EPICS_CA_MAX_ARRAY_BYTES", "80000")

# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in this build from CARS
dbLoadDatabase("../../dbd/CARSLinux.dbd")
CARSLinux_registerRecordDeviceDriver(pdbbase)

epicsEnvSet("PREFIX", "HindsXray:")

#< industryPack.cmd

< USBCTR.cmd

##########################################################
# Configure asyn device
# FOLLOWING 1 LINE COMMENTED OUT WHILE TESTING AT APS BECAUSE IT LEADS TO VERY LONG TIMEOUT
#pmacAsynIPConfigure("PMAC_IP","10.135.28.41:1025",0,0,0)
#asynSetTraceMask("PMAC_IP",-1,0xFF)
asynSetTraceIOMask("PMAC_IP",-1,0x1)
#asynSetTraceMask("PMAC_IP",-1,0x1)
#asynSetTraceIOMask("PMAC_IP",-1,0x0)

pmacAsynMotorCreate("PMAC_IP", 0, 0, 9);

# Setup the motor Asyn layer (portname, low-level driver drvet name, card, number of axes on card)
drvAsynMotorConfigure("PMAC1", "pmacAsynMotor", 0, 9)

### Motors
dbLoadTemplate  "motors.template"

### Scan-support software
# crate-resident scan.  This executes 1D, 2D, 3D, and 4D scans, and caches
# 1D data, but it doesn't store anything to disk.  (You need the data catcher
# or the equivalent for that.)  This database is configured to use the
# "alldone" database (above) to figure out when motors have stopped moving
# and it's time to trigger detectors.
dbLoadRecords("$(SSCAN)/sscanApp/Db/scan.db", "P=$(PREFIX),MAXPTS1=2000,MAXPTS2=200,MAXPTS3=20,MAXPTS4=10,MAXPTSH=10")

# A set of scan parameters for each positioner.  This is a convenience
# for the user.  It can contain an entry for each scannable thing in the
# crate.
dbLoadTemplate("scanParms.template")

# Miscellaneous PV's
dbLoadRecords("$(STD)/stdApp/Db/misc.db","P=$(PREFIX)", std)

< ../calc_GSECARS.iocsh

### Allstop, alldone
dbLoadRecords("$(MOTOR)/db/motorUtil.db","P=13PMAC1:")

dbLoadRecords("$(ASYN)/db/asynRecord.db","P=$(PREFIX),R=serial1,PORT=PMAC_IP,ADDR=0,OMAX=80,IMAX=80")

< ../save_restore_IOCSH.cmd
save_restoreSet_status_prefix("$(PREFIX)")
dbLoadRecords("$(AUTOSAVE)/asApp/Db/save_restoreStatus.db", "P=$(PREFIX)")

iocInit

seq(USBCTR_SNL, "P=$(MCS_PREFIX), R=$(RNAME), NUM_COUNTERS=$(MAX_COUNTERS), FIELD=$(FIELD)")

# save other things every thirty seconds
create_monitor_set("auto_positions.req", 5, "P=$(PREFIX)")
create_monitor_set("auto_settings.req", 30, "P=$(PREFIX)")

### Start the saveData task.
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

