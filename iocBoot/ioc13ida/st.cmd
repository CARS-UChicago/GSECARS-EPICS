# vxWorks startup file for 13IDA ioc

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

# Debugging flags
devPM304Debug=0
drvPM304Debug=0

# need more entries in Wait-record channel-access queue (?)
recDynLinkQsize = 1024

# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in this build.
dbLoadDatabase("../../dbd/CARSApp.dbd")


# Set up the Allen-Bradley 6008 scanner
abConfigNlinks 1
abConfigVme 0,0xc00000,0x60,5
abConfigAuto

# Load database
dbLoadRecords  "CARSApp/Db/eps_valid.db", "P=13IDA:", top
dbLoadTemplate  "eps_inputs.template"
dbLoadTemplate  "eps_outputs.template"
dbLoadTemplate  "eps_valves.template"
dbLoadRecords "ipApp/Db/MKS.db","P=13IDA:,C=0,IPSLOT=a,CHAN=0,CC1=cc1,CC2=cc3,PR1=pr1,PR2=pr3", ip
dbLoadRecords "ipApp/Db/MKS.db","P=13IDA:,C=0,IPSLOT=a,CHAN=1,CC1=cc2,CC2=ccA,PR1=pr2,PR2=prA", ip
dbLoadRecords "ipApp/Db/Digitel.db","P=13IDA:,PUMP=ip1,C=0,IPSLOT=a,CHAN=2", ip
dbLoadRecords "ipApp/Db/Digitel.db","P=13IDA:,PUMP=ip3,C=0,IPSLOT=a,CHAN=3", ip
dbLoadRecords "ipApp/Db/MKS.db","P=13IDA:,C=0,IPSLOT=a,CHAN=4,CC1=cc5,CC2=cc6,PR1=pr5,PR2=pr6", ip
dbLoadRecords "ipApp/Db/Digitel.db","P=13IDA:,PUMP=ip5,C=0,IPSLOT=a,CHAN=5", ip
#dbLoadRecords "CARSApp/Db/MPC.db","P=13IDA:,PUMP=ip2,C=0,IPSLOT=a,CHAN=6", top
dbLoadRecords("ipApp/Db/MPC.db","P=13IDA:,PUMP=ip2,C=0,IPSLOT=a,CHAN=6,PA=0,PN=1", ip)
dbLoadRecords "CARSApp/Db/Keithley2kDMM_mf.db","P=13IDA:,Dmm=DMM1,C=0,IPSLOT=b,CHAN=0", top
# a-Serial[7] is McClennan PM-304 motor controller
dbLoadRecords "CARSApp/Db/generic_serial.db","P=13IDA:,R=ser1,C=0,IPSLOT=a,CHAN=7,BAUD=9600,PRTY=Even,DBIT=7,SBIT=1", top
dbLoadRecords "CARSApp/Db/ILM200.db","P=13IDA:,R=ILM200,C=0,IPSLOT=b,CHAN=1", top
dbLoadRecords "CARSApp/Db/generic_serial.db","P=13IDA:,R=ser2,C=0,IPSLOT=b,CHAN=2,BAUD=19200,PRTY=Even,DBIT=8,SBIT=1", top
dbLoadRecords "ipApp/Db/MKS.db","P=13IDA:,C=0,IPSLOT=b,CHAN=2,CC1=cc7,CC2=ccB,PR1=pr7,PR2=prB", ip
dbLoadRecords("ipApp/Db/MPC.db","P=13IDA:,PUMP=ip6,C=0,IPSLOT=b,CHAN=3,PA=0,PN=1", ip)
dbLoadRecords("ipApp/Db/MPC.db","P=13IDA:,PUMP=ip7,C=0,IPSLOT=b,CHAN=3,PA=0,PN=2", ip)
dbLoadRecords("ipApp/Db/TSP.db","P=13IDA:,TSP=tsp1,C=0,IPSLOT=b,CHAN=3,PA=0", ip)

dbLoadRecords "CARSApp/Db/Keithley2kDMM_mf.db","P=13IDA:,Dmm=DMM2,C=0,IPSLOT=b,CHAN=4", top

#dbLoadRecords "CARSApp/Db/generic_gpib.db","P=13IDA:,R=gpib1,SIZE=2048", top

dbLoadTemplate "motors.template"

# Digital to analog converter, used for Queensgate piezo drivers
dbLoadTemplate "DAC.template"

# Monochromator PID
dbLoadTemplate "mono_pid.template"

### Allstop, alldone
# This database must agree with the motors you've actually loaded.
# Several versions (e.g., all_com_32.db) are in std/stdApp/Db
dbLoadRecords("stdApp/Db/all_com_16.db","P=13IDA:", std)

### Scan-support software
# crate-resident scan.  This executes 1D, 2D, 3D, and 4D scans, and caches
# 1D data, but it doesn't store anything to disk.  (You need the data catcher
# or the equivalent for that.)  This database is configured to use the
# "alldone" database (above) to figure out when motors have stopped moving
# and it's time to trigger detectors.
dbLoadRecords("stdApp/Db/scan.db","P=13IDA:,MAXPTS1=500,MAXPTS2=50,MAXPTS3=10,MAXPTS4=10,MAXPTSH=10", std)

# A set of scan parameters for each positioner.  This is a convenience
# for the user.  It can contain an entry for each scannable thing in the
# crate.
dbLoadTemplate "scanParms.template"

#  load the databases for the MSL MRD100 module ...
dbLoadRecords ("stdApp/Db/msl_mrd101.db","C=0,S=13,ID1=13,ID2=13us", std)

# Miscellaneous PV's, such as burtResult
dbLoadRecords("stdApp/Db/misc.db","P=13IDA:", std)

# vxWorks statistics
dbLoadRecords("stdApp/Db/VXstats.db","P=13IDA:", std)

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
#     (2) Hideos/MPF card
#     (3) Hideos task/MPF server
# Example:
#   PM304Config(0, 1, "a-Serial[0]")  Hideos card 1, port 0 on IP slot A.
PM304Config(0, 0, "a-Serial[7]")

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

seq &Keithley2kDMM, "P=13IDA:, Dmm=DMM1, stack=10000"
seq &Keithley2kDMM, "P=13IDA:, Dmm=DMM2, stack=10000"

##MATT 08/May/2001
seq &Energy, "ID=ID13:, E=13IDA:E, MONO=13IDA:m17, EXPTAB_Z=13IDC:m6, XTAL=13IDA:MON:, SHUTTER=13IDA:eps_mbbi4" 

# For the bypass valves swap the severity of the open and closed states
dbpf "13IDA:V5_status.ONSV","MAJOR"
dbpf "13IDA:V5_status.TWSV","NO_ALARM"
dbpf "13IDA:V6_status.ONSV","MAJOR"
dbpf "13IDA:V6_status.TWSV","NO_ALARM"
