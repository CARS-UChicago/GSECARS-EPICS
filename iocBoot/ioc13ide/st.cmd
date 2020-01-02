# vxWorks startup file
< cdCommands
< ../nfsCommandsGSE

cd topbin
load("CARSApp.munch")

# Increase size of errlog buffer
errlogInit(20000)

# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in this build.
dbLoadDatabase("$(CARS)/dbd/CARSVX.dbd")
CARSVX_registerRecordDeviceDriver(pdbbase)

cd startup
< industryPack.cmd
< serial.cmd

# Set debugging flags
mcaRecordDebug = 0
save_restoreDebug = 0
# Asyn XPS driver debug variable 0-5
asynXPSC8Debug = 0


dbLoadTemplate("motors.template")

# SIS3820 MCS as 32-channel multi-element detector and scaler
iocsh "SIS3820_32.cmd"

### Scan-support software
# crate-resident scan.  This executes 1D, 2D, 3D, and 4D scans, and caches
# 1D data, but it doesn't store anything to disk.  (You need the data catcher
# or the equivalent for that.)  This database is configured to use the
# "alldone" database (above) to figure out when motors have stopped moving
# and it's time to trigger detectors.

### Allstop, alldone
dbLoadRecords("$(MOTOR)/db/motorUtil.db","P=13IDE:")

dbLoadRecords("$(SSCAN)/sscanApp/Db/scan.db","P=13IDE:,MAXPTS1=2000,MAXPTS2=500,MAXPTS3=20,MAXPTS4=5,MAXPTSH=10")

# A set of scan parameters for each positioner.  This is a convenience
# for the user.  It can contain an entry for each scannable thing in the
# crate.
dbLoadTemplate("scanParms.template")

dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=13IDE:,M=mip330_1,DTYP=asynMCA,NCHAN=2048,INP=@asyn(Ip330Sweep1 0)")
dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=13IDE:,M=mip330_2,DTYP=asynMCA,NCHAN=2048,INP=@asyn(Ip330Sweep1 1)")
dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=13IDE:,M=mip330_3,DTYP=asynMCA,NCHAN=2048,INP=@asyn(Ip330Sweep1 2)")
dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=13IDE:,M=mip330_4,DTYP=asynMCA,NCHAN=2048,INP=@asyn(Ip330Sweep1 3)")
# added 2-05 for split ion chmaber
dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=13IDE:,M=mip330_5,DTYP=asynMCA,NCHAN=2048,INP=@asyn(Ip330Sweep1 4)")
dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=13IDE:,M=mip330_6,DTYP=asynMCA,NCHAN=2048,INP=@asyn(Ip330Sweep1 5)")

# Miscellaneous PV's, such as burtResult
dbLoadRecords("$(STD)/db/misc.db","P=13IDE:")

# Experiment description
dbLoadRecords("$(CARS)/db/experiment_info.db","P=13IDE:")

# User calc stuff
epicsEnvSet("PREFIX", "13IDE:")
iocsh("../calc_GSECARS.iocsh")

# devIocStats
putenv("ENGINEER=Mark Rivers")
putenv("LOCATION=13-ID-C roof")
putenv("GROUP=GSECARS")
dbLoadRecords("$(DEVIOCSTATS)/db/iocAdminVxWorks.db","IOC=13IDE:")

< ../save_restore.cmd
save_restoreSet_status_prefix("13IDE:")
dbLoadRecords("$(AUTOSAVE)/asApp/Db/save_restoreStatus.db", "P=13IDE:")

# Setup device/driver support addresses, interrupt vectors, etc.

################################################################################
# OMS VME58 driver setup parameters:
#     (1)cards, (2)base address(short, 4k boundary),
#     (3)interrupt vector (0=disable or  64 - 255), (4)interrupt level (1 - 6),
#     (5)motor task polling rate (min=1Hz,max=60Hz)
oms58Setup(5, 0x4000, 190, 5, 10)
################################################################################

################################################################################

# dbrestore setup
sr_restore_incomplete_sets_ok = 1
#reboot_restoreDebug=5

iocInit

# Sleep for 10 seconds to let iocInit do its thing and see any messages
# before going on
taskDelay(600)

### Start up the autosave task and tell it what to do.
# The task is actually named "save_restore".
# (See also, 'initHooks' above, which is the means by which the values that
# will be saved by the task we're starting here are going to be restored.
#
# save positions every five seconds
create_monitor_set("auto_positions.req",5,"P=13IDE:")
# save other things every thirty seconds
create_monitor_set("auto_settings.req",30,"P=13IDE:")

### Start the saveData task.
# saveData_MessagePolicy
# 0: wait forever for space in message queue, then send message
# 1: send message only if queue is not full
# 2: send message only if queue is not full and specified time has passed (SetCptWait()
#    sets this time.)
# 3: if specified time has passed, wait for space in queue, then send message
# else: don't send message
#debug_saveData = 2
# saveData_MessagePolicy = 2
# saveData_SetCptWait_ms(10)
# saveData_Init("saveDataExtraPVs.req", "P=13IDE:")
# saveData_PrintScanInfo("13IDE:scan1")

seq &Keithley2kDMM, "P=13IDE:, Dmm=DMM1"

seq(&SIS38XX_SNL, "P=13IDE:SIS1:, R=mca, NUM_SIGNALS=32, FIELD=READ")

# # set scale for sum/diff for TT slits
# dbpf("13IDE:sm1C1","0.50")
# dbpf("13IDE:sm1C2","0.50")
# dbpf("13IDE:sm2C1","1.00")
# dbpf("13IDE:sm2C2","1.00")
# 
# dbpf("13IDE:sm4C1","0.50")
# dbpf("13IDE:sm4C2","0.50")
# dbpf("13IDE:sm3C1","1.00")
# dbpf("13IDE:sm3C2","1.00")

# Enable user string calcs and user transforms
dbpf "13IDE:EnableUserTrans.PROC","1"
dbpf "13IDE:EnableUserSCalcs.PROC","1"
dbpf "13IDE:EnableuserACalcs.PROC","1"

dbpf "13IDE:Unidig1Bo0.ZNAM","Out"
dbpf "13IDE:Unidig1Bo1.ZNAM","Out"
dbpf "13IDE:Unidig1Bo2.ZNAM","Out"
dbpf "13IDE:Unidig1Bo3.ZNAM","Out"
dbpf "13IDE:Unidig1Bo0.ONAM","In"
dbpf "13IDE:Unidig1Bo1.ONAM","In"
dbpf "13IDE:Unidig1Bo2.ONAM","In"
dbpf "13IDE:Unidig1Bo3.ONAM","In"


motorUtilInit("13IDE:")
