< envPaths

epicsEnvSet("STREAM_PROTOCOL_PATH","$(CARS)/db")

## Register all support components
dbLoadDatabase "../../dbd/CARSLinux.dbd"
CARSLinux_registerRecordDeviceDriver pdbbase

epicsEnvSet(WDIG_POINTS, "4096")
# This is the unit labeled NET DEV 1 on the box.
epicsEnvSet(UNIQUE_ID1, "10.54.160.193")
# This is the unit labeled NET DEV 2 on the box. 
epicsEnvSet(UNIQUE_ID2, "10.54.160.10")

epicsEnvSet("PREFIX", "13IDD:LVP:")
epicsEnvSet("MOTOR_PREFIX", "13IDD:")

## Configure port driver
# MultiFunctionConfig((portName,        # The name to give to this asyn port driver
#                      uniqueID,        # For USB the serial number.  For Ethernet the MAC address or IP address.
#                      maxInputPoints,  # Maximum number of input points for waveform digitizer
#                      maxOutputPoints) # Maximum number of output points for waveform generator
MultiFunctionConfig("E1608_1", $(UNIQUE_ID1), $(WDIG_POINTS), 1)
MultiFunctionConfig("E1608_2", $(UNIQUE_ID2), $(WDIG_POINTS), 1)

#asynSetTraceMask E1608_1 -1 255
#asynSetTraceMask E1608_2 -1 255

dbLoadTemplate("$(MEASCOMP)/db/E1608.substitutions", "P=$(PREFIX)MC1:,PORT=E1608_1,WDIG_POINTS=$(WDIG_POINTS)")
dbLoadTemplate("$(MEASCOMP)/db/E1608.substitutions", "P=$(PREFIX)MC2:,PORT=E1608_2,WDIG_POINTS=$(WDIG_POINTS)")
dbLoadTemplate("pid_slow.substitutions")

# Serial ports on on Moxa 4 port terminal server at gsets10
drvAsynIPPortConfigure("serial1", "gsets10:4001")
drvAsynIPPortConfigure("serial2", "gsets10:4002")
drvAsynIPPortConfigure("serial3", "gsets10:4003")
asynOctetSetInputEos("serial1",0,"\r")
asynOctetSetOutputEos("serial1",0,"\r")
asynOctetSetInputEos("serial2",0,"\r\n")
asynOctetSetOutputEos("serial2",0,"\n")
asynOctetSetInputEos("serial3",0,"\r\n")
asynOctetSetOutputEos("serial3",0,"\n")
dbLoadTemplate("asynRecord.template")

dbLoadRecords("$(IP)/db/Keithley2kDMM_mf.db", "P=$(PREFIX),Dmm=DMM3,PORT=serial2")
dbLoadRecords("$(IP)/db/Keithley2kDMM_mf.db", "P=$(PREFIX),Dmm=DMM4,PORT=serial3")

# Galil motors
iocshLoad("Galil.cmd", "P=$(MOTOR_PREFIX)")
 
# LVP pressure control.  This talks to the Omega meter.
dbLoadTemplate("LVP_pressure_control.template")

# LVP furnace controls
dbLoadTemplate("LVP_furnace_control.template")

# LVP Theta (temperature ramping) controller
dbLoadRecords("$(CARS)/db/RampScan.db","P=$(PREFIX),R=Theta1_,DRV=LVP:PID1.VAL,RBV=LVP_furnace_calcs.E")

< ../calc_GSECARS.iocsh

### Scan-support software
dbLoadRecords("$(SSCAN)/db/scan.db", "P=$(PREFIX),MAXPTS1=2000,MAXPTS2=200,MAXPTS3=20,MAXPTS4=10,MAXPTSH=10")

# devIocStats
epicsEnvSet("ENGINEER", "Mark Rivers")
epicsEnvSet("LOCATION","13IDD")
epicsEnvSet("GROUP","GSECARS")
dbLoadRecords("$(DEVIOCSTATS)/db/iocAdminSoft.db","IOC=$(PREFIX)")

< ../save_restore_IOCSH.cmd

var recDynLinkQsize 1024
iocInit

seq &Keithley2kDMM, "P=$(PREFIX), Dmm=DMM3, stack=10000"
seq &Keithley2kDMM, "P=$(PREFIX), Dmm=DMM4, stack=10000"

# save positions every five seconds
create_monitor_set("auto_positions.req",5,"P=$(MOTOR_PREFIX)")
# save other things every thirty seconds
create_monitor_set("auto_settings.req",30,"P=$(PREFIX),MP=$(MOTOR_PREFIX)")

# Set the scale factor for the LVP Press Camera DIFF calculation
# This causes a move pm17 of 1 unit to move each real motor by 1 unit, rather than 0.5 units
dbpf("13IDD:pm17C1.VAL", "0.5")

# Need to force the time arrays to process because the records are scan=I/O Intr
# but asynPortDriver does not do array callbacks before iocInit.

dbpf $(PREFIX)MC1:WaveDigDwell.PROC 1
dbpf $(PREFIX)MC2:WaveDigDwell.PROC 1
