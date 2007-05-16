# vxWorks startup file for 13BMD IOC
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

# Load database
dbLoadRecords("$(STD)/stdApp/Db/scaler.db", "P=13IDD:,S=scaler1,OUT=#C0 S0 @,FREQ=1e7,DTYP=Joerger VSC8/16")

# MAR345 shutter
dbLoadRecords("$(CARS)/CARSApp/Db/MAR345_shutter.db","P=13IDD:,R=MAR345,IN=13IDD:Unidig1Bi14,OUT=13IDD:Unidig1Bo11")

dbLoadTemplate("motors.template")


# Multichannel analyzer stuff
# AIMConfig(portName, ethernet_address, portNumber(1 or 2), maxChans,
#           maxSignals, maxSequences, ethernetDevice)
AIMConfig("NI3ED/1", 0x3ED, 1, 4000, 1, 1,"dc0")
AIMConfig("NI3ED/2", 0x3ED, 2, 4000, 1, 1,"dc0")
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
icbConfig("icbAdc1", 0x3ed, 5, 0)
dbLoadRecords("$(MCA)/mcaApp/Db/icb_adc.db", "P=13IDD:,ADC=adc1,PORT=icbAdc1")
icbConfig("icbAmp1", 0x3ed, 3, 1)
dbLoadRecords("$(MCA)/mcaApp/Db/icb_amp.db", "P=13IDD:,AMP=amp1,PORT=icbAmp1")
icbConfig("icbHvps1", 0x3ed, 2, 2)
dbLoadRecords("$(MCA)/mcaApp/Db/icb_hvps.db", "P=13IDD:,HVPS=hvps1,PORT=icbHvps1,LIMIT=1000")

dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=13IDD:,M=mip330_1,DTYP=asynMCA,NCHAN=2048,INP=@asyn(Ip330Sweep1 0)")
dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=13IDD:,M=mip330_2,DTYP=asynMCA,NCHAN=2048,INP=@asyn(Ip330Sweep1 1)")
dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=13IDD:,M=mip330_3,DTYP=asynMCA,NCHAN=2048,INP=@asyn(Ip330Sweep1 2)")
dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=13IDD:,M=mip330_4,DTYP=asynMCA,NCHAN=2048,INP=@asyn(Ip330Sweep1 3)")

### Allstop, alldone
# This database must agree with the motors you've actually loaded.
# Several versions (e.g., all_com_32.db) are in share/stdApp/Db
dbLoadRecords("$(STD)/stdApp/Db/all_com_72.db","P=13IDD:")

# Laser PID control
dbLoadTemplate("laser_pid.template")

# Simple laser heating database
dbLoadRecords("$(CARS)/CARSApp/Db/laser_heating.db", "P=13IDD:")

# LVP furnace controls
dbLoadTemplate("LVP_furnace_control.template")

# LVP pressure control
dbLoadTemplate("LVP_pressure_control.template")

#MN May-29-2002
# LVP Theta (temperature ramping) controller
dbLoadRecords("$(CARS)/CARSApp/Db/RampScan.db","P=13IDD:,R=Theta1_,DRV=LVP:PID1.VAL,RBV=LVP_furnace_calcs.E")

# Experiment description
dbLoadRecords("$(CARS)/CARSApp/Db/experiment_info.db","P=13IDD:")

### Scan-support software
# crate-resident scan.  This executes 1D, 2D, 3D, and 4D scans, and caches
# 1D data, but it doesn't store anything to disk.  (You need the data catcher
# or the equivalent for that.)  This database is configured to use the
# "alldone" database (above) to figure out when motors have stopped moving
# and it's time to trigger detectors.
dbLoadRecords("$(SSCAN)/sscanApp/Db/scan.db","P=13IDD:,MAXPTS1=2000,MAXPTS2=200,MAXPTS3=20,MAXPTS4=10,MAXPTSH=10")

# A set of scan parameters for each positioner.  This is a convenience
# for the user.  It can contain an entry for each scannable thing in the
# crate.
dbLoadTemplate("scanParms.template")

# Miscellaneous PV's, such as burtResult
dbLoadRecords("$(STD)/stdApp/Db/misc.db","P=13IDD:", std)
dbLoadRecords("$(CALC)/calcApp/Db/userTransforms10.db", "P=13IDD:", std)

# vxWorks statistics
dbLoadTemplate("vxStats.substitutions")

< ../save_restore.cmd
save_restoreSet_status_prefix("13IDD:")
dbLoadRecords("$(AUTOSAVE)/asApp/Db/save_restoreStatus.db", "P=13IDD:")

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
seq &Keithley2kDMM, "P=13IDD:, Dmm=DMM3, stack=10000"
seq &Keithley2kDMM, "P=13IDD:, Dmm=DMM4, stack=10000"

seq &IDD_LVP_Detector, "P=13IDD:,PMR=pm9,PMT=pm10,PMC=pm11,X=m33,Y=m34,Z=m35,TX=m38,TZ=m39"

seq &smartControl, "P=13IDD:,R=smart1,TTH=m31,OMEGA=m31,PHI=m31,KAPPA=m31,SCALER=scaler1,I0=6,stack=10000"

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
