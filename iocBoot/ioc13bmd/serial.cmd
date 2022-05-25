# int tyGSAsynInit(char *port, int uart, int channel, int baud, char parity, int sbits,
#                 int dbits, char handshake, char *inputEos, char *outputEos)
tyGSAsynInit("serial1",  "UART0", 0, 9600,'N',2,8,'N',"\r","\r")  /* SRS570 */
tyGSAsynInit("serial2",  "UART0", 1,19200,'N',1,8,'N',"\n","\r")  /* Keithley 2000 */
tyGSAsynInit("serial3",  "UART0", 2, 9600,'N',2,8,'N',"\r","\r")  /* SRS570 */
tyGSAsynInit("serial4",  "UART0", 3, 9600,'N',2,8,'N',"\r","\r")  /* SRS570 */
#tyGSAsynInit("serial4",  "UART0", 3,19200,'N',1,8,'N',"\r","\r")  /* MM4000 */
tyGSAsynInit("serial5",  "UART0", 4, 9600,'N',2,7,'N',"\r","\r")  /* Omega meter */
tyGSAsynInit("serial6",  "UART0", 5, 9600,'N',1,8,'N',"\r","\r")  /* SMART PC */
tyGSAsynInit("serial7",  "UART0", 6,19200,'N',1,8,'N',"\n","\r")  /* Keithley 2000 */
tyGSAsynInit("serial8",  "UART0", 7,19200,'N',1,8,'N',"\n","\r")  /* Keithley 2000 */
# Second IP-Octal
tyGSAsynInit("serial9",  "UART1", 0,19200,'N',1,8,'N',"\n","\r")  /* Keithley 2000 */
tyGSAsynInit("serial10", "UART1", 1, 9600,'N',1,8,'N',"\r","\r")  /* XIA shutter */
tyGSAsynInit("serial11", "UART1", 2,19200,'N',1,8,'N',"\r\n","\r\n")  /* Verdi Laser */
tyGSAsynInit("serial12", "UART1", 3, 9600,'N',1,8,'N',"\r","\r")  /* Pelco CM6700 video switch */
tyGSAsynInit("serial13", "UART1", 4, 9600,'N',1,8,'N',"\r","\r")  /* Unused */
tyGSAsynInit("serial14", "UART1", 5, 9600,'N',1,8,'N',"\r","\r")  /* Unused */
tyGSAsynInit("serial15", "UART1", 6, 9600,'N',1,8,'N',"\r","\r")  /* Unused */
tyGSAsynInit("serial16", "UART1", 7, 9600,'N',1,8,'N',"\r","\r")  /* Unused */

# Set up 2 serial ports on Moxa terminal server which is inside the MCB-4B slit controller box
drvAsynIPPortConfigure("serial17", "10.54.160.57:4001")
#asynSetOption(serial1,0,baud,19200)
#asynSetOption(serial1,0,parity,none)
drvAsynIPPortConfigure("serial18", "10.54.160.57:4002")
#asynSetOption(serial2,0,baud,19200)
#asynSetOption(serial2,0,parity,none)
asynOctetSetInputEos("serial17",0,"\r")
asynOctetSetOutputEos("serial17",0,"\r")
asynOctetSetInputEos("serial18",0,"\r")
asynOctetSetOutputEos("serial18",0,"\r")
# Serial port for Mitutoyo Digimatic
drvAsynIPPortConfigure("serial19", "164.54.160.123:4006", 0, 0, 0)
asynOctetSetInputEos ("serial19",0,"\n")
asynOctetSetOutputEos("serial19",0,"\r\n")

# Load asyn records on all ports
dbLoadTemplate("asynRecord.template")
dbLoadRecords("$(IP)/db/SR570.db", "P=13BMD:,A=A1,PORT=serial1")
dbLoadRecords("$(IP)/db/Keithley2kDMM_mf.db", "P=13BMD:,Dmm=DMM3,PORT=serial2")
dbLoadRecords("$(IP)/db/SR570.db", "P=13BMD:,A=A2,PORT=serial3")
dbLoadRecords("$(IP)/db/SR570.db", "P=13BMD:,A=A3,PORT=serial4")
# LVP Omega meter on serial 5
dbLoadTemplate "LVP_pressure_control.template"
dbLoadRecords("$(IP)/db/Keithley2kDMM_mf.db", "P=13BMD:,Dmm=DMM2,PORT=serial7")
dbLoadRecords("$(CARS)/db/lvp_dmm.db", "P=13BMD:,Dmm=DMM2,DLY=0.1")
dbLoadRecords("$(IP)/db/Keithley2kDMM_mf.db", "P=13BMD:,Dmm=DMM1,PORT=serial8")
dbLoadRecords("$(IP)/db/Keithley2kDMM_mf.db", "P=13BMD:,Dmm=DMM4,PORT=serial9")
dbLoadRecords("$(OPTICS)/db/XIA_shutter.db", "P=13BMD:,S=filter1,ADDRESS=1,PORT=serial10")
# Serial 11 is Verdi Laser
dbLoadRecords("$(CARS)/db/VerdiLaser.db", "P=13BMD:,R=Verdi1:,PORT=serial11")

# Serial 12 is Pelco CM6700 video switch
dbLoadTemplate("Pelco_CM6700.substitutions")

# Serial 19 is Mitutoyo Digimatic
dbLoadRecords("$(CARS)/db/Mitutoyo_Digimatic.db","P=13BMD:,R=Mitu,PORT=serial19")
