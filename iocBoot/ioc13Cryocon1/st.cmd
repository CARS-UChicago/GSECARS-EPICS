errlogInit(5000)
< envPaths

epicsEnvSet("PREFIX","13Cryocon1:")
epicsEnvSet("TCTRLR", $(PREFIX)CC1)
epicsEnvSet("DEVICE", $(PREFIX)CC1)
epicsEnvSet("PORT", "serial1")
epicsEnvSet("STREAM_PROTOCOL_PATH", "$(CRYOCONM32)/CryoconM32App/protocol")

# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in this build from CARS
dbLoadDatabase("../../dbd/CARSLinux.dbd")
CARSLinux_registerRecordDeviceDriver(pdbbase)

#drvAsynIPPortConfigure("portName","hostInfo",priority,noAutoConnect,
#                        noProcessEos)
drvAsynIPPortConfigure("$(PORT)", "164.54.160.122:5000", 0, 0, 0)
asynSetTraceIOMask("$(PORT)", 0, 2)
#asynSetTraceMask("$(PORT)", 0, 255)
asynOctetSetInputEos("$(PORT)", 0,"\n")
asynOctetSetOutputEos("$(PORT)", 0,"\n")

dbLoadTemplate("Cryocon22C.substitutions", "tctrlr=$(TCTRLR), device=$(TCTRLR), rampratelim=200, port=$(PORT)")
dbLoadRecords("$(ASYN)/db/asynRecord.db","P=$(PREFIX),R=serial1,PORT=$(PORT), ADDR=0, OMAX=256, IMAX=256")

### Scan-support software
# crate-resident scan.  This executes 1D, 2D, 3D, and 4D scans, and caches
# 1D data, but it doesn't store anything to disk.  (You need the data catcher
# or the equivalent for that.)  This database is configured to use the
# "alldone" database (above) to figure out when motors have stopped moving
# and it's time to trigger detectors.
dbLoadRecords("$(SSCAN)/db/scan.db", "P=$(PREFIX),MAXPTS1=2000,MAXPTS2=200,MAXPTS3=20,MAXPTS4=10,MAXPTSH=10")

<../calc_GSECARS.iocsh

# Miscellaneous PV's, such as burtResult
dbLoadRecords("$(STD)/db/misc.db", "P=$(PREFIX)")

< ../save_restore_IOCSH.cmd
save_restoreSet_status_prefix("$(PREFIX)")
dbLoadRecords("$(AUTOSAVE)/db/save_restoreStatus.db", "P=$(PREFIX)")

# devIocStats
epicsEnvSet("ENGINEER", "Mark Rivers")
epicsEnvSet("LOCATION","Sector 13 portable")
epicsEnvSet("GROUP","GSECARS")
dbLoadRecords("$(DEVIOCSTATS)/db/iocAdminSoft.db","IOC=$(PREFIX)")

iocInit

# Save settings every thirty seconds
create_monitor_set("auto_settings.req", 30, "P=$(PREFIX)")
