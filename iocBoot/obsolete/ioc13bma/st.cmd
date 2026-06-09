# vxWorks startup file for 13BMA ioc
< cdCommands
< ../nfsCommandsGSE
loginUserAdd "epics", "9cebSebcd"

cd topbin
load("CARSApp.munch")

# Increase size of errlog buffer
errlogInit(20000)

# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in this build.i
dbLoadDatabase("$(CARS)/dbd/CARSVX.dbd")
CARSVX_registerRecordDeviceDriver(pdbbase)

cd startup

devPM304Debug = 0
drvPM304Debug = 0

dbLoadTemplate("motors.template")

### Allstop, alldone
dbLoadRecords("$(MOTOR)/db/motorUtil.db","P=13BMA:")

# A set of scan parameters for each positioner.  This is a convenience
# for the user.  It can contain an entry for each scannable thing in the crate.
dbLoadTemplate("scanParms.template")

# devIocStats
putenv("ENGINEER=Mark Rivers")
putenv("LOCATION=13-BM-A roof")
putenv("GROUP=GSECARS")
dbLoadRecords("$(DEVIOCSTATS)/db/iocAdminVxWorks.db","IOC=13BMA:")

< ../save_restore.cmd
save_restoreSet_status_prefix("13BMA:")
dbLoadRecords("$(AUTOSAVE)/db/save_restoreStatus.db", "P=13BMA:")

################################################################################
# Setup device/driver support addresses, interrupt vectors, etc.

# OMS VME58 driver setup parameters:
#     (1)cards, (2)base address(short, 4k boundary),
#     (3)interrupt vector (0=disable or  64 - 255), (4)interrupt level (1 - 6),
#     (5)motor task polling rate (min=1Hz,max=60Hz)
oms58Setup(3, 0x4000, 190, 5, 10)

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
create_monitor_set("auto_positions.req",5,"P=13BMA:")
# save other things every thirty seconds
create_monitor_set("auto_settings.req",30,"P=13BMA:")

# Mn 20/Mar/02  see note in ioc13ida st.cmd
#  this reduces the readback following error for the McLennan mono controller.
(double) drvPM304ReadbackDelay = 0.25

motorUtilInit("13BMA:")

