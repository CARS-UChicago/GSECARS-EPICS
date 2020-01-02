# vxWorks startup file
< cdCommands

< ../nfsCommandsGSE
#loginUserAdd "epics","SzeSebbzRR"

cd topbin
load("CARSApp.munch")

cd startup

# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in this build from CARS
dbLoadDatabase("$(CARS)/dbd/CARSVX.dbd")
CARSVX_registerRecordDeviceDriver(pdbbase)

# Increase size of buffer for error logging from default 1256 
# Use the new shell
#iocsh

errlogInit(50000)

# Set debugging flags
save_restoreDebug=0
devMM4000debug = 0
devMCB4BDebug=0
drvMCB4BDebug=0
drvMM4000debug = 0
mcaRecordDebug = 0
aimDebug = 0
llcDebug=0
drvSTR7201Debug = 0
devSTR7201Debug = 0
scalerRecordDebug=0
devScalerSTR7201Debug=0
icbDebug=0
sscanRecordDebug=0
devMCA_softDebug = 0 

< industryPack.cmd
< serial.cmd

# Test Koyo PLC
# < Koyo1.cmd

# Test Lewis Muir's problem
dbLoadRecords("bi_test.db", "P=13LAB:")

# Heidenhain IK320 VME encoder interpolator
#dbLoadRecords("$(VME)/vmeApp/Db/IK320card.db", "P=13LAB:,sw2=card0:,axis=1,switches=41344,irq=3")
#dbLoadRecords("$(VME)/vmeApp/Db/IK320card.db", "P=13LAB:,sw2=card0:,axis=2,switches=41344,irq=3")
#dbLoadRecords("$(VME)/vmeApp/Db/IK320group.db", "P=13LAB:,group=5")
#drvIK320RegErrStr()

# Heater control
dbLoadTemplate "heater_control.template"

#PID slow
dbLoadTemplate "pid_slow.template"

#PID fast
dbLoadTemplate "pid_fast.template"

# Tomography data collection
dbLoadRecords("$(CARS)/db/TomoCollect.template", "P=13LAB:,R=TC:")

### Motors
dbLoadTemplate  "motors.template"

### APS Quad Electrometer
#iocsh("APS_EM.cmd")

# Experiment description
dbLoadRecords("$(CARS)/db/experiment_info.db", "P=13LAB:")


#MN----------------------------------------------------------------------
dbLoadRecords("$(CARS)/db/scanner.db", "P=13LAB:,Q=EDB")

# A set of scan parameters for each positioner.  This is a convenience
# for the user.  It can contain an entry for each scannable thing in the
# crate.
dbLoadTemplate "scanParms.template"

# Multichannel analyzer stuff

# AIMConfig(portName, ethernet_address, portNumber(1 or 2), maxChans, 
#           maxSignals, maxSequences, ethernetDevice)
AIMConfig("AIM1/1", 0x3ED, 1, 2048, 1, 1, "fei0")
AIMConfig("AIM1/2", 0x3ED, 2, 2048, 8, 1, "fei0")
AIMConfig("DSA2000", 0x8058, 1, 2048, 1, 1, "fei0")
dbLoadRecords("$(MCA)/db/mca.db", "P=13LAB:,M=aim_adc1,DTYP=asynMCA,INP=@asyn(AIM1/1 0),NCHAN=2048")
dbLoadRecords("$(MCA)/db/mca.db", "P=13LAB:,M=aim_adc2,DTYP=asynMCA,INP=@asyn(AIM1/2 0),NCHAN=2048")
dbLoadRecords("$(MCA)/db/mca.db", "P=13LAB:,M=aim_adc3,DTYP=asynMCA,INP=@asyn(AIM1/2 2),NCHAN=2048")
dbLoadRecords("$(MCA)/db/mca.db", "P=13LAB:,M=aim_adc4,DTYP=asynMCA,INP=@asyn(AIM1/2 4),NCHAN=2048")
dbLoadRecords("$(MCA)/db/mca.db", "P=13LAB:,M=aim_adc5,DTYP=asynMCA,INP=@asyn(AIM1/2 6),NCHAN=2048")
dbLoadRecords("$(MCA)/db/mca.db", "P=13LAB:,M=dsa2000_1,DTYP=asynMCA,INP=@asyn(DSA2000 0),NCHAN=2048")

