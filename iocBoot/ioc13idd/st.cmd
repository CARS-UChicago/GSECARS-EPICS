# vxWorks startup file for 13BMD IOC
< cdCommands
< ../nfsCommandsGSE
###MATT May-28-2002 
loginUserAdd "epics","SzeSebbzRR"

cd topbin
ld < CARSApp.munch

# Increase size of errlog buffer
errlogInit(20000)

# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in this build.
dbLoadDatabase("$(CARS)/dbd/CARSVX.dbd")
CARSVX_registerRecordDeviceDriver(pdbbase)

# This IOC loads the MPF server code locally
cd startup
< st_mpfserver.cmd

# Load database
dbLoadRecords("$(VME)/vmeApp/Db/Jscaler.db","P=13IDD:,S=scaler1,C=0")

# asyn record on each serial port
dbLoadTemplate("asynRecord.template")

dbLoadRecords("$(IP)/ipApp/Db/SR570.db", "P=13IDD:,A=A1,C=0,PORT=serial1")
dbLoadRecords("$(IP)/ipApp/Db/SR570.db", "P=13IDD:,A=A2,C=0,PORT=serial2")
dbLoadRecords("$(IP)/ipApp/Db/Keithley2kDMM_mf.db", "P=13IDD:,Dmm=DMM1,C=0,PORT=serial3")
dbLoadRecords("$(CARS)/CARSApp/Db/generic_serial.db","P=13IDD:,R=ser1,C=0,PORT=serial4")
dbLoadRecords("$(IP)/ipApp/Db/Keithley2kDMM_mf.db", "P=13IDD:,Dmm=DMM3,C=0,PORT=serial5")
dbLoadRecords("$(IP)/ipApp/Db/Keithley2kDMM_mf.db", "P=13IDD:,Dmm=DMM4,C=0,PORT=serial6")
dbLoadRecords("$(IP)/ipApp/Db/SR570.db", "P=13IDD:,A=A3,C=0,PORT=serial7")
dbLoadRecords("$(CARS)/CARSApp/Db/LAE500.db","P=13IDD:,R=LAE500,C=0,PORT=serial8")
dbLoadRecords("$(CARS)/CARSApp/Db/RSF715.db","P=13IDD:,ENCODER=RSF715,C=0,PORT=serial10")
dbLoadTemplate("picoMotors.template")
dbLoadRecords("$(IP)/ipApp/Db/Keithley2kDMM_mf.db", "P=13IDD:,Dmm=DMM5,C=0,PORT=serial12")

# Acromag Ip330 ADC
dbLoadTemplate("Ip330_ADC.template")

# IP-Unidig binary I/O
dbLoadTemplate("IpUnidig.template")

# MAR345 shutter
dbLoadRecords("$(CARS)/CARSApp/Db/MAR345_shutter.db","P=13IDD:,R=MAR345,IN=13IDD:UnidigBi14,OUT=13IDD:UnidigBo11")

# SMART detector database
str=malloc(256)
strcpy(str,"P=13IDD:,R=smart1,C=0,PORT=serial8,")
# Use Bo0 for Bruker shutter, Bo11 for XIA
strcat(str,"FSHUT=UnidigBo11,TRIG=UnidigBo1,SSHUT=UnidigBo2")
dbLoadRecords("$(CCD)/ccdApp/Db/smartControl.db", str)

dbLoadTemplate("motors.template")


# Multichannel analyzer stuff
# AIMConfig(mpfServer, ethernet_address, port, maxChans, 
#           maxSignals, maxSequences, ethernetDevice, queueSize)
AIMConfig("NI3ED/1", 0x3ED, 1, 4000, 1, 1,"dc0", 40)
AIMConfig("NI3ED/2", 0x3ED, 2, 4000, 1, 1,"dc0", 40)
dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=13IDD:,M=aim_adc1,DTYPE=MPF MCA,INP=#C0 S0 @NI3ED/1,NCHAN=4000")
dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=13IDD:,M=aim_mcs1,DTYPE=MPF MCA,INP=#C0 S0 @NI3ED/2,NCHAN=4000")

icbSetup("icb/1", 10, 100)
icbConfig("icb/1", 0, 0x3ed, 5)
dbLoadRecords("$(MCA)/mcaApp/Db/icb_adc.db", "P=13IDD:,ADC=adc1,CARD=0,SERVER=icb/1,ADDR=0")
icbConfig("icb/1", 1, 0x3ed, 3)
dbLoadRecords("$(MCA)/mcaApp/Db/icb_amp.db", "P=13IDD:,AMP=amp1,CARD=0,SERVER=icb/1,ADDR=1")
icbConfig("icb/1", 2, 0x3ed, 2)
dbLoadRecords("$(MCA)/mcaApp/Db/icb_hvps.db", "P=13IDD:,HVPS=hvps1,CARD=0,SERVER=icb/1,ADDR=2, LIMIT=1000")

dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=13IDD:,M=mip330_1,DTYPE=MPF MCA,NCHAN=2048,INP=#C0 S0 @Ip330Sweep1")
dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=13IDD:,M=mip330_2,DTYPE=MPF MCA,NCHAN=2048,INP=#C0 S1 @Ip330Sweep1")
dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=13IDD:,M=mip330_3,DTYPE=MPF MCA,NCHAN=2048,INP=#C0 S2 @Ip330Sweep1")
dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=13IDD:,M=mip330_4,DTYPE=MPF MCA,NCHAN=2048,INP=#C0 S3 @Ip330Sweep1")

### Allstop, alldone
# This database must agree with the motors you've actually loaded.
# Several versions (e.g., all_com_32.db) are in share/stdApp/Db
dbLoadRecords("$(STD)/stdApp/Db/all_com_72.db","P=13IDD:")

# Digital to analog converter
dbLoadTemplate("DigitalToAnalog.template")

##MN 12/05/04 moved up in st.cmd 
### Acromag Ip330 ADC
##dbLoadTemplate("Ip330_ADC.template")

# Laser PID control
dbLoadTemplate("laser_pid.template")

# Simple laser heating database
dbLoadRecords("$(CARS)/CARSApp/Db/laser_heating.db", "P=13IDD:")

# Laser power controller
dbLoadRecords("$(CARS)/CARSApp/Db/lpc.db", "P=13IDD:,L=LPC1_,DAC=DAC1_2,C=0,PORT=serial4")

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

################################################################################
# Setup device/driver support addresses, interrupt vectors, etc.

# OMS VME58 driver setup parameters: 
#     (1)cards, (2)axis per card, (3)base address(short, 4k boundary), 
#     (4)interrupt vector (0=disable or  64 - 255), (5)interrupt level (1 - 6),
#     (6)motor task polling rate (min=1Hz,max=60Hz)
oms58Setup(9, 8, 0x4000, 190, 5, 10)

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
< ../requestFileCommands
# save positions every five seconds
create_monitor_set("auto_positions.req",5)
# save other things every thirty seconds
create_monitor_set("auto_settings.req",30)

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
