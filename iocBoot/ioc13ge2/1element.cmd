# Setup the DXP CAMAC MCA.
# Set logging level (1=ERROR, 2=WARNING, 3=XXX, 4=DEBUG)
xiaSetLogLevel(4)
xiaInit("1element_reset.ini")
xiaStartSystem()

# DXPConfig(serverName, nchans)
DXPConfig("DXP1",  1)

dbLoadRecords("$(DXP)/dxpApp/Db/dxp2x_reset.db","P=dxpLinux:, R=dxp1, INP=@asyn(DXP1 0)")
dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=dxpLinux:, M=mca1, DTYP=asynMCA,INP=@asyn(DXP1 0),NCHAN=2048")

