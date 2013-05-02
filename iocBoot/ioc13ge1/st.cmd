# vxWorks startup file
< cdCommands
< ../nfsCommandsGSE

cd topbin
load("CARSApp.munch")
cd startup

# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in this build from CARSApp
dbLoadDatabase("../../dbd/CARSVX.dbd")
CARSVX_registerRecordDeviceDriver(pdbbase)

routerInit
localMessageRouterStart(0)

# Set debugging flags
mcaRecordDebug = 1
devMcaMpfDebug = 0
mcaAIMServerDebug = 1
drvSTR7201Debug = 0
devSTR7201Debug = 0
save_restoreDebug = 0

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
dbLoadRecords("$(STD)/stdApp/Db/misc.db","P=13GE1:")

# Experiment description
dbLoadRecords("$(CARS)/CARSApp/Db/experiment_info.db","P=13GE1:")

# vxWorks statistics
#dbLoadRecords("$(STD)/stdApp/Db/VXstats.db","P=13GE1:")

################################################################################
# Setup device/driver support addresses, interrupt vectors, etc.


# dbrestore setup
sr_restore_incomplete_sets_ok = 1
#reboot_restoreDebug=5

iocInit
#epicsThreadCreate("iocInit",100, 15000, iocInit, 0)

### Start up the autosave task and tell it what to do.
# The task is actually named "save_restore".
# (See also, 'initHooks' above, which is the means by which the values that
# will be saved by the task we're starting here are going to be restored.
#

< ../requestFileCommands

# save positions every five seconds
create_monitor_set("auto_positions.req",5,"P=13GE1:")
# save other things every thirty seconds
create_monitor_set("auto_settings.req",30,"P=13GE1:")

