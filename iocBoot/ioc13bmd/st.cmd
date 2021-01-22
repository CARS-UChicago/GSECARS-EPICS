# vxWorks startup file for 13BMD IOC
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
# Koyo PLC for lasers
< Koyo.cmd

# Joerger VSC setup parameters: 
#     (1)cards, (2)base address(ext, 256-byte boundary), 
#     (3)interrupt vector (0=disable or  64 - 255)
VSCSetup(1, 0xB0000000, 200)
dbLoadRecords("$(STD)/db/scaler.db", "P=13BMD:,S=scaler1,OUT=#C0 S0 @,FREQ=1e7,DTYP=Joerger VSC8/16")

dbLoadRecords("$(CARS)/db/lvp_dmm.db", "P=13BMD:,Dmm=DMM1,DLY=0.1")
dbLoadTemplate "heater_control.template"
dbLoadTemplate "LVP_furnace_control.template"
dbLoadTemplate "laser_pid.template"

# MAR345 shutter
st=malloc(256)
strcpy(st,"P=13BMD:,R=MAR345,IN=13BMD:Unidig1Bi13,")
strcat(st,"OUT=13BMD:filter1sendCommand.VAL")
dbLoadRecords("$(CARS)/db/MAR345_shutter_serial.db",st)

# Multichannel analyzer stuff
# AIMConfig(portName, card, ethernet_address, port, maxChans,
#           maxSignals, maxSequences, ethernetDevice)
AIMConfig("NI9CE/1", 0x9CE, 1, 2048, 1, 1,"dc0")
AIMConfig("NI9CE/2", 0x9CE, 2, 2048, 4, 1,"dc0")
dbLoadRecords("$(MCA)/db/mca.db", "P=13BMD:,M=aim_adc1,DTYP=asynMCA,INP=@asyn(NI9CE/1 0),NCHAN=4096")
dbLoadRecords("$(MCA)/db/mca.db", "P=13BMD:,M=aim_mcs1,DTYP=asynMCA,INP=@asyn(NI9CE/2 0),NCHAN=4096")
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
icbConfig("icbAdc1", 0x9ce, 5, 0)
dbLoadRecords("$(MCA)/db/icb_adc.db", "P=13BMD:,ADC=adc1,PORT=icbAdc1")
icbConfig("icbAmp1", 0x9ce, 3, 1)
dbLoadRecords("$(MCA)/db/icb_amp.db", "P=13BMD:,AMP=amp1,PORT=icbAmp1")
icbConfig("icbHvps1", 0x9ce, 2, 2)
dbLoadRecords("$(MCA)/db/icb_hvps.db", "P=13BMD:,HVPS=hvps1,PORT=icbHvps1,LIMIT=1000")

# CCD synchronization for older version of tomo_collect
dbLoadRecords("$(CARS)/db/CCD.db", "P=13BMD:,C=CCD1")
# Tomography data collection
#dbLoadRecords("$(CARS)/db/TomoCollect.template", "P=13BMDRP1:,R=TC:")

# Struck MCS as 32-channel multi-element detector
iocsh "SIS3820_32.cmd"

################################################################################
# OMS VME58 driver setup parameters:
#     (1)cards, (2)base address(short, 4k boundary),
#     (3)interrupt vector (0=disable or  64 - 255), (4)interrupt level (1 - 6),
#     (5)motor task polling rate (min=1Hz,max=60Hz)
oms58Setup(10, 0x4000, 190, 5, 10)

# OMS MAXv driver setup parameters:
#     (1)number of cards in array.
#     (2)VME Address Type (16,24,32).
#     (3)Base Address on 4K (0x1000) boundary.
#     (4)interrupt vector (0=disable or  64 - 255).
#     (5)interrupt level (1 - 6).
#     (6)motor task polling rate (min=1Hz,max=60Hz).
MAXvSetup(1, 16, 0xE000, 190, 5, 10)

drvMAXvdebug=0
# OMS MAXv configuration string:
#     (1) number of card being configured (0-14).
#     (2) configuration string; axis type (PSO/PSE/PSM) MUST be set here.
#         For example, set which TTL signal level defines
#         an active limit switch.  Set X,Y,Z,T to active low and set U,V,R,S
#         to active high.  Set all axes to open-loop stepper (PSO). See MAXv
#         User's Manual for LL/LH and PSO/PSE/PSM commands.

# Set all axes to open-loop stepper and active high limits
configStep="AX LMH LTH PSO; AY LMH LTH PSO; AZ LMH LTH PSO; AT LMH LTH PSO; AU LMH LTH PSO; AV LMH LTH PSO; AR LMH LTH PSO; AS LMH LTH PSO;"
MAXvConfig(0, configStep)

