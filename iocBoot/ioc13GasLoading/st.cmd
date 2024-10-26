errlogInit(5000)
< envPaths

# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in this build from CARS
#dbLoadDatabase("../../dbd/CARSWin32.dbd")
#CARSWin32_registerRecordDeviceDriver(pdbbase)
dbLoadDatabase("../../dbd/CARSLinux.dbd")
CARSLinux_registerRecordDeviceDriver(pdbbase)

epicsEnvSet("PREFIX", "13GasLoad:")
epicsEnvSet("TS", "gsets6")

# Set up 5 serial ports on Moxa terminal server

# Serial 1 and 2 are the Omega meters.  They are nominally
# 8 data bits and 1 stop bit.  However, they actually always
# set bit 7(MSB)=1, which results in non-printable ASCII.
# Work around this problem by setting the Moxa terminal server
# to 7 data bits and 2 stop bits.
# Omega meters should be
#   9600 baud, 7 data, 2 stop, parity=None, Flow control=None
drvAsynIPPortConfigure("serial1", "$(TS):4001", 0, 0, 0)
drvAsynIPPortConfigure("serial2", "$(TS):4002", 0, 0, 0)
# Serial 3 is the ACS MCB-4B motor controller
# Settings: 19200, 8, 1, None, None
#drvAsynIPPortConfigure("serial3", "$(TS):4003", 0, 0, 0)
# Serial 4 is the SensaVac vaccum gauge controller
# Settings: 19200, 8, 1, None, None
drvAsynIPPortConfigure("serial4", "$(TS):4004", 0, 0, 0)
# Serial 5 is an Omega meter.  See above. Switched from port 5 to port 6 because port 5 seems bad
drvAsynIPPortConfigure("serial5", "$(TS):4006", 0, 0, 0)
asynOctetSetInputEos("serial1",0,"\r")
asynOctetSetOutputEos("serial1",0,"\r")
asynOctetSetInputEos("serial2",0,"\r")
asynOctetSetOutputEos("serial2",0,"\r")
#asynOctetSetInputEos("serial3",0,"\r")
#asynOctetSetOutputEos("serial3",0,"\r")
asynOctetSetInputEos("serial4",0,"\r")
asynOctetSetOutputEos("serial4",0,"\r")
asynOctetSetInputEos("serial5",0,"\r")
asynOctetSetOutputEos("serial5",0,"\r")

# Load asyn records on each of these ports
dbLoadTemplate("asynRecord.template")

# Omega meters
epicsEnvSet STREAM_PROTOCOL_PATH $(IP)/db
dbLoadTemplate("Omega.substitutions")

# Alcatel vacuum gauge
dbLoadRecords("$(IP)/db/Alcatel_ACS1000.db", "P=$(PREFIX), R=ACS1000, PORT=serial4")

### Motors
iocshLoad("Galil.cmd", "P=$(PREFIX)")

# A set of scan parameters for each positioner.  This is a convenience
# for the user.  It can contain an entry for each scannable thing in the
# crate.
dbLoadTemplate "scanParms.template"

### Allstop, alldone
# This database must agree with the motors you've actually loaded.
# Several versions (e.g., all_com_32.db) are in stdApp/Db
dbLoadRecords("$(STD)/db/all_com_4.db", "P=$(PREFIX)")

### Scan-support software
# crate-resident scan.  This executes 1D, 2D, 3D, and 4D scans, and caches
# 1D data, but it doesn't store anything to disk.  (You need the data catcher
# or the equivalent for that.)  This database is configured to use the
# "alldone" database (above) to figure out when motors have stopped moving
# and it's time to trigger detectors.
dbLoadRecords("$(SSCAN)/db/scan.db", "P=$(PREFIX),MAXPTS1=2000,MAXPTS2=200,MAXPTS3=20,MAXPTS4=10,MAXPTSH=10")

# User calc stuff
iocshLoad("../calc_GSECARS.iocsh", "P=$(PREFIX)")

# Miscellaneous PV's, such as burtResult
dbLoadRecords("$(STD)/db/misc.db", "P=$(PREFIX)")

# MCB-4B driver setup parameters:
#     (1) maximum # of controllers,
#     (2) maximum # axis per controller
#     (3) motor task polling rate (min=1Hz, max=60Hz)
#MCB4BSetup(1, 4, 10)

# MCB-4B driver configuration parameters:
#     (1) controller
#     (2) asyn port name (e.g. serial1)
#MCB4BConfig(0, "serial3")

# Koyo PLC
< Koyo.cmd

< ../save_restore_IOCSH.cmd
save_restoreSet_status_prefix("$(PREFIX)")
dbLoadRecords("$(AUTOSAVE)/db/save_restoreStatus.db", "P=$(PREFIX)")

# devIocStats
epicsEnvSet("ENGINEER", "Mark Rivers")
epicsEnvSet("LOCATION","Gas loading system")
epicsEnvSet("GROUP","GSECARS")
dbLoadRecords("$(DEVIOCSTATS)/db/iocAdminSoft.db","IOC=$(PREFIX)")

iocInit

### Start up the autosave task and tell it what to do.
# The task is actually named "save_restore".
# (See also, 'initHooks' above, which is the means by which the values that
# will be saved by the task we're starting here are going to be restored.
#
# save positions every five seconds
create_monitor_set("auto_positions.req", 5, "P=$(PREFIX)")
# save other things every thirty seconds
create_monitor_set("auto_settings.req", 30, "P=$(PREFIX)")

