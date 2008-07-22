# Setup the DXP CAMAC MCA.
# Set logging level (1=ERROR, 2=WARNING, 3=XXX, 4=DEBUG)
xiaSetLogLevel(2)
xiaInit("4element_reset.ini")
xiaStartSystem()

# DXPConfig(serverName, ndetectors, ngroups, pollFrequency)
DXPConfig("DXP1",  4, 1, 10)

# Load all of the MCA and DXP records
dbLoadTemplate("4element.template")
