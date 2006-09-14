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
devMM4000debug = 0
drvMM4000debug = 0
mcaRecordDebug = 0
drvSTR7201Debug = 0
devSTR7201Debug = 0
save_restoreDebug = 0

# Load database
dbLoadRecords("$(VME)/vmeApp/Db/Jscaler.db","P=13IDC:,S=scaler1,C=0")

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
#dbLoadRecords("$(MCA)/mcaApp/Db/icb_amp.db", "P=13IDC:,AMP=amp1,PORT=icbAmp1")
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

dbLoadRecords("$(SSCAN)/sscanApp/Db/scan.db","P=13IDC:,MAXPTS1=1000,MAXPTS2=500,MAXPTS3=20,MAXPTS4=5,MAXPTSH=10")

## MN: database for scan communication
dbLoadRecords("$(CARS)/CARSApp/Db/scanner.db","P=13IDC:,Q=EDB", top)
## MN: database for ion chamber calculations
dbLoadRecords("$(CARS)/CARSApp/Db/IonChamber.db","P=13IDC:,Q=ION", top)

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

# vxWorks statistics
dbLoadTemplate("vxStats.substitutions")

# MN scanner db for long string args
dbLoadRecords("$(CARS)/CARSApp/Db/scanner.db","P=13IDC:,Q=edb")

< ../save_restore.cmd
save_restoreSet_status_prefix("13IDC:")
dbLoadRecords("$(AUTOSAVE)/asApp/Db/save_restoreStatus.db", "P=13IDC:")

################################################################################
# Setup device/driver support addresses, interrupt vectors, etc.

# OMS VME58 driver setup parameters:
#     (1)cards, (2)base address(short, 4k boundary),
#     (3)interrupt vector (0=disable or  64 - 255), (4)interrupt level (1 - 6),
#     (5)motor task polling rate (min=1Hz,max=60Hz)
oms58Setup(9, 0x4000, 190, 5, 10)

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
create_monitor_set("auto_positions.req",5)
# save other things every thirty seconds
create_monitor_set("auto_settings.req",30)

#mn 16-sep-1999
## seq(&Keithley2kDMM, "P=13IDC:, Dmm=DMM1, stack=10000")

#{MN 15-Feb-00 : energy sequencer for channel-cut crystal
seq(&Energy_CC, "P=13IDC:, IDXX=ID13:, EN=Energy,  MONO=m8, TABLE=m6, DIF=DIF:t1.Y")

#}
#{ for using crystal analyzer
#  commented out MN 08-Aug-98 
#  seq &Analyzer, "P=13IDC:, THETA=m43, DETECTOR=m44, ANAL=ANAL"
#}
#  PVSstart

# Trajectory scanning with GPD
seq(&trajectoryScan, "P=13IDC:, R=traj1, M1=m25,M2=m26,M3=m27,M4=m28,M5=m29,M6=m30,M7=m31,M8=m32,PORT=serial13")
seq(&trajectoryScan, "P=13IDC:, R=traj2, M1=m33,M2=m34,M3=m35,M4=m36,M5=m37,M6=m38,M7=m39,M8=m40,PORT=serial14")

# newport table sequencer
str=malloc(256)
strcpy(str,"P=13IDC:,T=NewTab1:, M1=m34,M2=m33,M3=m35,M4=m36,M5=m37,")
strcat(str,"PM1=pm7,PM2=pm8,PM3=pm9,PM4=pm10,PM5=pm11,PM6=pm12,PM7=pm13,PM8=pm14")
newport_tableDebug = 1
seq(&newport_table, str)

seq(&smartControl, "P=13IDC:,R=smart1,TTH=m29,OMEGA=m27,PHI=m25,KAPPA=m26,SCALER=scaler2,I0=2,stack=10000")

### Start the saveData task.
# saveData_MessagePolicy
# 0: wait forever for space in message queue, then send message
# 1: send message only if queue is not full
# 2: send message only if queue is not full and specified time has passed (SetCptWait()
#    sets this time.)
# 3: if specified time has passed, wait for space in queue, then send message
# else: don't send message
#debug_saveData = 2
#{ MN 16-Dec-2004
problems with scan record, trying to comment outsaveData 
saveData_MessagePolicy = 2
saveData_SetCptWait_ms(100)
saveData_Init("saveDataExtraPVs.req", "P=13IDC:")
saveData_PrintScanInfo("13IDC:scan1")


seq &Keithley2kDMM, "P=13IDC:, Dmm=DMM1"

