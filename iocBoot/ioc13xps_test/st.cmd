errlogInit(5000)
< envPaths
# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in this build from CARS
dbLoadDatabase("../../dbd/CARSLinux.dbd")
CARSLinux_registerRecordDeviceDriver(pdbbase)

### Motors
dbLoadTemplate  "motors.template"

drvAsynIPPortConfigure("xps3","164.54.160.34:5001 tcp", 0, 0, 1)

# cards (total controllers), scan rate
XPSC8Setup(1, 60)

# card, IP, PORT, number of axes
XPSC8Config(0,"xps3",0,2)

# card,  axis, groupnumber, groupsize,axis in group, group, positioner
XPSC8NameConfig(0,0,0,1,0,"GROUP1","GROUP1.POSITIONER")
XPSC8NameConfig(0,1,1,1,0,"GROUP2","GROUP2.POSITIONER")

# A set of scan parameters for each positioner.  This is a convenience
# for the user.  It can contain an entry for each scannable thing in the
# crate.
dbLoadTemplate "scanParms.template"

### Allstop, alldone
# This database must agree with the motors you've actually loaded.
# Several versions (e.g., all_com_32.db) are in stdApp/Db
dbLoadRecords("$(STD)/stdApp/Db/all_com_8.db", "P=13xps3:")

### Scan-support software
# crate-resident scan.  This executes 1D, 2D, 3D, and 4D scans, and caches
# 1D data, but it doesn't store anything to disk.  (You need the data catcher
# or the equivalent for that.)  This database is configured to use the
# "alldone" database (above) to figure out when motors have stopped moving
# and it's time to trigger detectors.
dbLoadRecords("$(SSCAN)/sscanApp/Db/scan.db", "P=13xps3:,MAXPTS1=2000,MAXPTS2=200,MAXPTS3=20,MAXPTS4=10,MAXPTSH=10")

# Free-standing user string/number calculations (sCalcout records)
dbLoadRecords("$(CALC)/calcApp/Db/userStringCalcs10.db", "P=13xps3:")

# Free-standing user transforms (transform records)
dbLoadRecords("$(CALC)/calcApp/Db/userTransforms10.db", "P=13xps3:")

# Miscellaneous PV's, such as burtResult
dbLoadRecords("$(STD)/stdApp/Db/misc.db", "P=13xps3:")

< ../save_restore_IOCSH.cmd
save_restoreSet_status_prefix("13xps3:")
dbLoadRecords("$(AUTOSAVE)/asApp/Db/save_restoreStatus.db", "P=13xps3:")

dbLoadRecords("$(ASYN)/db/asynRecord.db", "P=13xps3:,R=asyn1,PORT=xps3,ADDR=0,IMAX=256,OMAX=256")

asynSetTraceIOMask("xps3",0,2)
asynSetTraceMask("xps3",0,0x3)
asynSetTraceIOTruncateSize("xps3",0,200)
iocInit

# save positions every five seconds
create_monitor_set("auto_positions.req", 5)
# save other things every thirty seconds
create_monitor_set("auto_settings.req", 30)

