# vxWorks startup file for 13BMA ioc
< cdCommands
< ../nfsCommandsGSE
loginUserAdd "epics", "9cebSebcd"

cd topbin
ld < CARSApp.munch

# Increase size of errlog buffer
errlogInit(20000)

# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in this build.i
dbLoadDatabase("$(CARS)/dbd/CARSVX.dbd")
CARSVX_registerRecordDeviceDriver(pdbbase)

# This IOC loads the MPF server code locally
cd startup
< st_mpfserver.cmd

devPM304Debug = 0
drvPM304Debug = 0
serialIODebug = 0
devSerialDebug = 0
serialRecordDebug = 0
devSiStrParmDebug=0
devAiMKSDebug = 0
devMPCDebug = 0

# Set up the Allen-Bradley 6008 scanner
abConfigNlinks 1
abConfigVme 0,0xc00000,0x60,5
abConfigAuto

# Load database
dbLoadRecords("$(CARS)/CARSApp/Db/eps_valid.db", "P=13BMA:")
dbLoadTemplate("eps_inputs.template")
dbLoadTemplate("eps_outputs.template")
dbLoadTemplate("eps_valves.template")
dbLoadRecords("$(CARS)/CARSApp/Db/generic_serial.db","P=13BMA:,R=ser1,C=0,SERVER=serial1")
dbLoadRecords("$(IP)/ipApp/Db/Digitel.db","P=13BMA:,PUMP=ip1,C=0,SERVER=serial1")
dbLoadRecords("$(IP)/ipApp/Db/MKS.db","P=13BMA:,C=0,SERVER=serial2,CC1=cc1,CC2=cc3,PR1=pr1,PR2=pr3")
dbLoadRecords("$(IP)/ipApp/Db/Digitel.db","P=13BMA:,PUMP=ip7,C=0,SERVER=serial3")
dbLoadRecords("$(IP)/ipApp/Db/MKS.db","P=13BMA:,C=0,SERVER=serial4,CC1=cc7,CC2=ccy,PR1=pr7,PR2=pry")
dbLoadRecords("$(IP)/ipApp/Db/MKS.db","P=13BMA:,C=0,SERVER=serial5,CC1=cc9,CC2=cc10,PR1=pr9,PR2=pr10")
dbLoadRecords("$(IP)/ipApp/Db/Digitel.db","P=13BMA:,PUMP=ip10,C=0,SERVER=serial6")
dbLoadRecords("$(IP)/ipApp/Db/MKS.db","P=13BMA:,C=0,SERVER=serial7,CC1=cc2,CC2=ccyyy,PR1=pr2,PR2=pryyy")
dbLoadRecords("$(IP)/ipApp/Db/Digitel.db","P=13BMA:,PUMP=ip2,C=0,SERVER=serial8")

# This is the McClennan controller
dbLoadRecords("$(CARS)/CARSApp/Db/generic_serial.db","P=13BMA:,R=ser2,C=0,SERVER=serial9")

dbLoadRecords("$(IP)/ipApp/Db/Keithley2kDMM_mf.db","P=13BMA:,Dmm=DMM1,C=0,SERVER=serial10")
dbLoadRecords("$(IP)/ipApp/Db/MPC.db","P=13BMA:,PUMP=ip8,C=0,SERVER=serial11,PA=0,PN=1")
dbLoadRecords("$(IP)/ipApp/Db/MPC.db","P=13BMA:,PUMP=ip9,C=0,SERVER=serial11,PA=0,PN=2")
dbLoadRecords("$(IP)/ipApp/Db/TSP.db","P=13BMA:,TSP=tsp1,C=0,SERVER=serial11,PA=0")
dbLoadRecords("$(IP)/ipApp/Db/MKS.db","P=13BMA:,C=0,SERVER=serial12,CC1=cc8,CC2=ccyyyy,PR1=pr8,PR2=pryyyy")
dbLoadRecords("$(IP)/ipApp/Db/Keithley2kDMM_mf.db","P=13BMA:,Dmm=DMM2,C=0,SERVER=serial13")

dbLoadTemplate("motors.template")

