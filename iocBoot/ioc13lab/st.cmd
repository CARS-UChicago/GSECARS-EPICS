# Allocate 96MB of memory so we load everything else into low memory
mem = malloc(1024*1024*96)

# vxWorks startup file
< cdCommands

< ../nfsCommandsGSE
#loginUserAdd "epics","SzeSebbzRR"

cd topbin
ld < CARSApp.munch
cd startup

# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in this build from CARS
dbLoadDatabase("$(CARS)/dbd/CARSVX.dbd")
CARSVX_registerRecordDeviceDriver(pdbbase)

# Increase size of buffer for error logging from default 1256 
# Use the new shell
#iocsh

errlogInit(5000)

# Currently, the only thing we do in initHooks is call reboot_restore(), which
# restores positions and settings saved ~continuously while EPICS is alive.
# See calls to "create_monitor_set()" at the end of this file.  To disable
# autorestore, comment out the following line.
#ld < initHooks.o

# Set debugging flags
save_restoreDebug=0
devMM4000debug = 0
devMCB4BDebug=0
drvMCB4BDebug=0
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
quadEMDebug=0
fastSweepDebug=0
sscanRecordDebug=0
devMCA_softDebug = 0 

# Load local MPF server
< st_mpfserver.cmd

# Debug serial port
#serialPortSniff("UART[6]",1000)

# Initialize remote MPF stuff
# tcpMessageRouterClientStart(1,9900,"164.54.160.118",10000,100)

# override address, interrupt vector, etc. information in module_types.h
#module_types()

# Generic GPIB record
#dbLoadRecords("$(CARS)/CARSApp/Db/generic_gpib.db", "P=13LAB:,R=gpib1,SIZE=4096")

# Serial 1 is for SMART
# SMART detector database
str=malloc(256)
strcpy(str,"P=13LAB:,R=smart1,C=0,SERVER=serial1,")
strcat(str,"FSHUT=UnidigBo0,TRIG=UnidigBo1,SSHUT=UnidigBo2")
dbLoadRecords("$(CCD)/ccdApp/Db/smartControl.db", str)

# Serial 2 has Newport LAE500 Laser Autocollimator (and generic serial port)
dbLoadRecords("$(CARS)/CARSApp/Db/LAE500.db", "P=13LAB:,R=LAE500,C=0,SERVER=serial2")
dbLoadRecords("$(CARS)/CARSApp/Db/generic_serial.db", "P=13LAB:,R=ser2,C=0,SERVER=serial2")

# Port 3 Encoder readout unit
#dbLoadRecords("$(CARS)/CARSApp/Db/RSF715.db","P=13LAB:,ENCODER=RSF715,C=0,SERVER=serial4")
#dbLoadRecords("$(CARS)/CARSApp/Db/generic_serial.db","P=13LAB:,R=ser1,C=0,SERVER=serial4")

# Serial 4 MCB4B motor controller
#dbLoadRecords("$(CARS)/CARSApp/Db/generic_serial.db", "P=13LAB:,R=ser1,C=0,SERVER=serial4")

# Serial 5, 6 Keithley Multimeter
dbLoadRecords("$(IP)/ipApp/Db/Keithley2kDMM_mf.db", "P=13LAB:,Dmm=DMM1,C=0,SERVER=serial5")
dbLoadRecords("$(IP)/ipApp/Db/Keithley2kDMM_mf.db", "P=13LAB:,Dmm=DMM2,C=0,SERVER=serial6")
#dbLoadRecords("$(IP)/ipApp/Db/Keithley2kDMM_mf.db", "P=13LAB:,Dmm=DMM3,C=0,SERVER=serial7")

# Serial 7 for the MM4000.  We have both motor record and generic serial records on them
dbLoadRecords("$(CARS)/CARSApp/Db/generic_serial.db", "P=13LAB:,R=ser1,C=0,SERVER=serial7")

# Serial 8 Stanford Research Systems SR570 Current Preamplifier
dbLoadRecords("$(IP)/ipApp/Db/SR570.db", "P=13LAB:,A=A1,C=0,SERVER=serial8")

# Test initialization of ipUnidig
#dbLoadRecords("testUnidig.db", "P=13LAB:")

# Heidenhain IK320 VME encoder interpolator
#dbLoadRecords("$(STD)/stdApp/Db/IK320card.db", "P=13LAB:,sw2=card0:,axis=1,switches=41344,irq=3")
#dbLoadRecords("$(STD)/stdApp/Db/IK320card.db", "P=13LAB:,sw2=card0:,axis=2,switches=41344,irq=3")
#dbLoadRecords("$(STD)/stdApp/Db/IK320group.db", "P=13LAB:,group=5")
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


