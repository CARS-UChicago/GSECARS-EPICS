
# BEGIN serial.cmd ------------------------------------------------------------

# Set up 2 local serial ports

# serial 1 connected to Keithley2K DMM at 19200 baud
#drvAsynSerialPortConfigure("portName","ttyName",priority,noAutoConnect,
#                            noProcessEos)
drvAsynSerialPortConfigure("serial1", "/dev/ttyS0", 0, 0, 0)
# Make port available from the iocsh command line
#asynOctetConnect(const char *entry, const char *port, int addr,
#                 int timeout, int buffer_len, const char *drvInfo)
asynOctetConnect("serial1", "serial1")
asynSetOption(serial1,0,baud,19200)
#asynOctetSetInputEos(const char *portName, int addr,
#                     const char *eosin,const char *drvInfo)
asynOctetSetInputEos("serial1",0,"\r\n")
#asynOctetSetOutputEos(const char *portName, int addr,
#                       const char *eosin,const char *drvInfo)
asynOctetSetOutputEos("serial1",0,"\r")

# serial 2 connected to Newport MM4000 at 38400 baud
# Move this connection to Port 2 on the Moxa
drvAsynSerialPortConfigure("serial2", "/dev/ttyS1", 0, 0, 0)
asynOctetConnect("serial2", "serial2")
asynSetOption(serial2,0,baud,38400)
asynOctetSetInputEos("serial2",0,"\r")
asynOctetSetOutputEos("serial2",0,"\r")

# Set up ports 1 and 2 on Moxa box

# serial 3 is connected to the ACS MCB-4B at 9600 baud
#drvAsynIPPortConfigure("portName","hostInfo",priority,noAutoConnect,
#                        noProcessEos)
drvAsynIPPortConfigure("serial3", "164.54.160.50:4003", 0, 0, 0)
asynOctetConnect("serial3", "serial3")
# For Digitel need to use null input terminator
asynOctetSetInputEos("serial3",0,"\n")
asynOctetSetOutputEos("serial3",0,"\n")

# serial 4 is connected to the Newport MM4000 at 38400 baud
drvAsynIPPortConfigure("serial4", "164.54.160.50:4002", 0, 0, 0)
asynOctetConnect("serial4", "serial4")
asynOctetSetInputEos("serial4",0,"\r")
asynOctetSetOutputEos("serial4",0,"\r")

# Newport MM4000 driver setup parameters:
#     (1) maximum # of controllers,
MM4000AsynSetup(1)

# Newport MM4000 driver configuration parameters:
#     (1) controller
#     (2) asyn port name (e.g. serial1 or gpib1)
#     (3) GPIB address (0 for serial)
#     (4) Number of axes
#     (5) Moving poll period (msec)
#     (6) Idle poll period (msec)
MM4000AsynConfig(0, "serial4", 0, 3, 20, 500)
# asyn port, driver name, controller index, max. axes)
drvAsynMotorConfigure("MM4000_1", "motorMM4000", 0, 3)

# Newport PM500 driver setup parameters:
#     (1) maximum number of controllers in system
#     (2) motor task polling rate (min=1Hz,max=60Hz)
#PM500Setup(1, 10)

# Newport PM500 configuration parameters:
#     (1) controller
#     (2) asyn port name (e.g. serial1 or gpib1)
#PM500Config(0, "serial3")

# McClennan PM304 driver setup parameters:
#     (1) maximum number of controllers in system
#     (2) motor task polling rate (min=1Hz, max=60Hz)
#PM304Setup(1, 10)

# McClennan PM304 driver configuration parameters:
#     (1) controller being configured
#     (2) MPF serial server name (string)
#     (3) Number of axes on this controller
#PM304Config(0, "serial4", 1)

# ACS MCB-4B driver setup parameters:
#     (1) maximum number of controllers in system
#     (2) motor task polling rate (min=1Hz, max=60Hz)
#MCB4BSetup(1, 10)

# ACS MCB-4B driver configuration parameters:
#     (1) controller being configured
#     (2) asyn port name (string)
#MCB4BConfig(0, "serial3")

##### Pico Motors (Ernest Williams MHATT-CAT)
##### Motors (see picMot.substitutions in same directory as this file) ####
#dbLoadTemplate("picMot.substitutions")

# Load asynRecord records on all ports
dbLoadTemplate("asynRecord.substitutions")

# send impromptu message to serial device, parse reply
# (was serial_OI_block)
dbLoadRecords("$(IP)/db/deviceCmdReply.db","P=xxx:,N=1,PORT=serial1,ADDR=0,OMAX=100,IMAX=100")
dbLoadRecords("$(IP)/db/deviceCmdReply.db","P=xxx:,N=2,PORT=serial2,ADDR=0,OMAX=100,IMAX=100")
dbLoadRecords("$(IP)/db/deviceCmdReply.db","P=xxx:,N=3,PORT=serial3,ADDR=0,OMAX=100,IMAX=100")

# Stanford Research Systems SR570 Current Preamplifier
#dbLoadRecords("$(IP)/db/SR570.db", "P=xxx:,A=A1,PORT=serial1")

# Lakeshore DRC-93CA Temperature Controller
#dbLoadRecords("$(IP)/db/LakeShoreDRC-93CA.db", "P=xxx:,Q=TC1,PORT=serial4")

# Huber DMC9200 DC Motor Controller
#dbLoadRecords("$(IP)/db/HuberDMC9200.db", "P=xxx:,Q=DMC1:,PORT=serial5")

# Oriel 18011 Encoder Mike
#dbLoadRecords("$(IP)/db/eMike.db", "P=xxx:,M=em1,PORT=serial3")

# Keithley 2000 DMM
dbLoadRecords("$(IP)/db/Keithley2kDMM_mf.db","P=13Linux:,Dmm=DMM1,PORT=serial3")

# Oxford Cyberstar X1000 Scintillation detector and pulse processing unit
#dbLoadRecords("$(IP)/db/Oxford_X1k.db","P=xxx:,S=s1,PORT=serial4")

# Oxford ILM202 Cryogen Level Meter (Serial)
#dbLoadRecords("$(IP)/db/Oxford_ILM202.db","P=xxx:,S=s1,PORT=serial5")

# Elcomat autocollimator
#dbLoadRecords("$(IP)/db/Elcomat.db", "P=xxx:,PORT=serial8")

# Eurotherm temp controller
#dbLoadRecords("$(IP)/db/Eurotherm.db","P=xxx:,PORT=serial7")

# MKS vacuum gauges
#dbLoadRecords("$(IP)/db/MKS.db","P=xxx:,PORT=serial2,CC1=cc1,CC2=cc3,PR1=pr1,PR2=pr3")

# PI Digitel 500/1500 pump
#dbLoadRecords("$(IP)/db/Digitel.db","xxx:,PUMP=ip1,PORT=serial3")

# PI MPC ion pump
#dbLoadRecords("$(IP)/db/MPC.db","P=xxx:,PUMP=ip2,PORT=serial4,PA=0,PN=1")

# PI MPC TSP (titanium sublimation pump)
#dbLoadRecords("$(IP)/db/TSP.db","P=xxx:,TSP=tsp1,PORT=serial4,PA=0")

# Heidenhain ND261 encoder (for PSL monochromator)
#dbLoadRecords("$(IP)/db/heidND261.db", "P=xxx:,PORT=serial1")

# Love Controllers
#devLoveDebug=1
#loveServerDebug=1
#dbLoadRecords("$(IP)/db/love.db", "P=xxx:,Q=Love_0,C=0,PORT=PORT2,ADDR=1")

# END serial.cmd --------------------------------------------------------------
