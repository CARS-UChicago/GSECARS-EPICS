# Setup the DXP CAMAC MCA.
# Change the following environment variable to point to the desired
# system configuration file
putenv("XIA_CONFIG=xiasystem.cfg")
dxp_initialize

# DXPConfig(serverName, detChan1, detChan2, detChan3, detChan4, queueSize)
DXPConfig("DXP1",  0,  1,  2,  3, 100)
DXPConfig("DXP2",  4,  5,  6,  7, 100)
DXPConfig("DXP3",  8,  9, 10, 11, 100)
DXPConfig("DXP4", 12, 13, 14, 15, 100)

dbLoadRecords("camacApp/Db/16element_dxp.db","P=13GE2:med:", camac)

# Load all of the records for the MCAs and ICB devices
dbLoadTemplate("16element.template")
