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
< industryPack.cmd
< serial.cmd

# Debugging flags
devPM304Debug=0
drvPM304Debug=0
devA32VmeDebug=0

# Set up the Allen-Bradley 6008 scanner
abConfigNlinks 1
abConfigVme 0,0xc00000,0x60,5
abConfigAuto

# Load database
dbLoadRecords("$(CARS)/CARSApp/Db/eps_valid.db", "P=13IDA:")
dbLoadTemplate("eps_inputs.template")
dbLoadTemplate("eps_outputs.template")
dbLoadTemplate("eps_valves.template")

dbLoadTemplate("motors.template")

#Quad electrometer
dbLoadRecords("$(QUADEM)/quadEMApp/Db/quadEM.db", "P=13IDA:, EM=EM1, CARD=0, PORT=quadEM1")

dbLoadRecords("$(QUADEM)/quadEMApp/Db/quadEM_med.db", "P=13IDA:quadEM:,NCHAN=2048,PORT=quadEMSweep")
dbLoadRecords("$(QUADEM)/quadEMApp/Db/quadEM_med_FFT.db", "P=13IDA:quadEM_FFT:,NCHAN=1024")

# Monochromator PID
dbLoadTemplate("mono_pid.template")

# Large KB Mirror PID
dbLoadTemplate("mirror_pid.template")

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

< ../save_restore.cmd
save_restoreSet_status_prefix("13IDA:")
dbLoadRecords("$(AUTOSAVE)/asApp/Db/save_restoreStatus.db", "P=13IDA:")

################################################################################
# Setup device/driver support addresses, interrupt vectors, etc.

# Machine Status Link (MSL) board (MRD 100)
#####################################################
# devAvmeMRDConfig( base, vector, level )
#    base   = base address of card
#    vector = interrupt vector
#    level  = interrupt level
# For Example
#    devAvmeMRDConfig(0xA0000200, 0xA0, 5)
#####################################################
#  Configure the MSL MRD 100 module.....
devAvmeMRDConfig(0xB0000200, 0xA0, 5)

# OMS VME58 driver setup parameters:
#     (1)cards, (2)base address(short, 4k boundary),
#     (3)interrupt vector (0=disable or  64 - 255), (4)interrupt level (1 - 6),
#     (5)motor task polling rate (min=1Hz,max=60Hz)
oms58Setup(4, 0x4000, 190, 5, 10)

# initQuadEM(baseAddress, fiberChannel, microSecondsPerScan, maxClients,
#            unidigName, unidigChan)
#  quadEMName  = name of quadEM object created
#  baseAddress = base address of VME card
#  channel     = 0-3, fiber channel number
#  microSecondsPerScan = microseconds to integrate.  When used with ipUnidig
#                interrupts the unit is also read at this rate.
#  unidigName  = name of ipInidig server if it is used for interrupts.
#                Set to 0 if there is no IP-Unidig being used, in which
#                case the quadEM will be read at 60Hz.
#  unidigChan  = IP-Unidig channel connected to quadEM pulse output

# Use this line for 60Hz polling
#initQuadEM("quadEM1", 0xf000, 0, 1000, 0, 0)
# Use this line for interrupts on channel 0 of IpUnidig
initQuadEM("quadEM1", 0xf000, 0, 1000, "Unidig1", 0)

# initFastSweep(portName, inputName, maxSignals, maxPoints)
#  portName = asyn port name for this new port (string)
#  inputName = name of asynPort providing data
#  maxSignals  = maximum number of signals (spectra)
#  maxPoints  = maximum number of channels per spectrum
initFastSweep("quadEMSweep", "quadEM1", 10, 2048)

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
create_monitor_set("auto_positions.req",5,"P=13IDA:")
# save other things every thirty seconds
create_monitor_set("auto_settings.req",30,"P=13IDA:")

seq &Keithley2kDMM, "P=13IDA:, Dmm=DMM1, stack=10000"
seq &Keithley2kDMM, "P=13IDA:, Dmm=DMM2, stack=10000"

str=malloc(256)
strcpy(str,"PRE=13IDA:,ID=ID13ds:,EXPTAB_Z=13IDC:m6,")
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
# (double) drvPM304ReadbackDelay = 0.25
# Note, the above has been replaced with the .DLY field of the motor record, which
# we now have in save/restore.  Change the .DLY field in medm.

# 2009-May-28: Set the NTM fields of the DC/PID motors to 0 (NO) so they don't 
#              get stopped when the motor changes direction due to PID
dbpf("13IDA:m17.NTM","0")

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


