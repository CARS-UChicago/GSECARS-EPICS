# Allocate 32MB of memory temporarily so that all code loads in 32MB.
mem = malloc(1024*1024*96)

# vxWorks startup file
< cdCommands

< ../nfsCommandsGSE

cd topbin
load("CARSApp.munch")
cd startup

# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in this build from CARSApp
dbLoadDatabase("$(CARS)/dbd/CARSVX.dbd")
CARSVX_registerRecordDeviceDriver(pdbbase)

putenv("EPICS_TS_MIN_WEST=300")

# Initialize MPF stuff
routerInit

# Initialize local MPF connection
localMessageRouterStart(0)

# Set debugging flags
mcaRecordDebug = 0
devScalerCamacDebug=0
devE500Debug=0
drvE500Debug=0
aimDebug=0
icbDebug=0
dxpRecordDebug=0
mcaDXPServerDebug=0
devDxpMpfDebug=0

# Setup the ksc2917 hardware definitions
# These are all actually the defaults, so this is not really necessary
# num_cards, addrs, ivec, irq_level
ksc2917_setup(1, 0xFF00, 0x00A0, 2)

# Initialize the CAMAC library.  Note that this is normally done automatically
# in iocInit, but we need to get the CAMAC routines working before iocInit
# because we need to initialize the DXP hardware.
camacLibInit

# Load the DXP stuff
#< 16element.cmd
# <  4element.cmd
 < 8element.cmd

# Generic CAMAC record
dbLoadRecords("$(CAMAC)/camacApp/Db/generic_camac.db","P=13GE3:,R=camac1,SIZE=2048")

### Scan-support software
# crate-resident scan.  This executes 1D, 2D, 3D, and 4D scans, and caches
# 1D data, but it doesn't store anything to disk.  (You need the data catcher
# or the equivalent for that.)  This database is configured to use the
# "alldone" database (above) to figure out when motors have stopped moving
# and it's time to trigger detectors.
dbLoadRecords("$(SSCAN)/db/scan.db","P=13GE3:,MAXPTS1=2000,MAXPTS2=200,MAXPTS3=20,MAXPTS4=10,MAXPTSH=10")

# A set of scan parameters for each positioner.  This is a convenience
# for the user.  It can contain an entry for each scannable thing in the
# crate.
dbLoadTemplate "scanParms.template"

# Free-standing user string/number calculations (sCalcout records)
dbLoadRecords("$(CALC)/db/userStringCalcs10.db","P=13GE3:")

# Free-standing user transforms (transform records)
dbLoadRecords("$(CALC)/db/userTransforms10.db","P=13GE3:")

# vme test record
dbLoadRecords("$(VME)/vmeApp/Db/vme.db", "P=13GE3:,Q=vme1")

# Miscellaneous PV's, such as burtResult
dbLoadRecords("$(STD)/db/misc.db","P=13GE3:")

# vxWorks statistics
#dbLoadRecords("$(STD)/db/VXstats.db","P=13GE3:")


################################################################################
# Setup device/driver support addresses, interrupt vectors, etc.

# dbrestore setup
sr_restore_incomplete_sets_ok = 1
#reboot_restoreDebug=5

set_pass0_restoreFile "auto_settings.sav"
set_pass1_restoreFile "auto_settings.sav"

iocInit

#Reset the CAMAC crate - may not want to do this after things are all working
#ext = 0
#cdreg &ext, 0, 0, 1, 0
#cccz ext


### Start up the autosave task and tell it what to do.
# The task is actually named "save_restore".
# (See also, 'initHooks' above, which is the means by which the values that
# will be saved by the task we're starting here are going to be restored.

< ../requestFileCommands
#
# save other things every thirty seconds
create_monitor_set("auto_settings.req",30,"P=13GE3:")

# Enable user string calcs and user transforms
dbpf "13GE3:EnableUserTrans.PROC","1"
dbpf "13GE3:EnableUserSCalcs.PROC","1"

# Free the memory we allocated at the beginning of this script
free(mem)