# Database for trajectory scanning with the MM4005/GPD
# The required command string is longer than the vxWorks command line, must use malloc and strcpy, strcat
str = malloc(300)
strcpy(str, "P=13LAB:,R=traj1,NAXES=6,NELM=1000,NPULSE=1000,C=0,SERVER=serial7,")
strcat(str, ",DONPV=13LAB:str:EraseStart,DONV=1,DOFFPV=13LAB:str:StopAll,DOFFV=1")
dbLoadRecords("$(CARS)/CARSApp/Db/trajectoryScan.db", str, top)


#Quad electrometer
dbLoadRecords("$(QUADEM)/quadEMApp/Db/quadEM.db", "P=13LAB:, EM=EM1, CARD=0, SERVER=quadEM1")

# Experiment description
dbLoadRecords("$(CARS)/CARSApp/Db/experiment_info.db", "P=13LAB:")


#MN
dbLoadRecords("$(CARS)/CARSApp/Db/scanner.db", "P=13LAB:,Q=EDB")

# A set of scan parameters for each positioner.  This is a convenience
# for the user.  It can contain an entry for each scannable thing in the
# crate.
dbLoadTemplate "scanParms.template"

# Multichannel analyzer stuff
# AIMConfig(mpfServer, card, ethernet_address, port, maxChans, 
#           maxSignals, maxSequences, ethernetDevice, queueSize)
AIMConfig("AIM1/1", 0x59e, 1, 2048, 1, 1, "dc0", 100)
AIMConfig("AIM1/2", 0x59e, 2, 2048, 8, 1, "dc0", 400)
dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=13LAB:,M=aim_adc1,DTYPE=MPF MCA,INP=#C0 S0 @AIM1/1,NCHAN=2048")
dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=13LAB:,M=aim_adc2,DTYPE=MPF MCA,INP=#C0 S0 @AIM1/2,NCHAN=2048")
dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=13LAB:,M=aim_adc3,DTYPE=MPF MCA,INP=#C0 S2 @AIM1/2,NCHAN=2048")
dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=13LAB:,M=aim_adc4,DTYPE=MPF MCA,INP=#C0 S4 @AIM1/2,NCHAN=2048")
dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=13LAB:,M=aim_adc5,DTYPE=MPF MCA,INP=#C0 S6 @AIM1/2,NCHAN=2048")

dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=13LAB:,M=mip330_1,DTYPE=MPF MCA,NCHAN=2048,INP=#C0 S0 @Ip330Sweep1")
dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=13LAB:,M=mip330_2,DTYPE=MPF MCA,NCHAN=2048,INP=#C0 S1 @Ip330Sweep1")
dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=13LAB:,M=mip330_3,DTYPE=MPF MCA,NCHAN=2048,INP=#C0 S2 @Ip330Sweep1")
dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=13LAB:,M=mip330_4,DTYPE=MPF MCA,NCHAN=2048,INP=#C0 S3 @Ip330Sweep1")

dbLoadRecords("$(QUADEM)/quadEMApp/Db/quadEM_med.db", "P=13LAB:quadEM:,NCHAN=2048,C=0,SERVER=quadEMSweep")
dbLoadRecords("$(QUADEM)/quadEMApp/Db/quadEM_med_FFT.db", "P=13LAB:quadEM_FFT:,NCHAN=1024")

#icbDspConfig("icbDsp/1", 1, "NI59E:1", 100)
#dbLoadRecords("$(MCA)/mcaApp/Db/icbDsp.db", "P=13LAB:,DSP=dsp1,CARD=0,SERVER=icbDsp/1,ADDR=0")
icbSetup("icb/1", 10, 100)
icbConfig("icb/1", 0, 0x59e, 5)
dbLoadRecords("$(MCA)/mcaApp/Db/icb_adc.db", "P=13LAB:,ADC=adc1,CARD=0,SERVER=icb/1,ADDR=0")
icbConfig("icb/1", 1, 0x59e, 3)
dbLoadRecords("$(MCA)/mcaApp/Db/icb_amp.db", "P=13LAB:,AMP=amp1,CARD=0,SERVER=icb/1,ADDR=1")
icbConfig("icb/1", 2, 0x59e, 2)
dbLoadRecords("$(MCA)/mcaApp/Db/icb_hvps.db", "P=13LAB:,HVPS=hvps1,CARD=0,SERVER=icb/1,ADDR=2, LIMIT=1000")

#icbTcaSetup(serverName, maxModules, queueSize)
icbTcaSetup("icbTca/1", 10, 100)
#icbTcaConfig(serverName, module, ethernetAddress, icbAddress)
icbTcaConfig("icbTca/1", 0, 0x59e, 8)
dbLoadRecords("$(MCA)/mcaApp/Db/icb_tca.db", "P=13LAB:,TCA=tca1,MCA=aim_adc2,CARD=0,SERVER=icbTca/1,ADDR=0")

# Struck MCS as 32-channel multi-element detector
<Struck32.cmd

### Scalers: Joerger VSC8/16
dbLoadRecords("$(STD)/stdApp/Db/Jscaler.db", "P=13LAB:,S=scaler1,C=0")

