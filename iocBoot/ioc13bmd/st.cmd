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

# Joerger VSC setup parameters: 
#     (1)cards, (2)base address(ext, 256-byte boundary), 
#     (3)interrupt vector (0=disable or  64 - 255)
VSCSetup(1, 0xB0000000, 200)
dbLoadRecords("$(STD)/stdApp/Db/scaler.db", "P=13BMD:,S=scaler1,OUT=#C0 S0 @,FREQ=1e7,DTYP=Joerger VSC8/16")

dbLoadRecords("$(CARS)/CARSApp/Db/lvp_dmm.db", "P=13BMD:,Dmm=DMM1,DLY=0.1")
dbLoadTemplate "heater_control.template"
dbLoadTemplate "LVP_furnace_control.template"
dbLoadTemplate "laser_pid.template"

# MAR345 shutter
str=malloc(256)
strcpy(str,"P=13BMD:,R=MAR345,IN=13BMD:Unidig1Bi13,")
strcat(str,"OUT=13BMD:filter1sendCommand.VAL")
dbLoadRecords("$(CARS)/CARSApp/Db/MAR345_shutter_serial.db",str)

# Multichannel analyzer stuff
# AIMConfig(portName, card, ethernet_address, port, maxChans,
#           maxSignals, maxSequences, ethernetDevice)
AIMConfig("NI9CE/1", 0x9CE, 1, 2048, 1, 1,"dc0")
AIMConfig("NI9CE/2", 0x9CE, 2, 2048, 4, 1,"dc0")
dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=13BMD:,M=aim_adc1,DTYP=asynMCA,INP=@asyn(NI9CE/1 0),NCHAN=2048")
dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=13BMD:,M=aim_mcs1,DTYP=asynMCA,INP=@asyn(NI9CE/2 0),NCHAN=2048")
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
dbLoadRecords("$(MCA)/mcaApp/Db/icb_adc.db", "P=13BMD:,ADC=adc1,PORT=icbAdc1")
icbConfig("icbAmp1", 0x9ce, 3, 1)
dbLoadRecords("$(MCA)/mcaApp/Db/icb_amp.db", "P=13BMD:,AMP=amp1,PORT=icbAmp1")
icbConfig("icbHvps1", 0x9ce, 2, 2)
dbLoadRecords("$(MCA)/mcaApp/Db/icb_hvps.db", "P=13BMD:,HVPS=hvps1,PORT=icbHvps1,LIMIT=1000")

# CCD synchronization for older version of tomo_collect
dbLoadRecords("$(CARS)/CARSApp/Db/CCD.db", "P=13BMD:,C=CCD1")
# Tomography data collection
dbLoadRecords("$(CARS)/CARSApp/Db/TomoCollect.template", "P=13BMDRP1:,R=TC:")

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
configStep="AX LH PSO; AY LH PSO; AZ LH PSO; AT LH PSO; AU LH PSO; AV LH PSO; AR LH PSO; AS LH PSO;"
# Set all to active low limits for ThorLabs micrometers.  Set all to servo.
configServo="AX LL PSM; AY LL PSM; AZ LL PSM; AT LL PSM; AU LL PSM; AV LL PSM; AR LL PSM; AS LL PSM;"
# First MAXv
MAXvConfig(0, configStep)

dbLoadTemplate "motors.template"

### Allstop, alldone
dbLoadRecords("$(MOTOR)/motorApp/Db/motorUtil.db","P=13BMD:")

### Scan-support software
# crate-resident scan.  This executes 1D, 2D, 3D, and 4D scans, and caches
# 1D data, but it doesn't store anything to disk.  (You need the data catcher
# or the equivalent for that.)  This database is configured to use the
# "alldone" database (above) to figure out when motors have stopped moving
# and it's time to trigger detectors.
dbLoadRecords("$(SSCAN)/sscanApp/Db/scan.db","P=13BMD:,MAXPTS1=2000,MAXPTS2=200,MAXPTS3=4,MAXPTS4=3,MAXPTSH=10")

dbLoadRecords("$(CARS)/CARSApp/Db/scanner.db", "P=13BMD:,Q=edb")

# A set of scan parameters for each positioner.  This is a convenience
# for the user.  It can contain an entry for each scannable thing in the
# crate.
dbLoadTemplate "scanParms.template"

# Miscellaneous PV's, such as burtResult
dbLoadRecords("$(STD)/stdApp/Db/misc.db","P=13BMD:")
dbLoadRecords("$(CALC)/calcApp/Db/userTransform.db", "P=13BMD:, N=1")
dbLoadRecords("$(CALC)/calcApp/Db/userTransform.db", "P=13BMD:, N=2")

# Experiment description
dbLoadRecords("$(CARS)/CARSApp/Db/experiment_info.db","P=13BMD:")

# vxWorks statistics
dbLoadTemplate("vxStats.substitutions")

< ../save_restore.cmd
save_restoreSet_status_prefix("13BMD:")
dbLoadRecords("$(AUTOSAVE)/asApp/Db/save_restoreStatus.db", "P=13BMD:")

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
create_monitor_set("auto_positions.req",5,"P=13BMD:")
# save other things every thirty seconds
create_monitor_set("auto_settings.req",30,"P=13BMD:")

seq &Keithley2kDMM, "P=13BMD:, Dmm=DMM1, stack=10000"
seq &Keithley2kDMM, "P=13BMD:, Dmm=DMM2, stack=15000"
seq &Keithley2kDMM, "P=13BMD:, Dmm=DMM3, stack=15000"
seq &Keithley2kDMM, "P=13BMD:, Dmm=DMM4, stack=15000"
seq &BMD_LVP_Detector, "P=13BMD:,PMT=pm4,PMR=pm3,X=m9,Y=m16,Z=m10,TV=m12,TH=m13"

seq(&SIS38XX_SNL, "P=13BMD:SIS1:, R=mca, NUM_SIGNALS=32, FIELD=READ")

# Force the DAC to be 0 volts.  The hardware does this automatically on VME 
# reset but the the software display is not correct
dbpf "13BMD:DAC1_1", "0."

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
saveData_MessagePolicy = 1
# saveData_SetCptWait_ms(100)
saveData_Init("saveDataExtraPVsMN.req", "P=13BMD:")
#saveData_PrintScanInfo("13BMD:scan1")
##}

motorUtilInit("13BMD:")

dbpf("13BMD:saveData_status", "0")

