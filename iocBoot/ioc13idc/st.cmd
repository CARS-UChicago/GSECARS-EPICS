# vxWorks startup file
< cdCommands
< ../nfsCommandsGSE

cd topbin
ld < iocCore
ld < seq
ld < CARSLib

# This IOC loads the MPF server code locally
cd startup
< st_mpfserver.cmd
cd topbin
# This IOC talks to a local GPIB server
ld < GpibHideosLocal.o
# Currently, the only thing we do in initHooks is call reboot_restore(), which
# restores positions and settings saved ~continuously while EPICS is alive.
# See calls to "create_monitor_set()" at the end of this file.  To disable
# autorestore, comment out the following line.
ld < initHooks.o

cd startup

# HiDEOSGpibLinkConfig(10,1,"GPIB0")


# override address, interrupt vector, etc. information in module_types.h
module_types()

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

# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in this build from CARSApp
dbLoadDatabase("../../dbd/CARSApp.dbd")

# Load database
dbLoadRecords  "stdApp/Db/Jscaler.db","P=13IDC:,S=scaler1,C=0",std

# First Octal UART for microprobe experiments
dbLoadRecords  "ipApp/Db/SR570.db", "P=13IDC:,A=A1,C=0,IPSLOT=a,CHAN=0",ip
dbLoadRecords  "ipApp/Db/SR570.db", "P=13IDC:,A=A2,C=0,IPSLOT=a,CHAN=1",ip
dbLoadRecords  "ipApp/Db/SR570.db", "P=13IDC:,A=A3,C=0,IPSLOT=a,CHAN=7",ip
dbLoadRecords  "ipApp/Db/Keithley2kDMM_mf.db", "P=13IDC:,Dmm=DMM1,C=0,IPSLOT=a,CHAN=5", ip

# Second Octal UART for diffractometer experiments
# Serial ports 0 and 1 are for SR570 current amplifiers
dbLoadRecords  "ipApp/Db/SR570.db", "P=13IDC:,A=A4,C=0,IPSLOT=b,CHAN=0",ip
dbLoadRecords  "ipApp/Db/SR570.db", "P=13IDC:,A=A5,C=0,IPSLOT=b,CHAN=1",ip
# Serial ports 2 and 3 are for the MM4000.  We have both motor record and generic serial records on them
dbLoadRecords  "CARSApp/Db/generic_serial.db","P=13IDC:,R=ser1,C=0,IPSLOT=b,CHAN=2,BAUD=38400,PRTY=None,DBIT=8,SBIT=1", top
dbLoadRecords  "CARSApp/Db/generic_serial.db","P=13IDC:,R=ser2,C=0,IPSLOT=b,CHAN=3,BAUD=38400,PRTY=None,DBIT=8,SBIT=1", top
# Serial port 4 is for the SMART PC
str=malloc(256)
strcpy(str,"P=13IDC:,R=smart1,C=0,IPSLOT=b,CHAN=4,BAUD=9600,")
strcat(str,"FSHUT=UnidigBo0,TRIG=UnidigBo1,SSHUT=UnidigBo2")
dbLoadRecords("CARSApp/Db/smartControl.db",str,top)
# Serial port 5 and 6 are IDB bpm amplifiers
dbLoadRecords  "ipApp/Db/SR570.db", "P=13IDC:,A=A6,C=0,IPSLOT=b,CHAN=5",ip
dbLoadRecords  "ipApp/Db/SR570.db", "P=13IDC:,A=A7,C=0,IPSLOT=b,CHAN=6",ip
#----

dbLoadTemplate "motors.template"

# Digital to analog converter
dbLoadTemplate "DAC.template"

# Database for trajectory scanning with the MM4005/GPD
# The required command string is longer than the vxWorks command line, must use malloc and strcpy, strcat
str = malloc(300)
strcpy(str, "P=13IDC:,R=traj1,NAXES=6,NELM=1000,NPULSE=1000,C=0,IPSLOT=b,CHAN=2,BAUD=38400")
strcat(str, ",DONPV=13IDC:str:EraseStart,DONV=1,DOFFPV=13IDC:str:StopAll,DOFFV=1")
dbLoadRecords("CARSApp/Db/trajectoryScan.db", str, top)
strcpy(str, "P=13IDC:,R=traj2,NAXES=8,NELM=1000,NPULSE=1000,C=0,IPSLOT=b,CHAN=3,BAUD=38400")
strcat(str, ",DONPV=13IDC:str:EraseStart,DONV=1,DOFFPV=13IDC:str:StopAll,DOFFV=1")
strcat(str, ",M1=Y1,M2=Y2,M3=Y3,M4=Rotation AY,M5=X translation,M6=Sample X,M7=Sample Y,M8=Sample Z")
dbLoadRecords("CARSApp/Db/trajectoryScan.db", str, top)

