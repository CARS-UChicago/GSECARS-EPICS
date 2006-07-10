tyGSAsynInit("serial1",  "UART0", 0,  9600,'N',2,8,'N',"\r","\r") /* SRS 570 */
tyGSAsynInit("serial2",  "UART0", 1,  9600,'N',2,8,'N',"\r","\r") /* SRS 570 */
tyGSAsynInit("serial3",  "UART0", 2, 19200,'N',1,8,'N',"\r\n","\n") /* Keithley 2000 */
tyGSAsynInit("serial4",  "UART0", 3,  4800,'N',1,8,'N',"\r","\r") /* Generic serial / LPC */
tyGSAsynInit("serial5",  "UART0", 4, 19200,'N',1,8,'N',"\r\n","\n") /* Keithley 2000 */
tyGSAsynInit("serial6",  "UART0", 5, 19200,'N',1,8,'N',"\r\n","\n") /* Keithley 2000 */
tyGSAsynInit("serial7",  "UART0", 6,  9600,'N',2,8,'N',"\r","\r") /* SRS 570 */
tyGSAsynInit("serial8",  "UART0", 7,  9600,'N',1,8,'N',"\r","\r") /* SMART PC */
tyGSAsynInit("serial9",  "UART1", 0,  9600,'N',2,7,'N',"\r","\r") /* Omega meter */
tyGSAsynInit("serial10", "UART1", 1, 19200,'N',1,8,'N',"\r","\r") /* RSF encoder readout */
tyGSAsynInit("serial11", "UART1", 2, 19200,'N',1,8,'N',">","\r") /* PicoMotor controller */
tyGSAsynInit("serial12", "UART1", 3, 19200,'N',1,8,'N',"\r","\r") /* Keithley 2700 */
tyGSAsynInit("serial13", "UART1", 4,  9600,'N',1,8,'N',"\r","\r") /* Pelco CM6700 video switch */
tyGSAsynInit("serial14", "UART1", 5,  9600,'N',1,8,'N',"\r","\r") /* Unused */
tyGSAsynInit("serial15", "UART1", 6,  9600,'N',1,8,'N',"\r","\r") /* Unused */
tyGSAsynInit("serial16", "UART1", 7,  9600,'N',1,8,'N',"\r","\r") /* Unused */

# asyn record on each serial port
dbLoadTemplate("asynRecord.template")

dbLoadRecords("$(IP)/ipApp/Db/SR570.db", "P=13IDD:,A=A1,PORT=serial1")
dbLoadRecords("$(IP)/ipApp/Db/SR570.db", "P=13IDD:,A=A2,PORT=serial2")
dbLoadRecords("$(IP)/ipApp/Db/Keithley2kDMM_mf.db", "P=13IDD:,Dmm=DMM1,PORT=serial3")
# Laser power controller
dbLoadRecords("$(CARS)/CARSApp/Db/lpc.db", "P=13IDD:,L=LPC1_,DAC=DAC1_2,PORT=serial4")
dbLoadRecords("$(IP)/ipApp/Db/Keithley2kDMM_mf.db", "P=13IDD:,Dmm=DMM3,PORT=serial5")
dbLoadRecords("$(IP)/ipApp/Db/Keithley2kDMM_mf.db", "P=13IDD:,Dmm=DMM4,PORT=serial6")
dbLoadRecords("$(IP)/ipApp/Db/SR570.db", "P=13IDD:,A=A3,PORT=serial7")
#dbLoadRecords("$(CARS)/CARSApp/Db/LAE500.db","P=13IDD:,R=LAE500,PORT=serial8")
# SMART detector database
str=malloc(256)
strcpy(str,"P=13IDD:,R=smart1,PORT=serial8,")
# Use Bo0 for Bruker shutter, Bo11 for XIA
strcat(str,"FSHUT=Unidig1Bo11,TRIG=Unidig1Bo1,SSHUT=Unidig1Bo2")
dbLoadRecords("$(CCD)/ccdApp/Db/smartControl.db", str)


dbLoadRecords("$(CARS)/CARSApp/Db/RSF715.db","P=13IDD:,ENCODER=RSF715,PORT=serial10")
# Serial 11 is picoMotors
dbLoadTemplate("picoMotors.template")
dbLoadRecords("$(IP)/ipApp/Db/Keithley2kDMM_mf.db", "P=13IDD:,Dmm=DMM5,PORT=serial12")

# Serial 13 is Pelco CM6700 video switch
dbLoadTemplate("Pelco_CM6700.substitutions")