dbLoadRecords("$(MCA)/db/mca.db", "P=13LAB:,M=mip330_1,DTYP=asynMCA,NCHAN=2048,INP=@asyn(Ip330Sweep1 0)")
dbLoadRecords("$(MCA)/db/mca.db", "P=13LAB:,M=mip330_2,DTYP=asynMCA,NCHAN=2048,INP=@asyn(Ip330Sweep1 1)")
dbLoadRecords("$(MCA)/db/mca.db", "P=13LAB:,M=mip330_3,DTYP=asynMCA,NCHAN=2048,INP=@asyn(Ip330Sweep1 2)")
dbLoadRecords("$(MCA)/db/mca.db", "P=13LAB:,M=mip330_4,DTYP=asynMCA,NCHAN=2048,INP=@asyn(Ip330Sweep1 3)")

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
icbConfig("icbAdc1", 0x3ED, 5, 0)
dbLoadRecords("$(MCA)/db/icb_adc.db", "P=13LAB:,ADC=adc1,PORT=icbAdc1")
icbConfig("icbAmp1", 0x3ED, 3, 1)
dbLoadRecords("$(MCA)/db/icb_amp.db", "P=13LAB:,AMP=amp1,PORT=icbAmp1")
#icbConfig("icbHvps1", 0x3ED, 2, 2)
#dbLoadRecords("$(MCA)/db/icb_hvps.db", "P=13LAB:,HVPS=hvps1,PORT=icbHvps1,LIMIT=6000")
icbConfig("icbTca1", 0x3ED, 8, 3)
dbLoadRecords("$(MCA)/db/icb_tca.db", "P=13LAB:,TCA=tca1,MCA=aim_adc1,PORT=icbTca1")
#icbConfig("icbDsp1", 0x8058, 0, 4)
#dbLoadRecords("$(MCA)/db/icbDsp.db", "P=13LAB:,DSP=dsp1,PORT=icbDsp1")

# SIS 3801 and SIS3820
<SIS3801.cmd
<SIS3820.cmd

### Scalers: Joerger VSC8/16
dbLoadRecords("$(STD)/db/scaler.db", "P=13LAB:,S=scaler1,OUT=#C0 S0 @,FREQ=1e7,DTYP=Joerger VSC8/16")

### Allstop, alldone
dbLoadRecords("$(MOTOR)/db/motorUtil.db", "P=13LAB:")

### Scan-support software
# crate-resident scan.  This executes 1D, 2D, 3D, and 4D scans, and caches
# 1D data, but it doesn't store anything to disk.  (You need the data catcher
# or the equivalent for that.)  This database is configured to use the
# "alldone" database (above) to figure out when motors have stopped moving
# and it's time to trigger detectors.
dbLoadRecords("$(SSCAN)/db/scan.db", "P=13LAB:,MAXPTS1=2000,MAXPTS2=200,MAXPTS3=20,MAXPTS4=10,MAXPTSH=10000")

# Miscellaneous PV's
dbLoadRecords("$(STD)/db/misc.db","P=13BMD:")

# Free-standing user string/number calculations (sCalcout records)
dbLoadRecords("$(CALC)/db/userStringCalcs10.db", "P=13LAB:")

# Free-standing user array calculations (sCalcout records)
dbLoadRecords("$(CALC)/db/userArrayCalcs10.db", "P=13LAB:,N=10")

# Free-standing user transforms (transform records)
dbLoadRecords("$(CALC)/db/userTransforms10.db", "P=13LAB:")

# vme test record
dbLoadRecords("$(VME)/vmeApp/Db/vme.db", "P=13LAB:,Q=vme1")

# devIocStats
putenv("ENGINEER=Mark Rivers")
putenv("LOCATION=A020 lab")
putenv("GROUP=GSECARS")
dbLoadRecords("$(DEVIOCSTATS)/db/iocAdminVxWorks.db","IOC=13LAB:")

< ../save_restore.cmd
save_restoreSet_status_prefix("13LAB:")
dbLoadRecords("$(AUTOSAVE)/asApp/Db/save_restoreStatus.db", "P=13LAB:")

################################################################################
# Setup device/driver support addresses, interrupt vectors, etc.


# OMS MAXv driver setup parameters:
#     (1)number of cards in array.
#     (2)VME Address Type (16,24,32).
#     (3)Base Address on 4K (0x1000) boundary.
#     (4)interrupt vector (0=disable or  64 - 255).
#     (5)interrupt level (1 - 6).
#     (6)motor task polling rate (min=1Hz,max=60Hz).

MAXvSetup(1, 16, 0x5000, 190, 5, 10)

drvMAXvdebug=0

# OMS MAXv configuration string:
#     (1) number of card being configured (0-14).
#     (2) configuration string; axis type (PSO/PSE/PSM) MUST be set here.
#         For example, set which TTL signal level defines
#         an active limit switch.  Set X,Y,Z,T to active low and set U,V,R,S
#         to active high.  Set all axes to open-loop stepper (PSO). See MAXv
#         User's Manual for LM, LT and PSO/PSE/PSM commands.

