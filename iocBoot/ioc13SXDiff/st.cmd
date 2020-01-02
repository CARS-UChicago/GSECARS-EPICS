errlogInit(5000)
< envPaths
# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in this build from CARS
dbLoadDatabase("../../dbd/CARSLinux.dbd")
CARSLinux_registerRecordDeviceDriver(pdbbase)

### Motors
dbLoadTemplate  "motors.template"

# asyn port, IP address, IP port, number of axes, 
# active poll period (ms), idle poll period (ms), 
# enable set position, set position settling time (ms)
XPSCreateController("XPS1", "newport-xps11", 5001, 6, 10, 500, 1, 500)
asynSetTraceIOMask("XPS1", 0, 2)
#asynSetTraceMask("XPS1", 0, 255)

# asynPort, IP address, IP port, poll period (ms)
XPSAuxConfig("XPS_AUX1", "newport-xps11", 5001, 50)
#asynSetTraceIOMask("XPS_AUX1", 0, 2)
#asynSetTraceMask("XPS_AUX1", 0, 255)

# XPS asyn port,  axis, groupName.positionerName, stepSize
XPSCreateAxis("XPS1",0,"2theta.2theta",        "10000")  
XPSCreateAxis("XPS1",1,"omega.omega",          "10000")  
XPSCreateAxis("XPS1",2,"chi.chi",              "10000")  
XPSCreateAxis("XPS1",3,"horizontal.horizontal","10000")  
XPSCreateAxis("XPS1",4,"distance.distance",    "10000")  
XPSCreateAxis("XPS1",5,"phi.phi",              "750")  

# Auxillary I/O records
dbLoadTemplate("XPSAux.substitutions")

# A set of scan parameters for each positioner.  This is a convenience
# for the user.  It can contain an entry for each scannable thing in the
# crate.
dbLoadTemplate "scanParms.template"

### Allstop, alldone
# This database must agree with the motors you've actually loaded.
# Several versions (e.g., all_com_32.db) are in stdApp/Db
dbLoadRecords("$(STD)/db/all_com_8.db", "P=13SXD:")

### Scan-support software
# crate-resident scan.  This executes 1D, 2D, 3D, and 4D scans, and caches
# 1D data, but it doesn't store anything to disk.  (You need the data catcher
# or the equivalent for that.)  This database is configured to use the
# "alldone" database (above) to figure out when motors have stopped moving
# and it's time to trigger detectors.
dbLoadRecords("$(SSCAN)/sscanApp/Db/scan.db", "P=13SXD:,MAXPTS1=2000,MAXPTS2=200,MAXPTS3=20,MAXPTS4=10,MAXPTSH=10")

# Free-standing user string/number calculations (sCalcout records)
dbLoadRecords("$(CALC)/db/userStringCalcs10.db", "P=13SXD:")

# Free-standing user transforms (transform records)
dbLoadRecords("$(CALC)/db/userTransforms10.db", "P=13SXD:")

# Miscellaneous PV's, such as burtResult
dbLoadRecords("$(STD)/db/misc.db", "P=13SXD:")

< ../save_restore_IOCSH.cmd
save_restoreSet_status_prefix("13SXD:")
dbLoadRecords("$(AUTOSAVE)/asApp/Db/save_restoreStatus.db", "P=13SXD:")

dbLoadRecords("$(ASYN)/db/asynRecord.db", "P=13SXD:,R=asyn1,PORT=xps3,ADDR=0,IMAX=256,OMAX=256")

asynSetTraceIOMask("xps3",0,2)
asynSetTraceMask("xps3",0,0x3)
asynSetTraceIOTruncateSize("xps3",0,200)
iocInit

# save positions every five seconds
create_monitor_set("auto_positions.req", 5, "P=13SXD:")
# save other things every thirty seconds
create_monitor_set("auto_settings.req", 30, "P=13SXD:")

