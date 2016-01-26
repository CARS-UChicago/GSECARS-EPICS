# VXWorks startup file for 13IDA ioc

< cdCommands
< ../nfsCommandsGSE
loginUserAdd "epics", "9cebSebcd"

cd topbin
load("CARSApp.munch")
# Increase size of errlog buffer
errlogInit(20000)

# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in this build.i
dbLoadDatabase("$(CARS)/dbd/CARSVX.dbd")
CARSVX_registerRecordDeviceDriver(pdbbase)

# For areaDetector
iocshCmd("epicsEnvSet(EPICS_DB_INCLUDE_PATH,$(ADCORE)/db)")

cd startup

# Debugging flags
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

< industryPack.cmd
< serial.cmd

# APS electrometer for C/D branch
iocsh("APS_EM.cmd")

# AH501 electrometer for E branch
iocsh("AH501.cmd")

# Monochromator positions
#dbLoadTemplate("mono_position.template")

# Quad BPM foils
dbLoadTemplate("13ID_BPM_Foil.substitutions")

# Monochromator PID
dbLoadTemplate("mono_pid.template")
dbLoadTemplate("emono_pid.template")

# Large KB Mirror PID
dbLoadTemplate("mirror_pid.template")

# Auto-shutters
dbLoadTemplate("auto_shutter.substitutions")

### Allstop, alldone
dbLoadRecords("$(MOTOR)/motorApp/Db/motorUtil.db","P=13IDA:")

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
#dbLoadRecords ("$(VME)/vmeApp/Db/msl_mrd101.db","C=0,S=13,ID1=13,ID2=13us")
dbLoadRecords ("$(VME)/vmeApp/Db/MRD100_CantedID.db","C=0,S=13,ID1=13ds,ID2=13us")

# Free-standing user string/number calculations (sCalcout records)
dbLoadRecords("$(CALC)/calcApp/Db/userStringCalcs10.db", "P=13IDA:")

# Free-standing user array calculations (aCalcout records)
dbLoadRecords("$(CALC)/calcApp/Db/userArrayCalcs10.db", "P=13IDA:,N=10")

# Free-standing user transforms (transform records)
dbLoadRecords("$(CALC)/calcApp/Db/userTransforms10.db", "P=13IDA:")

# Miscellaneous PV's
dbLoadRecords("$(STD)/stdApp/Db/misc.db","P=13IDA:")

# devIocStats
putenv("ENGINEER=Mark Rivers")
putenv("LOCATION=13-ID-A roof")
putenv("GROUP=GSECARS")
dbLoadRecords("$(DEVIOCSTATS)/db/iocAdminVxWorks.db","IOC=13IDA:")

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

################################################################################
# OMS MAXv driver setup parameters:
#     (1)number of cards in array.
#     (2)VME Address Type (16,24,32).
#     (3)Base Address on 4K (0x1000) boundary.
#     (4)interrupt vector (0=disable or  64 - 255).
#     (5)interrupt level (1 - 6).
#     (6)motor task polling rate (min=1Hz,max=60Hz).
MAXvSetup(3, 16, 0x8000, 192, 5, 10)
drvMAXvdebug=0
# OMS MAXv configuration string:
#     (1) number of card being configured (0-14).
#     (2) configuration string; axis type (PSO/PSE/PSM) MUST be set here.
#         For example, set which TTL signal level defines
#         an active limit switch.  Set X,Y,Z,T to active low and set U,V,R,S
#         to active high.  Set all axes to open-loop stepper (PSO). See MAXv
#         User's Manual for LL/LH and PSO/PSE/PSM commands.
# Set all axes to open-loop stepper and active high limits
configStep="AX LMH LTH PSO; AY LMH LTH PSO; AZ LMH LTH PSO; AT LMH LTH PSO; AU LMH LTH PSO; AV LMH LTH PSO; AR LMH LTH PSO; AS LMH LTH PSO;"
MAXvConfig(0, configStep)
MAXvConfig(1, configStep)
MAXvConfig(2, configStep)

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

seq &Keithley2kDMM, "P=13IDA:, Dmm=DMM1, channels=22, model=2700, stack=10000"
seq &Keithley2kDMM, "P=13IDA:, Dmm=DMM2, stack=10000"

#str=malloc(256)
#strcpy(str,"PRE=13IDA:,ID=ID13ds:,")
#strcat(str,"FB=mono_pid1")
#seq &Energy, str

seq(&quadEM_SNL, "P=13IDA:, R=QE1_TS:, NUM_CHANNELS=2048")
seq(&quadEM_SNL, "P=13IDA:, R=QE2_TS:, NUM_CHANNELS=2048")

# For the bypass valve swap the severity of the open and closed states
dbpf "13IDA:V8_status.ONSV","MAJOR"
dbpf "13IDA:V8_status.TWSV","NO_ALARM"

# Enable user string calcs and user transforms
dbpf "13IDA:EnableUserTrans.PROC","1"
dbpf "13IDA:EnableUserSCalcs.PROC","1"
dbpf "13IDA:EnableuserACalcs.PROC","1"

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

motorUtilInit("13IDA:")


