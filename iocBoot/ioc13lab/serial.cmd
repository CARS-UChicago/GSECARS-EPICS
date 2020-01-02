# int tyGSAsynInit(char *port, int uart, int channel, int baud, char parity, int sbits,
#                 int dbits, char handshake, char *inputEos, char *outputEos)
tyGSAsynInit("serial1",  "UART0", 0, 9600,'N',1,8,'N',"\r","\r")  /* Pelco */
tyGSAsynInit("serial2",  "UART0", 1, 9600,'N',1,8,'N',"\r","\r")  /* LAE 500 */
tyGSAsynInit("serial3",  "UART0", 2,19200,'E',1,8,'N',"\r","\r")  /* MKS */
#tyGSAsynInit("serial3", "UART0", 2,19200,'N',1,8,'N',"\r","\r")  /* RSF715 */
tyGSAsynInit("serial4",  "UART0", 3,19200,'N',1,8,'N',"\r","\r")  /* ACS MCB4B */
tyGSAsynInit("serial5",  "UART0", 4, 9600,'N',1,8,'N',"\r","\r")  /* Pelco */
tyGSAsynInit("serial6",  "UART0", 5,19200,'N',1,8,'N',"\n","\r")  /* Keithley 2000 */
tyGSAsynInit("serial7",  "UART0", 6,38400,'N',1,8,'N',"\r","\r")  /* MM4000 */
tyGSAsynInit("serial8",  "UART0", 7,19200,'N',1,8,'N',"\r\n","\r\n")  /* Verdi Laser */
tyGSAsynInit("serial9",  "UART1", 0, 9600,'N',1,8,'N',"\r","\r")  /* Pelco CM6700 video switch */
tyGSAsynInit("serial10", "UART1", 1, 9600,'N',1,8,'N',"\r","\r")  /* SR630 thermocouple reader */
tyGSAsynInit("serial11", "UART1", 2, 9600,'N',1,8,'N',"\r","\r")  /* Unused */
tyGSAsynInit("serial12", "UART1", 3, 9600,'N',1,8,'N',"\r","\r")  /* Unused */
tyGSAsynInit("serial13", "UART1", 4, 9600,'N',1,8,'N',"\r","\r")  /* Unused */
tyGSAsynInit("serial14", "UART1", 5, 9600,'N',1,8,'N',"\r","\r")  /* Unused */
tyGSAsynInit("serial15", "UART1", 6, 9600,'N',1,8,'N',"\r","\r")  /* Unused */
tyGSAsynInit("serial16", "UART1", 7, 9600,'N',1,8,'N',"\r","\r")  /* Unused */

# Set up first 2 ports on Moxa box
#drvAsynIPPortConfigure("serial20", "164.54.160.50:4001", 0, 0)
#drvAsynIPPortConfigure("serial21", "164.54.160.50:4002", 0, 0)
# Make these ports available from the iocsh command line
#asynOctetConnect("serial20", "serial20", 0, 1, 80)
#asynOctetConnect("serial21", "serial21", 0, 1, 80)

# GPIB addresses: 1=Tektronix scope, 2=Keithley 2000, 3=Fluke meter
asynInterposeEosConfig("gpib1", 1, 1, 0)
asynOctetSetInputEos("gpib1", 1, "\n")
asynOctetConnect("gpib1:1", "gpib1", 1, 1, 80)
asynOctetConnect("gpib1:2", "gpib1", 2, 1, 80)
asynInterposeEosConfig("gpib1", 3, 1, 0)
asynOctetSetInputEos("gpib1", 3, "\r")
asynOctetConnect("gpib1:3", "gpib1", 3, 1, 80)

# Debugging
#asynSetTraceMask("gpib1",3,0xff)
#asynSetTraceIOMask("gpib1",3,2)
#asynSetTraceMask("serial3",0,0xff)
#asynSetTraceIOMask("serial3",0,2)
#asynSetTraceMask("serial20",0,0xff)
#asynSetTraceIOMask("serial20",0,2)

# Load asynRecord records on all ports
dbLoadTemplate("asynRecord.template")

# Serial 2 has Newport LAE500 Laser Autocollimator
#dbLoadRecords("$(IP)/ipApp/Db/Newport_LAE500.db", "P=13LAB:,R=LAE500,PORT=serial2")

# Port 3 Encoder readout unit
#dbLoadRecords("$(CARS)/db/RSF715.db","P=13LAB:,ENCODER=RSF715,PORT=serial4")

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
#MM4000Setup(1, 10)

# MM4000 driver configuration parameters:
#     (1) controller
#     (2) asyn port name (e.g. serial1 or gpib1)
#     (3) GPIB address (0 for serial)
#MM4000Config(0, "serial7", 0)

# Database for trajectory scanning with the MM4005/GPD
# The required command string is longer than the vxWorks command line, must use malloc and strcpy, strcat
#str = malloc(300)
#strcpy(str, "P=13LAB:,R=traj1,NAXES=6,NELM=1000,NPULSE=1000,PORT=serial7,")
#strcat(str, "DONPV=13LAB:str:EraseStart,DONV=1,DOFFPV=13LAB:str:StopAll,DOFFV=1")
#dbLoadRecords("$(CARS)/db/trajectoryScan.db", str, top)

# Serial 8 Stanford Research Systems SR570 Current Preamplifier
#dbLoadRecords("$(IP)/ipApp/Db/SR570.db", "P=13LAB:,A=A1,PORT=serial8")

# Serial 8 is Verdi Laser for testing
#dbLoadRecords("$(CARS)/db/VerdiLaser.db", "P=13LAB:,R=Verdi1:,PORT=serial8")

# Serial 8 XIA filter rack
#dbLoadRecords("$(OPTICS)/opticsApp/Db/XIA_shutter.db", "P=13LAB:,S=filter1,ADDRESS=1,PORT=serial8")

# Serial 5 Pelco CM6700 video switch
dbLoadTemplate("Pelco_CM6700.substitutions")

# Serial 10 SR630 thermocouple reader
#dbLoadTemplate("SR630.substitutions")

# GPIB 3 is Fluke multimeter
#dbLoadRecords("$(CARS)/db/Fluke_8842A.db", "P=13LAB:,M=Fluke1,PORT=gpib1,A=3")

