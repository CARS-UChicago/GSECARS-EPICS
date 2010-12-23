# vxWorks startup file for 13BMD IOC
< cdCommands
< ../nfsCommandsGSE
loginUserAdd "epics","SzeSebbzRR"

cd topbin
ld < CARSApp.munch
cd startup

# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in this build.
dbLoadDatabase("$(CARS)/dbd/CARSVX.dbd")
CARSVX_registerRecordDeviceDriver(pdbbase)

< industryPack.cmd
< serial.cmd

# Load database
### Scalers: Joerger VSC8/16
dbLoadRecords("$(STD)/stdApp/Db/scaler.db", "P=13BMD:,S=scaler1,OUT=#C0 S0 @,FREQ=1e7,DTYP=Joerger VSC8/16")
dbLoadRecords("$(CARS)/CARSApp/Db/lvp_dmm.db", "P=13BMD:,Dmm=DMM1,DLY=0.1")
dbLoadTemplate "DAC.template"
dbLoadTemplate "heater_control.template"
dbLoadTemplate "LVP_furnace_control.template"
dbLoadTemplate "motors.template"
dbLoadTemplate "laser_pid.template"


# MAR345 shutter
str=malloc(256)
strcpy(str,"P=13BMD:,R=MAR345,IN=13BMD:Unidig1Bi13,")
strcat(str,"OUT=13BMD:filter1sendCommand.VAL")
dbLoadRecords("$(CARS)/CARSApp/Db/MAR345_shutter_serial.db",str)


##==== XPS Motors    ==================================
XPSSetup(1)
#    card, IP, PORT, number of axes, active poll period (ms), idle poll period (ms)
XPSConfig(0, "164.54.160.83", 5001, 8, 10, 200)

# asyn port, driver name, controller index, max. axes)
drvAsynMotorConfigure("XPS1", "motorXPS", 0, 8)
 XPSInterpose("XPS1")

# configure axes
#card, axis, groupName.positionerName, steps/rev
XPSConfigAxis(0,0,"GROUP1.POSITIONER",  10000)  
XPSConfigAxis(0,1,"GROUP2.POSITIONER",  10000)  
XPSConfigAxis(0,2,"GROUP3.POSITIONER",  50000)  

# Disable setting position from motor record
XPSEnableSetPosition(0)
 
##=====================================================

# Acromag Ip330 ADC
dbLoadTemplate "Ip330_ADC.template"

# IP-Unidig binary I/O
dbLoadTemplate "ipUnidig.substitutions"

# CCD synchronization for tomo.exe Visual Basic program
dbLoadRecords("$(CARS)/CARSApp/Db/CCD.db", "P=13BMD:,C=CCD1")

# Struck MCS as 32-channel multi-element detector
< SIS3820_32.cmd

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

# Set up Struck multichannel scaler
#STR7201Setup(1,0xA0000000,220,6)
#STR7201Config(0, 4, 2048)
#dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=13BMD:,M=mca_str1,DTYP=Struck STR7201 MCS,NCHAN=1024,INP=#C0 S0")

# IP-330 ADC with MCA record as transient recorder
dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=13BMD:,M=mip330_1,DTYP=asynMCA,NCHAN=2048,INP=@asyn(Ip330Sweep1 0)")
dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=13BMD:,M=mip330_2,DTYP=asynMCA,NCHAN=2048,INP=@asyn(Ip330Sweep1 1)")
dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=13BMD:,M=mip330_3,DTYP=asynMCA,NCHAN=2048,INP=@asyn(Ip330Sweep1 2)")
dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=13BMD:,M=mip330_4,DTYP=asynMCA,NCHAN=2048,INP=@asyn(Ip330Sweep1 3)")

### Allstop, alldone
# This database must agree with the motors you've actually loaded.
# Several versions (e.g., all_com_40.db) are in std/stdApp/Db
dbLoadRecords("$(STD)/stdApp/Db/all_com_80.db","P=13BMD:")

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

################################################################################
# Setup device/driver support addresses, interrupt vectors, etc.

# OMS VME58 driver setup parameters:
#     (1)cards, (2)base address(short, 4k boundary),
#     (3)interrupt vector (0=disable or  64 - 255), (4)interrupt level (1 - 6),
#     (5)motor task polling rate (min=1Hz,max=60Hz)
oms58Setup(10, 0x4000, 190, 5, 10)

################################################################################
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
################################################################################


# Joerger VSC setup parameters: 
#     (1)cards, (2)base address(ext, 256-byte boundary), 
#     (3)interrupt vector (0=disable or  64 - 255)
VSCSetup(1, 0xB0000000, 200)
 
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


