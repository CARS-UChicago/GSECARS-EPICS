errlogInit(5000)
< envPaths
# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in this build from CARS
dbLoadDatabase("../../dbd/CARSLinux.dbd")
CARSLinux_registerRecordDeviceDriver(pdbbase)

var aimDebug,0
var icbDebug,0
var dxpRecordDebug,0
var

< serial.cmd

# Load asyn records on each of these ports
dbLoadTemplate("asynRecord.template")

# Serial 1 Keithley Multimeter
#dbLoadRecords("$(IP)/ipApp/Db/Keithley2kDMM_mf.db", "P=13Linux:,Dmm=DMM1,C=0,SERVER=serial1")

#PID slow
dbLoadTemplate "pid_slow.template"

### Motors
dbLoadTemplate  "motors.template"

# Experiment description
dbLoadRecords("$(CARS)/db/experiment_info.db", "P=13Linux:")

#MN
dbLoadRecords("$(CARS)/db/scanner.db", "P=13Linux:,Q=EDB")

# A set of scan parameters for each positioner.  This is a convenience
# for the user.  It can contain an entry for each scannable thing in the
# crate.
dbLoadTemplate "scanParms.template"

# Multichannel analyzer stuff
# AIMConfig(portName, ethernet_address, portNumber(1 or 2), maxChans,
#           maxSignals, maxSequences, ethernetDevice)
#AIMConfig("AIM1/1", 0x59e, 1, 2048, 1, 1, "eth0")
#AIMConfig("AIM1/2", 0x59e, 2, 2048, 8, 1, "eth0")
#AIMConfig("DSA2000", 0x8058, 1, 2048, 1, 1, "eth0")
#dbLoadRecords("$(MCA)/db/mca.db", "P=13Linux:,M=aim_adc1,DTYP=asynMCA,INP=@asyn(AIM1/1 0),NCHAN=2048")
#dbLoadRecords("$(MCA)/db/mca.db", "P=13Linux:,M=aim_adc2,DTYP=asynMCA,INP=@asyn(AIM1/2 0),NCHAN=2048")

#icbConfig(portName, module, ethernetAddress, icbAddress, moduleType)
#   portName to give to this asyn port
#   ethernetAddress - Ethernet address of module, low order 16 bits
#   icbAddress - rotary switch setting inside ICB module
#   moduleType
#      0 = ADC
#      1 = Amplifier
#      2 = HVPS
#      3 = TCA
#      4 = DSP
#icbConfig("icbAdc1", 0x59e, 5, 0)
#dbLoadRecords("$(MCA)/db/icb_adc.db", "P=13Linux:,ADC=adc1,PORT=icbAdc1")
#icbConfig("icbAmp1", 0x59e, 3, 1)
#dbLoadRecords("$(MCA)/db/icb_amp.db", "P=13Linux:,AMP=amp1,PORT=icbAmp1")
#icbConfig("icbHvps1", 0x59e, 2, 2)
#dbLoadRecords("$(MCA)/db/icb_hvps.db", "P=13Linux:,HVPS=hvps1,PORT=icbHvps1,LIMIT=1000")
#icbConfig("icbTca1", 0x59e, 8, 3)
#dbLoadRecords("$(MCA)/db/icb_tca.db", "P=13Linux:,TCA=tca1,MCA=aim_adc2,PORT=icbTca1")
##icbConfig("icbDsp1", 0x8058, 0, 4)
#dbLoadRecords("$(MCA)/db/icbDsp.db", "P=13Linux:,DSP=dsp1,PORT=icbDsp1")

# Roper CCD detector database
#dbLoadRecords("$(CCD)/ccdApp/Db/ccd.db", "P=13Linux:, C=ccd1")

# MAR CCD detector database
#dbLoadRecords("$(CCD)/ccdApp/Db/ccd.db", "P=13Linux:, C=ccd2")

# DXP and mca records for the Vortex detector
#< vortex.cmd

### Allstop, alldone
# This database must agree with the motors you've actually loaded.
# Several versions (e.g., all_com_32.db) are in stdApp/Db
dbLoadRecords("$(STD)/db/all_com_8.db", "P=13Linux:")

### Scan-support software
# crate-resident scan.  This executes 1D, 2D, 3D, and 4D scans, and caches
# 1D data, but it doesn't store anything to disk.  (You need the data catcher
# or the equivalent for that.)  This database is configured to use the
# "alldone" database (above) to figure out when motors have stopped moving
# and it's time to trigger detectors.
dbLoadRecords("$(SSCAN)/sscanApp/Db/scan.db", "P=13Linux:,MAXPTS1=2000,MAXPTS2=200,MAXPTS3=20,MAXPTS4=10,MAXPTSH=10")

# Free-standing user string/number calculations (sCalcout records)
dbLoadRecords("$(CALC)/calcApp/Db/userStringCalcs10.db", "P=13Linux:")

# Free-standing user transforms (transform records)
dbLoadRecords("$(CALC)/calcApp/Db/userTransforms10.db", "P=13Linux:")

# Miscellaneous PV's, such as burtResult
dbLoadRecords("$(STD)/db/misc.db", "P=13Linux:")

< ../save_restore_IOCSH.cmd
save_restoreSet_status_prefix("13Linux:")
dbLoadRecords("$(AUTOSAVE)/asApp/Db/save_restoreStatus.db", "P=13Linux:")

asynSetTraceMask serial3 0 3
asynSetTraceIOMask serial3 0 2
iocInit

dbpr "13Linux:ccd1ServerName"
dbpr "13Linux:ccd1ServerPort"

# save positions every five seconds
create_monitor_set("auto_positions.req", 5, "P=13Linux:")
# save other things every thirty seconds
create_monitor_set("auto_settings.req", 30, "P=13Linux:")

# Enable user string calcs and user transforms
dbpf "13Linux:EnableUserTrans.PROC","1"
dbpf "13Linux:EnableUserSCalcs.PROC","1"

#seq &roperCCD, "P=13Linux:,C=ccd1"
#seq &marCCD, "P=13Linux:,C=ccd2"
seq &Keithley2kDMM, "P=13Linux:, Dmm=DMM1, model=2700, stack=10000"

