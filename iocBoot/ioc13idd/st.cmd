# vxWorks startup file for 13IDD IOC
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

# Joerger VSC setup parameters: 
#     (1)cards, (2)base address(ext, 256-byte boundary), 
#     (3)interrupt vector (0=disable or  64 - 255)
VSCSetup(1, 0xB0000000, 200)
dbLoadRecords("$(STD)/stdApp/Db/scaler.db", "P=13IDD:,S=scaler2,OUT=#C0 S0 @,FREQ=1e7,DTYP=Joerger VSC8/16")

# MAR345 shutter
dbLoadRecords("$(CARS)/CARSApp/Db/MAR345_shutter.db","P=13IDD:,R=MAR345,IN=13IDD:Unidig1Bi14,OUT=13IDD:Unidig1Bo11")

# Multichannel analyzer stuff
# AIMConfig(portName, ethernet_address, portNumber(1 or 2), maxChans,
#           maxSignals, maxSequences, ethernetDevice)
AIMConfig("NI3ED/1", 0x59E, 1, 4000, 1, 1,"dc0")
AIMConfig("NI3ED/2", 0x59E, 2, 4000, 1, 1,"dc0")
dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=13IDD:,M=aim_adc1,DTYP=asynMCA,INP=@asyn(NI3ED/1 0),NCHAN=4000")
dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=13IDD:,M=aim_mcs1,DTYP=asynMCA,INP=@asyn(NI3ED/2 0),NCHAN=4000")

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
icbConfig("icbAdc1", 0x59E, 5, 0)
dbLoadRecords("$(MCA)/mcaApp/Db/icb_adc.db", "P=13IDD:,ADC=adc1,PORT=icbAdc1")
icbConfig("icbAmp1", 0x59E, 3, 1)
dbLoadRecords("$(MCA)/mcaApp/Db/icb_amp.db", "P=13IDD:,AMP=amp1,PORT=icbAmp1")
icbConfig("icbHvps1", 0x59E, 2, 2)
dbLoadRecords("$(MCA)/mcaApp/Db/icb_hvps.db", "P=13IDD:,HVPS=hvps1,PORT=icbHvps1,LIMIT=1000")

# Struck MCS
iocsh "SIS3820_32.cmd"

# Laser PID control
# This is for the old YLF laser using a photodiode with slow and fast feedback records, not used any more
dbLoadTemplate("laser_pid.template")

# Simple laser heating database
dbLoadRecords("$(CARS)/CARSApp/Db/laser_heating.db", "P=13IDD:")

# XRD File Base and relative paths
dbLoadRecords("$(CARS)/CARSApp/Db/xrd_files.db", "P=13IDD:")

# Koyo PLC for lasers
< Koyo.cmd

# Experiment description
dbLoadRecords("$(CARS)/CARSApp/Db/experiment_info.db","P=13IDD:")

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
# Set second channel to use encoder
configStep="AX LMH LTH PSO; AY LMH LTH PSE; AZ LMH LTH PSO; AT LMH LTH PSO; AU LMH LTH PSO; AV LMH LTH PSO; AR LMH LTH PSO; AS LMH LTH PSO;"
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

dbLoadTemplate("motors.template")

### motorUtil - for allstop, moving, etc.
dbLoadRecords("$(MOTOR)/db/motorUtil.db","P=13IDD:")

### Scan-support software
# crate-resident scan.  This executes 1D, 2D, 3D, and 4D scans, and caches
# 1D data, but it doesn't store anything to disk.  (You need the data catcher
# or the equivalent for that.)  This database is configured to use the
# "alldone" database (above) to figure out when motors have stopped moving
# and it's time to trigger detectors.
dbLoadRecords("$(SSCAN)/sscanApp/Db/scan.db","P=13IDD:,MAXPTS1=2000,MAXPTS2=2000,MAXPTS3=2000,MAXPTS4=2000,MAXPTSH=2048")

# A set of scan parameters for each positioner.  This is a convenience
# for the user.  It can contain an entry for each scannable thing in the
# crate.
dbLoadTemplate("scanParms.template")

# Miscellaneous PV's
dbLoadRecords("$(STD)/stdApp/Db/misc.db","P=13IDD:", std)

# devIocStats
putenv("ENGINEER=Mark Rivers")
putenv("LOCATION=13-ID-D roof")
putenv("GROUP=GSECARS")
dbLoadRecords("$(DEVIOCSTATS)/db/iocAdminVxWorks.db","IOC=13IDD:")

< ../save_restore.cmd
save_restoreSet_status_prefix("13IDD:")
dbLoadRecords("$(AUTOSAVE)/asApp/Db/save_restoreStatus.db", "P=13IDD:")

# dbrestore setup
sr_restore_incomplete_sets_ok = 1

iocInit

### Start up the autosave task and tell it what to do.
# The task is actually named "save_restore".
# (See also, 'initHooks' above, which is the means by which the values that
# will be saved by the task we're starting here are going to be restored.
#
# save positions every five seconds
create_monitor_set("auto_positions.req",5,"P=13IDD:")
# save other things every thirty seconds
create_monitor_set("auto_settings.req",30,"P=13IDD:")

seq &Keithley2kDMM, "P=13IDD:, Dmm=DMM1, channels=20, model=2700, stack=10000"

seq &IDD_LVP_Detector, "P=13IDD:,PMR=pm9,PMT=pm10,PMC=pm11,X=m33,Y=m34,Z=m35,TX=m38,TZ=m39"

# For SISXX MCS
seq(&SIS38XX_SNL, "P=13IDD:SIS1:, R=mca, NUM_SIGNALS=8, FIELD=READ")

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
saveData_Init("saveDataExtraPVs.req", "P=13IDD:")
#saveData_PrintScanInfo("13IDD:scan1")

# There is a bug in dbLoadRecords, it does not correctly remove \ from \"
dbpf "13IDD:LPC1_power_decode.CALC","AA[-3,-2]==\"mW\"?DBL(AA)/1e3:DBL(AA)"
# The scale factor from LPC power reading to actual laser watts
dbpf "13IDD:LPC1_power_scale.B","1.0"

# Set the encoder resolution for the LVP detector Y stages
dbpf("13IDD:m34.ERES",".001")

motorUtilInit("13IDD:")
