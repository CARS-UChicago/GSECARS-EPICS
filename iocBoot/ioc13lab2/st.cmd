# vxWorks startup file

< cdCommands

< ../nfsCommandsGSE

cd topbin
ld < CARSApp.munch
cd startup

# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in this build from CARSApp
dbLoadDatabase("$(CARS)/dbd/CARSVX.dbd")
CARSVX_registerRecordDeviceDriver(pdbbase)

< industryPack.cmd
< serial.cmd

# Load asyn records on all serial ports
dbLoadTemplate("asynRecord.template")

dbLoadRecords("$(IP)/ipApp/Db/Keithley2kDMM_mf.db","P=13LAB2:,Dmm=DMM1,C=0,PORT=serial1")

dbLoadRecords("$(IP)/ipApp/Db/SR570.db", "P=13LAB2:,A=A1,C=0,PORT=serial2")
dbLoadRecords("$(IP)/ipApp/Db/SR570.db", "P=13LAB2:,A=A2,C=0,PORT=serial3")

# Port 4 has Newport LAE500 Laser Autocollimator (and generic serial port)
dbLoadRecords("$(CARS)/CARSApp/Db/LAE500.db","P=13LAB2:,R=LAE500,C=0,PORT=serial4")

# Acromag Ip330 ADC
#dbLoadTemplate "Ip330_ADC.template"

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
#     (1)cards, (2)base address(short, 4k boundary),
#     (3)interrupt vector (0=disable or  64 - 255), (4)interrupt level (1 - 6),
#     (5)motor task polling rate (min=1Hz,max=60Hz)
oms58Setup(1, 0x4000, 190, 5, 10)

# dbrestore setup
sr_restore_incomplete_sets_ok = 1
#reboot_restoreDebug=5
< ../save_restore.cmd
save_restoreSet_status_prefix("13LAB2:")
dbLoadRecords("$(AUTOSAVE)/asApp/Db/save_restoreStatus.db", "P=13LAB2:")

iocInit

### Start up the autosave task and tell it what to do.
# The task is actually named "save_restore".
# (See also, 'initHooks' above, which is the means by which the values that
# will be saved by the task we're starting here are going to be restored.
#
# save positions every five seconds
create_monitor_set("auto_positions.req",5)
# save other things every thirty seconds
create_monitor_set("auto_settings.req",30)

seq &Keithley2kDMM, "P=13LAB2:, Dmm=DMM1, stack=10000"
