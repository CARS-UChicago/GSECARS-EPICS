# vxWorks startup file

< cdCommands

< ../nfsCommandsGSE

cd topbin
ld < CARSApp.munch
# ld < ../../../motor/bin/vxWorks-ppc604/XPSGathering.munch
cd startup

# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in this build from CARSApp
dbLoadDatabase("$(CARS)/dbd/CARSVX.dbd")
CARSVX_registerRecordDeviceDriver(pdbbase)

# Set debugging flags
mcaRecordDebug = 0
aimDebug = 0
scalerRecordDebug=0
icbDebug=0
motorRecordDebug = 0

< industryPack.cmd
< serial.cmd

### Motors
dbLoadTemplate  "motors.template"

# SIS3801 MCS
iocsh "SIS3801_8.cmd"

# CCD synchronization for tomo.exe Visual Basic program
dbLoadRecords("$(CARS)/CARSApp/Db/CCD.db", "P=13BMC:,C=CCD1")
# Tomography data collection
dbLoadRecords("$(CARS)/CARSApp/Db/TomoCollect.template", "P=13BMC:,R=TC:")

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

### Scan-support software
# crate-resident scan.  This executes 1D, 2D, 3D, and 4D scans, and caches
# 1D data, but it doesn't store anything to disk.  (You need the data catcher
# or the equivalent for that.)  This database is configured to use the
# "alldone" database (above) to figure out when motors have stopped moving
# and it's time to trigger detectors.
dbLoadRecords("$(SSCAN)/sscanApp/Db/scan.db","P=13BMC:,MAXPTS1=2000,MAXPTS2=1000,MAXPTS3=10,MAXPTS4=10,MAXPTSH=10")

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

#str = malloc(500)
#strcpy(str, "P=13BMC:,R=traj1,NAXES=6,NELM=2000,NPULSE=2000,PORT=5001")
#strcat(str, ",DONPV=13BMC:str:EraseStart,DONV=1,DOFFPV=13BMC:str:StopAll,DOFFV=1")
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

# Auto-shutter logic
dbLoadTemplate("auto_shutter.substitutions")

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

# For SISXX MCS
seq(&SIS38XX_SNL, "P=13BMC:SIS1:, R=mca, NUM_SIGNALS=8, FIELD=READ")

# Initialize the motorUtil software
motorUtilInit("13BMC:")

# Enable UserstringCALs
dbpf("13BMC:userStringCalcEnable.VAL","Enable")


