tyGSAsynInit("serial1",  0, 0,  9600,'N',2,8,'N',"") /* SRS 570 */
tyGSAsynInit("serial2",  0, 1,  9600,'N',2,8,'N',"") /* SRS 570 */
tyGSAsynInit("serial3",  0, 2, 19200,'N',1,8,'N',"") /* Keithley 2000 */
tyGSAsynInit("serial4",  0, 3,  4800,'N',1,8,'N',"") /* Generic serial / LPC */
tyGSAsynInit("serial5",  0, 4, 19200,'N',1,8,'N',"") /* Keithley 2000 */
tyGSAsynInit("serial6",  0, 5, 19200,'N',1,8,'N',"") /* Keithley 2000 */
tyGSAsynInit("serial7",  0, 6,  9600,'N',2,8,'N',"") /* SRS 570 */
tyGSAsynInit("serial8",  0, 7,  9600,'N',1,8,'N',"") /* SMART PC */
tyGSAsynInit("serial9",  1, 0,  9600,'N',2,7,'N',"") /* Omega meter */
tyGSAsynInit("serial10", 1, 1, 19200,'N',1,8,'N',"") /* RSF encoder readout */
tyGSAsynInit("serial11", 1, 2, 19200,'N',1,8,'N',"") /* PicoMotor controller */
tyGSAsynInit("serial12", 1, 3, 19200,'N',1,8,'N',"") /* Keithley 2700 */
tyGSAsynInit("serial13", 1, 4,  9600,'N',1,8,'N',"") /* Unused */
tyGSAsynInit("serial14", 1, 5,  9600,'N',1,8,'N',"") /* Unused */
tyGSAsynInit("serial15", 1, 6,  9600,'N',1,8,'N',"") /* Unused */
tyGSAsynInit("serial16", 1, 7,  9600,'N',1,8,'N',"") /* Unused */

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
strcat(str,"FSHUT=UnidigBo11,TRIG=UnidigBo1,SSHUT=UnidigBo2")
dbLoadRecords("$(CCD)/ccdApp/Db/smartControl.db", str)


dbLoadRecords("$(CARS)/CARSApp/Db/RSF715.db","P=13IDD:,ENCODER=RSF715,PORT=serial10")
# Serial 11 is picoMotors
dbLoadTemplate("picoMotors.template")
dbLoadRecords("$(IP)/ipApp/Db/Keithley2kDMM_mf.db", "P=13IDD:,Dmm=DMM5,PORT=serial12")


