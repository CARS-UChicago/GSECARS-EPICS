# vxWorks startup file
< cdCommands
< ../nfsCommandsGSE

cd topbin
ld < iocCore
ld < seq
ld < CARSLib

# Initialize local MPF connection
ld < mpfServLib 
ld < GpibHideosLocal.o
# Currently, the only thing we do in initHooks is call reboot_restore(), which
# restores positions and settings saved ~continuously while EPICS is alive.
# See calls to "create_monitor_set()" at the end of this file.  To disable
# autorestore, comment out the following line.
ld < initHooks.o

cd startup
routerInit
localMessageRouterStart(0)

# override address, interrupt vector, etc. information in module_types.h
module_types()

# Set debugging flags
mcaRecordDebug = 0
devMcaMpfDebug = 0
mcaAIMServerDebug = 0
drvSTR7201Debug = 0
devSTR7201Debug = 0
save_restoreDebug = 0

# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in this build from CARSApp
dbLoadDatabase("../../dbd/CARSApp.dbd")

# Load database

# Multichannel analyzer stuff
# Load 16 element detector software
< 16element.cmd

### Scan-support software
# crate-resident scan.  This executes 1D, 2D, 3D, and 4D scans, and caches
# 1D data, but it doesn't store anything to disk.  (You need the data catcher
# or the equivalent for that.)  This database is configured to use the
# "alldone" database (above) to figure out when motors have stopped moving
# and it's time to trigger detectors.

# Miscellaneous PV's, such as burtResult
dbLoadRecords("stdApp/Db/misc.db","P=13GE1:", std)

# Experiment description
dbLoadRecords("CARSApp/Db/experiment_info.db","P=13GE1:", top)

# vxWorks statistics
dbLoadRecords("stdApp/Db/VXstats.db","P=13GE1:", std)

################################################################################
# Setup device/driver support addresses, interrupt vectors, etc.


# dbrestore setup
sr_restore_incomplete_sets_ok = 1
#reboot_restoreDebug=5

iocInit

### Start up the autosave task and tell it what to do.
# The task is actually named "save_restore".
# (See also, 'initHooks' above, which is the means by which the values that
# will be saved by the task we're starting here are going to be restored.
#
# save positions every five seconds
create_monitor_set("auto_positions.req",5.0)
# save other things every thirty seconds
create_monitor_set("auto_settings.req",30.0)