# BMD and BMC filter racks
dbLoadRecords("$(CARS)/CARSApp/Db/13BMC_Filters.db","P=13BMA:,R=BMC_Filters,MOTOR=m6")
dbLoadRecords("$(CARS)/CARSApp/Db/13BMD_Filters.db","P=13BMA:,R=BMD_Filters,MOTOR=m5")

# Digital to analog converter, used for Queensgate piezo drivers
dbLoadTemplate "DAC.template"

# Monochromator PID
dbLoadTemplate "mono_pid.template"
 
### Allstop, alldone
# This database must agree with the motors you've actually loaded.
# Several versions (e.g., all_com_32.db) are in "$(STD)/stdApp/Db
# NOTE: this must exist for slit databases to work
dbLoadRecords("$(STD)/stdApp/Db/all_com_24.db","P=13BMA:")

### Scan-support software
# crate-resident scan.  This executes 1D, 2D, 3D, and 4D scans, and caches
# 1D data, but it doesn't store anything to disk.  (You need the data catcher
# or the equivalent for that.)  This database is configured to use the
# "alldone" database (above) to figure out when motors have stopped moving
# and it's time to trigger detectors.
dbLoadRecords("$(STD)/stdApp/Db/scan.db","P=13BMA:,MAXPTS1=2000,MAXPTS2=200,MAXPTS3=20,MAXPTS4=10,MAXPTSH=10")

# A set of scan parameters for each positioner.  This is a convenience
# for the user.  It can contain an entry for each scannable thing in the
# crate.
dbLoadTemplate("scanParms.template")

# Free-standing user string/number calculations (sCalcout records)
dbLoadRecords("$(STD)/stdApp/Db/userStringCalcs10.db","P=13BMA:")

# Free-standing user transforms (transform records)
dbLoadRecords("$(STD)/stdApp/Db/userTransforms10.db","P=13BMA:")

# Miscellaneous PV's, such as burtResult
dbLoadRecords("$(STD)/stdApp/Db/misc.db","P=13BMA:")

# vxWorks statistics FIX THIS!!!
#dbLoadRecords("$(STD)/stdApp/Db/VXstats.db","P=13BMA:")

################################################################################
# Setup device/driver support addresses, interrupt vectors, etc.

# OMS VME58 driver setup parameters: 
#     (1)cards, (2)axis per card, (3)base address(short, 4k boundary), 
#     (4)interrupt vector (0=disable or  64 - 255), (5)interrupt level (1 - 6),
#     (6)motor task polling rate (min=1Hz,max=60Hz)
oms58Setup(4, 8, 0x4000, 190, 5, 10)

# PM304 driver setup parameters: 
#     (1) maximum # of controllers, 
#     (2) maximum # axis per controller
#     (3) motor task polling rate (min=1Hz, max=60Hz)
PM304Setup(1, 1, 10)

# PM304 driver configuration parameters: 
#     (1) controller
#     (2) MPF ID
#     (3) MPF server
# Example:
#   PM304Config(0, 1, "serial1")  MPF server "serial1"
PM304Config(0, 0, "serial9")

# dbrestore setup
sr_restore_incomplete_sets_ok = 1
#reboot_restoreDebug=5

iocInit

### Start up the autosave task and tell it what to do.
# The task is actually named "save_restore".
# (See also, 'initHooks' above, which is the means by which the values that
# will be saved by the task we're starting here are going to be restored.
#
< ../requestFileCommands
# save positions every five seconds
create_monitor_set("auto_positions.req",5)
# save other things every thirty seconds
create_monitor_set("auto_settings.req",30)

seq &Keithley2kDMM, "P=13BMA:, Dmm=DMM1, stack=10000"
seq &Keithley2kDMM, "P=13BMA:, Dmm=DMM2, stack=10000"

# Enable user string calcs and user transforms
dbpf "13BMA:EnableUserTrans.PROC","1"
dbpf "13BMA:EnableUserSCalcs.PROC","1"

seq &BM13_Energy, "E=13BMA:E, MONO=13BMA:m17, EXPTAB_Z=13BMD:m22, YXTAL=13BMA:MON:, ZXTAL=13BMA:m14" 

# Mn 20/Mar/02  see note in ioc13ida st.cmd
#  this reduces the readback following error for the McLennan mono controller.
(double) drvPM304ReadbackDelay = 0.25
