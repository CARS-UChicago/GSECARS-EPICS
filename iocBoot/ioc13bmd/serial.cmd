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
tyGSAsynInit("serial12", "UART1", 3, 9600,'N',1,8,'N',"\r","\r")  /* Unused */
tyGSAsynInit("serial13", "UART1", 4, 9600,'N',1,8,'N',"\r","\r")  /* Unused */
tyGSAsynInit("serial14", "UART1", 5, 9600,'N',1,8,'N',"\r","\r")  /* Unused */
tyGSAsynInit("serial15", "UART1", 6, 9600,'N',1,8,'N',"\r","\r")  /* Unused */
tyGSAsynInit("serial16", "UART1", 7, 9600,'N',1,8,'N',"\r","\r")  /* Unused */

# Load asyn records on all ports
dbLoadTemplate("asynRecord.template")
dbLoadRecords("$(IP)/ipApp/Db/SR570.db", "P=13BMD:,A=A1,PORT=serial1")
dbLoadRecords("$(IP)/ipApp/Db/Keithley2kDMM_mf.db", "P=13BMD:,Dmm=DMM3,PORT=serial2")
dbLoadRecords("$(IP)/ipApp/Db/SR570.db", "P=13BMD:,A=A2,PORT=serial3")
dbLoadRecords("$(IP)/ipApp/Db/SR570.db", "P=13BMD:,A=A3,PORT=serial4")
# LVP Omega meter on serial 5
dbLoadTemplate "LVP_pressure_control.template"
# SMART detector database on serial 6
str=malloc(256)
strcpy(str,"P=13BMD:,R=smart1,PORT=serial6,")
strcat(str,"FSHUT=UnidigBo0,TRIG=UnidigBo1,SSHUT=UnidigBo2")
dbLoadRecords("$(CCD)/ccdApp/Db/smartControl.db",str)
dbLoadRecords("$(IP)/ipApp/Db/Keithley2kDMM_mf.db", "P=13BMD:,Dmm=DMM2,PORT=serial7")
dbLoadRecords("$(CARS)/CARSApp/Db/lvp_dmm.db", "P=13BMD:,Dmm=DMM2,DLY=0.1")
dbLoadRecords("$(IP)/ipApp/Db/Keithley2kDMM_mf.db", "P=13BMD:,Dmm=DMM1,PORT=serial8")
dbLoadRecords("$(IP)/ipApp/Db/Keithley2kDMM_mf.db", "P=13BMD:,Dmm=DMM4,PORT=serial9")
dbLoadRecords("$(OPTICS)/opticsApp/Db/XIA_shutter.db", "P=13BMD:,S=filter1,ADDRESS=1,PORT=serial10")
# Serial 11 is Verdi Laser for testing
dbLoadRecords("$(CARS)/CARSApp/Db/VerdiLaser.db", "P=13BMD:,R=Verdi1:,PORT=serial11")


