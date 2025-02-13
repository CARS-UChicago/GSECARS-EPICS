# tyGSAsynInit(char *port, char *moduleName, int channel, int baud,
#              char parity, int sbits, int dbits, char handshake,
#              char *inputEos, char *outputEos)
tyGSAsynInit("serial1", "UART0", 0,  9600,'N',2,8,'N',"\r","\r") /* SRS570 */
tyGSAsynInit("serial2", "UART0", 1,  9600,'N',2,8,'N',"\r","\r") /* SRS570 */
tyGSAsynInit("serial3", "UART0", 2,  9600,'N',2,8,'N',"\r","\r") /* SRS570 */
tyGSAsynInit("serial4", "UART0", 3,  9600,'N',2,8,'N',"\r","\r") /* SRS570 */
tyGSAsynInit("serial5", "UART0", 4, 19200,'N',1,8,'N',"\r","\r") /* SRS570 */
tyGSAsynInit("serial6", "UART0", 5, 19200,'N',1,8,'N',"\r\n","\n") /* Keithley 2000 */
tyGSAsynInit("serial7", "UART0", 6,  9600,'N',2,8,'N',"\r","\r") /* Pelco CM6700 */
tyGSAsynInit("serial8", "UART0", 7, 19200,'N',1,8,'N',"\r\n","\n") /* Keithley 2000 */

# Load asyn records on all serial ports
dbLoadTemplate("asynRecord.template")

# First Octal UART for microprobe experiments
dbLoadRecords("$(IP)/db/SR570.db", "P=13LAB2:,A=A1,PORT=serial1")
dbLoadRecords("$(IP)/db/SR570.db", "P=13LAB2:,A=A2,PORT=serial2")
dbLoadRecords("$(IP)/db/SR570.db", "P=13LAB2:,A=A3,PORT=serial3")
dbLoadRecords("$(IP)/db/SR570.db", "P=13LAB2:,A=A4,PORT=serial4")
dbLoadRecords("$(IP)/db/Keithley2kDMM_mf.db","P=13LAB2:,Dmm=DMM1,PORT=serial6")
dbLoadRecords("$(IP)/db/Keithley2kDMM_mf.db","P=13LAB2:,Dmm=DMM2,PORT=serial8")