# Multichannel analyzer stuff
### AIMConfig(serverName, ethernet_address, port, maxChans, maxSignals,
###           maxSequences, ethernetDevice, queueSize)
AIMConfig("NI6E6/1", 0x6E6, 1, 2048, 1, 1, "dc0", 40)
AIMConfig("NI6E6/2", 0x6E6, 2, 2048, 4, 1, "dc0", 40)
dbLoadRecords("mcaApp/Db/mca.db", "P=13IDC:,M=aim_adc1,DTYPE=MPF MCA,INP=#C0 S0 @NI6E6/1,NCHAN=2048", mca)
dbLoadRecords("mcaApp/Db/mca.db", "P=13IDC:,M=aim_mcs1,DTYPE=MPF MCA,INP=#C0 S0 @NI6E6/2,NCHAN=2048", mca)
# dbLoadRecords "mcaApp/Db/icb_amp.db", "P=13IDC:,AMP=amp1,ICB=NI6E6:3", mca
# dbLoadRecords "mcaApp/Db/icb_adc.db", "P=13IDC:,ADC=adc1,ICB=NI6E6:5", mca
# dbLoadRecords "mcaApp/Db/icb_hvps.db","P=13IDC:,HVPS=hvps1,ICB=NI6E6:2", mca

# T^2 added below 11-01 to config the ADC
picbServer = icbConfig("icb/1", 10, "NI6E6:5", 100)
dbLoadRecords "mcaApp/Db/icb_adc.db", "P=13IDC:,ADC=adc1,CARD=0,SERVER=icb/1,ADDR=0", mca

# Struck MCS as 8-channel multi-element detector
<Struck8.cmd

### Scalers: Struck/SIS as simple scaler 
# Don't execute the next 2 lines if Struck8.cmd is loaded above
#STR7201Setup(1,0xA0000000,220,6)
#STR7201Config(0, 16, 100)
dbLoadRecords("mcaApp/Db/STR7201scaler.db","P=13IDC:,S=scaler2,C=0", mca)


### Allstop, alldone
# This database must agree with the motors you've actually loaded.
# Several versions (e.g., all_com_32.db) are in stdApp/Db
dbLoadRecords("stdApp/Db/all_com_56.db","P=13IDC:", std)

### Scan-support software
# crate-resident scan.  This executes 1D, 2D, 3D, and 4D scans, and caches
# 1D data, but it doesn't store anything to disk.  (You need the data catcher
# or the equivalent for that.)  This database is configured to use the
# "alldone" database (above) to figure out when motors have stopped moving
# and it's time to trigger detectors.

dbLoadRecords("stdApp/Db/scan.db","P=13IDC:,MAXPTS1=1000,MAXPTS2=500,MAXPTS3=20,MAXPTS4=5,MAXPTSH=10", std)

## MN: scanner database for scan communication
dbLoadRecords("CARSApp/Db/scanner.db","P=13IDC:,Q=EDB", top)

# A set of scan parameters for each positioner.  This is a convenience
# for the user.  It can contain an entry for each scannable thing in the
# crate.
dbLoadTemplate "scanParms.template"

# IP-Unidig binary I/O
dbLoadTemplate "IpUnidig.template"

# Acromag Ip330 ADC
dbLoadTemplate "Ip330_ADC.substitutions"

