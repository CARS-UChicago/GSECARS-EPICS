errlogInit(5000)
< envPaths

# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in this build from CARS
dbLoadDatabase("../../dbd/CARS.dbd")
CARSWin32_registerRecordDeviceDriver(pdbbase)
#CARSLinux_registerRecordDeviceDriver(pdbbase)

# Set up 4 serial ports on Moxa terminal server

# Serial 1 and 2 are the Omega meters.  They are nominally
# 8 data bits and 1 stop bit.  However, they actually always
# set bit 7(MSB)=1, which results in non-printable ASCII.
# Work around this problem by setting the Moxa terminal server
# to 7 data bits and 2 stop bits.
drvAsynIPPortConfigure("serial1", "164.54.160.163:4001", 0, 0, 0)
drvAsynIPPortConfigure("serial2", "164.54.160.163:4002", 0, 0, 0)
# Serial 3 is the ACS MCB-4B motor controller
drvAsynIPPortConfigure("serial3", "164.54.160.163:4003", 0, 0, 0)
# Serial 4 is the SensaVac vaccum gauge controller
drvAsynIPPortConfigure("serial4", "164.54.160.163:4004", 0, 0, 0)
asynOctetSetInputEos("serial1",0,"\r")
asynOctetSetOutputEos("serial1",0,"\r")
asynOctetSetInputEos("serial2",0,"\r")
asynOctetSetOutputEos("serial2",0,"\r")
asynOctetSetInputEos("serial3",0,"\r")
asynOctetSetOutputEos("serial3",0,"\r")
asynOctetSetInputEos("serial4",0,"\r")
asynOctetSetOutputEos("serial4",0,"\r")

# Load asyn records on each of these ports
dbLoadTemplate("asynRecord.template")

# Omega meters
epicsEnvSet STREAM_PROTOCOL_PATH $(IP)/ipApp/Db
dbLoadTemplate("Omega.substitutions")

# Alcatel vacuum gauge
dbLoadRecords("$(IP)/ipApp/Db/Alcatel_ACS1000.db", "P=13GasLoad:, R=ACS1000, PORT=serial4")

### Motors
dbLoadTemplate  "motors.template"

# A set of scan parameters for each positioner.  This is a convenience
# for the user.  It can contain an entry for each scannable thing in the
# crate.
dbLoadTemplate "scanParms.template"

### Allstop, alldone
# This database must agree with the motors you've actually loaded.
# Several versions (e.g., all_com_32.db) are in stdApp/Db
dbLoadRecords("$(STD)/stdApp/Db/all_com_4.db", "P=13GasLoad:")

### Scan-support software
# crate-resident scan.  This executes 1D, 2D, 3D, and 4D scans, and caches
# 1D data, but it doesn't store anything to disk.  (You need the data catcher
# or the equivalent for that.)  This database is configured to use the
# "alldone" database (above) to figure out when motors have stopped moving
# and it's time to trigger detectors.
dbLoadRecords("$(SSCAN)/sscanApp/Db/scan.db", "P=13GasLoad:,MAXPTS1=2000,MAXPTS2=200,MAXPTS3=20,MAXPTS4=10,MAXPTSH=10")

# Free-standing user string/number calculations (sCalcout records)
dbLoadRecords("$(CALC)/calcApp/Db/userStringCalcs10.db", "P=13GasLoad:")

# Free-standing user transforms (transform records)
dbLoadRecords("$(CALC)/calcApp/Db/userTransforms10.db", "P=13GasLoad:")

# sseq records
dbLoadRecords("$(STD)/stdApp/Db/userStringSeqs10.db", "P=13GasLoad:")

# Miscellaneous PV's, such as burtResult
dbLoadRecords("$(STD)/stdApp/Db/misc.db", "P=13GasLoad:")

# MCB-4B driver setup parameters:
#     (1) maximum # of controllers,
#     (2) maximum # axis per controller
#     (3) motor task polling rate (min=1Hz, max=60Hz)
MCB4BSetup(1, 4, 10)

# MCB-4B driver configuration parameters:
#     (1) controller
#     (2) asyn port name (e.g. serial1)
MCB4BConfig(0, "serial3")

# Koyo PLC
< Koyo.cmd

< ../save_restore_IOCSH.cmd
save_restoreSet_status_prefix("13GasLoad:")
dbLoadRecords("$(AUTOSAVE)/asApp/Db/save_restoreStatus.db", "P=13GasLoad:")

iocInit

### Start up the autosave task and tell it what to do.
# The task is actually named "save_restore".
# (See also, 'initHooks' above, which is the means by which the values that
# will be saved by the task we're starting here are going to be restored.
#
# save positions every five seconds
create_monitor_set("auto_positions.req", 5, "P=13GasLoad:")
# save other things every thirty seconds
create_monitor_set("auto_settings.req", 30, "P=13GasLoad:")

