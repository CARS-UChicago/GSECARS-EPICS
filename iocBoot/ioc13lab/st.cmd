# vxWorks startup file
< cdCommands

< ../nfsCommandsGSE
loginUserAdd "epics","SzeSebbzRR"

cd topbin
ld < iocCore
ld < seq
ld < CARSLib

# Currently, the only thing we do in initHooks is call reboot_restore(), which
# restores positions and settings saved ~continuously while EPICS is alive.
# See calls to "create_monitor_set()" at the end of this file.  To disable
# autorestore, comment out the following line.
ld < initHooks.o

cd startup
# Load local MPF server
< st_mpfserver_local.cmd
cd topbin
# This IOC talks to a local GPIB server
ld < GpibHideosLocal.o
cd startup

# Initialize remote MPF stuff
tcpMessageRouterClientStart(1,9900,"164.54.160.118",10000,100)

# override address, interrupt vector, etc. information in module_types.h
module_types()

# Set debugging flags
devMM4000debug = 0
drvMM4000debug = 0
gpibIODebug = 0
serialIODebug = 0
mcaRecordDebug = 0
devMcaMpfDebug = 0
mcaAIMServerDebug = 0
aimDebug = 0
devMcaIp330Debug = 0
drvSTR7201Debug = 0
devSTR7201Debug = 0
devSiStrParmDebug = 0
devAiMKSDebug=0
devAiDigitelDebug=0
devAoDAC128VDebug=0
devLiIpUnidigDebug=0
devBiIpUnidigDebug=0
devBoIpUnidigDebug=0
devSerialDebug=0
DevMpfDebug=0
devEpidIp330Debug=0
scalerRecordDebug=0
devScalerSTR7201Debug=0
icbDebug=0
devIcbMpfDebug=0
icbDspServerDebug=0
icbServerDebug=0

# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in this build from CARSApp
dbLoadDatabase("../../dbd/CARSApp.dbd")

# Generic GPIB record
dbLoadRecords ("CARSApp/Db/generic_gpib.db","P=13LAB:,R=gpib1,SIZE=4096", top)

# generic serial port
# Port 1 has Newport LAE500 Laser Autocollimator (and generic serial port)
dbLoadRecords("CARSApp/Db/LAE500.db","P=13LAB:,R=LAE500,C=1,IPSLOT=a,CHAN=1,BAUD=9600,PRTY=None,DBIT=8,SBIT=1", top)
dbLoadRecords("CARSApp/Db/generic_serial.db","P=13LAB:,R=ser2,C=1,IPSLOT=a,CHAN=1,BAUD=9600,PRTY=None,DBIT=8,SBIT=1", top)

# Encoder readout unit
dbLoadRecords("CARSApp/Db/RSF715.db","P=13LAB:,ENCODER=RSF715,C=1,IPSLOT=a,CHAN=3", top)
dbLoadRecords("CARSApp/Db/generic_serial.db","P=13LAB:,R=ser1,C=1,IPSLOT=a,CHAN=3,BAUD=19200,PRTY=None,DBIT=8,SBIT=1", top)

# Keithley Multimeter
dbLoadRecords("CARSApp/Db/Keithley2kDMM_mf.db", "P=13LAB:,Dmm=DMM1,C=1,IPSLOT=a,CHAN=5", top)
dbLoadRecords("CARSApp/Db/Keithley2kDMM_mf.db", "P=13LAB:,Dmm=DMM2,C=1,IPSLOT=a,CHAN=6", top)

# Performance tester - don't load routinely
#dbLoadRecords("CARSApp/Db/perform.db", top)

# SMART detector database
str=malloc(256)
strcpy(str,"P=13LAB:,R=smart1,C=1,IPSLOT=a,CHAN=0,BAUD=9600,")
strcat(str,"FSHUT=UnidigBo0,TRIG=UnidigBo1,SSHUT=UnidigBo2")
dbLoadRecords("CARSApp/Db/smartControl.db",str, top)

# DAC
dbLoadTemplate "DAC.template"

# IP-Unidig binary I/O
dbLoadTemplate "IpUnidig.template"

# Acromag Ip330 ADC
dbLoadTemplate "Ip330_ADC.template"

