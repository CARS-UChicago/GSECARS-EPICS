# Allocate 96MB of memory so we load everything else into low memory
mem = malloc(1024*1024*96)

# vxWorks startup file
< cdCommands

< ../nfsCommandsGSE
loginUserAdd "epics","SzeSebbzRR"

cd topbin
ld < iocCore
ld < seq
ld < CARSLib

# Increase size of buffer for error logging from default 1256 
errlogInit(5000)

# Currently, the only thing we do in initHooks is call reboot_restore(), which
# restores positions and settings saved ~continuously while EPICS is alive.
# See calls to "create_monitor_set()" at the end of this file.  To disable
# autorestore, comment out the following line.
ld < initHooks.o

# Set debugging flags
save_restoreDebug=0
devMM4000debug = 0
devMCB4BDebug=1
drvMCB4BDebug=1
drvMM4000debug = 0
gpibIODebug = 0
serialIODebug = 0
mcaRecordDebug = 0
devMcaMpfDebug = 0
mcaAIMServerDebug = 0
aimDebug = 0
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
devEpidMpfDebug=0
scalerRecordDebug=0
devScalerSTR7201Debug=0
icbDebug=0
devIcbMpfDebug=0
icbDspServerDebug=0
icbServerDebug=0

cd startup
# Load local MPF server
< st_mpfserver.cmd
cd topbin
# This IOC talks to a local GPIB server
ld < GpibHideosLocal.o
cd startup

# Debug serial port
#serialPortSniff("UART[6]",1000)

# Initialize remote MPF stuff
# tcpMessageRouterClientStart(1,9900,"164.54.160.118",10000,100)

# override address, interrupt vector, etc. information in module_types.h
module_types()

# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in this build from CARSApp
dbLoadDatabase("../../dbd/CARSApp.dbd")

# Generic GPIB record
dbLoadRecords ("CARSApp/Db/generic_gpib.db","P=13LAB:,R=gpib1,SIZE=4096", top)

# Channel 0 is for SMART
# SMART detector database
#str=malloc(256)
#strcpy(str,"P=13LAB:,R=smart1,C=0,IPSLOT=a,CHAN=0,BAUD=9600,")
#strcat(str,"FSHUT=UnidigBo0,TRIG=UnidigBo1,SSHUT=UnidigBo2")
#dbLoadRecords("CARSApp/Db/smartControl.db",str, top)

# Port 1 has Newport LAE500 Laser Autocollimator (and generic serial port)
dbLoadRecords("CARSApp/Db/LAE500.db","P=13LAB:,R=LAE500,C=0,IPSLOT=a,CHAN=1,BAUD=9600,PRTY=None,DBIT=8,SBIT=1", top)
dbLoadRecords("CARSApp/Db/generic_serial.db","P=13LAB:,R=ser2,C=0,IPSLOT=a,CHAN=1,BAUD=9600,PRTY=None,DBIT=8,SBIT=1", top)

# Port 3 Encoder readout unit
#dbLoadRecords("CARSApp/Db/RSF715.db","P=13LAB:,ENCODER=RSF715,C=0,IPSLOT=a,CHAN=3", top)
#dbLoadRecords("CARSApp/Db/generic_serial.db","P=13LAB:,R=ser1,C=0,IPSLOT=a,CHAN=3,BAUD=19200,PRTY=None,DBIT=8,SBIT=1", top)

# Port 3 MCB4B motor controller
dbLoadRecords("CARSApp/Db/generic_serial.db","P=13LAB:,R=ser1,C=0,IPSLOT=a,CHAN=3,BAUD=19200,PRTY=None,DBIT=8,SBIT=1", top)

# Ports 4, 5 Keithley Multimeter
dbLoadRecords("ipApp/Db/Keithley2kDMM_mf.db", "P=13LAB:,Dmm=DMM1,C=0,IPSLOT=a,CHAN=4", ip)
dbLoadRecords("ipApp/Db/Keithley2kDMM_mf.db", "P=13LAB:,Dmm=DMM2,C=0,IPSLOT=a,CHAN=5", ip)
#dbLoadRecords("ipApp/Db/Keithley2kDMM_mf.db", "P=13LAB:,Dmm=DMM3,C=0,IPSLOT=a,CHAN=6", ip)

# Port 6 for the MM4000.  We have both motor record and generic serial records on them
dbLoadRecords  "CARSApp/Db/generic_serial.db","P=13LAB:,R=ser1,C=0,IPSLOT=a,CHAN=6,BAUD=19200,PRTY=None,DBIT=8,SBIT=1", top

# Stanford Research Systems SR570 Current Preamplifier
dbLoadRecords("ipApp/Db/SR570.db", "P=13LAB:,A=A1,C=0,IPSLOT=a,CHAN=7", ip)

# Performance tester - don't load routinely

# Test initialization of ipUnidig
#dbLoadRecords("testUnidig.db", "P=13LAB:")

