# VXWorks startup file for 13IDA ioc

< cdCommands
< ../nfsCommandsGSE
loginUserAdd "epics", "9cebSebcd"

cd topbin
ld < CARSApp.munch
# Increase size of errlog buffer
errlogInit(20000)

# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in this build.i
dbLoadDatabase("$(CARS)/dbd/CARSVX.dbd")
CARSVX_registerRecordDeviceDriver(pdbbase)

# This IOC loads the MPF server code locally
cd startup
< st_mpfserver.cmd

# Debugging flags
devPM304Debug=0
drvPM304Debug=0
devA32VmeDebug=0
devMPCDebug=0
quadEMDebug=0

# Set up the Allen-Bradley 6008 scanner
abConfigNlinks 1
abConfigVme 0,0xc00000,0x60,5
abConfigAuto

# Load database
dbLoadRecords("$(CARS)/CARSApp/Db/eps_valid.db", "P=13IDA:")
dbLoadTemplate("eps_inputs.template")
dbLoadTemplate("eps_outputs.template")
dbLoadTemplate("eps_valves.template")

# Load asyn records on all serial ports
dbLoadTemplate("asynRecord.template")
dbLoadRecords("$(IP)/ipApp/Db/MKS.db","P=13IDA:,C=0,SERVER=serial1,CC1=cc1,CC2=cc3,PR1=pr1,PR2=pr3")
dbLoadRecords("$(IP)/ipApp/Db/MKS.db","P=13IDA:,C=0,SERVER=serial2,CC1=cc2,CC2=ccA,PR1=pr2,PR2=prA")
dbLoadRecords("$(IP)/ipApp/Db/Digitel.db","P=13IDA:,PUMP=ip1,C=0,PORT=serial3")
dbLoadRecords("$(IP)/ipApp/Db/Digitel.db","P=13IDA:,PUMP=ip3,C=0,PORT=serial4")
dbLoadRecords("$(IP)/ipApp/Db/MKS.db","P=13IDA:,C=0,SERVER=serial5,CC1=cc5,CC2=cc6,PR1=pr5,PR2=pr6")
dbLoadRecords("$(IP)/ipApp/Db/Digitel.db","P=13IDA:,PUMP=ip5,C=0,PORT=serial6")
dbLoadRecords("$(IP)/ipApp/Db/MPC.db","P=13IDA:,PUMP=ip2,C=0,SERVER=serial7,PA=0,PN=1", ip)
# serial8 is McClennan PM-304 motor controller
dbLoadRecords("$(IP)/ipApp/Db/Keithley2kDMM_mf.db","P=13IDA:,Dmm=DMM1,C=0,PORT=serial9")
dbLoadRecords("$(CARS)/CARSApp/Db/ILM200.db","P=13IDA:,R=ILM200,C=0,PORT=serial10")
dbLoadRecords("$(IP)/ipApp/Db/MKS.db","P=13IDA:,C=0,SERVER=serial11,CC1=cc7,CC2=ccB,PR1=pr7,PR2=prB")
dbLoadRecords("$(IP)/ipApp/Db/MPC.db","P=13IDA:,PUMP=ip6,C=0,SERVER=serial12,PA=0,PN=1")
dbLoadRecords("$(IP)/ipApp/Db/MPC.db","P=13IDA:,PUMP=ip7,C=0,SERVER=serial12,PA=0,PN=2")
dbLoadRecords("$(IP)/ipApp/Db/TSP.db","P=13IDA:,TSP=tsp1,C=0,SERVER=serial12,PA=0")

dbLoadRecords("$(IP)/ipApp/Db/Keithley2kDMM_mf.db","P=13IDA:,Dmm=DMM2,C=0,PORT=serial13")

dbLoadTemplate("motors.template")

# Digital to analog converter, used for Queensgate piezo drivers
dbLoadTemplate("DAC.template")

# ipUnidig digital I/O
dbLoadTemplate("IpUnidig.template")

#Quad electrometer
 dbLoadRecords("$(QUADEM)/quadEMApp/Db/quadEM.db", "P=13IDA:, EM=EM1, CARD=0, SERVER=quadEM1")

dbLoadRecords("$(QUADEM)/quadEMApp/Db/quadEM_med.db", "P=13IDA:quadEM:,NCHAN=2048,C=0,SERVER=quadEMSweep")
dbLoadRecords("$(QUADEM)/quadEMApp/Db/quadEM_med_FFT.db", "P=13IDA:quadEM_FFT:,NCHAN=1024")

# Monochromator PID
dbLoadTemplate("mono_pid.template")

### Allstop, alldone
# This database must agree with the motors you've actually loaded.
# Several versions (e.g., all_com_32.db) are in std/stdApp/Db
dbLoadRecords("$(STD)/stdApp/Db/all_com_16.db","P=13IDA:")

