errlogInit(5000)
< envPaths

# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in this build from CARS
dbLoadDatabase("../../dbd/CARS.dbd")
CARS_registerRecordDeviceDriver(pdbbase)

# Serial 1 and 2 are the Omega meters.  They are nominally
# 8 data bits and 1 stop bit.  However, they actually always
# set bit 7(MSB)=1, which results in non-printable ASCII.
# Work around this problem by setting the Moxa terminal server
# to 7 data bits and 2 stop bits.

drvAsynIPPortConfigure("serial1", "164.54.160.154:2001", 0, 0, 0)

asynOctetSetInputEos("serial1",0,"\r")
asynOctetSetOutputEos("serial1",0,"\r")

# Load asyn records on each of these ports
dbLoadTemplate("asynRecord.template")

# Omega meters
epicsEnvSet STREAM_PROTOCOL_PATH $(IP)/ipApp/Db
dbLoadTemplate("Omega.substitutions")

# Free-standing user string/number calculations (sCalcout records)
dbLoadRecords("$(CALC)/calcApp/Db/userStringCalcs10.db", "P=Instek:")

# Free-standing user transforms (transform records)
dbLoadRecords("$(CALC)/calcApp/Db/userTransforms10.db", "P=Instek:")

# sseq records
dbLoadRecords("$(STD)/stdApp/Db/userStringSeqs10.db", "P=Instek:")

# Miscellaneous PV's, such as burtResult
dbLoadRecords("$(STD)/stdApp/Db/misc.db", "P=Instek:")


< ../save_restore_IOCSH.cmd
save_restoreSet_status_prefix("Instek:")
dbLoadRecords("$(AUTOSAVE)/asApp/Db/save_restoreStatus.db", "P=Instek:")

iocInit

### Start up the autosave task and tell it what to do.
# The task is actually named "save_restore".
# (See also, 'initHooks' above, which is the means by which the values that
# will be saved by the task we're starting here are going to be restored.
#

# save other things every thirty seconds
create_monitor_set("auto_settings.req", 30, "P=Instek:")
