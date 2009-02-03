# vxWorks startup file
mem = malloc(1024*1024*96)

< cdCommands

< ../nfsCommandsGSE

cd topbin
# ld < CARS167.munch
ld < CARSApp.munch
# ld < ../../../motor/bin/vxWorks-ppc604/XPSGathering.munch
cd startup

# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in this build from CARSApp
dbLoadDatabase("$(CARS)/dbd/CARSVX.dbd")
CARSVX_registerRecordDeviceDriver(pdbbase)

# Set debugging flags
devMM4000debug = 0
drvMM4000debug = 0
mcaRecordDebug = 0
aimDebug = 0
drvSTR7201Debug = 0
devSTR7201Debug = 0
scalerRecordDebug=0
devScalerSTR7201Debug=0
devScalerCamacDebug=0
devE500Debug=0
drvE500Debug=0
icbDebug=0
motorRecordDebug = 0
devXPSC8Debug = 0
drvXPSC8Debug = 0
# Asyn XPS driver debug variable 0-5
asynXPSC8Debug = 0

< industryPack.cmd
< serial.cmd

### Motors
dbLoadTemplate  "motors.template"

# Struck MCS as 8-channel multi-element detector
<Struck8.cmd

# CCD synchronization for tomo.exe Visual Basic program
dbLoadRecords("$(CARS)/CARSApp/Db/CCD.db", "P=13BMC:,C=CCD1")

### Scalers: Struck/SIS as simple scaler
# Don't execute the next 2 lines if Struck8.cmd is loaded above
#STR7201Setup(1,0xA0000000,220,6)
#STR7201Config(0, 16, 100)
dbLoadRecords("$(MCA)/mcaApp/Db/STR7201scaler.db","P=13BMC:,S=scaler1,C=0")

# Multichannel analyzer stuff
# Multichannel analyzer stuff
# AIMConfig(portName, ethernet_address, portNumber(1 or 2), maxChans,
#           maxSignals, maxSequences, ethernetDevice)
AIMConfig("AIM1/1", 0x8D7, 1, 2048, 1, 1, "dc0")
dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=13BMC:,M=aim_adc1,DTYP=asynMCA,INP=@asyn(AIM1/1),NCHAN=2048")
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
icbConfig("icbAdc1", 0x8D7, 1, 0)
dbLoadRecords("$(MCA)/mcaApp/Db/icb_adc.db", "P=13BMC:,ADC=adc1,PORT=icbAdc1")
icbConfig("icbAmp1", 0x8D7, 4, 1)
dbLoadRecords("$(MCA)/mcaApp/Db/icb_amp.db", "P=13BMC:,AMP=amp1,PORT=icbAmp1")

# A set of scan parameters for each positioner.  This is a convenience
# for the user.  It can contain an entry for each scannable thing in the
# crate.
dbLoadTemplate "scanParms.template"

### Allstop, alldone
# This database must agree with the motors you've actually loaded.
# Several versions (e.g., all_com_32.db) are in std/stdApp/Db
dbLoadRecords("$(STD)/stdApp/Db/all_com_8.db","P=13BMC:")

### Scan-support software
# crate-resident scan.  This executes 1D, 2D, 3D, and 4D scans, and caches
# 1D data, but it doesn't store anything to disk.  (You need the data catcher
# or the equivalent for that.)  This database is configured to use the
# "alldone" database (above) to figure out when motors have stopped moving
# and it's time to trigger detectors.
dbLoadRecords("$(SSCAN)/sscanApp/Db/scan.db","P=13BMC:,MAXPTS1=2000,MAXPTS2=10,MAXPTS3=10,MAXPTS4=10,MAXPTSH=10")

# Free-standing user string/number calculations (sCalcout records)
dbLoadRecords("$(CALC)/calcApp/Db/userStringCalcs10.db","P=13BMC:")

# Free-standing user transforms (transform records)
dbLoadRecords("$(CALC)/calcApp/Db/userTransforms10.db","P=13BMC:")

# vme test record
dbLoadRecords("$(VME)/vmeApp/Db/vme.db", "P=13BMC:,Q=vme1")

# Miscellaneous PV's, such as burtResult
dbLoadRecords("$(STD)/stdApp/Db/misc.db","P=13BMC:")

# vxWorks statistics
dbLoadTemplate("vxStats.substitutions")

< ../save_restore.cmd
save_restoreSet_status_prefix("13BMC:")
dbLoadRecords("$(AUTOSAVE)/asApp/Db/save_restoreStatus.db", "P=13BMC:")

# Setup device/driver support addresses, interrupt vectors, etc.

################################################################################
# XPS trajectoryScan records

# Database for trajectory scanning with the XPS
# The required command string is longer than the vxWorks command line, 
# must use malloc and strcpy, strcat. Some of the macros don't apply

str = malloc(500)
strcpy(str, "P=13BMC:,R=traj1,NAXES=6,NELM=2000,NPULSE=2000,PORT=5001")
strcat(str, ",DONPV=13BMC:str:EraseStart,DONV=1,DOFFPV=13BMC:str:StopAll,DOFFV=1")
#dbLoadRecords("$(MOTOR)/motorApp/Db/trajectoryScan.db", str)
################################################################################

