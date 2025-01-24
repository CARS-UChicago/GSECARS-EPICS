errlogInit(5000)
< envPaths
# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in this build from CARS
dbLoadDatabase("../../dbd/CARSLinux.dbd")
CARSLinux_registerRecordDeviceDriver(pdbbase)

epicsEnvSet(PREFIX, "13CryoJet1:")

epicsEnvSet(STREAM_PROTOCOL_PATH, "$(IP)/db:$(CARS)/db")

# Set up ports on Moxa box
#drvAsynIPPortConfigure("portName", "hostInfo", priority, noAutoConnect, noProcessEos)

# First port is for CryoJet
# The Moxa must be configure as RS-232, 9600 baud, 8 data bits, 1 stop bit
drvAsynIPPortConfigure("serial1", "gsets22:4001", 0, 0, 0)
asynSetTraceIOMask serial1 0 ESCAPE
#asynSetTraceMask serial1 0 ERROR|DRIVER
asynOctetSetInputEos("serial1", 0, "\r")
asynOctetSetOutputEos("serial1", 0, "\r")

# Second port is for the ILM 201
# The Moxa must be configure as RS-232, 9600 baud, 8 data bits, 1 stop bit
drvAsynIPPortConfigure("serial2", "gsets22:4002", 0, 0, 0)
asynSetTraceIOMask serial2 0 ESCAPE
#asynSetTraceMask serial2 0 ERROR|DRIVER
asynOctetSetInputEos("serial2", 0, "\r")
asynOctetSetOutputEos("serial2", 0, "\r")

dbLoadRecords("$(ASYN)/db/asynRecord.db", "P=$(PREFIX), R=serial1, PORT=serial1, ADDR=0, OMAX=256, IMAX=256")
dbLoadRecords("$(ASYN)/db/asynRecord.db", "P=$(PREFIX), R=serial2, PORT=serial2, ADDR=0, OMAX=256, IMAX=256")

# Oxford CryoJet
dbLoadRecords("$(IP)/db/Oxford_CryoJet.db", "P=$(PREFIX)Cryo1:, PORT=serial1")

# Oxford ILM 201
dbLoadRecords("$(IP)/db/Oxford_ILM200.db", "P=$(PREFIX)Cryo1:, R=ILM, PORT=serial2")

# PVHistory
dbLoadRecords("$(STD)/db/pvHistory.db", "P=$(PREFIX)Cryo1:, N=1, MAXSAMPLES=2000")


### Scan-support software
# crate-resident scan.  This executes 1D, 2D, 3D, and 4D scans, and caches
# 1D data, but it doesn't store anything to disk.  (You need the data catcher
# or the equivalent for that.)  This database is configured to use the
# "alldone" database (above) to figure out when motors have stopped moving
# and it's time to trigger detectors.
dbLoadRecords("$(SSCAN)/db/scan.db", "P=$(PREFIX), MAXPTS1=2000, MAXPTS2=200, MAXPTS3=20, MAXPTS4=10, MAXPTSH=10")

iocshLoad(../calc_GSECARS.iocsh)

#PID slow
#dbLoadTemplate "pid_slow.substitutions"

# Miscellaneous PV's, such as burtResult
dbLoadRecords("$(STD)/db/misc.db", "P=$(PREFIX)")

< ../save_restore_IOCSH.cmd
save_restoreSet_status_prefix("$(PREFIX)")
dbLoadRecords("$(AUTOSAVE)/db/save_restoreStatus.db", "P=$(PREFIX)")

# devIocStats
epicsEnvSet("ENGINEER", "Mark Rivers")
epicsEnvSet("LOCATION","Sector 13 portable")
epicsEnvSet("GROUP","GSECARS")
dbLoadRecords("$(DEVIOCSTATS)/db/iocAdminSoft.db","IOC=$(PREFIX)")

iocInit

# save positions every five seconds
#create_monitor_set("auto_positions.req", 5, "P=$(PREFIX)")
# save other things every thirty seconds
create_monitor_set("auto_settings.req", 30, "P=$(PREFIX)")
