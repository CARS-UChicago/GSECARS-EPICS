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

# This IOC loads the MPF server code locally
cd startup
< st_mpfserver.cmd

# Set debugging flags
devMM4000debug = 0
drvMM4000debug = 0
gpibIODebug = 0
serialIODebug = 0
mcaRecordDebug = 0
devMcaMpfDebug = 0
Ip330SweepServerDebug = 0
mcaAIMServerDebug = 0
drvSTR7201Debug = 0
devSTR7201Debug = 0
devSiStrParmDebug = 0
devAoDAC128VDebug = 0
devLiIpUnidigDebug = 0
devBiIpUnidigDebug = 0
devBoIpUnidigDebug = 0
devSerialDebug = 0
save_restoreDebug = 0

# Load database
dbLoadRecords("$(STD)/stdApp/Db/Jscaler.db","P=13IDC:,S=scaler1,C=0")

# First Octal UART for microprobe experiments
dbLoadRecords("$(IP)/ipApp/Db/SR570.db", "P=13IDC:,A=A1,C=0,SERVER=serial1")
dbLoadRecords("$(IP)/ipApp/Db/SR570.db", "P=13IDC:,A=A2,C=0,SERVER=serial2")
dbLoadRecords("$(IP)/ipApp/Db/SR570.db", "P=13IDC:,A=A3,C=0,SERVER=serial3")
dbLoadRecords("$(IP)/ipApp/Db/SR570.db", "P=13IDC:,A=A4,C=0,SERVER=serial4")
dbLoadRecords("$(IP)/ipApp/Db/SR570.db", "P=13IDC:,A=A5,C=0,SERVER=serial5")
##dbLoadRecords("$(IP)/ipApp/Db/SR570.db", "P=13IDC:,A=A6,C=0,SERVER=serial6")

# # Serial port 6 and 7 are IDB bpm amplifiers
dbLoadRecords("$(IP)/ipApp/Db/SR570.db", "P=13IDC:,A=A6,C=0,SERVER=serial14")
dbLoadRecords("$(IP)/ipApp/Db/SR570.db", "P=13IDC:,A=A7,C=0,SERVER=serial15")

dbLoadRecords("$(IP)/ipApp/Db/Keithley2kDMM_mf.db", "P=13IDC:,Dmm=DMM1,C=0,SERVER=serial8")

# Second Octal UART for diffractometer experiments
# Serial ports 1 and 2 are for SR570 current amplifiers
# dbLoadRecords("$(IP)/ipApp/Db/SR570.db", "P=13IDC:,A=A4,C=0,SERVER=serial9")
# dbLoadRecords("$(IP)/ipApp/Db/SR570.db", "P=13IDC:,A=A5,C=0,SERVER=serial10")

# Serial ports 3 and 4 are for the MM4000.  We have both motor record and generic serial records on them
dbLoadRecords("$(CARS)/CARSApp/Db/generic_serial.db","P=13IDC:,R=ser1,C=0,SERVER=serial11")
dbLoadRecords("$(CARS)/CARSApp/Db/generic_serial.db","P=13IDC:,R=ser2,C=0,SERVER=serial12")
# Serial port 5 is for the SMART PC
str=malloc(256)
strcpy(str,"P=13IDC:,R=smart1,C=0,SERVER=serial13,")
strcat(str,"FSHUT=UnidigBo0,TRIG=UnidigBo1,SSHUT=UnidigBo2")
dbLoadRecords("$(CARS)/CARSApp/Db/smartControl.db",str,top)

dbLoadTemplate("motors.template")

# Digital to analog converter
dbLoadTemplate("DAC.template")

# Database for trajectory scanning with the MM4005/GPD
# The required command string is longer than the vxWorks command line, must use malloc and strcpy, strcat
str = malloc(300)
strcpy(str, "P=13IDC:,R=traj1,NAXES=6,NELM=1000,NPULSE=1000,C=0,SERVER=serial11,")
strcat(str, ",DONPV=13IDC:str:EraseStart,DONV=1,DOFFPV=13IDC:str:StopAll,DOFFV=1")
dbLoadRecords("$(CARS)/CARSApp/Db/trajectoryScan.db", str, top)
strcpy(str, "P=13IDC:,R=traj2,NAXES=8,NELM=1000,NPULSE=1000,C=0,SERVER=serial12,")
strcat(str, ",DONPV=13IDC:str:EraseStart,DONV=1,DOFFPV=13IDC:str:StopAll,DOFFV=1")
strcat(str, ",M1=Y1,M2=Y2,M3=Y3,M4=Rotation AY,M5=X translation,M6=Sample X,M7=Sample Y,M8=Sample Z")
dbLoadRecords("$(CARS)/CARSApp/Db/trajectoryScan.db", str, top)

# Multichannel analyzer stuff
### AIMConfig(serverName, ethernet_address, port, maxChans, maxSignals,
###           maxSequences, ethernetDevice, queueSize)
AIMConfig("NI6E6/1", 0x6E6, 1, 2048, 1, 1, "dc0", 40)
AIMConfig("NI6E6/2", 0x6E6, 2, 2048, 4, 1, "dc0", 40)
dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=13IDC:,M=aim_adc1,DTYPE=MPF MCA,INP=#C0 S0 @NI6E6/1,NCHAN=2048")
dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=13IDC:,M=aim_mcs1,DTYPE=MPF MCA,INP=#C0 S0 @NI6E6/2,NCHAN=2048")
icbSetup("icb/1", 10, 100)
icbConfig("icb/1", 0, 0x6e6, 5)
dbLoadRecords("$(MCA)/mcaApp/Db/icb_adc.db", "P=13IDC:,ADC=adc1,CARD=0,SERVER=icb/1,ADDR=0")
# Matt 2/24/04  commented out to avoid "Can't communicate" messages (not
#        using AMP or HVPS anyway)
# icbConfig("icb/1", 1, 0x6e6, 3)
# dbLoadRecords("$(MCA)/mcaApp/Db/icb_amp.db", "P=13IDC:,AMP=amp1,CARD=0,SERVER=icb/1,ADDR=1")
# icbConfig("icb/1", 2, 0x6e6, 2)
# dbLoadRecords("$(MCA)/mcaApp/Db/icb_hvps.db", "P=13IDC:,HVPS=hvps1,CARD=0,SERVER=icb/1,ADDR=2, LIMIT=1000")
 
