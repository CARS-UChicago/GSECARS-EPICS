# vxWorks startup file for 13BMA ioc
< cdCommands
< ../nfsCommandsGSE
loginUserAdd "epics", "9cebSebcd"

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
# override address, interrupt vector, etc. information in module_types.h
module_types()

devPM304Debug = 0
drvPM304Debug = 0
serialIODebug = 0
devSerialDebug = 0
serialRecordDebug = 0
devSiStrParmDebug=0
devAiMKSDebug = 0

# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in this build.
dbLoadDatabase("../../dbd/CARSApp.dbd")

# Set up the Allen-Bradley 6008 scanner
abConfigNlinks 1
abConfigVme 0,0xc00000,0x60,5
abConfigAuto

# Load database
dbLoadRecords("CARSApp/Db/eps_valid.db", "P=13BMA:",top)
dbLoadTemplate("eps_inputs.template")
dbLoadTemplate("eps_outputs.template")
dbLoadTemplate("eps_valves.template")
dbLoadRecords("CARSApp/Db/generic_serial.db","P=13BMA:,R=ser1,C=0,IPSLOT=a,CHAN=0,BAUD=9600,PRTY=Even,DBIT=7,SBIT=1",top)
dbLoadRecords("ipApp/Db/Digitel.db","P=13BMA:,PUMP=ip1,C=0,IPSLOT=a,CHAN=0",ip)
dbLoadRecords("ipApp/Db/MKS.db","P=13BMA:,C=0,IPSLOT=a,CHAN=1,CC1=cc1,CC2=cc3,PR1=pr1,PR2=pr3",ip)
dbLoadRecords("ipApp/Db/Digitel.db","P=13BMA:,PUMP=ip7,C=0,IPSLOT=a,CHAN=2",ip)
dbLoadRecords("ipApp/Db/MKS.db","P=13BMA:,C=0,IPSLOT=a,CHAN=3,CC1=cc7,CC2=ccy,PR1=pr7,PR2=pry",ip)
dbLoadRecords("ipApp/Db/MKS.db","P=13BMA:,C=0,IPSLOT=a,CHAN=4,CC1=cc9,CC2=ccyy,PR1=pr9,PR2=pryy",ip)
dbLoadRecords("ipApp/Db/Digitel.db","P=13BMA:,PUMP=ip10,C=0,IPSLOT=a,CHAN=5",ip)
dbLoadRecords("ipApp/Db/MKS.db","P=13BMA:,C=0,IPSLOT=a,CHAN=6,CC1=cc2,CC2=ccyyy,PR1=pr2,PR2=pryyy",ip)
dbLoadRecords("ipApp/Db/Digitel.db","P=13BMA:,PUMP=ip2,C=0,IPSLOT=a,CHAN=7",ip)

dbLoadRecords("CARSApp/Db/generic_serial.db","P=13BMA:,R=ser2,C=0,IPSLOT=b,CHAN=0,BAUD=9600,PRTY=Even,DBIT=7,SBIT=1",top)

dbLoadRecords("CARSApp/Db/Keithley2kDMM_mf.db","P=13BMA:,Dmm=DMM1,C=0,IPSLOT=b,CHAN=1",top)
dbLoadRecords("ipApp/Db/MPC.db","P=13BMA:,PUMP=ip8,C=0,IPSLOT=b,CHAN=2,PA=0,PN=1",ip)
dbLoadRecords("ipApp/Db/MPC.db","P=13BMA:,PUMP=ip9,C=0,IPSLOT=b,CHAN=2,PA=0,PN=2",ip)
dbLoadRecords("ipApp/Db/TSP.db","P=13BMA:,TSP=tsp1,C=0,IPSLOT=b,CHAN=2,PA=0",ip)
dbLoadRecords("ipApp/Db/MKS.db","P=13BMA:,C=0,IPSLOT=b,CHAN=3,CC1=cc8,CC2=ccyyyy,PR1=pr8,PR2=pryyyy",ip)
dbLoadRecords("CARSApp/Db/Keithley2kDMM_mf.db","P=13BMA:,Dmm=DMM2,C=0,IPSLOT=b,CHAN=4",top)

