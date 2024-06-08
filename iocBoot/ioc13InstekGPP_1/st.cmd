< envPaths
# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in this build from CARS
dbLoadDatabase("../../dbd/CARSLinux.dbd")
CARSLinux_registerRecordDeviceDriver(pdbbase)

epicsEnvSet("STREAM_PROTOCOL_PATH","$(IP)/db")
epicsEnvSet("PREFIX", "13INSTEK_1:")
epicsEnvSet(PORT, "INSTEK")

drvAsynIPPortConfigure("$(PORT)","164.54.160.223:1026",0,0,0)
asynOctetSetOutputEos("$(PORT)", 0, "\n")
asynOctetSetInputEos("$(PORT)", 0, "\n")
asynSetTraceIOMask $(PORT), 0, ESCAPE
#asynSetTraceMask $(PORT), 0, ERROR|DRIVER

dbLoadRecords("$(IP)/db/InstekGPP.db", "P=$(PREFIX),R=Instek1:,PORT=$(PORT)")
dbLoadTemplate("pid_slow.substitutions")

< ../calc_GSECARS.iocsh

### Scan-support software
dbLoadRecords("$(SSCAN)/db/scan.db", "P=$(PREFIX),MAXPTS1=2000,MAXPTS2=200,MAXPTS3=20,MAXPTS4=10,MAXPTSH=10")

# asyn record for debugging
dbLoadRecords("$(ASYN)/db/asynRecord.db", "P=$(PREFIX),R=asyn1,PORT=$(PORT),ADDR=0,IMAX=80,OMAX=80")

< ../save_restore_IOCSH.cmd

iocInit

create_monitor_set("auto_settings.req", 30, "P=$(PREFIX),R=Instek1:")

