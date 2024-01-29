# vxWorks startup file for 13IDA ioc

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

dbLoadTemplate("motors.template")

# Monochromator positions
#dbLoadTemplate("mono_position.template")

### Allstop, alldone
dbLoadRecords("$(MOTOR)/db/motorUtil.db","P=13IDA:")

# devIocStats
putenv("ENGINEER=Mark Rivers")
putenv("LOCATION=13-ID-A roof")
putenv("GROUP=GSECARS")
dbLoadRecords("$(DEVIOCSTATS)/db/iocAdminVxWorks.db","IOC=13IDA:")

< ../save_restore.cmd
save_restoreSet_status_prefix("13IDA:")
dbLoadRecords("$(AUTOSAVE)/db/save_restoreStatus.db", "P=13IDA:")

################################################################################
# OMS MAXv driver setup parameters:
#     (1)number of cards in array.
#     (2)VME Address Type (16,24,32).
#     (3)Base Address on 4K (0x1000) boundary.
#     (4)interrupt vector (0=disable or  64 - 255).
#     (5)interrupt level (1 - 6).
#     (6)motor task polling rate (min=1Hz,max=60Hz).
MAXvSetup(3, 16, 0x8000, 192, 5, 10)
drvMAXvdebug=0
# OMS MAXv configuration string:
#     (1) number of card being configured (0-14).
#     (2) configuration string; axis type (PSO/PSE/PSM) MUST be set here.
#         For example, set which TTL signal level defines
#         an active limit switch.  Set X,Y,Z,T to active low and set U,V,R,S
#         to active high.  Set all axes to open-loop stepper (PSO). See MAXv
#         User's Manual for LL/LH and PSO/PSE/PSM commands.
# Set all axes to open-loop stepper and active high limits
configStep="AX LMH LTH PSO; AY LMH LTH PSO; AZ LMH LTH PSO; AT LMH LTH PSO; AU LMH LTH PSO; AV LMH LTH PSO; AR LMH LTH PSO; AS LMH LTH PSO;"
MAXvConfig(0, configStep)
MAXvConfig(1, configStep)
MAXvConfig(2, configStep)

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
create_monitor_set("auto_positions.req",5,"P=13IDA:")
# save other things every thirty seconds
create_monitor_set("auto_settings.req",30,"P=13IDA:")

motorUtilInit("13IDA:")
