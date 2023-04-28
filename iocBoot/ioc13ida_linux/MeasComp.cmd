## Configure port driver
# MultiFunctionConfig((portName,        # The name to give to this asyn port driver
#                      uniqueID,        # For USB the serial number.  For Ethernet the MAC address or IP address.
#                      maxInputPoints,  # Maximum number of input points for waveform digitizer
#                      maxOutputPoints) # Maximum number of output points for waveform generator
MultiFunctionConfig(E1608_1, gse-e1608-3, 4096, 1)
MultiFunctionConfig(E1608_2, gse-e1608-1, 4096, 1)

dbLoadTemplate("$(MEASCOMP)/db/E1608.substitutions", "P=$(P)E1608_1:, PORT=E1608_1, WDIG_POINTS=4096")
dbLoadTemplate("$(MEASCOMP)/db/E1608.substitutions", "P=$(P)E1608_2:, PORT=E1608_2, WDIG_POINTS=4096")