################################################################################
# OMS MAXv driver setup parameters:
#     (1)number of cards in array.
#     (2)VME Address Type (16,24,32).
#     (3)Base Address on 4K (0x1000) boundary.
#     (4)interrupt vector (0=disable or  64 - 255).
#     (5)interrupt level (1 - 6).
#     (6)motor task polling rate (min=1Hz,max=60Hz).
MAXvSetup(2, 16, 0x9000, 190, 5, 10)

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
MAXvConfig(0, configServo)
# Second MAXv is steppers
MAXvConfig(1, configStep)
################################################################################

################################################################################
# OMS VME58 driver setup parameters:
#     (1)cards, (2)base address(short, 4k boundary),
#     (3)interrupt vector (0=disable or  64 - 255), (4)interrupt level (1 - 6),
#     (5)motor task polling rate (min=1Hz,max=60Hz)
oms58Setup(5, 0x4000, 190, 5, 10)
################################################################################

################################################################################
# XPS Setup
#drvAsynIPPortConfigure("tcp1","164.54.160.124:5001 tcp", 0, 0, 1)
#asynOctetSetInputEos("tcp1",0,"")
#asynOctetSetOutputEos("tcp1",0,"")
#drvAsynIPPortConfigure("tcp2","164.54.160.131:5001 tcp", 0, 0, 1)
#asynOctetSetInputEos("tcp2",0,"")
#asynOctetSetOutputEos("tcp2",0,"")

# cards (total controllers)
XPSSetup(2)

# card, IP, PORT, number of axes, active poll period (ms), idle poll period (ms)
XPSConfig(0, "164.54.160.124", 5001, 6, 10, 500)
# asyn port, driver name, controller index, max. axes)
drvAsynMotorConfigure("XPS1", "motorXPS", 0, 6)
# card, IP, PORT, number of axes, active poll period (ms), idle poll period (ms)
XPSConfig(1, "164.54.160.131", 5001, 8, 10, 500)
# asyn port, driver name, controller index, max. axes)
drvAsynMotorConfigure("XPS2", "motorXPS", 1, 8)

# card,  axis, groupName.positionerName, stepsPerUnit
XPSConfigAxis(0,0,"GROUP1.PHI",     1000)
XPSConfigAxis(0,1,"GROUP1.KAPPA",   5000)
XPSConfigAxis(0,2,"GROUP1.OMEGA",   5000)
XPSConfigAxis(0,3,"GROUP1.PSI",     4000)
XPSConfigAxis(0,4,"GROUP1.2THETA", 10000)
XPSConfigAxis(0,5,"GROUP1.NU",      4000)

# card,  axis, groupnumber, groupsize,axis in group, group, positioner
XPSConfigAxis(1,0,"GROUP1.Y1_BASE",    10000)
XPSConfigAxis(1,1,"GROUP2.Y2_BASE",    10000)
XPSConfigAxis(1,2,"GROUP3.Y3_BASE",    10000)
XPSConfigAxis(1,3,"GROUP4.TRX_BASE",     200)
XPSConfigAxis(1,4,"GROUP5.THETA-Y_BASE", 200)
XPSConfigAxis(1,5,"GROUP6.X_SAMPLE",    3816)
XPSConfigAxis(1,6,"GROUP7.Y_SAMPLE",    3816)
XPSConfigAxis(1,7,"GROUP8.Z_SAMPLE",    3816)
################################################################################

# dbrestore setup
sr_restore_incomplete_sets_ok = 1
#reboot_restoreDebug=5

# Turn on debugging for the Omega axis
#asynSetTraceMask("XPS1",2,255)
#asynSetTraceIOMask("XPS1",2,2)

iocInit

### Start up the autosave task and tell it what to do.
# The task is actually named "save_restore".
# (See also, 'initHooks' above, which is the means by which the values that
# will be saved by the task we're starting here are going to be restored.
#
# save positions every five seconds
create_monitor_set("auto_positions.req",5,"P=13BMC:")
# save other things every thirty seconds
create_monitor_set("auto_settings.req",30,"P=13BMC:")

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
saveData_Init("saveDataExtraPVs.req", "P=13BMC:")
#saveData_PrintScanInfo("13BMC:scan1")

seq &Keithley2kDMM, "P=13BMC:, Dmm=DMM1, stack=10000"

# Trajectory scanning with XPS
str = malloc(500)
strcpy(str, "P=13BMC:,R=traj1,M1=m33,M2=m34,M3=m35,M4=m36,M5=m37,M6=m38,IPADDR=164.54.160.124,")
strcat(str, "PORT=5001,GROUP=GROUP1,P1=PHI,P2=KAPPA,P3=OMEGA,P4=PSI,P5=2THETA,P6=NU")
#seq(&XPS_trajectoryScan, str)

# Set the NTM fields of the XPS motors to 0 (NO) so they don't get stopped when the motor changes direction due to PID
dbpf("13BMC:m33.NTM","0")
dbpf("13BMC:m34.NTM","0")
dbpf("13BMC:m35.NTM","0")
dbpf("13BMC:m36.NTM","0")
dbpf("13BMC:m37.NTM","0")
dbpf("13BMC:m38.NTM","0")
dbpf("13BMC:m39.NTM","0")
dbpf("13BMC:m40.NTM","0")
dbpf("13BMC:m41.NTM","0")
dbpf("13BMC:m42.NTM","0")
dbpf("13BMC:m43.NTM","0")
dbpf("13BMC:m44.NTM","0")
dbpf("13BMC:m45.NTM","0")
dbpf("13BMC:m46.NTM","0")

# Free memory allocated at top
free(mem)
