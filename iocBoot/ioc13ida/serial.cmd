# int tyGSAsynInit(char *port, int uart, int channel, int baud, char parity, int sbits,
#                 int dbits, char handshake, char *inputEos, char *outputEos)
tyGSAsynInit("serial1",   "UART0", 0,19200,'E',1,8,'N',"\r","\r") /* MKS; PR1, CC1, PR2, CC2 */
dbLoadRecords("$(IP)/ipApp/Db/MKS.db","P=13IDA:,PORT=serial1,CC1=cc1,CC2=cc2,PR1=pr1,PR2=pr2")

tyGSAsynInit("serial2",   "UART0", 1,19200,'E',1,8,'N',"\r","\r") /* MKS; PR3, CC3, PR4, CC4 */
dbLoadRecords("$(IP)/ipApp/Db/MKS.db","P=13IDA:,PORT=serial2,CC1=cc3,CC2=cc4,PR1=pr3,PR2=pr4")

tyGSAsynInit("serial3",   "UART0", 2, 9600,'E',1,7,'N',"",  "\r") /* Digitel; IP1, IP5 */
dbLoadRecords("$(IP)/ipApp/Db/Digitel.db","P=13IDA:,PUMP=ip1,PORT=serial3")
dbLoadRecords("$(IP)/ipApp/Db/Digitel.db","P=13IDA:,PUMP=ip5,PORT=serial3")

tyGSAsynInit("serial4",   "UART0", 3, 9600,'E',1,7,'N',"",  "\r") /* Digitel; IP3 */
dbLoadRecords("$(IP)/ipApp/Db/Digitel.db","P=13IDA:,PUMP=ip3,PORT=serial4")

tyGSAsynInit("serial5",   "UART0", 4,19200,'E',1,8,'N',"\r","\r") /* MKS; P5, CC5, PR6, CC6 */
dbLoadRecords("$(IP)/ipApp/Db/MKS.db","P=13IDA:,PORT=serial5,CC1=cc5,CC2=cc6,PR1=pr5,PR2=pr6")

tyGSAsynInit("serial6",   "UART0", 5, 9600,'E',1,7,'N',"",  "\r") /* Digitel; IP6, IP7 */
dbLoadRecords("$(IP)/ipApp/Db/Digitel.db","P=13IDA:,PUMP=ip6,PORT=serial6")
dbLoadRecords("$(IP)/ipApp/Db/Digitel.db","P=13IDA:,PUMP=ip7,PORT=serial6")

tyGSAsynInit("serial7",   "UART0", 6, 9600,'N',1,8,'N',"\r","\r") /* MPC; IP2, IP4 */
dbLoadRecords("$(IP)/ipApp/Db/MPC.db","P=13IDA:,PUMP=ip2,PORT=serial7,PA=0,PN=2")
dbLoadRecords("$(IP)/ipApp/Db/MPC.db","P=13IDA:,PUMP=ip4,PORT=serial7,PA=0,PN=1")

tyGSAsynInit("serial8",   "UART0", 7, 9600,'N',1,8,'N',"\r","\r") /* MPC; IP9, IP10 */
dbLoadRecords("$(IP)/ipApp/Db/MPC.db","P=13IDA:,PUMP=ip9,PORT=serial8,PA=0,PN=1")
dbLoadRecords("$(IP)/ipApp/Db/MPC.db","P=13IDA:,PUMP=ip10,PORT=serial8,PA=0,PN=2")

tyGSAsynInit("serial9",   "UART1", 0,19200,'N',1,8,'N',"\n","\r") /* Keithley 2000; monos, E mirror, pinhole temps */
dbLoadRecords("$(IP)/ipApp/Db/Keithley2kDMM_mf.db","P=13IDA:,Dmm=DMM1,PORT=serial9")

