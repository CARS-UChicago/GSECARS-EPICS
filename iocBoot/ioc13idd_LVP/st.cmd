< envPaths

## Register all support components
dbLoadDatabase "../../dbd/CARSLinux.dbd"
CARSLinux_registerRecordDeviceDriver pdbbase

epicsEnvSet(INPUT_POINTS, "4096")
epicsEnvSet(OUTPUT_POINTS, "4096")

epicsEnvSet("PREFIX", "13IDD:LVP:")

# This is the unit labeled NET DEV 1 on the box. It will be boardNum 0.
cbAddBoard("E-1608", "164.54.160.2")
# This is the unit labeled NET DEV 2 on the box.  It will be boardNum 1.
cbAddBoard("E-1608", "164.54.160.10")

## Configure port driver
# MultiFunctionConfig((portName,        # The name to give to this asyn port driver
#                      boardNum,        # The number of this board assigned by the Measurement Computing Instacal program 
#                      maxInputPoints,  # Maximum number of input points for waveform digitizer
#                      maxOutputPoints) # Maximum number of output points for waveform generator
MultiFunctionConfig("E1608_1", 0, $(INPUT_POINTS), $(OUTPUT_POINTS))
MultiFunctionConfig("E1608_2", 1, $(INPUT_POINTS), $(OUTPUT_POINTS))

#asynSetTraceMask E1608_1 -1 255
#asynSetTraceMask E1608_2 -1 255

dbLoadTemplate("E1608.substitutions")
dbLoadTemplate("pid_slow.substitutions")

# Serial ports on on Moxa 4 port terminal server at 164.54.160.88
drvAsynIPPortConfigure("serial1", "164.54.160.88:4001")
drvAsynIPPortConfigure("serial2", "164.54.160.88:4002")
drvAsynIPPortConfigure("serial3", "164.54.160.88:4003")
asynOctetSetInputEos("serial1",0,"\r")
asynOctetSetOutputEos("serial1",0,"\r")
asynOctetSetInputEos("serial2",0,"\r\n")
asynOctetSetOutputEos("serial2",0,"\n")
asynOctetSetInputEos("serial3",0,"\r\n")
asynOctetSetOutputEos("serial3",0,"\n")
dbLoadTemplate("asynRecord.template")

dbLoadRecords("$(IP)/ipApp/Db/Keithley2kDMM_mf.db", "P=$(PREFIX),Dmm=DMM3,PORT=serial2")
dbLoadRecords("$(IP)/ipApp/Db/Keithley2kDMM_mf.db", "P=$(PREFIX),Dmm=DMM4,PORT=serial3")

# LVP pressure control.  This talks to the Omega meter.
dbLoadTemplate("LVP_pressure_control.template")

# LVP furnace controls
dbLoadTemplate("LVP_furnace_control.template")

# LVP Theta (temperature ramping) controller
dbLoadRecords("$(CARS)/CARSApp/Db/RampScan.db","P=$(PREFIX),R=Theta1_,DRV=LVP:PID1.VAL,RBV=LVP_furnace_calcs.E")


< ../calc_GSECARS.iocsh

### Scan-support software
dbLoadRecords("$(SSCAN)/sscanApp/Db/scan.db", "P=$(PREFIX),MAXPTS1=2000,MAXPTS2=200,MAXPTS3=20,MAXPTS4=10,MAXPTSH=10")

< ../save_restore_IOCSH.cmd

iocInit

seq &Keithley2kDMM, "P=$(PREFIX), Dmm=DMM3, stack=10000"
seq &Keithley2kDMM, "P=$(PREFIX), Dmm=DMM4, stack=10000"

create_monitor_set("auto_settings.req",30,"P=$(PREFIX)")

# Need to force the time arrays to process because the records are scan=I/O Intr
# but asynPortDriver does not do array callbacks before iocInit.

dbpf $(PREFIX)MC1:WaveDigDwell.PROC 1
dbpf $(PREFIX)MC2:WaveDigDwell.PROC 1
