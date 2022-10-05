epicsEnvSet("USB2408_PREFIX", "$(PREFIX)USB2408:")
epicsEnvSet(PORT, "2408")
epicsEnvSet(WDIG_POINTS, "4096")
epicsEnvSet(WGEN_POINTS, "4096")
epicsEnvSet(UNIQUE_ID, "01E74311")

## Configure port driver
# MultiFunctionConfig((portName,        # The name to give to this asyn port driver
#                      uniqueID,        # For USB the serial number.  For Ethernet the MAC address or IP address.
#                      maxInputPoints,  # Maximum number of input points for waveform digitizer
#                      maxOutputPoints) # Maximum number of output points for waveform generator
MultiFunctionConfig("$(PORT)", $(UNIQUE_ID), $(WDIG_POINTS), $(WGEN_POINTS))

dbLoadTemplate("$(MEASCOMP)/db/USB2408.substitutions", "P=$(USB2408_PREFIX),PORT=$(PORT),WDIG_POINTS=$(WDIG_POINTS), WGEN_POINTS=$(WGEN_POINTS)")

#PID slow
dbLoadTemplate "pid_slow.substitutions"
