errlogInit(5000)
< envPaths
# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in this build from CARS
dbLoadDatabase("../../dbd/CARSLinux.dbd")
CARSLinux_registerRecordDeviceDriver(pdbbase)

### Motors
dbLoadTemplate  "motors.template"

# cards (total controllers)
XPSSetup(2)

# card, IP, PORT, number of axes, active poll period (ms), idle poll period (ms)
XPSConfig(0, "164.54.160.180", 5001,68, 5, 100)
# XPSConfig(1, "164.54.160.14", 5001, 8, 10, 500)

# asyn port, driver name, controller index, max. axes)
drvAsynMotorConfigure("XPS1", "motorXPS", 0, 6)
# drvAsynMotorConfigure("XPS2", "motorXPS", 1, 3)

# card,  axis, groupName.positionerName, stepsPerUnit
XPSConfigAxis(0,0,"GROUP1.POSITIONER",  100000) # VP-25XL
XPSConfigAxis(0,1,"GROUP2.POSITIONER",    2000) # URS75CC
XPSConfigAxis(0,2,"GROUP3.POSITIONER",   50000) # VP-5ZA
XPSConfigAxis(0,3,"GROUP6.POSITIONER",    2000) # ILS200CC
XPSConfigAxis(0,4,"GROUP7.POSITIONER",    2000) # ILS200CC
XPSConfigAxis(0,5,"GROUP8.POSITIONER",    5000) # IMS300CC

# XPSConfigAxis(1,0,"GROUP1.POSITIONER",  1000) # UTS100PP
# XPSConfigAxis(1,1,"GROUP2.POSITIONER",  1000) # UTS100PP
# XPSConfigAxis(1,2,"GROUP3.POSITIONER",  1000) # UTS100PP

/* Disable setting position */
XPSEnableSetPosition(0)

# A set of scan parameters for each positioner.  This is a convenience
# for the user.  It can contain an entry for each scannable thing in the
# crate.
dbLoadTemplate "scanParms.template"

# Database for trajectory scanning with the XPS

dbLoadRecords("$(MOTOR)/motorApp/Db/trajectoryScan.db", "P=13XRM:,R=traj1,NAXES=1,NELM=2000,NPULSE=2000,PORT=5001,DONPV=13BMC:str:EraseStart,DONV=1,DOFFPV=13BMC:str:StopAll,DOFFV=1")

### Allstop, alldone
# This database must agree with the motors you've actually loaded.
# Several versions (e.g., all_com_32.db) are in stdApp/Db
dbLoadRecords("$(STD)/stdApp/Db/all_com_8.db", "P=13XRM:")

### Scan-support software
# crate-resident scan.  This executes 1D, 2D, 3D, and 4D scans, and caches
# 1D data, but it doesn't store anything to disk.  (You need the data catcher
# or the equivalent for that.)  This database is configured to use the
# "alldone" database (above) to figure out when motors have stopped moving
# and it's time to trigger detectors.
dbLoadRecords("$(SSCAN)/sscanApp/Db/scan.db", "P=13XRM:,MAXPTS1=2000,MAXPTS2=200,MAXPTS3=20,MAXPTS4=10,MAXPTSH=10")

# Free-standing user string/number calculations (sCalcout records)
dbLoadRecords("$(CALC)/calcApp/Db/userStringCalcs10.db", "P=13XRM:")

# Free-standing user transforms (transform records)
dbLoadRecords("$(CALC)/calcApp/Db/userTransforms10.db", "P=13XRM:")

# Miscellaneous PV's, such as burtResult
dbLoadRecords("$(STD)/stdApp/Db/misc.db", "P=13XRM:")

< ../save_restore_IOCSH.cmd
save_restoreSet_status_prefix("13XRM:")
dbLoadRecords("$(AUTOSAVE)/asApp/Db/save_restoreStatus.db", "P=13XRM:")

dbLoadRecords("$(ASYN)/db/asynRecord.db", "P=13XRM:,R=asyn1,PORT=XPS1,ADDR=0,IMAX=256,OMAX=256")

asynSetTraceIOMask("XPS1",0,2)
#asynSetTraceMask("XPS1",0,0x3)
asynSetTraceIOTruncateSize("XPS1",0,200)

# scan communication and meta data
dbLoadRecords("$(CARS)/CARSApp/Db/scanner.db","P=13XRM:,Q=edb")
#
# XRF Spectra Collector 
dbLoadRecords("$(CARS)/CARSApp/Db/XRF_Collect.db","P=13XRM:,Q=XRF")
## For FTomo at BMC:
##   dbLoadRecords("$(CARS)/CARSApp/Db/FluorTomo.db","P=13XRM:,Q=FT")

# ion chamber calculations
dbLoadRecords("$(CARS)/CARSApp/Db/IonChamber.db","P=13XRM:,Q=ION")
dbLoadRecords("$(CARS)/CARSApp/Db/zeromotors.db", "P=13XRM:,DEV=Stage,M1=13XRM:m1.VAL,M2=13XRM:m2.VAL,M3=13XRM:m4.VAL,M4=13XRM:m6.VAL")

iocInit

# Trajectory scanning with XPS
seq(XPS_trajectoryScan, "P=13XRM:,R=traj1,M1=m6,IPADDR=164.54.160.83,PORT=5001,GROUP=GROUP8,P1=POSITIONER")

# save positions every five seconds
create_monitor_set("auto_positions.req", 5, "P=13XRM:")
# save other things every thirty seconds
create_monitor_set("auto_settings.req", 30, "P=13XRM:")

dbpf("13XRM:m1.NTM","0")
dbpf("13XRM:m2.NTM","0")
dbpf("13XRM:m3.NTM","0")
dbpf("13XRM:m4.NTM","0")
dbpf("13XRM:m5.NTM","0")
dbpf("13XRM:m6.NTM","0")
#dbpf("13XRM:m7.NTM","0")
#dbpf("13XRM:m8.NTM","0")

