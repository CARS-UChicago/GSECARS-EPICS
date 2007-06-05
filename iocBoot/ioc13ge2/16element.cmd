# Setup the DXP CAMAC MCA.
# Change the following environment variable to point to the desired
# system configuration file

# Set logging level (1=ERROR, 2=WARNING, 3=INFO, 4=DEBUG)
xiaSetLogLevel(2)
xiaInit("16element_reset.ini")
xiaStartSystem()

# DXPConfig(serverName, ndetectors, ngroups, pollFrequency)
DXPConfig("DXP1",  16, 1, 10)

# Load all of the MCA and DXP records
dbLoadTemplate("16element.template")