# MCB-4B driver setup parameters:
#     (1) maximum # of controllers,
#     (2) maximum # axis per controller
#     (3) motor task polling rate (min=1Hz, max=60Hz)
MCB4BSetup(2, 4, 10)

# MCB-4B driver configuration parameters:
#     (1) controller
#     (2) asyn port name (e.g. serial1)
MCB4BConfig(0, "serial17")
MCB4BConfig(1, "serial18")

dbLoadTemplate "motors.template"

### Allstop, alldone
dbLoadRecords("$(MOTOR)/db/motorUtil.db","P=13BMD:")

### Scan-support software
# crate-resident scan.  This executes 1D, 2D, 3D, and 4D scans, and caches
# 1D data, but it doesn't store anything to disk.  (You need the data catcher
# or the equivalent for that.)  This database is configured to use the
# "alldone" database (above) to figure out when motors have stopped moving
# and it's time to trigger detectors.
dbLoadRecords("$(SSCAN)/db/scan.db","P=13BMD:,MAXPTS1=2000,MAXPTS2=200,MAXPTS3=4,MAXPTS4=3,MAXPTSH=10")

dbLoadRecords("$(CARS)/db/scanner.db", "P=13BMD:,Q=edb")

# A set of scan parameters for each positioner.  This is a convenience
# for the user.  It can contain an entry for each scannable thing in the
# crate.
dbLoadTemplate "scanParms.template"

# Miscellaneous PV's
dbLoadRecords("$(STD)/db/misc.db","P=13BMD:")

# User calc stuff
epicsEnvSet("PREFIX", "13BMD:")
iocsh("../calc_GSECARS.iocsh")

# Experiment description
dbLoadRecords("$(CARS)/db/experiment_info.db","P=13BMD:")

# devIocStats
putenv("ENGINEER=Mark Rivers")
putenv("LOCATION=13-BM-D roof")
putenv("GROUP=GSECARS")
dbLoadRecords("$(DEVIOCSTATS)/db/iocAdminVxWorks.db","IOC=13BMD:")

< ../save_restore.cmd
save_restoreSet_status_prefix("13BMD:")
dbLoadRecords("$(AUTOSAVE)/db/save_restoreStatus.db", "P=13BMD:")

# dbrestore setup
sr_restore_incomplete_sets_ok = 1
#reboot_restoreDebug=5

iocsh
epicsEnvSet("STREAM_PROTOCOL_PATH","$(IP)/db:$(CARS)/db")
exit

iocInit

### Start up the autosave task and tell it what to do.
# The task is actually named "save_restore".
# (See also, 'initHooks' above, which is the means by which the values that
# will be saved by the task we're starting here are going to be restored.
#
# save positions every five seconds
create_monitor_set("auto_positions.req",5,"P=13BMD:")
# save other things every thirty seconds
create_monitor_set("auto_settings.req",30,"P=13BMD:")

seq &Keithley2kDMM, "P=13BMD:, Dmm=DMM1, stack=10000"
seq &Keithley2kDMM, "P=13BMD:, Dmm=DMM2, stack=15000"
seq &Keithley2kDMM, "P=13BMD:, Dmm=DMM3, stack=15000"
seq &Keithley2kDMM, "P=13BMD:, Dmm=DMM4, stack=15000"
seq &BMD_LVP_Detector, "P=13BMD:,PMT=pm4,PMR=pm3,X=m9,Y=m16,Z=m10,TV=m12,TH=m13"

seq(&SIS38XX_SNL, "P=13BMD:SIS1:, R=mca, NUM_SIGNALS=32, FIELD=READ")

# Enable user string calcs and user transforms
dbpf "13BMD:EnableUserTrans.PROC","1"
dbpf "13BMD:EnableUserSCalcs.PROC","1"
dbpf "13BMD:EnableuserACalcs.PROC","1"

### Start the saveData task.
# saveData_MessagePolicy
# 0: wait forever for space in message queue, then send message
# 1: send message only if queue is not full
# 2: send message only if queue is not full and specified time has passed (SetCptWait()
#    sets this time.)
# 3: if specified time has passed, wait for space in queue, then send message
# else: don't send message
# debug_saveData = 2
##{
##  MN 05-Apr-2008  turn save data off
## altered saveDataExtraPVs
# saveData_MessagePolicy = 1
# saveData_SetCptWait_ms(100)
# saveData_Init("saveDataExtraPVsMN.req", "P=13BMD:")
# saveData_PrintScanInfo("13BMD:scan1")
##}

motorUtilInit("13BMD:")

dbpf("13BMD:saveData_status", "0")
# Laser shutter states
dbpf("13BMD:Unidig2Bo21.ZNAM","Open")
dbpf("13BMD:Unidig2Bo21.ONAM","Closed")