# Struck MCS as 8-channel multi-element detector
<Struck8.cmd

### Scalers: Struck/SIS as simple scaler 
# Don't execute the next 2 lines if Struck8.cmd is loaded above
#STR7201Setup(1,0xA0000000,220,6)
#STR7201Config(0, 16, 100)
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

dbLoadRecords("$(STD)/stdApp/Db/scan.db","P=13IDC:,MAXPTS1=1000,MAXPTS2=500,MAXPTS3=20,MAXPTS4=5,MAXPTSH=10")

## MN: scanner database for scan communication
dbLoadRecords("$(CARS)/CARSApp/Db/scanner.db","P=13IDC:,Q=EDB", top)

# A set of scan parameters for each positioner.  This is a convenience
# for the user.  It can contain an entry for each scannable thing in the
# crate.
dbLoadTemplate("scanParms.template")

# IP-Unidig binary I/O
dbLoadTemplate("IpUnidig.template")

# Acromag Ip330 ADC
dbLoadTemplate("Ip330_ADC.template")

dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=13IDC:,M=mip330_1,DTYPE=MPF MCA,NCHAN=2048,INP=#C0 S0 @Ip330Sweep1")
dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=13IDC:,M=mip330_2,DTYPE=MPF MCA,NCHAN=2048,INP=#C0 S1 @Ip330Sweep1")
dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=13IDC:,M=mip330_3,DTYPE=MPF MCA,NCHAN=2048,INP=#C0 S2 @Ip330Sweep1")
dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=13IDC:,M=mip330_4,DTYPE=MPF MCA,NCHAN=2048,INP=#C0 S3 @Ip330Sweep1")
# added 2-05 for split ion chmaber
dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=13IDC:,M=mip330_5,DTYPE=MPF MCA,NCHAN=2048,INP=#C0 S4 @Ip330Sweep1")
dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=13IDC:,M=mip330_6,DTYPE=MPF MCA,NCHAN=2048,INP=#C0 S5 @Ip330Sweep1")

# Miscellaneous PV's, such as burtResult
dbLoadRecords("$(STD)/stdApp/Db/misc.db","P=13IDC:")

# Experiment description
dbLoadRecords("$(CARS)/CARSApp/Db/experiment_info.db","P=13IDC:")

# vxWorks statistics
#dbLoadRecords("$(STD)/stdApp/Db/VXstats.db","P=13IDC:")

# MN scanner db for long string args
dbLoadRecords("$(CARS)/CARSApp/Db/scanner.db","P=13IDC:,Q=edb")


################################################################################
# Setup device/driver support addresses, interrupt vectors, etc.


# OMS VME58 driver setup parameters: 
#     (1)cards, (2)axis per card, (3)base address(short, 4k boundary), 
#     (4)interrupt vector (0=disable or  64 - 255), (5)interrupt level (1 - 6),
#     (6)motor task polling rate (min=1Hz,max=60Hz)
oms58Setup(9, 8, 0x4000, 190, 5, 10)

# MM4000 driver setup parameters: 
#     (1) maximum # of controllers, 
#     (2) maximum # axis per controller
#     (3) motor task polling rate (min=1Hz, max=60Hz)
MM4000Setup(2, 8, 10)

# MM4000 driver configuration parameters: 
#     (1) controller
#     (2) port type: 0=GPIB, 1=RS232, 
#     (3) GPIB link or MPF ID
#     (4) MPF server
# GPIB example:
#   MM4000Config(0,0,10,2)  #Link 10, address 2
# RS-232 example:
#   MM4000Config(0, 1, 0, "serial1")  MPF card 1, serial 1
MM4000Config(0, 1, 0, "serial11")
MM4000Config(1, 1, 0, "serial12")

# Set a delay in reading back MM4000 motors when they complete moves. 
# This is a temporary fix
# Not doing step scanning, set to 0. Use 0.5 when using step scanning
drvMM4000ReadbackDelay = 0.5

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
< ../requestFileCommands
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
seq(&trajectoryScan, "P=13IDC:, R=traj1, M1=m25,M2=m26,M3=m27,M4=m28,M5=m29,M6=m30,M7=m31,M8=m32")
seq(&trajectoryScan, "P=13IDC:, R=traj2, M1=m33,M2=m34,M3=m35,M4=m36,M5=m37,M6=m38,M7=m39,M8=m40")

# newport table sequencer
str=malloc(256)
strcpy(str,"P=13IDC:,T=NewTab1:, M1=m34,M2=m33,M3=m35,M4=m36,M5=m37,")
strcat(str,"PM1=pm7,PM2=pm8,PM3=pm9,PM4=pm10,PM5=pm11,PM6=pm12,PM7=pm13,PM8=pm14")
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
saveData_MessagePolicy = 2
saveData_SetCptWait_ms(100)
# COMMENT THIS OUT FOR NOW, IT MAY BE CAUSING THE MEMORY LEAK?
saveData_Init("saveDataExtraPVs.req", "P=13IDC:")
#saveData_PrintScanInfo("13IDC:scan1")


