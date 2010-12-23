# vxWorks startup file
< cdCommands
< ../nfsCommandsGSE

cd topbin
ld < CARSApp.munch

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
dbLoadRecords("$(STD)/stdApp/Db/scaler.db", "P=13IDC:,S=scaler1,OUT=#C0 S0 @,FREQ=1e7,DTYP=Joerger VSC8/16")

dbLoadTemplate("motors.template")

# Multichannel analyzer stuff
# AIMConfig(portName, ethernet_address, portNumber(1 or 2), maxChans,
#           maxSignals, maxSequences, ethernetDevice)
# This AIM moved to 13BMC.  No AIM in IDC now.
AIMConfig("NI6E6/1", 0x6E6, 1, 2048, 1, 1, "dc0")
AIMConfig("NI6E6/2", 0x6E6, 2, 2048, 4, 1, "dc0")
dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=13IDC:,M=aim_adc1,DTYP=asynMCA,INP=@asyn(NI6E6/1 0),NCHAN=2048")
dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=13IDC:,M=aim_mcs1,DTYP=asynMCA,INP=@asyn(NI6E6/2 0),NCHAN=2048")

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
icbConfig("icbAdc1", 0x6e6, 5, 0)
dbLoadRecords("$(MCA)/mcaApp/Db/icb_adc.db", "P=13IDC:,ADC=adc1,PORT=icbAdc1")
#icbConfig("icbAmp1", 0x6e6, 3, 1)
#dbLoadRecords"$(MCA)/mcaApp/Db/icb_amp.db", "P=13IDC:,AMP=amp1,PORT=icbAmp1")
#icbConfig("icbHvps1", 0x6e6, 2, 2)
#dbLoadRecords("$(MCA)/mcaApp/Db/icb_hvps.db", "P=13IDC:,HVPS=hvps1,PORT=icbHvps1,LIMIT=1000")
 
# Struck MCS as 8-channel multi-element detector
<Struck8.cmd

### Scalers: Struck/SIS as simple scaler 
# Don't execute the next 2 lines if Struck8.cmd is loaded above
#STR7201Setup(1,0xA0000000,220,6)
#STR7201Config(0, 16, 100, 1, 1)
dbLoadRecords("$(MCA)/mcaApp/Db/STR7201scaler.db","P=13IDC:,S=scaler2,C=0")


### Allstop, alldone
# This database must agree with the motors you've actually loaded.
# Several versions (e.g., all_com_32.db) are in stdApp/Db
dbLoadRecords("$(STD)/stdApp/Db/all_com_56.db","P=13IDC:")

### Scan-support software
# crate-resident scan.  This executes 1D, 2D, 3D, and 4D scans, and caches
# 1D data, but it doesn't store anything to disk.  (You need the data catcher
# or the equivalent for that.)  This database is configured to use the
# "alldone" database (above) to figure out when motors have stopped moving
# and it's time to trigger detectors.

dbLoadRecords("$(SSCAN)/sscanApp/Db/scan.db","P=13IDC:,MAXPTS1=2000,MAXPTS2=500,MAXPTS3=20,MAXPTS4=5,MAXPTSH=10")

# A set of scan parameters for each positioner.  This is a convenience
# for the user.  It can contain an entry for each scannable thing in the
# crate.
dbLoadTemplate("scanParms.template")

dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=13IDC:,M=mip330_1,DTYP=asynMCA,NCHAN=2048,INP=@asyn(Ip330Sweep1 0)")
dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=13IDC:,M=mip330_2,DTYP=asynMCA,NCHAN=2048,INP=@asyn(Ip330Sweep1 1)")
dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=13IDC:,M=mip330_3,DTYP=asynMCA,NCHAN=2048,INP=@asyn(Ip330Sweep1 2)")
dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=13IDC:,M=mip330_4,DTYP=asynMCA,NCHAN=2048,INP=@asyn(Ip330Sweep1 3)")
# added 2-05 for split ion chmaber
dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=13IDC:,M=mip330_5,DTYP=asynMCA,NCHAN=2048,INP=@asyn(Ip330Sweep1 4)")
dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=13IDC:,M=mip330_6,DTYP=asynMCA,NCHAN=2048,INP=@asyn(Ip330Sweep1 5)")

