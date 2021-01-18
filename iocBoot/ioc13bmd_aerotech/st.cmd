# HEX RC (hexapod) and NDrive (air bearing rotation stage) control
< envPaths
dbLoadDatabase("$(CARS)/dbd/CARSLinux.dbd")
CARSLinux_registerRecordDeviceDriver(pdbbase)

dbLoadTemplate "motors.template"
dbLoadTemplate  "scanParms.template"

# Aerotech A3200
drvAsynIPPortConfigure("HEX_TCP","hexapod-1:8000",0,0,0)
asynSetTraceIOMask("HEX_TCP", 0, ESCAPE)
#asynSetTraceMask("HEX_TCP", 0, ERROR|DRIVER|FLOW)
asynReport 10 HEX_TCP

# asyn record
dbLoadRecords("$(ASYN)/db/asynRecord.db", "P=13BMD:, R=HEX1:Asyn, PORT=HEX_TCP, ADDR=0, OMAX=80, IMAX=80")

A3200AsynSetup(1)   /* number of A3200 controllers in system.  */

# Aerotech A3200 asyn motor driver configure parameters.
#     (1) Controller number being configured 
#     (2) ASYN port name 
#     (3) ASYN address (GPIB only) 
#     (4) Number of axes to control 
#     (5) Time to poll (msec) when an axis is in motion 
#     (6) Time to poll (msec) when an axis is idle. 0 for no polling *
#     (7) The 1st Aerotech task number of the two used by this driver.** **
#     (8) Use linear (1) or single-axis (0) move commands.*
A3200AsynConfig(0,"HEX_TCP", 0, 13, 100, 1000, 3, 1)

# Asyn-based Motor Record support
#   (1) Asyn port
#   (2) Driver name
#   (3) Controller index
#   (4) Max. number of axes
# toggle line below 4 of 4
drvAsynMotorConfigure("HEX1","motorA3200", 0, 13)

< ../save_restore_IOCSH.cmd

save_restoreSet_status_prefix("13BMD_AEROTECH:")
dbLoadRecords("$(AUTOSAVE)/db/save_restoreStatus.db", "P=13BMD_AEROTECH:")

# A set of scan parameters for each positioner.  This is a convenience
# for the user.  It can contain an entry for each scannable thing in the
# crate.
dbLoadTemplate "scanParms.template"

### motorUtil - for allstop, moving, etc.
dbLoadRecords("$(MOTOR)/db/motorUtil.db","P=13BMD_AEROTECH:")

# devIocStats
epicsEnvSet("ENGINEER", "Mark Rivers")
epicsEnvSet("LOCATION","corvette")
epicsEnvSet("GROUP","GSECARS")
dbLoadRecords("$(DEVIOCSTATS)/db/iocAdminSoft.db","IOC=13BMD_AEROTECH:")
iocInit

### Start up the autosave task and tell it what to do.
# The task is actually named "save_restore".
# (See also, 'initHooks' above, which is the means by which the values that
# will be saved by the task we're starting here are going to be restored.
#
# save positions every five seconds
create_monitor_set("auto_positions.req",5,"P=13BMD:")
# save other things every thirty seconds
create_monitor_set("auto_settings.req",30,"P=13BMD:")

# Enable Cartesian motion on the hexapod.
# Send EnableTool via asyn record
dbpf("13BMD:HEX1:Asyn.AOUT", "EnableTool")
