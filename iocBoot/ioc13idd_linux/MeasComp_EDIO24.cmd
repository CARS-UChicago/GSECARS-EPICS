# EDIO24
epicsEnvSet("PORT",          "EDIO24")
epicsEnvSet("UNIQUE_ID",     "gse-edio24-1.cars.aps.anl.gov")
epicsEnvSet("MAX_POINTS",    "1")
epicsEnvSet("EDIO24_PREFIX",  "$(P)EDIO24_1:")
## Configure port driver
# MultiFunctionConfig((portName,        # The name to give to this asyn port driver
#                      uniqueID,        # For USB the serial number.  For Ethernet the MAC address or IP address.
#                      maxInputPoints,  # Maximum number of input points for waveform digitizer
#                      maxOutputPoints) # Maximum number of output points for waveform generator

MultiFunctionConfig($(PORT), $(UNIQUE_ID), $(MAX_POINTS), 1)
dbLoadTemplate("$(MEASCOMP)/db/EDIO24.substitutions", "P=$(EDIO24_PREFIX), PORT=$(PORT), WDIG_POINTS=$(MAX_POINTS)")

# Set all of the outputs high which will close the valves.
# There will be a brief period before this command executes when all of the valves will open
doAfterIocInit "dbpf $(EDIO24_PREFIX)Lo1 255"
doAfterIocInit "dbpf $(EDIO24_PREFIX)Lo2 255"
doAfterIocInit "dbpf $(EDIO24_PREFIX)Lo3 255"
