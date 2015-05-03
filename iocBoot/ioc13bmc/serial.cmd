# int tyGSAsynInit(char *port, int uart, int channel, int baud, char parity, int sbits,
#                 int dbits, char handshake, char *eomstr)
tyGSAsynInit("serial1", "UART0", 0, 9600,'N',2,8,'N',"\n","\n")  /* SRS 570 */
tyGSAsynInit("serial2", "UART0", 1, 9600,'N',2,8,'N',"\n","\n")  /* SRS 570 */
tyGSAsynInit("serial3", "UART0", 2, 9600,'N',2,8,'N',"\n","\n")  /* SRS 570 */
tyGSAsynInit("serial4", "UART0", 3, 9600,'N',2,8,'N',"\n","\n")  /* SRS 570 */
tyGSAsynInit("serial5", "UART0", 4, 9600,'N',2,8,'N',"\n","\n")  /* SRS 570 */
tyGSAsynInit("serial6", "UART0", 5, 9600,'N',2,8,'N',"\n","\n")  /* SRS 570 */
tyGSAsynInit("serial7", "UART0", 6, 9600,'N',2,8,'N',"\r","\r")  /* Pelco CM6700 video switch */
# Serial 8 can either be the LAE or the Keithley
#tyGSAsynInit("serial8", "UART0", 7, 9600,'N',1,8,'N',"\n","\n")  /* LAE500 */
tyGSAsynInit("serial8", "UART0", 7,19200,'N',1,8,'N',"\n","\r")  /* Keithley */

# Load asyn records on all serial ports
dbLoadTemplate("asynRecord.template")
dbLoadRecords("$(IP)/ipApp/Db/SR570.db", "P=13BMC:,A=A1,PORT=serial1")
dbLoadRecords("$(IP)/ipApp/Db/SR570.db", "P=13BMC:,A=A2,PORT=serial2")
dbLoadRecords("$(IP)/ipApp/Db/SR570.db", "P=13BMC:,A=A3,PORT=serial3")
dbLoadRecords("$(IP)/ipApp/Db/SR570.db", "P=13BMC:,A=A4,PORT=serial4")
dbLoadRecords("$(IP)/ipApp/Db/SR570.db", "P=13BMC:,A=A5,PORT=serial5")
dbLoadRecords("$(IP)/ipApp/Db/SR570.db", "P=13BMC:,A=A6,PORT=serial6")

# Serial 7 is Pelco CM6700 video switch
dbLoadTemplate("Pelco_CM6700.substitutions")

# Port 8 can either be the LAE or the Keithley 
#dbLoadRecords("$(IP)/ipApp/Db/Newport_LAE500.db","P=13BMC:,R=LAE500,PORT=serial8")
dbLoadRecords("$(IP)/ipApp/Db/Keithley2kDMM_mf.db","P=13BMC:,Dmm=DMM1,PORT=serial8")

