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
drvSTR7201Debug = 0
devSTR7201Debug = 0
save_restoreDebug = 0
devXSC8Debug = 0
drvXPSC8Debug = 0
# Asyn XPS driver debug variable 0-5
asynXPSC8Debug = 0

# Load database
# dbLoadRecords("$(SCALER)/db/scaler.db", "P=13IDC:,S=scaler1,OUT=#C0 S0 @,FREQ=1e7,DTYP=Joerger VSC8/16")

dbLoadTemplate("motors.template")

# Multichannel analyzer stuff
# AIMConfig(portName, ethernet_address, portNumber(1 or 2), maxChans,
#           maxSignals, maxSequences, ethernetDevice)
# This AIM moved to 13BMC.  No AIM in IDC now.
##AIMConfig("NI6E6/1", 0x6E6, 1, 2048, 1, 1, "dc0")
##AIMConfig("NI6E6/2", 0x6E6, 2, 2048, 4, 1, "dc0")
##dbLoadRecords("$(MCA)/db/mca.db", "P=13IDC:,M=aim_adc1,DTYP=asynMCA,INP=@asyn(NI6E6/1 0),NCHAN=2048")
##dbLoadRecords("$(MCA)/db/mca.db", "P=13IDC:,M=aim_mcs1,DTYP=asynMCA,INP=@asyn(NI6E6/2 0),NCHAN=2048")

#icbConfig(portName, module, ethernetAddress, icbAddress, moduleType)
#   portName to give to this asyn port
#   ethernetAddress - Ethernet address of module, low order 16 bits
#   icbAddress - rotary switch setting inside ICB module
#   moduleType
#      0 = ADC
#      1 = Amplifier
#      2 = HVPS
#      3 = TCA
#      4 = DSP
##icbConfig("icbAdc1", 0x6e6, 5, 0)
##dbLoadRecords("$(MCA)/db/icb_adc.db", "P=13IDC:,ADC=adc1,PORT=icbAdc1")
#icbConfig("icbAmp1", 0x6e6, 3, 1)
#dbLoadRecords"$(MCA)/db/icb_amp.db", "P=13IDC:,AMP=amp1,PORT=icbAmp1")
#icbConfig("icbHvps1", 0x6e6, 2, 2)
#dbLoadRecords("$(MCA)/db/icb_hvps.db", "P=13IDC:,HVPS=hvps1,PORT=icbHvps1,LIMIT=1000")
 
# SIS3820 MCS
##<SIS3820_8.cmd

# SIS3801 MCS
iocsh "SIS3801_8.cmd"

### Allstop, alldone
dbLoadRecords("$(MOTOR)/db/motorUtil.db","P=13IDC:")

### Scan-support software
# crate-resident scan.  This executes 1D, 2D, 3D, and 4D scans, and caches
# 1D data, but it doesn't store anything to disk.  (You need the data catcher
# or the equivalent for that.)  This database is configured to use the
# "alldone" database (above) to figure out when motors have stopped moving
# and it's time to trigger detectors.

dbLoadRecords("$(SSCAN)/db/scan.db","P=13IDC:,MAXPTS1=2000,MAXPTS2=500,MAXPTS3=20,MAXPTS4=5,MAXPTSH=10")

# A set of scan parameters for each positioner.  This is a convenience
# for the user.  It can contain an entry for each scannable thing in the
# crate.
dbLoadTemplate("scanParms.template")

