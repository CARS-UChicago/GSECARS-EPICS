# vxWorks startup file
< cdCommands

< ../nfsCommandsGSE

cd topbin
ld < CARS167.munch
cd startup

# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in this build from CARSApp
dbLoadDatabase("$(CARS)/dbd/CARS167.dbd")
CARS167_registerRecordDeviceDriver(pdbbase)

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
devScalerCamacDebug=0
devE500Debug=0
drvE500Debug=0
icbDebug=0
devIcbMpfDebug=1
icbDspServerDebug=1
icbServerDebug=1
mpcDebug=0
devMPCDebug=0

# This IOC loads the MPF server code locally
< st_mpfserver.cmd

dbLoadRecords("$(CARS)/CARSApp/Db/generic_serial.db","P=13LAB2:,R=ser1,C=0,SERVER=serial1")
#dbLoadRecords("$(IP)/ipApp/Db/Digitel.db","P=13LAB2:,PUMP=ip1,C=0,SERVER=serial1")
dbLoadRecords("$(CARS)/CARSApp/Db/generic_serial.db","P=13LAB2:,R=ser2,C=0,SERVER=serial2")
#dbLoadRecords("$(IP)/ipApp/Db/MKS_single.db","P=13LAB2:,C=0,SERVER=serial2,CC1=cc1,PR1=pr1")
dbLoadRecords("$(CARS)/CARSApp/Db/generic_serial.db","P=13LAB2:,R=ser3,C=0,SERVER=serial3")
dbLoadRecords("$(IP)/ipApp/Db/Keithley2kDMM_mf.db","P=13LAB2:,Dmm=DMM1,C=0,SERVER=serial3")
#dbLoadRecords("$(CARS)/CARSApp/Db/generic_serial.db","P=13LAB2:,R=ser4,C=0,SERVER=serial4")
#dbLoadRecords("$(IP)/ipApp/Db/MPC.db","P=13LAB2:,PUMP=ip1,C=0,SERVER=serial4,PA=0,PN=1")
#dbLoadRecords("$(IP)/ipApp/Db/MPC.db","P=13LAB2:,PUMP=ip2,C=0,SERVER=serial4,PA=0,PN=2")
#dbLoadRecords("$(IP)/ipApp/Db/TSP.db","P=13LAB2:,TSP=tsp1,C=0,SERVER=serial4,PA=0")

#MN Aug-22-2003: Config SR570s
dbLoadRecords("$(IP)/ipApp/Db/SR570.db", "P=13LAB2:,A=A1,C=0,SERVER=serial7")
dbLoadRecords("$(IP)/ipApp/Db/SR570.db", "P=13LAB2:,A=A2,C=0,SERVER=serial8")
#

# generic serial port
# Port 5 has Newport LAE500 Laser Autocollimator (and generic serial port)
dbLoadRecords("$(CARS)/CARSApp/Db/LAE500.db","P=13LAB2:,R=LAE500,C=0,SERVER=serial5")
dbLoadRecords("$(CARS)/CARSApp/Db/generic_serial.db","P=13LAB2:,R=ser5,C=0,SERVER=serial5")

### Motors
dbLoadTemplate  "motors.template"

# A set of scan parameters for each positioner.  This is a convenience
# for the user.  It can contain an entry for each scannable thing in the
# crate.
dbLoadTemplate "scanParms.template"

### Allstop, alldone
# This database must agree with the motors you've actually loaded.
# Several versions (e.g., all_com_32.db) are in std/stdApp/Db
dbLoadRecords("$(STD)/stdApp/Db/all_com_8.db","P=13LAB2:")

### Scan-support software
# crate-resident scan.  This executes 1D, 2D, 3D, and 4D scans, and caches
# 1D data, but it doesn't store anything to disk.  (You need the data catcher
# or the equivalent for that.)  This database is configured to use the
# "alldone" database (above) to figure out when motors have stopped moving
# and it's time to trigger detectors.
dbLoadRecords("$(SSCAN)/sscanApp/Db/scan.db","P=13LAB2:,MAXPTS1=2000,MAXPTS2=10,MAXPTS3=10,MAXPTS4=10,MAXPTSH=10")

# Free-standing user string/number calculations (sCalcout records)
dbLoadRecords("$(CALC)/calcApp/Db/userStringCalcs10.db","P=13LAB2:")

# Free-standing user transforms (transform records)
dbLoadRecords("$(CALC)/calcApp/Db/userTransforms10.db","P=13LAB2:")

# vme test record
dbLoadRecords("$(VME)/vmeApp/Db/vme.db", "P=13LAB2:,Q=vme1")

# Miscellaneous PV's, such as burtResult
dbLoadRecords("$(STD)/stdApp/Db/misc.db","P=13LAB2:")

# vxWorks statistics
dbLoadTemplate("vxStats.substitutions")


################################################################################
# Setup device/driver support addresses, interrupt vectors, etc.

# OMS VME58 driver setup parameters: 
#     (1)cards, (2)axis per card, (3)base address(short, 4k boundary), 
#     (4)interrupt vector (0=disable or  64 - 255), (5)interrupt level (1 - 6),
#     (6)motor task polling rate (min=1Hz,max=60Hz)
oms58Setup(1, 8, 0x4000, 190, 5, 10)

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

seq &Keithley2kDMM, "P=13LAB2:, Dmm=DMM1, stack=10000"
