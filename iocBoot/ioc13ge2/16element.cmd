# Setup the DXP CAMAC MCA.
# Change the following environment variable to point to the desired
# system configuration file

epicsEnvSet("XIA_CONFIG", "xiasystem.cfg")
# Set environment variables for the FiPPI files. 
# FIPPI0,FIPPI1,FIPPI2,FIPPI3 should point to the files for 
# decimation=0,2,4,6 respectively. FIPPI_DEFAULT should point to the
# file that will be loaded initially at boot time.
#
# These are the new Rev. 9 files.  They don't work right.
#epicsEnvSet("FIPPI0", "fxpd00j_psam.fip")
#epicsEnvSet("FIPPI1", "fxpd200j_st.fip")
#epicsEnvSet("FIPPI2", "fxpd420j_st.fip")
#epicsEnvSet("FIPPI3", "fxpd640j_st.fip")
#epicsEnvSet("FIPPI_DEFAULT", "fxpd200j_st.fip")

# These are the older Rev. 6 reset files
epicsEnvSet("FIPPI0", "f01x2p0g.fip")
epicsEnvSet("FIPPI1", "f01x2p2g.fip")
epicsEnvSet("FIPPI2", "f01x2p4g.fip")
epicsEnvSet("FIPPI3", "f01x2p6g.fip")
epicsEnvSet("FIPPI_DEFAULT", "f01x2p4g.fip")

# These are the Rev. 8 RC files
#epicsEnvSet("FIPPI0", "fxrc00.fip")
#epicsEnvSet("FIPPI1", "fxrc20.fip")
#epicsEnvSet("FIPPI2", "fxrc40.fip")
#epicsEnvSet("FIPPI3", "fxrc60.fip")
#epicsEnvSet("FIPPI_DEFAULT", "fxrc20.fip")

# Set logging level (1=ERROR, 2=WARNING, 3=XXX, 4=DEBUG)
dxp_md_set_log_level(2)
dxp_initialize

# DXPConfig(serverName, detChan1, detChan2, detChan3, detChan4)
DXPConfig("DXP1",  0,  1,  2,  3)
DXPConfig("DXP2",  4,  5,  6,  7)
DXPConfig("DXP3",  8,  9, 10, 11)
DXPConfig("DXP4", 12, 13, 14, 15)

dbLoadRecords("$(DXP)/dxpApp/Db/16element_dxp.db","P=13GE2:med:")

# Load all of the MCA and DXP records
dbLoadTemplate("16element.template")
