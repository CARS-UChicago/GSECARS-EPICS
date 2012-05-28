errlogInit(5000)
< envPaths
# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in this build from CARS
dbLoadDatabase("../../dbd/CARSLinux.dbd")
CARSLinux_registerRecordDeviceDriver(pdbbase)

### Motors
dbLoadTemplate  "motors.template"

################################################################################
# XPS Setup

# asyn port, IP address, IP port, number of axes, 
# active poll period (ms), idle poll period (ms), 
# enable set position, set position settling time (ms)
XPSCreateController("XPS1", "164.54.160.180", 5001, 6, 10, 500, 0, 500)
asynSetTraceIOMask("XPS1", 0, 2)
#asynSetTraceMask("XPS1", 0, 255)

# asynPort, IP address, IP port, poll period (ms)
XPSAuxConfig("XPS_AUX1", "164.54.160.180", 5001, 50)
#asynSetTraceIOMask("XPS_AUX1", 0, 2)
#asynSetTraceMask("XPS_AUX1", 0, 255)

# XPS asyn port,  axis, groupName.positionerName, stepSize
# card,  axis, groupName.positionerName, stepsPerUnit
XPSCreateAxis("XPS1", 0, "FINE.X",           "100000") # VP-25XL
XPSCreateAxis("XPS1", 1, "FINE.Y",            "50000") # VP-5ZA
XPSCreateAxis("XPS1", 2, "THETA.POSITIONER",   "2000") # URS75CC
XPSCreateAxis("XPS1", 3, "COARSEX.POSITIONER", "2000") # ILS200CC
XPSCreateAxis("XPS1", 4, "COARSEZ.POSITIONER", "2000") # ILS200CC
XPSCreateAxis("XPS1", 5, "COARSEY.POSITIONER", "5000") # IMS300CC
# XPSCreateAxis("XPS1", 6, "DETX.POSITIONER",    "1000") # UTS100PP

# XPS asyn port,  max points, FTP username, FTP password
# Note: this must be done after configuring axes
XPSCreateProfile("XPS1", 2000, "Administrator", "Administrator")

# Disable setting position
XPSEnableSetPosition(0)

# A set of scan parameters for each positioner.  This is a convenience
# for the user.  It can contain an entry for each scannable thing in the
# crate.
dbLoadTemplate "scanParms.template"

### Allstop, alldone
### Allstop, alldone
dbLoadRecords("$(MOTOR)/motorApp/Db/motorUtil.db","P=13XRM:")

### Scan-support software
# crate-resident scan.  This executes 1D, 2D, 3D, and 4D scans, and caches
# 1D data, but it doesn't store anything to disk.  (You need the data catcher
# or the equivalent for that.)  This database is configured to use the
# "alldone" database (above) to figure out when motors have stopped moving
# and it's time to trigger detectors.
dbLoadRecords("$(SSCAN)/sscanApp/Db/scan.db", "P=13XRM:,MAXPTS1=2000,MAXPTS2=500,MAXPTS3=50,MAXPTS4=10,MAXPTSH=10")

# Free-standing user string/number calculations (sCalcout records)
dbLoadRecords("$(CALC)/calcApp/Db/userStringCalcs10.db", "P=13XRM:")

# Free-standing user transforms (transform records)
dbLoadRecords("$(CALC)/calcApp/Db/userTransforms10.db", "P=13XRM:")
dbLoadRecords("$(CARS)/CARSApp/Db/auto_shutter.db","P=13IDE:,SHUT=ShutterA:")

# Miscellaneous PV's, such as burtResult
dbLoadRecords("$(STD)/stdApp/Db/misc.db", "P=13XRM:")

< ../save_restore_IOCSH.cmd
save_restoreSet_status_prefix("13XRM:")
dbLoadRecords("$(AUTOSAVE)/asApp/Db/save_restoreStatus.db", "P=13XRM:")

dbLoadRecords("$(ASYN)/db/asynRecord.db", "P=13XRM:,R=asyn1,PORT=XPS1,ADDR=0,IMAX=256,OMAX=256")

# scan communication and meta data
dbLoadRecords("$(CARS)/CARSApp/Db/scanner.db","P=13XRM:,Q=edb")
#
# XRF Spectra Collector 
dbLoadRecords("$(CARS)/CARSApp/Db/XRF_Collect.db","P=13XRM:,Q=XRF")

## For FTomo at BMC:
dbLoadRecords("$(CARS)/CARSApp/Db/FluorTomo.db","P=13XRM:,Q=FT")

# fast mapping
dbLoadRecords("$(CARS)/CARSApp/Db/XRM_fastmap.db","P=13XRM:,Q=map")

# Epics PyInstrument
dbLoadRecords("$(CARS)/CARSApp/Db/PyInstrument.db","P=13XRM:,Q=Inst")

# ion chamber calculations
dbLoadRecords("$(CARS)/CARSApp/Db/IonChamber.db","P=13XRM:,Q=ION")

dbLoadRecords("pydebug.db", "P=Py:")

dbLoadRecords("py_exapp.db", "P=Py:,Q=EXT")

#dbLoadRecords("$(CARS)/CARSApp/Db/zeromotors.db","P=13XRM:,DEV=Stage,M1=13XRM:m1.VAL,M2=13XRM:m2.VAL,M3=13XRM:m4.VAL,M4=13XRM:m6.VAL")

asynSetTraceIOMask("XPS1",0,2)
#asynSetTraceMask("XPS1",0,0x3)
asynSetTraceIOTruncateSize("XPS1",0,200)

iocInit

motorUtilInit("13XRM:")

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
dbpf("13XRM:m7.NTM","0")
dbpf("13XRM:pm1C1","0.70710678")
dbpf("13XRM:pm1C2","0.70710678")
dbpf("13XRM:pm2C1","0.70710678")
dbpf("13XRM:pm2C2","0.70710678")

#dbpf("13XRM:m8.NTM","0")

