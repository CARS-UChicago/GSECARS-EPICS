# vxWorks startup file
< cdCommands

< ../nfsCommandsGSE

cd appbin
ld < iocCore
ld < seq
ld < CARSLib
# This IOC talks to a local GPIB server
#ld < gpibHideosLocal.o
# Currently, the only thing we do in initHooks is call reboot_restore(), which
# restores positions and settings saved ~continuously while EPICS is alive.
# See calls to "create_monitor_set()" at the end of this file.  To disable
# autorestore, comment out the following line.
ld < initHooks.o
cd startup

# Initialize MPF stuff
routerInit

# Initialize local MPF connection
localMessageRouterStart(0)

# This IOC loads the MPF server code locally - disabled for now
# < st_mpfserver.cmd



# override address, interrupt vector, etc. information in module_types.h
module_types()

# Set debugging flags
mcaRecordDebug = 0
devScalerCamacDebug=0
devE500Debug=0
drvE500Debug=0
aimDebug=0
icbDebug=10
dxpRecordDebug=0
mcaDXPServerDebug=0
devDxpMpfDebug=0

# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in this build from CARSApp
dbLoadDatabase("../../dbd/CARSApp.dbd")

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


# Generic CAMAC record
dbLoadRecords("camacApp/Db/generic_camac.db","P=13GE2:,R=camac1,SIZE=2048", camac)

### Motors
# E500 driver setup parameters: 
#     (1) maximum # of controllers, 
#     (2) maximum # axis per card
#     (3) motor task polling rate (min=1Hz, max=60Hz)
E500Setup(2, 8, 10)

# E500 driver configuration parameters: 
#     (1) controller
#     (2) branch 
#     (3) crate
#     (4) slot
E500Config(0, 0, 0, 22)
E500Config(1, 0, 0, 23)

dbLoadTemplate  "motors.template"

### Scalers: CAMAC scaler
CAMACScalerSetup(1)
CAMACScalerConfig(0, 0, 0, 0, 20, 0, 21)
dbLoadRecords("camacApp/Db/CamacScaler.db","P=13GE2:,S=scaler1,C=0", camac)

# Test record for scaler synchronization at X-26
dbLoadRecords("CARSApp/Db/X26_scaler_sync.db","P=13GE2:,M=med:mca1,S=scaler1", top)

### Scan-support software
# crate-resident scan.  This executes 1D, 2D, 3D, and 4D scans, and caches
# 1D data, but it doesn't store anything to disk.  (You need the data catcher
# or the equivalent for that.)  This database is configured to use the
# "alldone" database (above) to figure out when motors have stopped moving
# and it's time to trigger detectors.
dbLoadRecords("stdApp/Db/scan.db","P=13GE2:,MAXPTS1=2000,MAXPTS2=200,MAXPTS3=20,MAXPTS4=10,MAXPTSH=10", std)

# A set of scan parameters for each positioner.  This is a convenience
# for the user.  It can contain an entry for each scannable thing in the
# crate.
dbLoadTemplate "scanParms.template", std

# Free-standing user string/number calculations (sCalcout records)
dbLoadRecords("stdApp/Db/userStringCalcs10.db","P=13GE2:", std)

# Free-standing user transforms (transform records)
dbLoadRecords("stdApp/Db/userTransforms10.db","P=13GE2:", std)

# vme test record
dbLoadRecords("stdApp/Db/vme.db", "P=13GE2:,Q=vme1", std)

# Miscellaneous PV's, such as burtResult
dbLoadRecords("stdApp/Db/misc.db","P=13GE2:", std)

# vxWorks statistics
dbLoadRecords("stdApp/Db/VXstats.db","P=13GE2:", std)


################################################################################
# Setup device/driver support addresses, interrupt vectors, etc.

# dbrestore setup
sr_restore_incomplete_sets_ok = 1
#reboot_restoreDebug=5

iocInit

#Reset the CAMAC crate - may not want to do this after things are all working
ext = 0
cdreg &ext, 0, 0, 1, 0
cccz ext


### Start up the autosave task and tell it what to do.
# The task is actually named "save_restore".
# (See also, 'initHooks' above, which is the means by which the values that
# will be saved by the task we're starting here are going to be restored.
#
# save positions every five seconds
create_monitor_set("auto_positions.req",5.0)
# save other things every thirty seconds
create_monitor_set("auto_settings.req",30.0)

# Enable user string calcs and user transforms
dbpf "13GE2:EnableUserTrans.PROC","1"
dbpf "13GE2:EnableUserSCalcs.PROC","1"
