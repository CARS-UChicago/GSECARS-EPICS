# int tyGSAsynInit(char *port, int uart, int channel, int baud, char parity, int sbits,
#                 int dbits, char handshake, char *eomstr)
tyGSAsynInit("serial1",  0, 0,19200,'N',1,8,'N',"")  /* Keithley */
tyGSAsynInit("serial2",  0, 1, 9600,'N',2,8,'N',"")  /* SRS 570 */
tyGSAsynInit("serial3",  0, 2, 9600,'N',2,8,'N',"")  /* SRS 570 */
tyGSAsynInit("serial4",  0, 3, 9600,'N',1,8,'N',"")  /* LAE500 */
tyGSAsynInit("serial5",  0, 4, 9600,'N',1,8,'N',"")  /* Unused */
tyGSAsynInit("serial6",  0, 5, 9600,'N',1,8,'N',"")  /* Unused */
tyGSAsynInit("serial7",  0, 6, 9600,'N',2,8,'N',"")  /* Unused */
tyGSAsynInit("serial8",  0, 7, 9600,'N',2,8,'N',"")  /* Unused */

# Load asyn records on all serial ports
dbLoadTemplate("asynRecord.template")

dbLoadRecords("$(IP)/ipApp/Db/Keithley2kDMM_mf.db","P=13BMC:,Dmm=DMM1,PORT=serial1")

dbLoadRecords("$(IP)/ipApp/Db/SR570.db", "P=13BMC:,A=A1,PORT=serial2")
dbLoadRecords("$(IP)/ipApp/Db/SR570.db", "P=13BMC:,A=A2,PORT=serial3")

# Port 4 has Newport LAE500 Laser Autocollimator (and generic serial port)
dbLoadRecords("$(CARS)/CARSApp/Db/LAE500.db","P=13BMC:,R=LAE500,PORT=serial4")

