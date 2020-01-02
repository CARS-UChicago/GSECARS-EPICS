# Setup the DXP CAMAC MCA.
# Set logging level (1=ERROR, 2=WARNING, 3=XXX, 4=DEBUG)
xiaSetLogLevel(2)
xiaInit("1element_reset.ini")
xiaStartSystem()

# DXPConfig(serverName, ndetectors, ngroups, pollFrequency)
DXPConfig("DXP1",  1)

dbLoadRecords("$(DXP)/db/dxp2x_reset.db","P=dxpLinux:, R=dxp1, INP=@asyn(DXP1 0)")
dbLoadRecords("$(MCA)/db/mca.db", "P=dxpLinux:, M=mca1, DTYP=asynMCA,INP=@asyn(DXP1 0),NCHAN=2048")

