< envPaths

## Register all support components
dbLoadDatabase("$(CARS)/dbd/CARSWin32.dbd")
CARSWin32_registerRecordDeviceDriver pdbbase

epicsEnvSet("PREFIX", "13USB2408_1:")
epicsEnvSet(PORT, "USB2408_1")
epicsEnvSet(WDIG_POINTS, "4096")
epicsEnvSet(WGEN_POINTS, "4096")
epicsEnvSet(UNIQUE_ID, "01AAA83C")
#epicsEnvSet(UNIQUE_ID, "01AAA83E") #USB2408_2

## Configure port driver
# MultiFunctionConfig((portName,        # The name to give to this asyn port driver
#                      uniqueID,        # For USB the serial number.  For Ethernet the MAC address or IP address.
#                      maxInputPoints,  # Maximum number of input points for waveform digitizer
#                      maxOutputPoints) # Maximum number of output points for waveform generator
MultiFunctionConfig("$(PORT)", $(UNIQUE_ID), $(WDIG_POINTS), 1)

dbLoadTemplate("$(MEASCOMP)/db/USB2408.substitutions", "P=$(PREFIX), PORT=$(PORT), WDIG_POINTS=$(WDIG_POINTS), WGEN_POINTS=$(WGEN_POINTS)")

#PID slow
dbLoadTemplate "pid_slow.substitutions"

### Scan-support software
# crate-resident scan.  This executes 1D, 2D, 3D, and 4D scans, and caches
# 1D data, but it doesn't store anything to disk.  (You need the data catcher
# or the equivalent for that.)  This database is configured to use the
# "alldone" database (above) to figure out when motors have stopped moving
# and it's time to trigger detectors.
dbLoadRecords("$(SSCAN)/db/scan.db", "P=$(PREFIX),MAXPTS1=2000,MAXPTS2=200,MAXPTS3=20,MAXPTS4=10,MAXPTSH=10")


#asynSetTraceMask USB2408_1 -1 255

< ../save_restore_IOCSH.cmd
save_restoreSet_status_prefix("13USB2408_1:")
dbLoadRecords("$(AUTOSAVE)/db/save_restoreStatus.db", "P=$(PREFIX)")

iocInit

create_monitor_set("auto_settings.req",30,"P=$(PREFIX)")

