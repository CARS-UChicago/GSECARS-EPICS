# int tyGSAsynInit(char *port, int uart, int channel, int baud, char parity, int sbits,
#                 int dbits, char handshake, char *eomstr)
tyGSAsynInit("serial1",   0, 0, 9600,'N',1,8,'N',"\r")  /* SMART PC */
tyGSAsynInit("serial2",   0, 1, 9600,'N',1,8,'N',"\r")  /* LAE 500 */
tyGSAsynInit("serial3",   0, 2,19200,'E',1,8,'N',"\r")  /* MKS */
#tyGSAsynInit("serial3",   0, 2,19200,'N',1,8,'N',"\r")  /* RSF715 */
tyGSAsynInit("serial4",   0, 3,19200,'N',1,8,'N',"\r")  /* ACS MCB4B */
tyGSAsynInit("serial5",   0, 4,19200,'N',1,8,'N',"\n")  /* Keithley 2000 */
tyGSAsynInit("serial6",   0, 5,19200,'N',1,8,'N',"\n")  /* Keithley 2000 */
tyGSAsynInit("serial7",   0, 6,38400,'N',1,8,'N',"\r")  /* MM4000 */
tyGSAsynInit("serial8",   0, 7, 9600,'N',1,8,'N',"\r")  /* SRS 570 */
tyGSAsynInit("serial9" ,  1, 0, 9600,'N',1,8,'N',"\r")  /* Unused */
tyGSAsynInit("serial10",  1, 1, 9600,'N',1,8,'N',"\r")  /* Unused */
tyGSAsynInit("serial11",  1, 2, 9600,'N',1,8,'N',"\r")  /* Unused */
tyGSAsynInit("serial12",  1, 3, 9600,'N',1,8,'N',"\r")  /* Unused */
tyGSAsynInit("serial13",  1, 4, 9600,'N',1,8,'N',"\r")  /* Unused */
tyGSAsynInit("serial14",  1, 5, 9600,'N',1,8,'N',"\r")  /* Unused */
tyGSAsynInit("serial15",  1, 6, 9600,'N',1,8,'N',"\r")  /* Unused */
tyGSAsynInit("serial16",  1, 7, 9600,'N',1,8,'N',"\r")  /* Unused */

# Set up first 2 ports on Moxa box
drvAsynIPPortConfigure("serial20", "164.54.160.50:4001", 0, 0)
drvAsynIPPortConfigure("serial21", "164.54.160.50:4002", 0, 0)
# Make these ports available from the iocsh command line
#asynOctetConnect("serial20", "serial20", 0, "\r", "\r")
#asynOctetConnect("serial21", "serial21", 0, "\r", "\r")

# GPIB addresses: 1=Tektronix scope, 2=Keithley 2000, 3=Fluke meter
asynOctetConnect("gpib1:1", "gpib1", 1, "", "\n", 1, 80)
asynOctetConnect("gpib1:2", "gpib1", 2, "", "\n", 1, 80)
asynOctetConnect("gpib1:3", "gpib1", 3, "\r", "\r", 1, 80)

# Debugging
#asynSetTraceMask("gpib1",3,0xff)
#asynSetTraceIOMask("gpib1",3,2)
#asynSetTraceMask("serial3",0,0xff)
#asynSetTraceIOMask("serial3",0,2)
#asynSetTraceMask("serial20",0,0xff)
#asynSetTraceIOMask("serial20",0,2)

# Generic GPIB record
dbLoadRecords("$(IP)/ipApp/Db/generic_gpib.db", "P=13LAB:,R=gpib2,SIZE=4096,ADDR=3,PORT=gpib1")

# Load asynRecord records on all ports
dbLoadTemplate("asynRecord.template")

# Serial 1 is for SMART
# SMART detector database
str=malloc(256)
strcpy(str,"P=13LAB:,R=smart1,PORT=serial1,")
strcat(str,"FSHUT=UnidigBo0,TRIG=UnidigBo1,SSHUT=UnidigBo2")
dbLoadRecords("$(CCD)/ccdApp/Db/smartControl.db", str)

# Serial 2 has Newport LAE500 Laser Autocollimator
dbLoadRecords("$(CARS)/CARSApp/Db/LAE500.db", "P=13LAB:,R=LAE500,PORT=serial2")

# Port 3 Encoder readout unit
#dbLoadRecords("$(CARS)/CARSApp/Db/RSF715.db","P=13LAB:,ENCODER=RSF715,PORT=serial4")

# Serial 4 MCB4B motor controller
# MCB-4B driver setup parameters:
#     (1) maximum # of controllers,
#     (2) motor task polling rate (min=1Hz, max=60Hz)
MCB4BSetup(1, 10)

# MCB-4B driver configuration parameters:
#     (1) controller
#     (2) asyn port name (e.g. serial1)
MCB4BConfig(0, "serial4")

# Serial 5, 6 Keithley Multimeter
dbLoadRecords("$(IP)/ipApp/Db/Keithley2kDMM_mf.db", "P=13LAB:,Dmm=DMM1,PORT=serial5")
#dbLoadRecords("$(IP)/ipApp/Db/Keithley2kDMM_mf.db", "P=13LAB:,Dmm=DMM2,PORT=gpib1:2")
dbLoadRecords("$(IP)/ipApp/Db/Keithley2kDMM_mf.db", "P=13LAB:,Dmm=DMM2,PORT=serial6")
#dbLoadRecords("$(IP)/ipApp/Db/Keithley2kDMM_mf.db", "P=13LAB:,Dmm=DMM3,PORT=serial7")

# Serial 7 for the MM4000.
# MM4000 driver setup parameters:
#     (1) maximum # of controllers,
#     (2) motor task polling rate (min=1Hz, max=60Hz)
MM4000Setup(1, 10)

# MM4000 driver configuration parameters:
#     (1) controller
#     (2) asyn port name (e.g. serial1 or gpib1)
#     (3) GPIB address (0 for serial)
MM4000Config(0, "serial7", 0)

# Database for trajectory scanning with the MM4005/GPD
# The required command string is longer than the vxWorks command line, must use malloc and strcpy, strcat
str = malloc(300)
strcpy(str, "P=13LAB:,R=traj1,NAXES=6,NELM=1000,NPULSE=1000,PORT=serial7,")
strcat(str, "DONPV=13LAB:str:EraseStart,DONV=1,DOFFPV=13LAB:str:StopAll,DOFFV=1")
dbLoadRecords("$(CARS)/CARSApp/Db/trajectoryScan.db", str, top)

# Serial 8 Stanford Research Systems SR570 Current Preamplifier
#dbLoadRecords("$(IP)/ipApp/Db/SR570.db", "P=13LAB:,A=A1,PORT=serial8")

# Serial 8 XIA filter rack
#dbLoadRecords("$(OPTICS)/opticsApp/Db/XIA_shutter.db", "P=13LAB:,S=filter1,ADDRESS=1,PORT=serial8")

# GPIB 3 is Fluke multimeter
#dbLoadRecords("$(CARS)/CARSApp/Db/Fluke_8842A.db", "P=13LAB:,M=Fluke1,PORT=gpib1,A=3")

