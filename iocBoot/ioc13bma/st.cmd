# vxWorks startup file for 13BMA ioc
< cdCommands
< ../nfsCommandsGSE
loginUserAdd "epics", "9cebSebcd"

cd topbin
load("CARSApp.munch")

# Increase size of errlog buffer
errlogInit(20000)

# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in this build.i
dbLoadDatabase("$(CARS)/dbd/CARSVX.dbd")
CARSVX_registerRecordDeviceDriver(pdbbase)

# This IOC loads the MPF server code locally
cd startup
< industryPack.cmd
< serial.cmd

devPM304Debug = 0
drvPM304Debug = 0

# Set up the Allen-Bradley 6008 scanner
abConfigNlinks 1
abConfigVme 0,0xc00000,0x60,5
abConfigAuto

# Load database
dbLoadRecords("$(CARS)/CARSApp/Db/eps_valid.db", "P=13BMA:")
dbLoadTemplate("eps_inputs.template")
dbLoadTemplate("eps_outputs.template")
dbLoadTemplate("eps_valves.template")

dbLoadTemplate("motors.template")

# BMD and BMC filter racks
dbLoadRecords("$(CARS)/CARSApp/Db/13BMC_Filters.db","P=13BMA:,R=BMC_Filters,MOTOR=m6")
dbLoadRecords("$(CARS)/CARSApp/Db/13BMD_Filters.db","P=13BMA:,R=BMD_Filters,MOTOR=m5")

# Monochromator PID
dbLoadTemplate "mono_pid.template"

# Auto-shutters
dbLoadTemplate("auto_shutter.substitutions")

### Allstop, alldone
dbLoadRecords("$(MOTOR)/motorApp/Db/motorUtil.db","P=13BMA:")

### Scan-support software
# crate-resident scan.  This executes 1D, 2D, 3D, and 4D scans, and caches
# 1D data, but it doesn't store anything to disk.  (You need the data catcher
# or the equivalent for that.)  This database is configured to use the
# "alldone" database (above) to figure out when motors have stopped moving
# and it's time to trigger detectors.
dbLoadRecords("$(SSCAN)/sscanApp/Db/scan.db","P=13BMA:,MAXPTS1=2000,MAXPTS2=200,MAXPTS3=20,MAXPTS4=10,MAXPTSH=10")

# A set of scan parameters for each positioner.  This is a convenience
# for the user.  It can contain an entry for each scannable thing in the
# crate.
dbLoadTemplate("scanParms.template")

# Free-standing user string/number calculations (sCalcout records)
dbLoadRecords("$(CALC)/calcApp/Db/userStringCalcs10.db", "P=13BMA:")

# Free-standing user array calculations (aCalcout records)
dbLoadRecords("$(CALC)/calcApp/Db/userArrayCalcs10.db", "P=13BMA:,N=10")

# Free-standing user transforms (transform records)
dbLoadRecords("$(CALC)/calcApp/Db/userTransforms10.db", "P=13BMA:")

# Miscellaneous PV's
dbLoadRecords("$(STD)/stdApp/Db/misc.db","P=13BMA:")

# devIocStats
putenv("ENGINEER=Mark Rivers")
putenv("LOCATION=13-BM-A roof")
putenv("GROUP=GSECARS")
dbLoadRecords("$(DEVIOCSTATS)/db/iocAdminVxWorks.db","IOC=13BMA:")

< ../save_restore.cmd
save_restoreSet_status_prefix("13BMA:")
dbLoadRecords("$(AUTOSAVE)/asApp/Db/save_restoreStatus.db", "P=13BMA:")

################################################################################
# Setup device/driver support addresses, interrupt vectors, etc.

# OMS VME58 driver setup parameters:
#     (1)cards, (2)base address(short, 4k boundary),
#     (3)interrupt vector (0=disable or  64 - 255), (4)interrupt level (1 - 6),
#     (5)motor task polling rate (min=1Hz,max=60Hz)
oms58Setup(3, 0x4000, 190, 5, 10)

# dbrestore setup
sr_restore_incomplete_sets_ok = 1
#reboot_restoreDebug=5

iocInit

### Start up the autosave task and tell it what to do.
# The task is actually named "save_restore".
# (See also, 'initHooks' above, which is the means by which the values that
# will be saved by the task we're starting here are going to be restored.
#
# save positions every five seconds
create_monitor_set("auto_positions.req",5,"P=13BMA:")
# save other things every thirty seconds
create_monitor_set("auto_settings.req",30,"P=13BMA:")

seq &Keithley2kDMM, "P=13BMA:, Dmm=DMM1, stack=10000"
seq &Keithley2kDMM, "P=13BMA:, Dmm=DMM2, stack=10000"

# Enable user string calcs and user transforms
dbpf "13BMA:EnableUserTrans.PROC","1"
dbpf "13BMA:EnableUserSCalcs.PROC","1"
dbpf "13BMA:EnableuserACalcs.PROC","1"


seq &BM13_Energy, "E=13BMA:E, MONO=13BMA:m17, EXPTAB_Z=13BMD:m22, YXTAL=13BMA:MON:, ZXTAL=13BMA:m14" 

# Mn 20/Mar/02  see note in ioc13ida st.cmd
#  this reduces the readback following error for the McLennan mono controller.
(double) drvPM304ReadbackDelay = 0.25


motorUtilInit("13BMA:")

