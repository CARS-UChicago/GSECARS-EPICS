# Linux startup script for 13-ID-A

< envPaths

dbLoadDatabase("$(CARS)/dbd/CARSLinux.dbd")
CARSLinux_registerRecordDeviceDriver(pdbbase)

epicsEnvSet("PREFIX", "13IDA:")
epicsEnvSet("LINUX_PREFIX", "13IDA_Linux:")
epicsEnvSet("STREAM_PROTOCOL_PATH", "$(CARS)/db:$(IP)/db")

iocshLoad("serial.cmd",     "P=$(PREFIX), TS=gsets17")
iocshLoad("eps_modbus.cmd", "P=$(PREFIX), PORT=MVI146_1, IPADDR=gse-mvi46-mnet-2")
iocshLoad("MeasComp.cmd",   "P=$(PREFIX)")
iocshLoad("motors.cmd",     "P=$(PREFIX)")

# For areaDetector and quadEM
epicsEnvSet("EPICS_DB_INCLUDE_PATH", "$(ADCORE)/db:$(QUADEM)/db")

# Quad BPM foils
dbLoadTemplate("13ID_BPM_Foil.substitutions", P=$(PREFIX))

# Large KB Mirror PID
dbLoadTemplate("mirror_pid.substitutions")

# Auto-shutters
dbLoadTemplate("auto_shutter.substitutions")

### Scan-support software
# crate-resident scan.  This executes 1D, 2D, 3D, and 4D scans, and caches
# 1D data, but it doesn't store anything to disk.  (You need the data catcher
# or the equivalent for that.)  This database is configured to use the
# "alldone" database (above) to figure out when motors have stopped moving
# and it's time to trigger detectors.
dbLoadRecords("$(SSCAN)/db/scan.db","P=$(PREFIX),MAXPTS1=500,MAXPTS2=50,MAXPTS3=10,MAXPTS4=10,MAXPTSH=10")

# User calc stuff
iocshLoad("../calc_GSECARS.iocsh","P=$(PREFIX)")

# Miscellaneous PV's
dbLoadRecords("$(STD)/db/misc.db","P=$(PREFIX)")

# devIocStats
epicsEnvSet("ENGINEER", "Mark Rivers")
epicsEnvSet("LOCATION", "13-ID-A roof")
epicsEnvSet("GROUP", "GSECARS")
dbLoadRecords("$(DEVIOCSTATS)/db/iocAdmin.db","IOC=$(LINUX_PREFIX)")

< ../save_restore_IOCSH.cmd
save_restoreSet_status_prefix("$(LINUX_PREFIX)")
dbLoadRecords("$(AUTOSAVE)/db/save_restoreStatus.db", "P=$(LINUX_PREFIX)")

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

### Start the saveData task.
# saveData_MessagePolicy
# 0: wait forever for space in message queue, then send message
# 1: send message only if queue is not full
# 2: send message only if queue is not full and specified time has passed (SetCptWait()
#    sets this time.)
# 3: if specified time has passed, wait for space in queue, then send message
# else: don't send message
#debug_saveData = 2
#saveData_MessagePolicy = 2
#saveData_SetCptWait_ms(100)
#saveData_Init("saveDataExtraPVs.req", "P=$(PREFIX)")
#saveData_PrintScanInfo("$(PREFIX)scan1")

