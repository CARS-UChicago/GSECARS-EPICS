# vxWorks startup file
mem = malloc(1024*1024*96)

< cdCommands

< ../nfsCommandsGSE

cd topbin
# ld < CARS167.munch
ld < CARSApp.munch
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

< industryPack.cmd
< serial.cmd

### Motors
dbLoadTemplate  "motors.template"

# Struck MCS as 8-channel multi-element detector
<Struck8.cmd

### Scalers: Struck/SIS as simple scaler
# Don't execute the next 2 lines if Struck8.cmd is loaded above
#STR7201Setup(1,0xA0000000,220,6)
#STR7201Config(0, 16, 100)
dbLoadRecords("$(MCA)/mcaApp/Db/STR7201scaler.db","P=13BMC:,S=scaler1,C=0")

# Multichannel analyzer stuff
# Multichannel analyzer stuff
# AIMConfig(portName, ethernet_address, portNumber(1 or 2), maxChans,
#           maxSignals, maxSequences, ethernetDevice)
#AIMConfig("AIM1/1", 0x6E6, 1, 2048, 1, 1, "dc0")
#dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=13BMC:,M=aim_adc1,DTYP=asynMCA,INP=@asyn(AIM1/1),NCHAN=2048")
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
#icbConfig("icbAdc1", 0x6e6, 5, 0)
#dbLoadRecords("$(MCA)/mcaApp/Db/icb_adc.db", "P=13BMC:,ADC=adc1,PORT=icbAdc1")

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

################################################################################
# Setup device/driver support addresses, interrupt vectors, etc.

# OMS VME58 driver setup parameters: 
#     (1)cards, (2)axis per card, (3)base address(short, 4k boundary), 
#     (4)interrupt vector (0=disable or  64 - 255), (5)interrupt level (1 - 6),
#     (6)motor task polling rate (min=1Hz,max=60Hz)
oms58Setup(4, 8, 0x4000, 190, 5, 10)

# Newport XPS configuration
# XPSC8Setup(cards, scan rate)
#XPSC8Setup(1, 60)

# XPSC8Config(card, IP, PORT, number of axes)
#XPSC8Config(0,"164.54.160.124",5001,6)
#XPSC8Config(1,"164.54.160.131",5001,6)

# XPSC8NameConfig(card,  axis, group, positioner)
#XPSC8NameConfig(0,0,"GROUP1","GROUP1.PHI")
#XPSC8NameConfig(0,1,"GROUP2","GROUP2.KAPPA")
#XPSC8NameConfig(0,2,"GROUP3","GROUP3.OMEGA")
#XPSC8NameConfig(0,3,"GROUP4","GROUP4.PSI")
#XPSC8NameConfig(0,4,"GROUP5","GROUP5.2THETA")
#XPSC8NameConfig(0,5,"GROUP6","GROUP6.NU")

# Set the debug variables which are now available to the shell
#motorRecordDebug = 0
#devXPSC8Debug = 0
#drvXPSC8Debug = 0

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
create_monitor_set("auto_positions.req",5)
# save other things every thirty seconds
create_monitor_set("auto_settings.req",30)

seq &Keithley2kDMM, "P=13BMC:, Dmm=DMM1, stack=10000"

free(mem)
