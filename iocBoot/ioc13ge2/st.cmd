# Allocate 96MB of memory temporarily so that all code loads in 32MB.
mem = malloc(1024*1024*96)

# vxWorks startup file
< cdCommands

< ../nfsCommandsGSE

cd topbin
ld < CARSApp.munch
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
< 16element.cmd
# <  4element.cmd
# < 8element.cmd

# Generic CAMAC record
dbLoadRecords("$(CAMAC)/camacApp/Db/generic_camac.db","P=13GE2:,R=camac1,SIZE=2048")

# ### Motors
# # E500 driver setup parameters: 
# #     (1) maximum # of controllers, 
# #     (2) maximum # axis per card
# #     (3) motor task polling rate (min=1Hz, max=60Hz)
# E500Setup(2, 8, 10)
# 
# # E500 driver configuration parameters: 
# #     (1) controller
# #     (2) branch 
# #     (3) crate
# #     (4) slot
# E500Config(0, 0, 0, 13)
# E500Config(1, 0, 0, 14)
# 
# dbLoadTemplate  "motors.template"
#
# Multichannel analyzer stuff
# AIMConfig(mpfServer, card, ethernet_address, port, maxChans,
#           maxSignals, maxSequences, ethernetDevice, queueSize)
#AIMConfig("AIM1/1", 0x59e, 1, 4000, 1, 1, "ei0", 100)
#dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=13GE2:,M=aim_adc1,DTYPE=MPF MCA,INP=#C0 S0 @AIM1/1,NCHAN=2048")
#

### Scalers: CAMAC scaler
# CAMACScalerSetup(int max_cards)   /* maximum number of logical cards */
# CAMACScalerSetup(1)

# CAMACScalerConfig(int card,       /* logical card */
#  int branch,                         /* CAMAC branch */
#  int crate,                          /* CAMAC crate */
#  int timer_type,                     /* 0=RTC-018 */
#  int timer_slot,                     /* Timer N */
#  int counter_type,                   /* 0=QS-450 */
#  int counter_slot)                   /* Counter N */
# CAMACScalerConfig(0, 0, 0, 0, 20, 0, 21)
#dbLoadRecords("$(CAMAC)/camacApp/Db/CamacScaler.db","P=13GE2:,S=scaler1,C=0")

# Test record for scaler synchronization at X-26
#dbLoadRecords("$(CARS)/CARSApp/Db/X26_scaler_sync.db","P=13GE2:,M=med:mca1,S=scaler1")

### Scan-support software
# crate-resident scan.  This executes 1D, 2D, 3D, and 4D scans, and caches
# 1D data, but it doesn't store anything to disk.  (You need the data catcher
# or the equivalent for that.)  This database is configured to use the
# "alldone" database (above) to figure out when motors have stopped moving
# and it's time to trigger detectors.
dbLoadRecords("$(STD)/stdApp/Db/scan.db","P=13GE2:,MAXPTS1=2000,MAXPTS2=100,MAXPTS3=10,MAXPTS4=5,MAXPTSH=5")

# A set of scan parameters for each positioner.  This is a convenience
# for the user.  It can contain an entry for each scannable thing in the
# crate.
dbLoadTemplate "scanParms.template"

# Free-standing user string/number calculations (sCalcout records)
dbLoadRecords("$(STD)/stdApp/Db/userStringCalcs10.db","P=13GE2:")

# Free-standing user transforms (transform records)
dbLoadRecords("$(STD)/stdApp/Db/userTransforms10.db","P=13GE2:")

# vme test record
dbLoadRecords("$(STD)/stdApp/Db/vme.db", "P=13GE2:,Q=vme1")

# Miscellaneous PV's, such as burtResult
dbLoadRecords("$(STD)/stdApp/Db/misc.db","P=13GE2:")

# vxWorks statistics
#dbLoadRecords("$(STD)/stdApp/Db/VXstats.db","P=13GE2:")


################################################################################
# Setup device/driver support addresses, interrupt vectors, etc.

# dbrestore setup
sr_restore_incomplete_sets_ok = 1
#reboot_restoreDebug=5

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
# save positions every five seconds
create_monitor_set("auto_positions.req",5)
# save other things every thirty seconds
create_monitor_set("auto_settings.req",30)

# Enable user string calcs and user transforms
dbpf "13GE2:EnableUserTrans.PROC","1"
dbpf "13GE2:EnableUserSCalcs.PROC","1"

# Free the memory we allocated at the beginning of this script
free(mem)
