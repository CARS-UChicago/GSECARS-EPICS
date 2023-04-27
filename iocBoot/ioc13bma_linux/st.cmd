# Linux startup script for 13-BM-A
< envPaths

dbLoadDatabase("$(CARS)/dbd/CARSLinux.dbd")
CARSLinux_registerRecordDeviceDriver(pdbbase)

epicsEnvSet("PREFIX", "13BMA:")

iocshLoad("serial.cmd",     "P=$(PREFIX), TS=gsets16")
#iocshLoad("eps_modbus.cmd", "P=$(PREFIX), PORT=MVI146_1, IPADDR=gse-mvi46-mnet-1")
#iocshLoad("MeasComp.cmd",   "P=$(PREFIX)")

#dbLoadTemplate("motors.template")

# BMD and BMC filter racks
#dbLoadRecords("$(CARS)/db/13BMC_Filters.db","P=$(PREFIX),R=BMC_Filters,MOTOR=m6")
#dbLoadRecords("$(CARS)/db/13BMD_Filters.db","P=$(PREFIX),R=BMD_Filters,MOTOR=m5")

# Monochromator PID
#dbLoadTemplate "mono_pid.template"

# Auto-shutters
#dbLoadTemplate("auto_shutter.substitutions")

### Allstop, alldone
#dbLoadRecords("$(MOTOR)/db/motorUtil.db","P=$(PREFIX)")

### Scan-support software
# crate-resident scan.  This executes 1D, 2D, 3D, and 4D scans, and caches
# 1D data, but it doesn't store anything to disk.  (You need the data catcher
# or the equivalent for that.)  This database is configured to use the
# "alldone" database (above) to figure out when motors have stopped moving
# and it's time to trigger detectors.
dbLoadRecords("$(SSCAN)/db/scan.db","P=$(PREFIX),MAXPTS1=2000,MAXPTS2=200,MAXPTS3=20,MAXPTS4=10,MAXPTSH=10")

# A set of scan parameters for each positioner.  This is a convenience
# for the user.  It can contain an entry for each scannable thing in the
# crate.
#dbLoadTemplate("scanParms.template")

# User calc stuff
#<../calc_GSECARS.iocsh

# Miscellaneous PV's
#dbLoadRecords("$(STD)/db/misc.db","P=$(PREFIX)")

# devIocStats
#epicsEnvSet("ENGINEER", "Mark Rivers")
#epicsEnvSet("LOCATION", "13-BM-A roof")
#epicsEnvSet("GROUP", "GSECARS")
#dbLoadRecords("$(DEVIOCSTATS)/db/iocAdmin.db","IOC=$(PREFIX)")

< ../save_restore_IOCSH.cmd
#save_restoreSet_status_prefix("$(PREFIX)")
#dbLoadRecords("$(AUTOSAVE)/db/save_restoreStatus.db", "P=$(PREFIX)")


iocInit

### Start up the autosave task and tell it what to do.
# The task is actually named "save_restore".
# (See also, 'initHooks' above, which is the means by which the values that
# will be saved by the task we're starting here are going to be restored.
#
# save positions every five seconds
create_monitor_set("auto_positions.req",5,"P=$(PREFIX)")
# save other things every thirty seconds
create_monitor_set("auto_settings.req",30,"P=$(PREFIX)")

#seq &Keithley2kDMM, "P=$(PREFIX), Dmm=DMM1, stack=10000"
#seq &Keithley2kDMM, "P=$(PREFIX), Dmm=DMM2, stack=10000"

# Enable user string calcs and user transforms
#dbpf "$(PREFIX)EnableUserTrans.PROC","1"
#dbpf "$(PREFIX)EnableUserSCalcs.PROC","1"
#dbpf "$(PREFIX)EnableuserACalcs.PROC","1"


#seq &BM13_Energy, "E=$(PREFIX)E, MONO=$(PREFIX)m17, EXPTAB_Z=13BMD:m22, YXTAL=$(PREFIX)MON:, ZXTAL=$(PREFIX)m14" 

# Mn 20/Mar/02  see note in ioc13ida st.cmd
#  this reduces the readback following error for the McLennan mono controller.
var drvPM304ReadbackDelay 0.25

#motorUtilInit("$(PREFIX)")

