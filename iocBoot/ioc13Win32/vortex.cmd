# Initialize the XIA software
# Set logging level (1=ERROR, 2=WARNING, 3=XXX, 4=DEBUG)
xiaSetLogLevel(2)
# Execute the following line if you have a Vortex detector or 
# another detector with a reset pre-amplifier
xiaInit("vortex.ini")
#xiaInit("vortex40MHz.ini")
# Execute the following line if you have a Ketek detector or 
# another detector with an RC pre-amplifier
#xiaInit("ketek.ini")
#xiaInit("ketek40MHz.ini")
xiaStartSystem

# DXPConfig(serverName, nchans)
DXPConfig("DXP1",  1)

# DXP record
# Execute the following line if you have a Vortex detector or 
# another detector with a reset pre-amplifier
#dbLoadRecords("$(DXP)/dxpApp/Db/dxp2x_reset.db","P=13Win32:, R=dxp1, INP=@asyn(DXP1 0)")
# Execute the following line if you have a Ketek detector or 
# another detector with an RC pre-amplifier
dbLoadRecords("$(DXP)/dxpApp/Db/dxp2x_rc.db","P=13Win32:, R=dxp1, INP=@asyn(DXP1 0)")

# MCA record
dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=13Win32:, M=mca1, DTYP=asynMCA,INP=@asyn(DXP1 0),NCHAN=2048")

# Template to copy MCA ROIs to DXP SCAs
#dbLoadTemplate("roi_to_sca.substitutions")