dbLoadRecords("mcaApp/Db/mca.db", "P=13IDC:,M=mip330_1,DTYPE=MPF MCA,NCHAN=2048,INP=#C0 S0 @c-Ip330Sweep", mca)
dbLoadRecords("mcaApp/Db/mca.db", "P=13IDC:,M=mip330_2,DTYPE=MPF MCA,NCHAN=2048,INP=#C0 S1 @c-Ip330Sweep", mca)
dbLoadRecords("mcaApp/Db/mca.db", "P=13IDC:,M=mip330_3,DTYPE=MPF MCA,NCHAN=2048,INP=#C0 S2 @c-Ip330Sweep", mca)
dbLoadRecords("mcaApp/Db/mca.db", "P=13IDC:,M=mip330_4,DTYPE=MPF MCA,NCHAN=2048,INP=#C0 S3 @c-Ip330Sweep", mca)
# added 2-05 for split ion chmaber
dbLoadRecords("mcaApp/Db/mca.db", "P=13IDC:,M=mip330_5,DTYPE=MPF MCA,NCHAN=2048,INP=#C0 S4 @c-Ip330Sweep", mca)
dbLoadRecords("mcaApp/Db/mca.db", "P=13IDC:,M=mip330_6,DTYPE=MPF MCA,NCHAN=2048,INP=#C0 S5 @c-Ip330Sweep", mca)

# Miscellaneous PV's, such as burtResult
dbLoadRecords("stdApp/Db/misc.db","P=13IDC:", std)

# Experiment description
dbLoadRecords("CARSApp/Db/experiment_info.db","P=13IDC:", top)

# vxWorks statistics
dbLoadRecords("stdApp/Db/VXstats.db","P=13IDC:", std)

# MN scanner db for long string args
dbLoadRecords("CARSApp/Db/scanner.db","P=13IDC:,Q=edb", top)


################################################################################
# Setup device/driver support addresses, interrupt vectors, etc.


# OMS VME58 driver setup parameters: 
#     (1)cards, (2)axis per card, (3)base address(short, 4k boundary), 
#     (4)interrupt vector (0=disable or  64 - 255), (5)interrupt level (1 - 6),
#     (6)motor task polling rate (min=1Hz,max=60Hz)
oms58Setup(7, 8, 0x4000, 190, 5, 10)

# MM4000 driver setup parameters: 
#     (1) maximum # of controllers, 
#     (2) maximum # axis per controller
#     (3) motor task polling rate (min=1Hz, max=60Hz)
MM4000Setup(2, 8, 10)

# MM4000 driver configuration parameters: 
#     (1) controller
#     (2) port type: 0=GPIB, 1=RS232, 
#     (3) GPIB link or Hideos card
#     (4) GPIB address or Hideos task
# GPIB example:
#   MM4000Config(0,0,10,2)  #Link 10, address 2
# RS-232 example:
#   MM4000Config(0, 1, 0, "a-Serial[0]")  Hideos card 1, port 0 on IP slot A.
MM4000Config(0, 1, 0, "b-Serial[2]")
MM4000Config(1, 1, 0, "b-Serial[3]")

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

# Wait 10 seconds so iocInit debugging output is not garbled
#  with other messages and to allow MPF servers to start
taskDelay 600

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
seq &Keithley2kDMM, "P=13IDC:, Dmm=DMM1, stack=10000"

#{MN 15-Feb-00 : energy sequencer
seq &Energy_CC, "P=13IDC:, IDXX=ID13:, EN=Energy,  MONO=m8, TABLE=m6, DIF=DIF:t1.Y"

# seq &Energy, "ID=ID13:, E=13IDC:E,  MONO=13IDA:m17, EXPTAB_Z=13IDC:m6, XTAL2=13IDA:MON:" 

#}
#{ for using crystal analyzer
#  commented out MN 08-Aug-98 
#  seq &Analyzer, "P=13IDC:, THETA=m43, DETECTOR=m44, ANAL=ANAL"
#}
#  PVSstart

# Trajectory scanning with GPD
seq &trajectoryScan, "P=13IDC:, R=traj1, M1=m25,M2=m26,M3=m27,M4=m28,M5=m29,M6=m30,M7=m31,M8=m32"
seq &trajectoryScan, "P=13IDC:, R=traj2, M1=m33,M2=m34,M3=m35,M4=m36,M5=m37,M6=m38,M7=m39,M8=m40"

seq &smartControl, "P=13IDC:,R=smart1,TTH=m29,OMEGA=m27,PHI=m25,KAPPA=m26,SCALER=scaler2,I0=2,stack=10000"

# newport table sequencer
str=malloc(256)
strcpy(str,"P=13IDC:,T=NewTab1:, M1=m34,M2=m33,M3=m35,M4=m36,M5=m37,")
strcat(str,"PM1=pm7,PM2=pm8,PM3=pm9,PM4=pm10,PM5=pm11,PM6=pm12,PM7=pm13,PM8=pm14")
seq &newport_table, str

