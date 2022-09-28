< envPaths

## Register all support components
dbLoadDatabase "../../dbd/CARSLinux.dbd"
CARSLinux_registerRecordDeviceDriver pdbbase

epicsEnvSet(PREFIX, "13ETC_1:")
epicsEnvSet(PORT, "ETC_1")
epicsEnvSet(UNIQUE_ID, "10.54.160.218")

## Configure port driver
# MultiFunctionConfig((portName,        # The name to give to this asyn port driver
#                      uniqueID,        # For USB the serial number.  For Ethernet the MAC address or IP address.
#                      maxInputPoints,  # Maximum number of input points for waveform digitizer
#                      maxOutputPoints) # Maximum number of output points for waveform generator
MultiFunctionConfig("$(PORT)", "$(UNIQUE_ID)", 1, 1)

#asynSetTraceMask $(PORT) -1 255

dbLoadTemplate("$(MEASCOMP)/db/ETC.substitutions", "P=$(PREFIX), PORT=$(PORT)")

< ../save_restore_IOCSH.cmd

iocInit

create_monitor_set("auto_settings.req",30,"P=$(PREFIX)")

