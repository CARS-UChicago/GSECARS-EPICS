errlogInit(5000)
< envPaths
# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in this build from CARS
dbLoadDatabase("../../dbd/CARSWin32.dbd")
CARSWin32_registerRecordDeviceDriver(pdbbase)

routerInit
localMessageRouterStart(0)

# Set up 2 local serial ports
drvAsynSerialPortConfigure("serial1", "/dev/ttyS0", 0, 0, 0)
asynSetOption(serial1,0,baud,19200)
drvAsynSerialPortConfigure("serial2", "/dev/ttyS1", 0, 0, 0)
asynSetOption(serial2,0,baud,38400)
# Set up last 2 ports on Moxa box
drvAsynTCPPortConfigure("serial3", "164.54.160.50:4003", 0, 0, 0)
drvAsynTCPPortConfigure("serial4", "164.54.160.50:4004", 0, 0, 0)

# Load asyn records on each of these ports
dbLoadTemplate("asynRecord.template")

# Load asyn record with no port or addr
dbLoadRecords("asynTest.db","P=13Cygwin:, R=asynTest")

# Serial 1 Keithley Multimeter
#dbLoadRecords("$(IP)/ipApp/Db/Keithley2kDMM_mf.db", "P=13Cygwin:,Dmm=DMM1,C=0,PORT=serial1")

# Serial 1 is MCB4B motor controller

# Serial 2 has Newport LAE500 Laser Autocollimator
dbLoadRecords("$(IP)/ipApp/Db/Newport_LAE500.db", "P=13Cygwin:,R=LAE500,PORT=serial2")

#PID slow
dbLoadTemplate "pid_slow.template"

### Motors
dbLoadTemplate  "motors.template"

# Experiment description
dbLoadRecords("$(CARS)/CARSApp/Db/experiment_info.db", "P=13Cygwin:")

#MN
dbLoadRecords("$(CARS)/CARSApp/Db/scanner.db", "P=13Cygwin:,Q=EDB")

# A set of scan parameters for each positioner.  This is a convenience
# for the user.  It can contain an entry for each scannable thing in the
# crate.
dbLoadTemplate "scanParms.template"

# Roper CCD detector database
dbLoadRecords("$(CCD)/ccdApp/Db/ccd.db", "P=13Cygwin:, C=ccd1")

# DXP and mca records for the Vortex detector
#< vortex.cmd

### Allstop, alldone
# This database must agree with the motors you've actually loaded.
# Several versions (e.g., all_com_32.db) are in stdApp/Db
dbLoadRecords("$(STD)/stdApp/Db/all_com_8.db", "P=13Cygwin:")

### Scan-support software
# crate-resident scan.  This executes 1D, 2D, 3D, and 4D scans, and caches
# 1D data, but it doesn't store anything to disk.  (You need the data catcher
# or the equivalent for that.)  This database is configured to use the
# "alldone" database (above) to figure out when motors have stopped moving
# and it's time to trigger detectors.
dbLoadRecords("$(SSCAN)/sscanApp/Db/scan.db", "P=13Cygwin:,MAXPTS1=2000,MAXPTS2=200,MAXPTS3=20,MAXPTS4=10,MAXPTSH=10")

# Free-standing user string/number calculations (sCalcout records)
dbLoadRecords("$(CALC)/calcApp/Db/userStringCalcs10.db", "P=13Cygwin:")

# Free-standing user transforms (transform records)
dbLoadRecords("$(CALC)/calcApp/Db/userTransforms10.db", "P=13Cygwin:")

# Miscellaneous PV's, such as burtResult
dbLoadRecords("$(STD)/stdApp/Db/misc.db", "P=13Cygwin:")

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

iocInit

### Start up the autosave task and tell it what to do.
# The task is actually named "save_restore".
# (See also, 'initHooks' above, which is the means by which the values that
# will be saved by the task we're starting here are going to be restored.
#
# Load the list of search directories for request files
< ../requestFileCommands

# save positions every five seconds
create_monitor_set("auto_positions.req", 5, "P=13Cygwin:")
# save other things every thirty seconds
create_monitor_set("auto_settings.req", 30, "P=13Cygwin:")

seq &roperCCD, "P=13Cygwin:,C=ccd1"
#seq &Keithley2kDMM, "P=13Cygwin:, Dmm=DMM1, stack=10000"