### Scan-support software
# crate-resident scan.  This executes 1D, 2D, 3D, and 4D scans, and caches
# 1D data, but it doesn't store anything to disk.  (You need the data catcher
# or the equivalent for that.)  This database is configured to use the
# "alldone" database (above) to figure out when motors have stopped moving
# and it's time to trigger detectors.
dbLoadRecords("$(SSCAN)/sscanApp/Db/scan.db","P=13IDA:,MAXPTS1=500,MAXPTS2=50,MAXPTS3=10,MAXPTS4=10,MAXPTSH=10")

# A set of scan parameters for each positioner.  This is a convenience
# for the user.  It can contain an entry for each scannable thing in the
# crate.
dbLoadTemplate("scanParms.template")

#  load the databases for the MSL MRD100 module ...
dbLoadRecords ("$(VME)/vmeApp/Db/msl_mrd101.db","C=0,S=13,ID1=13,ID2=13us")

# Miscellaneous PV's, such as burtResult
dbLoadRecords("$(STD)/stdApp/Db/misc.db","P=13IDA:")

# vxWorks statistics
dbLoadTemplate("vxStats.substitutions")

################################################################################
# Setup device/driver support addresses, interrupt vectors, etc.

#####################################################
# dev32VmeConfig(card,a32base,nreg,iVector,iLevel)                 
#    card    = card number                         
#    a32base = base address of card               
#    nreg    = number of A32 registers on this card
#    iVector = interrupt vector (MRD100 Only !!)
#    iLevel  = interrupt level  (MRD100 Only !!)
#  For Example                                     
#   devA32VmeConfig(0, 0x80000000, 44, 0, 0)             
#####################################################
#  Configure the MSL MRD 100 module.....
# Changed base address to 0xb0000200 from 0xa0000200 to avoid conflict
# with VPIC616 IP carrier
devA32VmeConfig(0, 0xb0000200, 30, 0xa0, 5)

# OMS VME58 driver setup parameters: 
#     (1)cards, (2)axis per card, (3)base address(short, 4k boundary), 
#     (4)interrupt vector (0=disable or  64 - 255), (5)interrupt level (1 - 6),
#     (6)motor task polling rate (min=1Hz,max=60Hz)
oms58Setup(4, 8, 0x4000, 190, 5, 10)

# PM304 driver setup parameters: 
#     (1) maximum # of controllers, 
#     (2) maximum # axis per controller
#     (3) motor task polling rate (min=1Hz, max=60Hz)
PM304Setup(1, 1, 10)

# PM304 driver configuration parameters:
#     (1) controller
#     (2) asyn port
#     (3) # axes
# Example:
#   PM304Config(0, "serial4", 1)
PM304Config(0, "serial8", 1)

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

# Use this line for 60Hz polling
#initQuadEM("quadEM1", 0xf000, 0, 1000, 10, 0, 0)
# Use this line for interrupts on channel 0 of IpUnidig
initQuadEM("quadEM1", 0xf000, 0, 1000, 10, "Unidig1", 0)

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
initQuadEMPID("quadEMPID1", "quadEM1", 8, "DAC1", 2, 20)
initQuadEMPID("quadEMPID2", "quadEM1", 9, "DAC1", 1, 20)

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

seq &Keithley2kDMM, "P=13IDA:, Dmm=DMM1, stack=10000"
seq &Keithley2kDMM, "P=13IDA:, Dmm=DMM2, stack=10000"

str=malloc(256)
strcpy(str,"PRE=13IDA:,ID=ID13:,EXPTAB_Z=13IDC:m6,")
strcat(str,"EXPTAB2=13IDA:pm5,SH=eps_mbbi4,FB=mono_pid1")
seq &Energy, str

# For the bypass valves swap the severity of the open and closed states
dbpf "13IDA:V5_status.ONSV","MAJOR"
dbpf "13IDA:V5_status.TWSV","NO_ALARM"
dbpf "13IDA:V6_status.ONSV","MAJOR"
dbpf "13IDA:V6_status.TWSV","NO_ALARM"


#
# MN/MR 27/Nov/01
# set readback delay for McLennan monochromator controller.
# We found empirically the following maximum error (in encoder pulses)
# for the following ReadbackDelay values.   In all cases, the maximum
# errors were rare (say, 2 out of 50)
#   ReadbackDelay     Max Encoder Errors 
#     0.0                  4
#     0.1                  3 
#     0.2                  2
#     0.5                  1
#
# Note: 1 encoder step ~= 0.05eV at 10keV.
(double) drvPM304ReadbackDelay = 0.25

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
saveData_Init("saveDataExtraPVs.req", "P=13IDA:")
#saveData_PrintScanInfo("13IDA:scan1")


