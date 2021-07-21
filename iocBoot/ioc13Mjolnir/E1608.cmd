epicsEnvSet(PORT, "E1608_1")
epicsEnvSet(WDIG_POINTS, "4096")
epicsEnvSet(UNIQUE_ID, "10.54.160.63")

## Configure port driver
# MultiFunctionConfig((portName,        # The name to give to this asyn port driver
#                      uniqueID,        # For USB the serial number.  For Ethernet the MAC address or IP address.
#                      maxInputPoints,  # Maximum number of input points for waveform digitizer
#                      maxOutputPoints) # Maximum number of output points for waveform generator
MultiFunctionConfig("$(PORT)", $(UNIQUE_ID), $(WDIG_POINTS), 1)

#asynSetTraceMask "$(PORT)" -1 255

dbLoadTemplate("$(MEASCOMP)/db/E1608.substitutions", "P=$(E1608_PREFIX),PORT=$(PORT),WDIG_POINTS=$(WDIG_POINTS)")
#dbLoadTemplate("pid_slow.substitutions")