# Heidenhain IK320 VME encoder interpolator
#dbLoadRecords("stdApp/Db/IK320card.db","P=13LAB:,sw2=card0:,axis=1,switches=41344,irq=3", std)
#dbLoadRecords("stdApp/Db/IK320card.db","P=13LAB:,sw2=card0:,axis=2,switches=41344,irq=3", std)
#dbLoadRecords("stdApp/Db/IK320group.db","P=13LAB:,group=5", std)
#drvIK320RegErrStr()

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

#Quad electrometer
dbLoadRecords("quadEMApp/Db/quadEM.db","P=13LAB:, EM=EM1, CARD=0, SERVER=quadEM1", quadem)

# Experiment description
dbLoadRecords("CARSApp/Db/experiment_info.db","P=13LAB:", top)


#MN
dbLoadRecords("CARSApp/Db/scanner.db","P=13LAB:,Q=EDB", top)

# A set of scan parameters for each positioner.  This is a convenience
# for the user.  It can contain an entry for each scannable thing in the
# crate.
dbLoadTemplate "scanParms.template"

# Multichannel analyzer stuff
# AIMConfig(mpfServer, card, ethernet_address, port, maxChans, 
#           maxSignals, maxSequences, ethernetDevice, queueSize)
AIMConfig("AIM1/1", 0x59e, 1, 2048, 1, 1, "dc0", 100)
AIMConfig("AIM1/2", 0x59e, 2, 2048, 8, 1, "dc0", 400)
dbLoadRecords("mcaApp/Db/mca.db", "P=13LAB:,M=aim_adc1,DTYPE=MPF MCA,INP=#C0 S0 @AIM1/1,NCHAN=2048", mca)
dbLoadRecords("mcaApp/Db/mca.db", "P=13LAB:,M=aim_adc2,DTYPE=MPF MCA,INP=#C0 S0 @AIM1/2,NCHAN=2048", mca)
dbLoadRecords("mcaApp/Db/mca.db", "P=13LAB:,M=aim_adc3,DTYPE=MPF MCA,INP=#C0 S2 @AIM1/2,NCHAN=2048", mca)
dbLoadRecords("mcaApp/Db/mca.db", "P=13LAB:,M=aim_adc4,DTYPE=MPF MCA,INP=#C0 S4 @AIM1/2,NCHAN=2048", mca)
dbLoadRecords("mcaApp/Db/mca.db", "P=13LAB:,M=aim_adc5,DTYPE=MPF MCA,INP=#C0 S6 @AIM1/2,NCHAN=2048", mca)

dbLoadRecords("mcaApp/Db/mca.db", "P=13LAB:,M=mip330_1,DTYPE=MPF MCA,NCHAN=2048,INP=#C0 S0 @c-Ip330Sweep", mca)
dbLoadRecords("mcaApp/Db/mca.db", "P=13LAB:,M=mip330_2,DTYPE=MPF MCA,NCHAN=2048,INP=#C0 S1 @c-Ip330Sweep", mca)
dbLoadRecords("mcaApp/Db/mca.db", "P=13LAB:,M=mip330_3,DTYPE=MPF MCA,NCHAN=2048,INP=#C0 S2 @c-Ip330Sweep", mca)
dbLoadRecords("mcaApp/Db/mca.db", "P=13LAB:,M=mip330_4,DTYPE=MPF MCA,NCHAN=2048,INP=#C0 S3 @c-Ip330Sweep", mca)

dbLoadRecords("mcaApp/Db/mca.db", "P=13LAB:,M=quadEM_1,DTYPE=MPF MCA,NCHAN=2048,INP=#C0 S0 @quadEMSweep", mca)
dbLoadRecords("mcaApp/Db/mca.db", "P=13LAB:,M=quadEM_2,DTYPE=MPF MCA,NCHAN=2048,INP=#C0 S1 @quadEMSweep", mca)
dbLoadRecords("mcaApp/Db/mca.db", "P=13LAB:,M=quadEM_3,DTYPE=MPF MCA,NCHAN=2048,INP=#C0 S2 @quadEMSweep", mca)
dbLoadRecords("mcaApp/Db/mca.db", "P=13LAB:,M=quadEM_4,DTYPE=MPF MCA,NCHAN=2048,INP=#C0 S3 @quadEMSweep", mca)
dbLoadRecords("mcaApp/Db/mca.db", "P=13LAB:,M=quadEM_5,DTYPE=MPF MCA,NCHAN=2048,INP=#C0 S8 @quadEMSweep", mca)
dbLoadRecords("mcaApp/Db/mca.db", "P=13LAB:,M=quadEM_6,DTYPE=MPF MCA,NCHAN=2048,INP=#C0 S9 @quadEMSweep", mca)

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

# vme test record
dbLoadRecords("stdApp/Db/vme.db", "P=13LAB:,Q=vme1", std)

# Miscellaneous PV's, such as burtResult
dbLoadRecords("stdApp/Db/misc.db","P=13LAB:", std)

# vxWorks statistics
dbLoadRecords("stdApp/Db/VXstats.db","P=13LAB:", std)

#HiDEOSGpibLinkConfig(10,0,"GPIB0")

################################################################################
# Setup device/driver support addresses, interrupt vectors, etc.

