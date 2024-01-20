# E1608
epicsEnvSet("PORT",          "E1608")
epicsEnvSet("UNIQUE_ID",     "gse-e1608-1.cars.aps.anl.gov")
epicsEnvSet("MAX_POINTS",    "4096")
epicsEnvSet("E1608_PREFIX",  "$(P)E1608:")
## Configure port driver
# MultiFunctionConfig((portName,        # The name to give to this asyn port driver
#                      uniqueID,        # For USB the serial number.  For Ethernet the MAC address or IP address.
#                      maxInputPoints,  # Maximum number of input points for waveform digitizer
#                      maxOutputPoints) # Maximum number of output points for waveform generator

MultiFunctionConfig($(PORT), $(UNIQUE_ID), $(MAX_POINTS), 1)
dbLoadTemplate("$(MEASCOMP)/db/E1608.substitutions", "P=$(E1608_PREFIX), PORT=$(PORT), WDIG_POINTS=$(MAX_POINTS)")

dbLoadTemplate("MeasCompAliases.substitutions")
