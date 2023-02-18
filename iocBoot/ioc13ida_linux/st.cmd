# Linux startup script for 13-ID-A

< envPaths

dbLoadDatabase("$(CARS)/dbd/CARSLinux.dbd")
CARSLinux_registerRecordDeviceDriver(pdbbase)

epicsEnvSet("PREFIX", "13IDA_TEST:")

iocshLoad("serial.cmd",     "P=$(PREFIX), TS=gsets17")
iocshLoad("eps_modbus.cmd", "P=$(PREFIX), PORT=MVI146_1, IPADDR=gse-mvi46-mnet-2")

#LoadTemplate("motors.template")

# For areaDetector and quadEM
epicsEnvSet("EPICS_DB_INCLUDE_PATH", "$(ADCORE)/db:$(QUADEM)/db")

# Quad BPM foils
dbLoadTemplate("13ID_BPM_Foil.substitutions", P=$(PREFIX))

# Large KB Mirror PID
#dbLoadTemplate("mirror_pid.substitutions")

# Auto-shutters
#dbLoadTemplate("auto_shutter.substitutions")

### Allstop, alldone
dbLoadRecords("$(MOTOR)/db/motorUtil.db","P=$(PREFIX)")

### Scan-support software
# crate-resident scan.  This executes 1D, 2D, 3D, and 4D scans, and caches
# 1D data, but it doesn't store anything to disk.  (You need the data catcher
# or the equivalent for that.)  This database is configured to use the
# "alldone" database (above) to figure out when motors have stopped moving
# and it's time to trigger detectors.
dbLoadRecords("$(SSCAN)/db/scan.db","P=$(PREFIX),MAXPTS1=500,MAXPTS2=50,MAXPTS3=10,MAXPTS4=10,MAXPTSH=10")

# A set of scan parameters for each positioner.  This is a convenience
# for the user.  It can contain an entry for each scannable thing in the
# crate.
#dbLoadTemplate("scanParms.template")

# User calc stuff
<../calc_GSECARS.iocsh

# Miscellaneous PV's
dbLoadRecords("$(STD)/db/misc.db","P=$(PREFIX)")

# devIocStats
epicsEnvSet("ENGINEER", "Mark Rivers")
epicsEnvSet("LOCATION", "13-ID-A roof")
epicsEnvSet("GROUP", "GSECARS")
dbLoadRecords("$(DEVIOCSTATS)/db/iocAdmin.db","IOC=$(PREFIX)")

< ../save_restore_IOCSH.cmd
save_restoreSet_status_prefix("$(PREFIX)")
dbLoadRecords("$(AUTOSAVE)/db/save_restoreStatus.db", "P=$(PREFIX)")

iocInit

### Start up the autosave task and tell it what to do.

# save positions every five seconds
create_monitor_set("auto_positions.req",5,"P=$(PREFIX)")
# save other things every thirty seconds
create_monitor_set("auto_settings.req",30,"P=$(PREFIX)")

seq &Keithley2kDMM, "P=$(PREFIX), Dmm=DMM1, channels=22, model=2700, stack=10000"
seq &Keithley2kDMM, "P=$(PREFIX), Dmm=DMM2, stack=10000"

# For the bypass valve swap the severity of the open and closed states
dbpf "$(PREFIX)V8_status.ONSV","MAJOR"
dbpf "$(PREFIX)V8_status.TWSV","NO_ALARM"

# Enable user string calcs and user transforms
dbpf "$(PREFIX)EnableUserTrans.PROC","1"
dbpf "$(PREFIX)EnableUserSCalcs.PROC","1"
dbpf "$(PREFIX)EnableuserACalcs.PROC","1"

#
# MN/MR 27/Nov/01
# set readback delay for McLennan monochromator controller.
# We found empirically the following maximum error (in encoder pulses)
# for the following ReadbackDelay values.   In all cases, the maximum
# errors were rare (say, 2 out of 50)
#   ReadbackDelay     Max Encoder Errors 
#     0.0                  4
#     0.1                  3 
#     0.2                  2
#     0.5                  1
#
# Note: 1 encoder step ~= 0.05eV at 10keV.
# (double) drvPM304ReadbackDelay = 0.25
# Note, the above has been replaced with the .DLY field of the motor record, which
# we now have in save/restore.  Change the .DLY field in medm.

# 2009-May-28: Set the NTM fields of the DC/PID motors to 0 (NO) so they don't 
#              get stopped when the motor changes direction due to PID
dbpf("$(PREFIX)m17.NTM","0")

### Start the saveData task.
# saveData_MessagePolicy
# 0: wait forever for space in message queue, then send message
# 1: send message only if queue is not full
# 2: send message only if queue is not full and specified time has passed (SetCptWait()
#    sets this time.)
# 3: if specified time has passed, wait for space in queue, then send message
# else: don't send message
#debug_saveData = 2
saveData_MessagePolicy = 2
saveData_SetCptWait_ms(100)
saveData_Init("saveDataExtraPVs.req", "P=$(PREFIX)")
#saveData_PrintScanInfo("$(PREFIX)scan1")

motorUtilInit("$(PREFIX)")