# OMS VME58 driver setup parameters: 
#     (1)cards, (2)axis per card, (3)base address(short, 4k boundary), 
#     (4)interrupt vector (0=disable or  64 - 255), (5)interrupt level (1 - 6),
#     (6)motor task polling rate (min=1Hz,max=60Hz)
oms58Setup(2, 8, 0x4000, 190, 5, 10)

# MCB-4B driver setup parameters:
#     (1) maximum # of controllers,
#     (2) maximum # axis per controller
#     (3) motor task polling rate (min=1Hz, max=60Hz)
MCB4BSetup(1, 1, 10)

# MM4000 driver setup parameters: 
#     (1) maximum # of controllers, 
#     (2) maximum # axis per controller
#     (3) motor task polling rate (min=1Hz, max=60Hz)
MM4000Setup(1, 8, 10)

# MM4000 driver configuration parameters: 
#     (1) controller
#     (2) port type: 0=GPIB, 1=RS232, 
#     (3) GPIB link or Hideos card
#     (4) GPIB address or Hideos task
# GPIB example:
#   MM4000Config(0,0,10,2)  #Link 10, address 2
# RS-232 example:
#   MM4000Config(0, 1, 0, "a-Serial[0]")  Hideos card 1, port 0 on IP slot A.
MM4000Config(0, 1, 0, "a-Serial[6]")
# Delay to allow motors to settle
drvMM4000ReadbackDelay=.5  

# MCB-4B driver configuration parameters:
#     (1) controller
#     (2) Hideos/MPF card
#     (3) Hideos task/MPF server
# Example:
#   MCB4BConfig(0, 1, "a-Serial[0]")  Hideos card 1, port 0 on IP slot A.
MCB4BConfig(0, 0, "a-Serial[3]")

# initQuadEM(baseAddress, fiberChannel, microSecondsPerScan, maxClients,
#            pIpUnidig, unidigChan)
#  baseAddress = base address of VME card
#  channel     = 0-3, fiber channel number
#  microSecondsPerScan = microseconds to integrate.  When used with ipUnidig
#                interrupts the unit is also read at this rate.
#  maxClients  = maximum number of clients that will connect to the
#                quadEM interrupt.  10 should be fine.
#  iIpUnidig   = pointer to ipInidig object if it is used for interrupts.
#                Set to 0 if there is no IP-Unidig being used, in which
#                case the quadEM will be read at 60Hz.
#  unidigChan  = IP-Unidig channel connected to quadEM pulse output
pQuadEM = initQuadEM(0xf000, 0, 1000, 10, pIpUnidig, 2)

# initQuadEMScan(pQuadEM, serverName, queueSize)
#  pQuadEM    = pointer to quadEM object created with initQuadEM
#  serverName = name of MPF server (string)
#  queueSize  = size of MPF queue
initQuadEMScan(pQuadEM, "quadEM1", 100)

# initQuadEMSweep(pquadEM, serverName, maxPoints, int queueSize)
#  pQuadEM    = pointer to quadEM object created with initQuadEM
#  serverName = name of MPF server (string)
#  maxPoints  = maximum number of channels per spectrum
#  queueSize  = size of MPF queue
initQuadEMSweep(pQuadEM, "quadEMSweep", 2048, 100)

# initQuadEMPID(serverName, pQuadEM, quadEMChannel, 
#               pDAC128V, DACChannel, queueSize)
#  serverName  = name of MPF server (string)
#  pQuadEM     = pointer to quadEM object created with initQuadEM
#  quadEMChannel = quadEM "channel" to be used for feedback (0-9)
#                  These are defined as:
#                        0 = current 1
#                        1 = current 2
#                        2 = current 3
#                        3 = current 4
#                        4 = sum 1 = current1 + current3
#                        5 = sum 2 = current2 + current4
#                        6 = difference 1 = current3 - current1
#                        7 = difference 2 = current4 - current2
#                        8 = position 1 = difference1/sum1 * 32767
#                        9 = position 2 = difference2/sum2 * 32767
#  pDAC128V    = pointer to DAC128V object created with initDAC128V
#  DACVChannel = DAC channel number used for this PID (0-7)
#  queueSize   = size of MPF queue
initQuadEMPID("quadEMPID1", pQuadEM, 8, pDAC128V, 2, 20)
initQuadEMPID("quadEMPID2", pQuadEM, 9, pDAC128V, 3, 20)

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
# Load the list of search directories for request files
< ../requestFileCommands

# save positions every five seconds
create_monitor_set("auto_positions.req", 5)
# save other things every thirty seconds
create_monitor_set("auto_settings.req", 30)

# Enable user string calcs and user transforms
dbpf "13LAB:EnableUserTrans.PROC","1"
dbpf "13LAB:EnableUserSCalcs.PROC","1"

seq &Keithley2kDMM, "P=13LAB:, Dmm=DMM1, stack=10000"
seq &Keithley2kDMM, "P=13LAB:, Dmm=DMM2, channels=20, stack=10000"
#seq &Keithley2kDMM, "P=13LAB:, Dmm=DMM3, channels=22, model=2700, stack=10000"

free(mem)

