tyGSAsynInit("serial1",  "UART0", 0,  9600,'N',2,8,'N',"\r","\r")   /* SRS 570 */
tyGSAsynInit("serial2",  "UART0", 1,  9600,'N',2,8,'N',"\r","\r")   /* SRS 570 */
tyGSAsynInit("serial3",  "UART0", 2, 19200,'N',1,8,'N',"\r\n","\n") /* Keithley 2000 */
tyGSAsynInit("serial4",  "UART0", 3,  4800,'N',1,8,'N',"\r","\r")   /* Generic serial / LPC */
tyGSAsynInit("serial5",  "UART0", 4, 19200,'N',1,8,'N',"\r\n","\n") /* Keithley 2000 */
tyGSAsynInit("serial6",  "UART0", 5, 19200,'N',1,8,'N',"\r\n","\n") /* Keithley 2000 */
tyGSAsynInit("serial7",  "UART0", 6,  9600,'N',2,8,'N',"\r","\r")   /* SRS 570 */
tyGSAsynInit("serial8",  "UART0", 7,  9600,'N',1,8,'N',"\r","\r")   /* SMART PC */
tyGSAsynInit("serial9",  "UART1", 0,  9600,'N',2,7,'N',"\r","\r")   /* Omega meter */
tyGSAsynInit("serial10", "UART1", 1, 19200,'N',1,8,'N',"\r","\r")   /* RSF encoder readout */
tyGSAsynInit("serial11", "UART1", 2, 19200,'N',1,8,'N',">","\r")    /* PicoMotor controller */
tyGSAsynInit("serial12", "UART1", 3,  9600,'N',1,8,'N',"\r\n","\r\n") /* LQExcel laser */
tyGSAsynInit("serial13", "UART1", 4,  9600,'N',1,8,'N',"\r","\r")   /* Pelco CM6700 video switch */
tyGSAsynInit("serial14", "UART1", 5, 38400,'N',1,8,'N',"\r","\r")   /* YLR laser */
#LU IPG laser
#drvAsynIPPortConfigure("serial14", "164.54.160.13:10001")
#asynOctetSetInputEos("serial14",0,"\r")
#asynOctetSetOutputEos("serial14",0,"\r")
tyGSAsynInit("serial15", "UART1", 6, 38400,'N',1,8,'N',"\r","\r")   /* YLR laser */
tyGSAsynInit("serial16", "UART1", 7,  9600,'N',1,8,'N',"\r\n","\r\n")   /* BNC 505 Pulse Generator */

# Set up 2 serial ports on Moxa terminal server which is inside the MCB-4B slit controller box
drvAsynIPPortConfigure("serial17", "164.54.160.30:4001")
#asynSetOption(serial1,0,baud,19200)
#asynSetOption(serial1,0,parity,none)
drvAsynIPPortConfigure("serial18", "164.54.160.30:4002")
#asynSetOption(serial2,0,baud,19200)
#asynSetOption(serial2,0,parity,none)
asynOctetSetInputEos("serial17",0,"\r")
asynOctetSetOutputEos("serial17",0,"\r")
asynOctetSetInputEos("serial18",0,"\r")
asynOctetSetOutputEos("serial18",0,"\r")

# Set up port on Digi box
#drvAsynIPPortConfigure("portName","hostInfo",priority,noAutoConnect,
#                        noProcessEos)
#drvAsynIPPortConfigure("serial17", "164.54.160.154:2101", 0, 0, 0)
#asynOctetConnect("serial17", "serial17")
#asynOctetSetInputEos("serial17",0,"\r")
#asynOctetSetOutputEos("serial17",0,"\r")

# IPG laser
dbLoadRecords("$(CARS)/db/IPG_YLR_laser.db","P=13IDD:,R=Laser1,PORT=serial14")
dbLoadRecords("$(CARS)/db/IPG_YLR_laser.db","P=13IDD:,R=Laser2,PORT=serial15")

# asyn record on each serial port
dbLoadTemplate("asynRecord.template")

dbLoadRecords("$(IP)/db/SR570.db", "P=13IDD:,A=A1,PORT=serial1")
dbLoadRecords("$(IP)/db/SR570.db", "P=13IDD:,A=A2,PORT=serial2")
dbLoadRecords("$(IP)/db/Keithley2kDMM_mf.db", "P=13IDD:,Dmm=DMM1,PORT=serial3")
# Laser power controller
dbLoadRecords("$(CARS)/db/lpc.db", "P=13IDD:,L=LPC1_,DAC=DAC1_2,PORT=serial4")
dbLoadRecords("$(IP)/db/SR570.db", "P=13IDD:,A=A3,PORT=serial7")
#dbLoadRecords("$(IP)/db/Newport_LAE500.db","P=13IDD:,R=LAE500,PORT=serial8")

dbLoadRecords("$(CARS)/db/RSF715.db","P=13IDD:,ENCODER=RSF715,PORT=serial10")
# Serial 11 is picoMotors
dbLoadTemplate("picoMotors.template")

# Laser Quantum Excel laser
dbLoadRecords("$(CARS)/db/LQExcel.db", "P=13IDD:,R=LQE1,PORT=serial12")

# Serial 13 is Pelco CM6700 video switch
dbLoadTemplate("Pelco_CM6700.substitutions")

# Serial 16 is the BNC 505 pulse generator
dbLoadRecords("$(DELAYGEN)/delaygenApp/Db/BNC_505.db", "P=13IDD:,R=BNC1:,PORT=serial16")
dbLoadRecords("$(DELAYGEN)/delaygenApp/Db/BNC_505_Pn.db", "P=13IDD:,R=BNC1:,PORT=serial16,N=1")
dbLoadRecords("$(DELAYGEN)/delaygenApp/Db/BNC_505_Pn.db", "P=13IDD:,R=BNC1:,PORT=serial16,N=2")
dbLoadRecords("$(DELAYGEN)/delaygenApp/Db/BNC_505_Pn.db", "P=13IDD:,R=BNC1:,PORT=serial16,N=3")
dbLoadRecords("$(DELAYGEN)/delaygenApp/Db/BNC_505_Pn.db", "P=13IDD:,R=BNC1:,PORT=serial16,N=4")

# Tell StreamDevice where to find protocol files
iocshCmd("epicsEnvSet(STREAM_PROTOCOL_PATH, $(IP)/db:$(DELAYGEN)/delaygenApp/Db:$(CARS)/db)")
