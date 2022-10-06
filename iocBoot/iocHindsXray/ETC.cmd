epicsEnvSet(ETC_PREFIX, "$(PREFIX)ETC:")
epicsEnvSet(PORT, "ETC_1")
# We can set the UNIQUE_ID either to the MAC address or the IP address
#epicsEnvSet(UNIQUE_ID, "10.100.160.11")
epicsEnvSet(UNIQUE_ID, "00:80:2F:34:F4:79")

## Configure port driver
# MultiFunctionConfig((portName,        # The name to give to this asyn port driver
#                      uniqueID,        # For USB the serial number.  For Ethernet the MAC address or IP address.
#                      maxInputPoints,  # Maximum number of input points for waveform digitizer
#                      maxOutputPoints) # Maximum number of output points for waveform generator
MultiFunctionConfig("$(PORT)", "$(UNIQUE_ID)", 1, 1)

#asynSetTraceMask $(PORT) -1 255

dbLoadTemplate("$(MEASCOMP)/db/ETC.substitutions", "P=$(ETC_PREFIX), PORT=$(PORT)")