### Scalers: Struck/SIS as simple scaler 
# Don't execute the next 2 lines if Struck8.cmd is loaded above
#STR7201Setup(1,0xA0000000,220,6)
#STR7201Config(0, 16, 100)
dbLoadRecords("$(MCA)/mcaApp/Db/STR7201scaler.db", "P=13LAB:,S=scaler2,C=0")

### Allstop, alldone
# This database must agree with the motors you've actually loaded.
# Several versions (e.g., all_com_32.db) are in stdApp/Db
dbLoadRecords("$(STD)/stdApp/Db/all_com_8.db", "P=13LAB:")

### Scan-support software
# crate-resident scan.  This executes 1D, 2D, 3D, and 4D scans, and caches
# 1D data, but it doesn't store anything to disk.  (You need the data catcher
# or the equivalent for that.)  This database is configured to use the
# "alldone" database (above) to figure out when motors have stopped moving
# and it's time to trigger detectors.
dbLoadRecords("$(STD)/stdApp/Db/scan.db.CA", "P=13LAB:,MAXPTS1=2000,MAXPTS2=200,MAXPTS3=20,MAXPTS4=10,MAXPTSH=10")

# Free-standing user string/number calculations (sCalcout records)
dbLoadRecords("$(STD)/stdApp/Db/userStringCalcs10.db", "P=13LAB:")

# Free-standing user transforms (transform records)
dbLoadRecords("$(STD)/stdApp/Db/userTransforms10.db", "P=13LAB:")

# vme test record
dbLoadRecords("$(STD)/stdApp/Db/vme.db", "P=13LAB:,Q=vme1")

# Miscellaneous PV's, such as burtResult
dbLoadRecords("$(STD)/stdApp/Db/misc.db", "P=13LAB:")

# vxWorks statistics
#dbLoadRecords("$(STD)/stdApp/Db/VXstats.db", "P=13LAB:")

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
MM4000Config(0, 1, 0, "serial7")
# Delay to allow motors to settle
#drvMM4000ReadbackDelay=.5  

# MCB-4B driver configuration parameters:
#     (1) controller
#     (2) Hideos/MPF card
#     (3) Hideos task/MPF server
# Example:
#   MCB4BConfig(0, 1, "serial1")  Hideos card 1, port 0 on IP slot A.
MCB4BConfig(0, 0, "serial4")

# initQuadEM(baseAddress, fiberChannel, microSecondsPerScan, maxClients,
#            unidigName, unidigChan)
#  quadEMName  = name of quadEM object created 
#  baseAddress = base address of VME card
#  channel     = 0-3, fiber channel number
#  microSecondsPerScan = microseconds to integrate.  When used with ipUnidig
#                interrupts the unit is also read at this rate.
#  maxClients  = maximum number of clients that will connect to the
#                quadEM interrupt.  10 should be fine.
#  unidigName  = name of ipInidig server if it is used for interrupts.
#                Set to 0 if there is no IP-Unidig being used, in which
#                case the quadEM will be read at 60Hz.
#  unidigChan  = IP-Unidig channel connected to quadEM pulse output
initQuadEM("quadEM1", 0xf000, 0, 1000, 10, "Unidig1", 2)

# initQuadEMScan(quadEMName, serverName, queueSize)
#  quadEMName = name of quadEM object created with initQuadEM
#  serverName = name of MPF server (string)
#  queueSize  = size of MPF queue
initQuadEMScan("quadEM1", "quadEM1", 100)

# initQuadEMSweep(quadEMName, serverName, maxPoints, int queueSize)
#  quadEMName = name of quadEM object created with initQuadEM
#  serverName = name of MPF server (string)
#  maxPoints  = maximum number of channels per spectrum
#  queueSize  = size of MPF queue
initQuadEMSweep("quadEM1", "quadEMSweep", 2048, 400)

# initQuadEMPID(serverName, quadEMName, quadEMChannel, 
#               DACName, DACChannel, queueSize)
#  serverName  = name of MPF server (string)
#  quadEMName = name of quadEM object created with initQuadEM
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
#  DACName     = name of DAC128V server created with initDAC128V
#  DACVChannel = DAC channel number used for this PID (0-7)
#  queueSize   = size of MPF queue
#initQuadEMPID("quadEMPID1", "quadEM1", 8, "DAC1", 2, 20)
#initQuadEMPID("quadEMPID2", "quadEM1", 9, "DAC1", 3, 20)

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
#seq &seq_test, "pv1=13LAB:m1, pv2=13LAB:m2"
seq &smartControl, "P=13LAB:,R=smart1,TTH=m1,OMEGA=m1,PHI=m1,KAPPA=m1,SCALER=scaler1,I0=6,stack=10000"
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
saveData_Init("saveDataExtraPVs.req", "P=13LAB:")
#saveData_PrintScanInfo("13LAB:scan1")

free(mem)