# Miscellaneous PV's, such as burtResult
dbLoadRecords("$(STD)/stdApp/Db/misc.db","P=13IDC:")

# Experiment description
dbLoadRecords("$(CARS)/CARSApp/Db/experiment_info.db","P=13IDC:")

# SCA Window for Bede detector
dbLoadRecords("$(CARS)/CARSApp/Db/sca_window.db","P=13IDC:,SCA=BEDE,DAC1=DAC1_1,DAC2=DAC1_2,MIN=0,MAX=3")

# vxWorks statistics
dbLoadTemplate("vxStats.substitutions")

< ../save_restore.cmd
save_restoreSet_status_prefix("13IDC:")
dbLoadRecords("$(AUTOSAVE)/asApp/Db/save_restoreStatus.db", "P=13IDC:")

# Setup device/driver support addresses, interrupt vectors, etc.

################################################################################
# OMS VME58 driver setup parameters:
#     (1)cards, (2)base address(short, 4k boundary),
#     (3)interrupt vector (0=disable or  64 - 255), (4)interrupt level (1 - 6),
#     (5)motor task polling rate (min=1Hz,max=60Hz)
oms58Setup(9, 0x4000, 190, 5, 10)
################################################################################

################################################################################
# Joerger VSC setup parameters: 
#     (1)cards, (2)base address(ext, 256-byte boundary), 
#     (3)interrupt vector (0=disable or  64 - 255)
VSCSetup(1, 0xB0000000, 200)
################################################################################

################################################################################
# XPS trajectoryScan records

# Database for trajectory scanning with the XPS
# The required command string is longer than the vxWorks command line, 
# must use malloc and strcpy, strcat. Some of the macros don't apply

# str = malloc(500)
# strcpy(str, "P=13IDC:,R=traj1,NAXES=6,NELM=2000,NPULSE=2000,PORT=5001")
# strcat(str, ",DONPV=13IDC:str:EraseStart,DONV=1,DOFFPV=13IDC:str:StopAll,DOFFV=1")
# dbLoadRecords("$(MOTOR)/motorApp/Db/trajectoryScan.db", str)
################################################################################

################################################################################
# XPS Setup
drvAsynIPPortConfigure("tcp1","164.54.160.55:5001 tcp", 0, 0, 1)
drvAsynIPPortConfigure("tcp2","164.54.160.56:5001 tcp", 0, 0, 1)

# cards (total controllers)
XPSSetup(2)

# Setup the XPS for the Rotation
# card, IP, PORT, number of axes, active poll period (ms), idle poll period (ms)
XPSConfig(0, "164.54.160.55", 5001, 6, 10, 500)
# asyn port, driver name, controller index, max. axes)
drvAsynMotorConfigure("XPS1", "motorXPS", 0, 6)

# Setup the XPS for the Base and X, Y and Z
# card, IP, PORT, number of axes, active poll period (ms), idle poll period (ms)
XPSConfig(1, "164.54.160.56", 5001, 8, 10, 500)
# asyn port, driver name, controller index, max. axes)
drvAsynMotorConfigure("XPS2", "motorXPS", 1, 8)

# Define the group names and the steps per unit.  This must match values defined
# in the XPS system.ini ([group.names]) and stages.ini (1/EncoderResolution)
 
# XPS for the Rotations
# card,  axis, groupName.positionerName, stepsPerUnit
XPSConfigAxis(0,0,"GROUP.PHI",      1000)
XPSConfigAxis(0,1,"GROUP.KAPPA",   10000)
XPSConfigAxis(0,2,"GROUP.OMEGA",   10000)
XPSConfigAxis(0,3,"GROUP.PSI",      4000)
XPSConfigAxis(0,4,"GROUP.THETA",   10000)
XPSConfigAxis(0,5,"GROUP.NU",       4000)
 
