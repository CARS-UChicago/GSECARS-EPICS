# Linux startup script for 13-ID-D
< envPaths

dbLoadDatabase("$(CARS)/dbd/CARSLinux.dbd")
CARSLinux_registerRecordDeviceDriver(pdbbase)

epicsEnvSet("PREFIX", "13IDD:")
epicsEnvSet("P", "13IDD:")
epicsEnvSet("LINUX_PREFIX", "13IDD_Linux:")

# Tell StreamDevice where to find protocol files
iocshCmd("epicsEnvSet(STREAM_PROTOCOL_PATH, $(IP)/db:$(DELAYGEN)/db:$(CARS)/db)")

iocshLoad("serial.cmd",          "P=$(PREFIX), TS=gsets19")
iocshLoad("MeasComp.cmd",        "P=$(PREFIX)")
iocshLoad("Koyo.cmd",            "P=$(PREFIX)LaserPLC:")
iocshLoad("motors.cmd",          "P=$(PREFIX)")

### Scan-support software
# crate-resident scan.  This executes 1D, 2D, 3D, and 4D scans, and caches
# 1D data, but it doesn't store anything to disk.  (You need the data catcher
# or the equivalent for that.)  This database is configured to use the
# "alldone" database (above) to figure out when motors have stopped moving
# and it's time to trigger detectors.
dbLoadRecords("$(SSCAN)/db/scan.db","P=$(PREFIX),MAXPTS1=2000,MAXPTS2=2000,MAXPTS3=100,MAXPTS4=100,MAXPTSH=2048")

# User calc stuff
iocshLoad("../calc_GSECARS.iocsh", "P=$(PREFIX)")

< ../save_restore_IOCSH.cmd
save_restoreSet_status_prefix("$(PREFIX)")
dbLoadRecords("$(AUTOSAVE)/db/save_restoreStatus.db", "P=$(LINUX_PREFIX)")

# devIocStats
epicsEnvSet("ENGINEER", "Mark Rivers")
epicsEnvSet("LOCATION","13IDD roof")
epicsEnvSet("GROUP","GSECARS")
dbLoadRecords("$(DEVIOCSTATS)/db/iocAdminSoft.db","IOC=$(LINUX_PREFIX)")

# Experiment info
dbLoadRecords("$(CARS)/db/experiment_info.db","P=13IDD:")

# Laser heating database
dbLoadRecords("$(CARS)/db/laser_heating.db", "P=13IDD:")

# Laser PID control
# This is for the old YLF laser using a photodiode with slow and fast feedback records, now used for DAC heater
dbLoadTemplate("laser_pid.template")

iocInit

### Start up the autosave task and tell it what to do.
# The task is actually named "save_restore".
# (See also, 'initHooks' above, which is the means by which the values that
# will be saved by the task we're starting here are going to be restored.
#
# save positions every five seconds
create_monitor_set("auto_positions.req",5,"P=$(PREFIX)")
# save other things every thirty seconds
create_monitor_set("auto_settings.req", 30, "P=$(PREFIX),P3104=$(USB3104_PREFIX),P1808=$(USB1808_PREFIX),PEDIO24=$(EDIO24_PREFIX),PCTR=$(USBCTR_PREFIX), MP=$(MCS_PREFIX), SP=$(SCALER_PREFIX)"

# There is a bug in dbLoadRecords, it does not correctly remove \ from \"
# dbpf "13IDD:LPC1_power_decode.CALC","AA[-3,-2]==\"mW\"?DBL(AA)/1e3:DBL(AA)"
# The scale factor from LPC power reading to actual laser watts
# dbpf "13IDD:LPC1_power_scale.B","1.0"

# Set DAC pneumatic shutters and photodiode real state to closed
dbpf("13IDD:TableShutter", "Open")
dbpf("13IDD:US_SpectShutter", "Open")
dbpf("13IDD:DS_SpectShutter", "Open")
dbpf("13IDD:LaserShutter", "Open")

# Set DAC laser modulation state to Disabled
dbpf("13IDD:Laser1DisableModulation.PROC", "1")
dbpf("13IDD:Laser2DisableModulation.PROC", "1")

# Set the scale factor for the LVP Press Camera DIFF calculation
# This causes a move pm17 of 1 unit to move each real motor by 1 unit, rather than 0.5 units
dbpf("13IDD:pm17C1.VAL", "0.5")