# Set all axes to open-loop stepper and active high limits
configStep="AX LMH LTH PSO; AY LMH LTH PSO; AZ LMH LTH PSO; AT LMH LTH PSO; AU LMH LTH PSO; AV LMH LTH PSO; AR LMH LTH PSO; AS LMH LTH PSO;"
MAXvConfig(0, configStep)

# OMS VME58 driver setup parameters: 
#     (1)cards, (2)base address(short, 4k boundary), 
#     (3)interrupt vector (0=disable or  64 - 255), (4)interrupt level (1 - 6),
#     (5)motor task polling rate (min=1Hz,max=60Hz)
oms58Setup(1, 0x4000, 190, 5, 10)

#{{{ MN May 7, 2007 -- comment out XPS controller
# # cards (total controllers)
# XPSSetup(1)
# 
# # card, IP, PORT, number of axes, active poll period (ms), idle poll period (ms)
# XPSConfig(0, "164.54.160.34", 5001, 3, 10, 5000)
# 
# # asynPort, IP address, IP port, poll period (ms)
# XPSAuxConfig("XPS_AUX1", "164.54.160.34", 5001, 50)
# #asynSetTraceMask("XPS_AUX1", 0, 255)
# #asynSetTraceIOMask("XPS_AUX1", 0, 2)
# 
# # asyn port, driver name, controller index, max. axes)
# drvAsynMotorConfigure("XPS1", "motorXPS", 0, 3)
# XPSInterpose("XPS1")
# 
# # card,  axis, groupName.positionerName
# XPSConfigAxis(0,0,"GROUP1.POSITIONER",20480)
# XPSConfigAxis(0,1,"GROUP2.POSITIONER1",6768)
# XPSConfigAxis(0,2,"GROUP2.POSITIONER2",20480)
#}}}}  
# Joerger VSC setup parameters: 
#     (1)cards, (2)base address(ext, 256-byte boundary), 
#     (3)interrupt vector (0=disable or  64 - 255)
# Can't use D000000 on PowerPC, change to B0000000
VSCSetup(1, 0xB0000000, 200)

#asynSetTraceMask "AIM1/1",0,0xff
#asynSetTraceMask "icbTca1",0,0x13
#asynSetTraceMask "icbHvps1",0,0xff
#asynSetTraceMask "Unidig1",0,0x19
#asynSetTraceMask "DAC1",0,0xff
#asynSetTraceMask("quadEM1",0,0x11)
#asynSetTraceMask("Ip330_1",0,0xff)
#asynSetTraceMask("Unidig1", 0, 255)

iocInit

### Start up the autosave task and tell it what to do.
# The task is actually named "save_restore".
# (See also, 'initHooks' above, which is the means by which the values that
# will be saved by the task we're starting here are going to be restored.
#

# save positions every five seconds
create_monitor_set("auto_positions.req", 5, "P=13LAB:")
# save other things every thirty seconds
create_monitor_set("auto_settings.req", 30, "P=13LAB:")

# Enable user string calcs and user transforms
dbpf "13LAB:EnableUserTrans.PROC","1"
dbpf "13LAB:EnableUserSCalcs.PROC","1"
dbpf "13LAB:EnableuserACalcs.PROC","1"

seq &Keithley2kDMM, "P=13LAB:, Dmm=DMM1, stack=10000"
seq &Keithley2kDMM, "P=13LAB:, Dmm=DMM2, channels=22, model=2700, stack=10000"
#seq &Keithley2kDMM, "P=13LAB:, Dmm=DMM3, channels=22, model=2700, stack=10000"
#seq &seq_test, "pv1=13LAB:m1, pv2=13LAB:m2"

seq(&SIS38XX_SNL, "P=13LAB:SIS3801:, R=mca, NUM_SIGNALS=8, FIELD=READ")

seq(&SIS38XX_SNL, "P=13LAB:SIS3820:, R=mca, NUM_SIGNALS=2, FIELD=PROC")

#seq(&quadEM_SNL, "P=13LAB:, R=QE1:, NUM_CHANNELS=2048")

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
saveData_SetCptWait_ms(100)
saveData_Init("saveDataExtraPVs.req", "P=13LAB:")
#saveData_PrintScanInfo("13LAB:scan1")

#free(mem)

# For debugging IpUnidig
#dbpf "13LAB:UnidigBi0.TPRO","1"
#dbpf "13LAB:UnidigBi5.TPRO","1"
#asynSetTraceMask("Unidig1",0,8)

motorUtilInit("13LAB:")

