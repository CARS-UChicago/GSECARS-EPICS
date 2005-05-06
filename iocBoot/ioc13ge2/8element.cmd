# Setup the DXP CAMAC MCA.
# Set logging level (1=ERROR, 2=WARNING, 3=XXX, 4=DEBUG)
xiaSetLogLevel(3)
xiaInit("8element_reset.ini")
xiaStartSystem()

# DXPConfig(serverName, nchans)
DXPConfig("DXP1",  8)

dbLoadRecords("$(DXP)/dxpApp/Db/dxpMED.db","P=13GE2:med:")

# Load all of the MCA and DXP records
dbLoadTemplate("8element.template")
