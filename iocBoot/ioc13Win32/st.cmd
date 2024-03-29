errlogInit(5000)
< envPaths
# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in this build from CARS
dbLoadDatabase("../../dbd/CARSWin32.dbd")
CARSWin32_registerRecordDeviceDriver(pdbbase)

# Set up 2 local serial ports
#drvAsynSerialPortConfigure("serial1", "/dev/ttyS0", 0, 0, 0)
#asynSetOption(serial1,0,baud,19200)
#drvAsynSerialPortConfigure("serial2", "/dev/ttyS1", 0, 0, 0)
#asynSetOption(serial2,0,baud,38400)
# Set up 4 ports on Moxa box
drvAsynIPPortConfigure("serial1", "164.54.160.50:4001", 0, 0)
drvAsynIPPortConfigure("serial2", "164.54.160.50:4002", 0, 0)
drvAsynIPPortConfigure("serial3", "164.54.160.50:4003", 0, 0)
drvAsynIPPortConfigure("serial4", "164.54.160.50:4004", 0, 0)
# Make these ports available from the iocsh command line
asynOctetConnect("serial1", "serial1", 0, 1, 80)
asynOctetConnect("serial2", "serial2", 0, 1, 80)
asynOctetConnect("serial3", "serial3", 0, 1, 80)
asynOctetConnect("serial4", "serial4", 0, 1, 80)

# Load asyn records on each of these ports
dbLoadTemplate("asynRecord.template")

# Load asyn record with no port or addr
dbLoadRecords("asynTest.db","P=13Win32:, R=asynTest")

# Serial 1 Keithley Multimeter
#dbLoadRecords("$(IP)/db/Keithley2kDMM_mf.db", "P=13Win32:,Dmm=DMM1,C=0,PORT=serial1")

# Serial 1 is MCB4B motor controller

# Serial 2 has Newport LAE500 Laser Autocollimator
dbLoadRecords("$(IP)/db/Newport_LAE500.db", "P=13Win32:,R=LAE500,PORT=serial2")

#PID slow
dbLoadTemplate "pid_slow.template"

### Motors
dbLoadTemplate  "motors.template"

# Experiment description
dbLoadRecords("$(CARS)/db/experiment_info.db", "P=13Win32:")

#MN
dbLoadRecords("$(CARS)/db/scanner.db", "P=13Win32:,Q=EDB")

# A set of scan parameters for each positioner.  This is a convenience
# for the user.  It can contain an entry for each scannable thing in the
# crate.
dbLoadTemplate "scanParms.template"

### Allstop, alldone
# This database must agree with the motors you've actually loaded.
# Several versions (e.g., all_com_32.db) are in stdApp/Db
dbLoadRecords("$(STD)/db/all_com_8.db", "P=13Win32:")

### Scan-support software
# crate-resident scan.  This executes 1D, 2D, 3D, and 4D scans, and caches
# 1D data, but it doesn't store anything to disk.  (You need the data catcher
# or the equivalent for that.)  This database is configured to use the
# "alldone" database (above) to figure out when motors have stopped moving
# and it's time to trigger detectors.
dbLoadRecords("$(SSCAN)/db/scan.db", "P=13Win32:,MAXPTS1=2000,MAXPTS2=200,MAXPTS3=20,MAXPTS4=10,MAXPTSH=10")

# Free-standing user string/number calculations (sCalcout records)
dbLoadRecords("$(CALC)/db/userStringCalcs10.db", "P=13Win32:")

# Free-standing user transforms (transform records)
dbLoadRecords("$(CALC)/db/userTransforms10.db", "P=13Win32:")

# Miscellaneous PV's, such as burtResult
dbLoadRecords("$(STD)/db/misc.db", "P=13Win32:")

# MM4000 driver setup parameters: 
#     (1) maximum # of controllers, 
#     (2) maximum # axis per controller
#     (3) motor task polling rate (min=1Hz, max=60Hz)
MM4000Setup(1, 8, 10)

# MM4000 driver configuration parameters: 
#     (1) controller
#     (2) Port name
#     (3) Address (GPIB)
# GPIB example:
#   MM4000Config(0,0,10,2)  #Link 10, address 2
# RS-232 example:
#   MM4000Config(0, 1, 0, "a-Serial[0]")  Hideos card 1, port 0 on IP slot A.
MM4000Config(0, "serial2", 0)

# MCB-4B driver setup parameters:
#     (1) maximum # of controllers,
#     (2) maximum # axis per controller
#     (3) motor task polling rate (min=1Hz, max=60Hz)
MCB4BSetup(1, 4, 10)

# MCB-4B driver configuration parameters:
#     (1) controller
#     (2) asyn port name (e.g. serial1)
MCB4BConfig(0, "serial1")

< ../save_restore_IOCSH.cmd
save_restoreSet_status_prefix("13Win32:")
dbLoadRecords("$(AUTOSAVE)/db/save_restoreStatus.db", "P=13Win32:")

iocInit

# save positions every five seconds
create_monitor_set("auto_positions.req", 5, "P=13Win32:")
# save other things every thirty seconds
create_monitor_set("auto_settings.req", 30, "P=13Win32:")

seq &roperCCD, "P=13Win32:,C=ccd1"
#seq &Keithley2kDMM, "P=13Win32:, Dmm=DMM1, stack=10000"

