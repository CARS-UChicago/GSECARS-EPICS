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
tyGSAsynInit("serial9", "UART1", 0,  9600,'N',2,8,'N',"\r","\r") /* SRS570 */
tyGSAsynInit("serial10","UART1", 1,  9600,'N',2,8,'N',"\r","\r") /* SRS570 */
tyGSAsynInit("serial11","UART1", 2,  9600,'N',2,8,'N',"\r","\r") /* SRS570 */
tyGSAsynInit("serial12","UART1", 3,  9600,'N',2,8,'N',"\r","\r") /* SRS570 */
tyGSAsynInit("serial13","UART1", 4, 38400,'N',1,8,'N',"\r","\r") /* MM4000 */
tyGSAsynInit("serial14","UART1", 5, 38400,'N',1,8,'N',"\r","\r") /* MM4000 */
tyGSAsynInit("serial15","UART1", 6,  9600,'N',2,8,'N',"\r","\r") /* Pelco CM6700 */
tyGSAsynInit("serial16","UART1", 7,  9600,'N',1,8,'N',"\r","\r") /* Unused */

# Load asyn records on all serial ports
dbLoadTemplate("asynRecord.template")

# First Octal UART for microprobe experiments
dbLoadRecords("$(IP)/ipApp/Db/SR570.db", "P=13IDC:,A=A1,PORT=serial1")
dbLoadRecords("$(IP)/ipApp/Db/SR570.db", "P=13IDC:,A=A2,PORT=serial2")
dbLoadRecords("$(IP)/ipApp/Db/SR570.db", "P=13IDC:,A=A3,PORT=serial3")
dbLoadRecords("$(IP)/ipApp/Db/SR570.db", "P=13IDC:,A=A4,PORT=serial4")
# dbLoadRecords("$(IP)/ipApp/Db/SR570.db", "P=13IDC:,A=A5,PORT=serial5")
# dbLoadRecords("$(IP)/ipApp/Db/SR570.db", "P=13IDC:,A=A6,PORT=serial6")
# Serial 7 is Pelco CM6700 video switch
dbLoadTemplate("Pelco_CM6700.substitutions")

dbLoadRecords("$(IP)/ipApp/Db/Keithley2kDMM_mf.db","P=13IDC:,Dmm=DMM1,PORT=serial6")
dbLoadRecords("$(IP)/ipApp/Db/Keithley2kDMM_mf.db","P=13IDC:,Dmm=DMM2,PORT=serial8")

# Second Octal UART for diffractometer experiments
# Serial ports 1 thru 4 are for SR570 current amplifiers
dbLoadRecords("$(IP)/ipApp/Db/SR570.db", "P=13IDC:,A=B1,PORT=serial9")
dbLoadRecords("$(IP)/ipApp/Db/SR570.db", "P=13IDC:,A=B2,PORT=serial10")
dbLoadRecords("$(IP)/ipApp/Db/SR570.db", "P=13IDC:,A=B3,PORT=serial11")
dbLoadRecords("$(IP)/ipApp/Db/SR570.db", "P=13IDC:,A=B4,PORT=serial12")

# Serial 13 and 14 are for MM4005s
# MM4000 driver setup parameters:
#     (1) maximum # of controllers,
#     (2) maximum # axis per controller
#     (3) motor task polling rate (min=1Hz, max=60Hz)
# MM4000Setup(2, 8, 10)

# MM4000 driver configuration parameters:
#     (1) controller
#     (2) asyn port name (e.g. serial1 or gpib1)
#     (3) GPIB address (0 for serial)
# MM4000Config(0, "serial13", 0)
# MM4000Config(1, "serial14", 0)

# Database for trajectory scanning with the MM4005/GPD
# The required command string is longer than the vxWorks command line, must use malloc and strcpy, strcat
# str = malloc(300)
# strcpy(str, "P=13IDC:,R=traj1,NAXES=6,NELM=2000,NPULSE=2000,")
# strcat(str, "DONPV=13IDC:str:EraseStart,DONV=1,DOFFPV=13IDC:str:StopAll,DOFFV=1")
# dbLoadRecords("$(MOTOR)/motorApp/Db/trajectoryScan.db", str)
# strcpy(str, "P=13IDC:,R=traj2,NAXES=8,NELM=2000,NPULSE=2000,")
# strcat(str, "DONPV=13IDC:str:EraseStart,DONV=1,DOFFPV=13IDC:str:StopAll,DOFFV=1")
# dbLoadRecords("$(MOTOR)/motorApp/Db/trajectoryScan.db", str)

# Serial port 16 is unused