dbLoadTemplate("motors.template")

# BMD filter rack
dbLoadRecords("CARSApp/Db/13BMD_Filters.db","P=13BMA:,R=BMD_Filters,MOTOR=m5",top)

# Digital to analog converter, used for Queensgate piezo drivers
dbLoadTemplate "DAC.template"

# Monochromator PID
dbLoadTemplate "mono_pid.template"
 
### Allstop, alldone
# This database must agree with the motors you've actually loaded.
# Several versions (e.g., all_com_32.db) are in stdApp/Db
# NOTE: this must exist for slit databases to work
dbLoadRecords("stdApp/Db/all_com_24.db","P=13BMA:",std)

### Scan-support software
# crate-resident scan.  This executes 1D, 2D, 3D, and 4D scans, and caches
# 1D data, but it doesn't store anything to disk.  (You need the data catcher
# or the equivalent for that.)  This database is configured to use the
# "alldone" database (above) to figure out when motors have stopped moving
# and it's time to trigger detectors.
dbLoadRecords("stdApp/Db/scan.db","P=13BMA:,MAXPTS1=2000,MAXPTS2=200,MAXPTS3=20,MAXPTS4=10,MAXPTSH=10",std)

# A set of scan parameters for each positioner.  This is a convenience
# for the user.  It can contain an entry for each scannable thing in the
# crate.
dbLoadTemplate("scanParms.template")

# Free-standing user string/number calculations (sCalcout records)
dbLoadRecords("stdApp/Db/userStringCalcs10.db","P=13BMA:",std)

# Free-standing user transforms (transform records)
dbLoadRecords("stdApp/Db/userTransforms10.db","P=13BMA:",std)

# Miscellaneous PV's, such as burtResult
dbLoadRecords("stdApp/Db/misc.db","P=13BMA:",std)

# vxWorks statistics
dbLoadRecords("stdApp/Db/VXstats.db","P=13BMA:",std)

################################################################################
# Setup device/driver support addresses, interrupt vectors, etc.

# OMS VME58 driver setup parameters: 
#     (1)cards, (2)axis per card, (3)base address(short, 4k boundary), 
#     (4)interrupt vector (0=disable or  64 - 255), (5)interrupt level (1 - 6),
#     (6)motor task polling rate (min=1Hz,max=60Hz)
oms58Setup(3, 8, 0x4000, 190, 5, 10)

# PM304 driver setup parameters: 
#     (1) maximum # of controllers, 
#     (2) maximum # axis per controller
#     (3) motor task polling rate (min=1Hz, max=60Hz)
PM304Setup(1, 1, 10)

# PM304 driver configuration parameters: 
#     (1) controller
#     (2) Hideos/MPF card
#     (3) Hideos task
# Example:
#   PM304Config(0, 1, "a-Serial[0]")  Hideos card 1, port 0 on IP slot A.
PM304Config(0, 0, "b-Serial[0]")

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

seq &Keithley2kDMM, "P=13BMA:, Dmm=DMM1, stack=10000"
seq &Keithley2kDMM, "P=13BMA:, Dmm=DMM2, stack=10000"

# Enable user string calcs and user transforms
dbpf "13BMA:EnableUserTrans.PROC","1"
dbpf "13BMA:EnableUserSCalcs.PROC","1"

seq &BM13_Energy, "E=13BMA:E, MONO=13BMA:m17, EXPTAB_Z=13BMD:m22, YXTAL=13BMA:MON:, ZXTAL=13BMA:m14" 

# Mn 20/Mar/02  see note in ioc13ida st.cmd
#  this reduces the readback following error for the McLennan mono controller.
(double) drvPM304ReadbackDelay = 0.2