tyGSAsynInit("serial10",  "UART1", 1, 9600,'N',1,8,'N',"\r","\r") /* Oxford ILM cryometer; C/D mono */
dbLoadRecords("$(CARS)/CARSApp/Db/ILM200.db","P=13IDA:,R=ILM200_1,PORT=serial10")

tyGSAsynInit("serial11",  "UART1", 2,19200,'E',1,8,'N',"\r","\r") /* MKS; PR7, CC7, PR8 */
dbLoadRecords("$(IP)/ipApp/Db/MKS.db","P=13IDA:,PORT=serial11,CC1=cc7,CC2=cc8,PR1=pr7,PR2=pr8")

tyGSAsynInit("serial12",  "UART1", 3, 9600,'N',1,8,'N',"\r","\r") /* MPC; IP8, IP11 */
dbLoadRecords("$(IP)/ipApp/Db/MPC.db","P=13IDA:,PUMP=ip8,PORT=serial12,PA=0,PN=1")
dbLoadRecords("$(IP)/ipApp/Db/MPC.db","P=13IDA:,PUMP=ip11,PORT=serial12,PA=0,PN=2")
dbLoadRecords("$(IP)/ipApp/Db/TSP.db","P=13IDA:,TSP=tsp1,PORT=serial12,PA=0")

tyGSAsynInit("serial13",  "UART1", 4,19200,'N',1,8,'N',"\n","\r") /* Keithley 2000; C/D vertical mirror temps */
dbLoadRecords("$(IP)/ipApp/Db/Keithley2kDMM_mf.db","P=13IDA:,Dmm=DMM2,PORT=serial13")

tyGSAsynInit("serial14",  "UART1", 5, 9600,'N',1,8,'N',"\r","\r") /* Oxford ILM cryometer; E mono */
dbLoadRecords("$(CARS)/CARSApp/Db/ILM200.db","P=13IDA:,R=ILM200_2,PORT=serial14")

tyGSAsynInit("serial15",  "UART1", 6,19200,'E',1,8,'N',"\r","\r") /* MKS; PR9, CC9, PR10 */
dbLoadRecords("$(IP)/ipApp/Db/MKS.db","P=13IDA:,PORT=serial15,CC1=cc9,CC2=cc10,PR1=pr9,PR2=pr10")

tyGSAsynInit("serial16",  "UART1", 7, 9600,'N',1,8,'N',"\r","\r") /* SR-570; E WBS/BPM blade current */
dbLoadRecords("$(IP)/ipApp/Db/SR570.db", "P=13IDA:,A=A1,PORT=serial16")

tyGSAsynInit("serial17",  "UART2", 0, 9600,'N',1,8,'N',"\r","\r") /* SR-570; C/D pinhole BPM blade current */
dbLoadRecords("$(IP)/ipApp/Db/SR570.db", "P=13IDA:,A=A2,PORT=serial17")

tyGSAsynInit("serial18",  "UART2", 1, 9600,'N',1,8,'N',"\r","\r") /* Unused */
tyGSAsynInit("serial19",  "UART2", 2, 9600,'N',1,8,'N',"\r","\r") /* Unused */
tyGSAsynInit("serial20",  "UART2", 3, 9600,'N',1,8,'N',"\r","\r") /* Unused */
tyGSAsynInit("serial21",  "UART2", 4, 9600,'N',1,8,'N',"\r","\r") /* Unused */
tyGSAsynInit("serial22",  "UART2", 5, 9600,'N',1,8,'N',"\r","\r") /* Unused */
tyGSAsynInit("serial23",  "UART2", 6, 9600,'N',1,8,'N',"\r","\r") /* Unused */
tyGSAsynInit("serial24",  "UART2", 7, 9600,'N',1,8,'N',"\r","\r") /* Unused */

# Load asyn records on all serial ports
dbLoadTemplate("asynRecord.template")


asynSetTraceMask("serial7",0,0)
asynSetTraceMask("serial8",0,0)
asynSetTraceMask("serial12",0,0)
