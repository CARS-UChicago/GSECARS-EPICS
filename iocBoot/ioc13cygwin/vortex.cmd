# Setup the DXP CAMAC MCA.
# Change the following environment variable to point to the desired
# system configuration file
epicsEnvSet("XIA_CONFIG", "xiasystem.cfg")
# Set environment variables for the FiPPI files. 
# FIPPI0,FIPPI1,FIPPI2,FIPPI3 should point to the files for 
# decimation=0,2,4,6 respectively. FIPPI_DEFAULT should point to the
# file that will be loaded initially at boot time.
epicsEnvSet("FIPPI0", "f01xpd0j.fip")
epicsEnvSet("FIPPI1", "f01xpd2j.fip")
epicsEnvSet("FIPPI2", "f01xpd4j.fip")
epicsEnvSet("FIPPI3", "f01xpd6j.fip")
epicsEnvSet("FIPPI_DEFAULT", "f01xpd4j.fip")
# Set logging level (1=ERROR, 2=WARNING, 3=XXX, 4=DEBUG)
dxp_md_set_log_level(2)
dxp_initialize

# DXPConfig(serverName, detChan1, detChan2, detChan3, detChan4, queueSize)
DXPConfig("DXP1",  0,  -1, -1, -1, 300)

dbLoadRecords("../../../dxp/dxpApp/Db/dxp2x.db","P=13Cygwin:, R=dxp1, INP=#C0 S0  @DXP1")
dbLoadRecords("../../../mca/mcaApp/Db/mca.db", "P=13Cygwin:,M=dxp_adc1,DTYPE=MPF MCA,INP=#C0 S0 @DXP1,NCHAN=2048")
