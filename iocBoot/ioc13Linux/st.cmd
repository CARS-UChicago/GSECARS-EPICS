errlogInit(5000)
< envPaths
# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in this build from CARS
dbLoadDatabase("../../dbd/CARS.dbd")
CARS_registerRecordDeviceDriver(pdbbase)

routerInit
localMessageRouterStart(0)

var aimDebug,0
var icbDebug,10
var dxpRecordDebug,0
var mcaDXPServerDebug,0
var devDxpMpfDebug,0
var

# Set up 2 serial ports
#initTtyPort("serial1", "/dev/ttyS0", 9600, "N", 1, 8, "N", 1000)
#initTtyPort("serial1", "/dev/ttyS0", 115200, "N", 1, 8, "N", 1000)
initTtyPort("serial2", "/dev/ttyS1", 19200, "N", 1, 8, "N", 1000)
initSerialServer("serial1", "serial1", 1000, 20, "")
initSerialServer("serial2", "serial2", 1000, 20, "")

# Load test database
dbLoadDatabase("test.db","", "P1=mytest")

# Serial 1 Keithley Multimeter
dbLoadRecords("$(IP)/ipApp/Db/Keithley2kDMM_mf.db", "P=13Linux:,Dmm=DMM1,C=0,SERVER=serial1")
dbLoadRecords("$(CARS)/CARSApp/Db/generic_serial.db", "P=13Linux:,R=ser1,C=0,SERVER=serial1")

# Serial 2 for the MM4000.  We have both motor record and generic serial record
dbLoadRecords("$(CARS)/CARSApp/Db/generic_serial.db", "P=13Linux:,R=ser2,C=0,SERVER=serial2")

#PID slow
dbLoadTemplate "pid_slow.template"

### Motors
dbLoadTemplate  "motors.template"

# Experiment description
dbLoadRecords("$(CARS)/CARSApp/Db/experiment_info.db", "P=13Linux:")

#MN
dbLoadRecords("$(CARS)/CARSApp/Db/scanner.db", "P=13Linux:,Q=EDB")

# A set of scan parameters for each positioner.  This is a convenience
# for the user.  It can contain an entry for each scannable thing in the
# crate.
dbLoadTemplate "scanParms.template"

# Multichannel analyzer stuff
# AIMConfig(mpfServer, card, ethernet_address, port, maxChans, 
#           maxSignals, maxSequences, ethernetDevice, queueSize)
AIMConfig("AIM1/1", 0x59e, 1, 2048, 1, 1, "eth0", 100)
AIMConfig("AIM1/2", 0x59e, 2, 2048, 8, 1, "eth0", 400)
dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=13Linux:,M=aim_adc1,DTYPE=MPF MCA,INP=#C0 S0 @AIM1/1,NCHAN=2048")
dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=13Linux:,M=aim_adc2,DTYPE=MPF MCA,INP=#C0 S0 @AIM1/2,NCHAN=2048")
dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=13Linux:,M=aim_adc3,DTYPE=MPF MCA,INP=#C0 S2 @AIM1/2,NCHAN=2048")
dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=13Linux:,M=aim_adc4,DTYPE=MPF MCA,INP=#C0 S4 @AIM1/2,NCHAN=2048")
dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=13Linux:,M=aim_adc5,DTYPE=MPF MCA,INP=#C0 S6 @AIM1/2,NCHAN=2048")

#icbDspConfig("icbDsp/1", 1, "NI59E:1", 100)
#dbLoadRecords("mcaApp/Db/icbDsp.db", "P=13Linux:,DSP=dsp1,CARD=0,SERVER=icbDsp/1,ADDR=0")
icbSetup("icb/1", 10, 100)
#icbConfig("icb/1", 0, 0x59e, 5)
dbLoadRecords("$(MCA)/mcaApp/Db/icb_adc.db", "P=13Linux:,ADC=adc1,CARD=0,SERVER=icb/1,ADDR=0")
icbConfig("icb/1", 1, 0x59e, 3)
dbLoadRecords("$(MCA)/mcaApp/Db/icb_amp.db", "P=13Linux:,AMP=amp1,CARD=0,SERVER=icb/1,ADDR=1")
icbConfig("icb/1", 2, 0x59e, 2)
dbLoadRecords("$(MCA)/mcaApp/Db/icb_hvps.db", "P=13Linux:,HVPS=hvps1,CARD=0,SERVER=icb/1,ADDR=2, LIMIT=1000")

#icbTcaSetup(serverName, maxModules, queueSize)
icbTcaSetup("icbTca/1", 10, 100)
#icbTcaConfig(serverName, module, ethernetAddress, icbAddress)
icbTcaConfig("icbTca/1", 0, 0x59e, 8)
dbLoadRecords("$(MCA)/mcaApp/Db/icb_tca.db", "P=13Linux:,TCA=tca1,MCA=aim_adc2,CARD=0,SERVER=icbTca/1,ADDR=0")

# DXP and mca records for the Vortex detector
< vortex.cmd

### Allstop, alldone
# This database must agree with the motors you've actually loaded.
# Several versions (e.g., all_com_32.db) are in stdApp/Db
dbLoadRecords("$(STD)/stdApp/Db/all_com_8.db", "P=13Linux:")

### Scan-support software
# crate-resident scan.  This executes 1D, 2D, 3D, and 4D scans, and caches
# 1D data, but it doesn't store anything to disk.  (You need the data catcher
# or the equivalent for that.)  This database is configured to use the
# "alldone" database (above) to figure out when motors have stopped moving
# and it's time to trigger detectors.
dbLoadRecords("$(STD)/stdApp/Db/scan.db", "P=13Linux:,MAXPTS1=2000,MAXPTS2=200,MAXPTS3=20,MAXPTS4=10,MAXPTSH=10")

# Free-standing user string/number calculations (sCalcout records)
dbLoadRecords("$(STD)/stdApp/Db/userStringCalcs10.db", "P=13Linux:")

# Free-standing user transforms (transform records)
dbLoadRecords("$(STD)/stdApp/Db/userTransforms10.db", "P=13Linux:")

# Miscellaneous PV's, such as burtResult
dbLoadRecords("$(STD)/stdApp/Db/misc.db", "P=13Linux:")

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
MM4000Config(0, 1, 0, "serial2")
# Delay to allow motors to settle
drvMM4000ReadbackDelay=.5  

initInetPort("moxa1","164.54.160.50",4001,1000) 
initSerialServer("serial3","moxa1",1000,20,"") 
  
dbLoadRecords("$(CARS)/CARSApp/Db/generic_serial.db", "P=13Linux:,R=ser3,C=0,SERVER=serial3") 

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
dbpf "13Linux:EnableUserTrans.PROC","1"
dbpf "13Linux:EnableUserSCalcs.PROC","1"

seq &Keithley2kDMM, "P=13Linux:, Dmm=DMM1, stack=10000"
