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

dbLoadRecords("$(IP)/db/Keithley2kDMM_mf.db", "P=$(PREFIX),Dmm=DMM3,PORT=serial2")
dbLoadRecords("$(IP)/db/Keithley2kDMM_mf.db", "P=$(PREFIX),Dmm=DMM4,PORT=serial3")

# LVP pressure control.  This talks to the Omega meter.
dbLoadTemplate("LVP_pressure_control.template")

# LVP furnace controls
dbLoadTemplate("LVP_furnace_control.template")

# LVP Theta (temperature ramping) controller
dbLoadRecords("$(CARS)/db/RampScan.db","P=$(PREFIX),R=Theta1_,DRV=LVP:PID1.VAL,RBV=LVP_furnace_calcs.E")

var aimDebug 1
# Multichannel analyzer stuff
# AIMConfig(portName, ethernet_address, portNumber(1 or 2), maxChans,
#           maxSignals, maxSequences, ethernetDevice)
#AIMConfig("NI3ED/1", 0x59E, 1, 4000, 1, 1,"p5p1")
#AIMConfig("NI3ED/2", 0x59E, 2, 4000, 1, 1,"p5p1")
#dbLoadRecords("$(MCA)/db/mca.db", "P=13IDD:,M=aim_adc1,DTYP=asynMCA,INP=@asyn(NI3ED/1 0),NCHAN=4000")
#dbLoadRecords("$(MCA)/db/mca.db", "P=13IDD:,M=aim_mcs1,DTYP=asynMCA,INP=@asyn(NI3ED/2 0),NCHAN=4000")

#icbConfig(portName, module, ethernetAddress, icbAddress, moduleType)
#   portName to give to this asyn port
#   ethernetAddress - Ethernet address of module, low order 16 bits
#   ethernetAddress - Ethernet address of module, low order 16 bits
#   icbAddress - rotary switch setting inside ICB module
#   moduleType
#      0 = ADC
#      1 = Amplifier
#      2 = HVPS
#      3 = TCA
#      4 = DSP
#icbConfig("icbAdc1", 0x59E, 5, 0)
#dbLoadRecords("$(MCA)/db/icb_adc.db", "P=13IDD:,ADC=adc1,PORT=icbAdc1")
#icbConfig("icbAmp1", 0x59E, 3, 1)
#dbLoadRecords("$(MCA)/db/icb_amp.db", "P=13IDD:,AMP=amp1,PORT=icbAmp1")
#icbConfig("icbHvps1", 0x59E, 2, 2)
#dbLoadRecords("$(MCA)/db/icb_hvps.db", "P=13IDD:,HVPS=hvps1,PORT=icbHvps1,LIMIT=1000")


< ../calc_GSECARS.iocsh

### Scan-support software
dbLoadRecords("$(SSCAN)/db/scan.db", "P=$(PREFIX),MAXPTS1=2000,MAXPTS2=200,MAXPTS3=20,MAXPTS4=10,MAXPTSH=10")

< ../save_restore_IOCSH.cmd

var recDynLinkQsize 1024
iocInit

seq &Keithley2kDMM, "P=$(PREFIX), Dmm=DMM3, stack=10000"
seq &Keithley2kDMM, "P=$(PREFIX), Dmm=DMM4, stack=10000"

create_monitor_set("auto_settings.req",30,"P=$(PREFIX)")

# Need to force the time arrays to process because the records are scan=I/O Intr
# but asynPortDriver does not do array callbacks before iocInit.

dbpf $(PREFIX)MC1:WaveDigDwell.PROC 1
dbpf $(PREFIX)MC2:WaveDigDwell.PROC 1