#PID slow
dbLoadTemplate "pid_slow.template"

#PID fast
dbLoadTemplate "pid_fast.template"
 
### Motors
dbLoadTemplate  "motors.template"

# Experiment description
dbLoadRecords("CARSApp/Db/experiment_info.db","P=13LAB:", top)

# A set of scan parameters for each positioner.  This is a convenience
# for the user.  It can contain an entry for each scannable thing in the
# crate.
dbLoadTemplate "scanParms.template"

# Multichannel analyzer stuff
# AIMConfig(mpfServer, card, ethernet_address, port, maxChans, 
#           maxSignals, maxSequences, ethernetDevice, queueSize)
AIMConfig("AIM1/1", 0x59e, 1, 4000, 1, 1, "dc0", 100)
AIMConfig("AIM1/2", 0x59e, 2, 2048, 8, 1, "dc0", 400)
dbLoadRecords("mcaApp/Db/mca.db", "P=13LAB:,M=aim_adc1,DTYPE=MPF MCA,INP=#C0 S0 @AIM1/1,NCHAN=4000", mca)
dbLoadRecords("mcaApp/Db/mca.db", "P=13LAB:,M=aim_adc2,DTYPE=MPF MCA,INP=#C0 S0 @AIM1/2,NCHAN=2048", mca)
dbLoadRecords("mcaApp/Db/mca.db", "P=13LAB:,M=aim_adc3,DTYPE=MPF MCA,INP=#C0 S2 @AIM1/2,NCHAN=2048", mca)
dbLoadRecords("mcaApp/Db/mca.db", "P=13LAB:,M=aim_adc4,DTYPE=MPF MCA,INP=#C0 S4 @AIM1/2,NCHAN=2048", mca)
dbLoadRecords("mcaApp/Db/mca.db", "P=13LAB:,M=aim_adc5,DTYPE=MPF MCA,INP=#C0 S6 @AIM1/2,NCHAN=2048", mca)

dbLoadRecords("mcaApp/Db/mca.db", "P=13LAB:,M=mip330_1,DTYPE=MPF MCA,NCHAN=2048,INP=#C0 S0 @a-Ip330Sweep", mca)
dbLoadRecords("mcaApp/Db/mca.db", "P=13LAB:,M=mip330_2,DTYPE=MPF MCA,NCHAN=2048,INP=#C0 S1 @a-Ip330Sweep", mca)
dbLoadRecords("mcaApp/Db/mca.db", "P=13LAB:,M=mip330_3,DTYPE=MPF MCA,NCHAN=2048,INP=#C0 S2 @a-Ip330Sweep", mca)
dbLoadRecords("mcaApp/Db/mca.db", "P=13LAB:,M=mip330_4,DTYPE=MPF MCA,NCHAN=2048,INP=#C0 S3 @a-Ip330Sweep", mca)

#icbDspConfig("icbDsp/1", 1, "NI59E:1", 100)
#dbLoadRecords "mcaApp/Db/icbDsp.db", "P=13LAB:,DSP=dsp1,CARD=0,SERVER=icbDsp/1,ADDR=0", mca
picbServer = icbConfig("icb/1", 10, "NI59E:5", 100)
dbLoadRecords "mcaApp/Db/icb_adc.db", "P=13LAB:,ADC=adc1,CARD=0,SERVER=icb/1,ADDR=0", mca
icbAddModule(picbServer, 1, "NI59E:3")
dbLoadRecords "mcaApp/Db/icb_amp.db", "P=13LAB:,AMP=amp1,CARD=0,SERVER=icb/1,ADDR=1", mca
icbAddModule(picbServer, 2, "NI59E:2")
dbLoadRecords "mcaApp/Db/icb_hvps.db", "P=13LAB:,HVPS=hvps1,CARD=0,SERVER=icb/1,ADDR=2, LIMIT=1000", mca
icbTcaConfig("icbTca/1", 1, "NI59E:8", 100)
dbLoadRecords "mcaApp/Db/icb_tca.db", "P=13LAB:,TCA=tca1,MCA=aim_adc2,CARD=0,SERVER=icbTca/1,ADDR=0", mca