# XPS for the Base and X, Y and Z 
# card,  axis, groupName.positionerName, stepsPerUnit
# This is the config for the Y1-3 is grouped together in "Y_Base"
#XPSConfigAxis(1,0,"Y_Base.Y1",     10000)
#XPSConfigAxis(1,1,"Y_Base.Y2",     10000)
#XPSConfigAxis(1,2,"Y_Base.Y3",     10000)
#XPSConfigAxis(1,3,"GROUP4.THETAY",   200)
#XPSConfigAxis(1,4,"GROUP5.TRX",      200)
#XPSConfigAxis(1,5,"GROUP6.X",      74627)
#XPSConfigAxis(1,6,"GROUP7.Y",      74627)
#XPSConfigAxis(1,7,"GROUP8.Z",     100000)

# XPS for the Base and X, Y and Z 
# card,  axis, groupName.positionerName, stepsPerUnit
# This is the config for the Y1-3 in single axis groups
XPSConfigAxis(1,0,"GROUP1.Y1_BASE", 10000)
XPSConfigAxis(1,1,"GROUP2.Y2_BASE", 10000)
XPSConfigAxis(1,2,"GROUP3.Y3_BASE", 10000)
XPSConfigAxis(1,3,"GROUP4.THETAY",    200)
XPSConfigAxis(1,4,"GROUP5.TRX",       200)
XPSConfigAxis(1,5,"GROUP6.X",       74627)
XPSConfigAxis(1,6,"GROUP7.Y",       74627)
XPSConfigAxis(1,7,"GROUP8.Z",      100000)


# Disable setting position from motor record
XPSEnableSetPosition(0) 

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

#mn 16-sep-1999
## seq(&Keithley2kDMM, "P=13IDC:, Dmm=DMM1, stack=10000")

#{MN 15-Feb-00 : energy sequencer for channel-cut crystal
## seq(&Energy_CC, "P=13IDC:, IDXX=ID13:, EN=Energy,  MONO=m8, TABLE=m6, DIF=DIF:t1.Y")

#}
#{ for using crystal analyzer
#  commented out MN 08-Aug-98 
#  seq &Analyzer, "P=13IDC:, THETA=m43, DETECTOR=m44, ANAL=ANAL"
#}
#  PVSstart

# newport table sequencer
str=malloc(256)
strcpy(str,"P=13IDC:,T=NewTab1:, M1=m34,M2=m33,M3=m35,M4=m36,M5=m37,")
strcat(str,"PM1=pm7,PM2=pm8,PM3=pm9,PM4=pm10,PM5=pm11,PM6=pm12,PM7=pm13,PM8=pm14")
newport_tableDebug = 1
# seq(&newport_table, str)

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

# Trajectory scanning with XPS
# str = malloc(500)
# strcpy(str, "P=13IDC:,R=traj1,M1=m25,M2=m26,M3=m27,M4=m28,M5=m29,M6=m30,IPADDR=164.54.160.55,")
# strcat(str, "PORT=5001,GROUP=GROUP,P1=PHI,P2=KAPPA,P3=OMEGA,P4=PSI,P5=THETA,P6=NU")
# seq(&XPS_trajectoryScan, str)

# Set the NTM fields of the XPS motors to 0 (NO) so they don't get stopped when the motor changes direction due to PID
dbpf("13IDC:m25.NTM","0")
dbpf("13IDC:m26.NTM","0")
dbpf("13IDC:m27.NTM","0")
dbpf("13IDC:m28.NTM","0")
dbpf("13IDC:m29.NTM","0")
dbpf("13IDC:m30.NTM","0")
dbpf("13IDC:m33.NTM","0")
dbpf("13IDC:m34.NTM","0")
dbpf("13IDC:m35.NTM","0")
dbpf("13IDC:m36.NTM","0")
dbpf("13IDC:m37.NTM","0")
dbpf("13IDC:m38.NTM","0")
dbpf("13IDC:m39.NTM","0")
dbpf("13IDC:m40.NTM","0")