dbLoadRecords("$(MCA)/db/mca.db", "P=13IDC:,M=mip330_1,DTYP=asynMCA,NCHAN=2048,INP=@asyn(Ip330Sweep1 0)")
dbLoadRecords("$(MCA)/db/mca.db", "P=13IDC:,M=mip330_2,DTYP=asynMCA,NCHAN=2048,INP=@asyn(Ip330Sweep1 1)")
dbLoadRecords("$(MCA)/db/mca.db", "P=13IDC:,M=mip330_3,DTYP=asynMCA,NCHAN=2048,INP=@asyn(Ip330Sweep1 2)")
dbLoadRecords("$(MCA)/db/mca.db", "P=13IDC:,M=mip330_4,DTYP=asynMCA,NCHAN=2048,INP=@asyn(Ip330Sweep1 3)")
# added 2-05 for split ion chmaber
dbLoadRecords("$(MCA)/db/mca.db", "P=13IDC:,M=mip330_5,DTYP=asynMCA,NCHAN=2048,INP=@asyn(Ip330Sweep1 4)")
dbLoadRecords("$(MCA)/db/mca.db", "P=13IDC:,M=mip330_6,DTYP=asynMCA,NCHAN=2048,INP=@asyn(Ip330Sweep1 5)")

# Miscellaneous PV's
dbLoadRecords("$(STD)/db/misc.db","P=13IDC:")

# User calc stuff
epicsEnvSet("PREFIX", "13IDC:")
iocsh("../calc_GSECARS.iocsh")

# Experiment description
dbLoadRecords("$(CARS)/db/experiment_info.db","P=13IDC:")

# SCA Window for Bede detector
dbLoadRecords("$(CARS)/db/sca_window.db","P=13IDC:,SCA=BEDE,DAC1=DAC1_1,DAC2=DAC1_2,MIN=0,MAX=3")

# devIocStats
putenv("ENGINEER=Mark Rivers")
putenv("LOCATION=13-ID-C")
putenv("GROUP=GSECARS")
dbLoadRecords("$(DEVIOCSTATS)/db/iocAdminVxWorks.db","IOC=13IDC:")

< ../save_restore.cmd
save_restoreSet_status_prefix("13IDC:")
dbLoadRecords("$(AUTOSAVE)/db/save_restoreStatus.db", "P=13IDC:")

# Setup device/driver support addresses, interrupt vectors, etc.

################################################################################
# OMS VME58 driver setup parameters:
#     (1)cards, (2)base address(short, 4k boundary),
#     (3)interrupt vector (0=disable or  64 - 255), (4)interrupt level (1 - 6),
#     (5)motor task polling rate (min=1Hz,max=60Hz)
oms58Setup(6, 0x4000, 190, 5, 10)
################################################################################

################################################################################
# Joerger VSC setup parameters: 
#     (1)cards, (2)base address(ext, 256-byte boundary), 
#     (3)interrupt vector (0=disable or  64 - 255)
# VSCSetup(1, 0xB0000000, 200)
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
create_monitor_set("auto_positions.req",5,"P=13IDC:")
# save other things every thirty seconds
create_monitor_set("auto_settings.req",30,"P=13IDC:")

# Enable user string calcs and user transforms
dbpf "13IDC:EnableUserTrans.PROC","1"
dbpf "13IDC:EnableUserSCalcs.PROC","1"
dbpf "13IDC:EnableuserACalcs.PROC","1"

### Start the saveData task.
# saveData_MessagePolicy
# 0: wait forever for space in message queue, then send message
# 1: send message only if queue is not full
# 2: send message only if queue is not full and specified time has passed (SetCptWait()
#    sets this time.)
# 3: if specified time has passed, wait for space in queue, then send message
# else: don't send message
#debug_saveData = 2
saveData_MessagePolicy = 2
saveData_SetCptWait_ms(10)
saveData_Init("saveDataExtraPVs.req", "P=13IDC:")
#saveData_PrintScanInfo("13IDC:scan1")

seq &Keithley2kDMM, "P=13IDC:, Dmm=DMM1"

# For SISXX MCS
seq(&SIS38XX_SNL, "P=13IDC:SIS1:, R=mca, NUM_SIGNALS=8, FIELD=READ")

# Filter seq program
seq(&filterDrive, "NAME=filterDrive,P=13IDC:,R=filter:,NUM_FILTERS=8")

# Our beamline is in eV, so change the calc to divide by 1000.
dbpf("13IDC:filter:Energy.CALC", "(A==0)?B/1000.:C")

motorUtilInit("13IDC:")