# Struck MCS as 32-channel multi-element detector
<Struck32.cmd

### Scalers: Joerger VSC8/16
dbLoadRecords("stdApp/Db/Jscaler.db","P=13LAB:,S=scaler1,C=0", std)

### Scalers: Struck/SIS as simple scaler 
# Don't execute the next 2 lines if Struck8.cmd is loaded above
#STR7201Setup(1,0xA0000000,220,6)
#STR7201Config(0, 16, 100)
dbLoadRecords("mcaApp/Db/STR7201scaler.db","P=13LAB:,S=scaler2,C=0", mca)

### Allstop, alldone
# This database must agree with the motors you've actually loaded.
# Several versions (e.g., all_com_32.db) are in stdApp/Db
dbLoadRecords("stdApp/Db/all_com_8.db","P=13LAB:", std)

### Scan-support software
# crate-resident scan.  This executes 1D, 2D, 3D, and 4D scans, and caches
# 1D data, but it doesn't store anything to disk.  (You need the data catcher
# or the equivalent for that.)  This database is configured to use the
# "alldone" database (above) to figure out when motors have stopped moving
# and it's time to trigger detectors.
dbLoadRecords("stdApp/Db/scan.db","P=13LAB:,MAXPTS1=2000,MAXPTS2=200,MAXPTS3=20,MAXPTS4=10,MAXPTSH=10", std)

# Free-standing user string/number calculations (sCalcout records)
dbLoadRecords("stdApp/Db/userStringCalcs10.db","P=13LAB:", std)

# Free-standing user transforms (transform records)
dbLoadRecords("stdApp/Db/userTransforms10.db","P=13LAB:", std)

# Stanford Research Systems SR570 Current Preamplifier
dbLoadRecords("ipApp/Db/SR570.db", "P=13LAB:,A=A1,C=1,IPSLOT=a,CHAN=7", ip)

# vme test record
dbLoadRecords("stdApp/Db/vme.db", "P=13LAB:,Q=vme1", std)

# Miscellaneous PV's, such as burtResult
dbLoadRecords("stdApp/Db/misc.db","P=13LAB:", std)


# vxWorks statistics
dbLoadRecords("stdApp/Db/VXstats.db","P=13LAB:", std)

HiDEOSGpibLinkConfig(10,0,"GPIB0")

################################################################################
# Setup device/driver support addresses, interrupt vectors, etc.

# OMS VME58 driver setup parameters: 
#     (1)cards, (2)axis per card, (3)base address(short, 4k boundary), 
#     (4)interrupt vector (0=disable or  64 - 255), (5)interrupt level (1 - 6),
#     (6)motor task polling rate (min=1Hz,max=60Hz)
oms58Setup(2, 8, 0x4000, 190, 5, 10)

# Joerger VSC setup parameters: 
#     (1)cards, (2)base address(ext, 256-byte boundary), 
#     (3)interrupt vector (0=disable or  64 - 255)
# Can't use D000000 on PowerPC, change to B0000000
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
create_monitor_set("auto_positions.req",5.0)
# save other things every thirty seconds
create_monitor_set("auto_settings.req",30.0)

# Enable user string calcs and user transforms
dbpf "13LAB:EnableUserTrans.PROC","1"
dbpf "13LAB:EnableUserSCalcs.PROC","1"

seq &Keithley2kDMM, "P=13LAB:, Dmm=DMM1, stack=10000"
seq &Keithley2kDMM, "P=13LAB:, Dmm=DMM2, stack=10000"

# Need to wait 15 seconds before starting this task - TRACK DOWN WHY !!!
#taskDelay(900)
#seq &smartControl, "P=13LAB:,R=smart1,TTH=m1,OMEGA=m1,PHI=m1,KAPPA=m1,SCALER=scaler1,I0=2,stack=10000"


# newport table sequencer
str=malloc(256)
strcpy(str,"P=13LAB:,T=NewTab1:, M1=m33,M2=m34,M3=m35,M4=m36,M5=m37,")
strcat(str,"PM1=pm1,PM2=pm2,PM3=pm3,PM4=pm4,PM5=pm5,PM6=pm6,PM7=pm7,PM8=pm8")
seq &newport_table, str


