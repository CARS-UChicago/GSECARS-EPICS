errlogInit(5000)
< envPaths
# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in this build from CARS
dbLoadDatabase("../../dbd/CARSLinux.dbd")
CARSLinux_registerRecordDeviceDriver(pdbbase)

### Motors
dbLoadTemplate  "motors.template"


drvAsynIPPortConfigure("ARIES1", "gse-aries1:5002", 0, 0, 0)
asynWaitConnect("ARIES1", 10.)
#asynSetTraceMask("ARIES1", 0, 3)
asynSetTraceIOMask("ARIES1", 0, 2)
asynOctetSetInputEos("ARIES1",0,"\r")
asynOctetSetOutputEos("ARIES1",0,"\r")

drvAsynIPPortConfigure("ARIES2", "gse-aries2:5002", 0, 0, 0)
asynWaitConnect("ARIES2", 10.)
#asynSetTraceMask("ARIES2", 0, 3)
asynSetTraceIOMask("ARIES2", 0, 2)
asynOctetSetInputEos("ARIES2",0,"\r")
asynOctetSetOutputEos("ARIES2",0,"\r")

dbLoadRecords("$(ASYN)/db/asynRecord.db", "P=IOC:, R=asyn1, PORT=ARIES1, ADDR=0, OMAX=256, IMAX=256")
dbLoadRecords("$(ASYN)/db/asynRecord.db", "P=IOC:, R=asyn2, PORT=ARIES1, ADDR=0, OMAX=256, IMAX=256")

# PORT, ACR_PORT, number of axes, active poll period (ms), idle poll period (ms)
ACRCreateController("ACR1", "ARIES1", 1, 20, 1000)
ACRCreateController("ACR2", "ARIES2", 1, 20, 1000)

#asynSetTraceMask("ACR1", 0, 255)
asynSetTraceIOMask("ACR1", 0, 2)
#asynSetTraceMask("ACR2", 0, 255)
asynSetTraceIOMask("ACR2", 0, 2)

### Scan-support software
# crate-resident scan.  This executes 1D, 2D, 3D, and 4D scans, and caches
# 1D data, but it doesn't store anything to disk.  (You need the data catcher
# or the equivalent for that.)  This database is configured to use the
# "alldone" database (above) to figure out when motors have stopped moving
# and it's time to trigger detectors.
dbLoadRecords("$(SSCAN)/sscanApp/Db/scan.db", "P=13xps3:,MAXPTS1=2000,MAXPTS2=200,MAXPTS3=20,MAXPTS4=10,MAXPTSH=10")

< ../save_restore_IOCSH.cmd
save_restoreSet_status_prefix("13DDIA30:")
dbLoadRecords("$(AUTOSAVE)/asApp/Db/save_restoreStatus.db", "P=13DDIA30:")

iocInit

# save positions every five seconds
create_monitor_set("auto_positions.req", 5, "P=13DDIA30:")
# save other things every thirty seconds
create_monitor_set("auto_settings.req", 30, "P=13DDIA30:")

