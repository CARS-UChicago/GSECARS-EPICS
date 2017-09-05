< envPaths

epicsEnvSet("PREFIX", "13IDD_PACE5000:")

# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in this build from CARS
dbLoadDatabase("../../dbd/CARSLinux.dbd")
CARSLinux_registerRecordDeviceDriver(pdbbase)

drvAsynIPPortConfigure("PACE5000", "164.54.160.26:5025", 0, 0, 0)
asynOctetSetInputEos ("PACE5000",0,"\r\n")
asynOctetSetOutputEos("PACE5000",0,"\r\n")

epicsEnvSet STREAM_PROTOCOL_PATH $(IP)/ipApp/Db
dbLoadRecords("$(IP)/ipApp/Db/PACE5000.db", "P=$(PREFIX),R=PC1:,PORT=PACE5000")

< ../save_restore_IOCSH.cmd
save_restoreSet_status_prefix("$(PREFIX)")
dbLoadRecords("$(AUTOSAVE)/asApp/Db/save_restoreStatus.db", "P=$(PREFIX)")

# devIocStats
epicsEnvSet("ENGINEER", "Mark Rivers")
epicsEnvSet("LOCATION","13-ID-D")
epicsEnvSet("GROUP","GSECARS")
dbLoadRecords("$(DEVIOCSTATS)/db/iocAdminSoft.db","IOC=$(PREFIX)")

iocInit

# save other things every thirty seconds
create_monitor_set("auto_settings.req", 30, "P=$(PREFIX)")
