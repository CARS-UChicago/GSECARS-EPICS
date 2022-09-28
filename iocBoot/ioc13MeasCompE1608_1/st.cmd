< envPaths

## Register all support components
dbLoadDatabase "../../dbd/CARSLinux.dbd"
CARSLinux_registerRecordDeviceDriver pdbbase

epicsEnvSet("PREFIX", "13E1608_1:")
epicsEnvSet(PORT, "E1608_1")
epicsEnvSet(WDIG_POINTS, "4096")
epicsEnvSet(UNIQUE_ID, "10.54.160.216")

## Configure port driver
# MultiFunctionConfig((portName,        # The name to give to this asyn port driver
#                      uniqueID,        # For USB the serial number.  For Ethernet the MAC address or IP address.
#                      maxInputPoints,  # Maximum number of input points for waveform digitizer
#                      maxOutputPoints) # Maximum number of output points for waveform generator
MultiFunctionConfig("$(PORT)", $(UNIQUE_ID), $(WDIG_POINTS), 1)

#asynSetTraceMask E1608_1 -1 255

dbLoadTemplate("$(MEASCOMP)/db/E1608.substitutions", "P=$(PREFIX),PORT=$(PORT),WDIG_POINTS=$(WDIG_POINTS)")
dbLoadTemplate("pid_slow.substitutions")

< ../calc_GSECARS.iocsh

### Scan-support software
dbLoadRecords("$(SSCAN)/db/scan.db", "P=$(PREFIX),MAXPTS1=2000,MAXPTS2=200,MAXPTS3=20,MAXPTS4=10,MAXPTSH=10")

< ../save_restore_IOCSH.cmd

iocInit

create_monitor_set("auto_settings.req",30,"P=$(PREFIX)")

# Need to force the time arrays to process because the records are scan=I/O Intr
# but asynPortDriver does not do array callbacks before iocInit.

dbpf $(PREFIX)WaveDigDwell.PROC 1
