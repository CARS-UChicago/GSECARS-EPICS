# int tyGSAsynInit(char *server, int uart, int channel, int baud, char parity, int sbits,
#                 int dbits, char handshake, char *eomstr)
tyGSAsynInit("serial1",  0, 0, 9600,'N',2,8,'N',"")  /* SRS570 */
tyGSAsynInit("serial2",  0, 1,19200,'N',1,8,'N',"")  /* Keithley 2000 */
tyGSAsynInit("serial3",  0, 2, 9600,'N',2,8,'N',"")  /* SRS570 */
tyGSAsynInit("serial4",  0, 3, 9600,'N',2,8,'N',"")  /* SRS570 */
#tyGSAsynInit("serial4",  0, 3,19200,'N',1,8,'N',"")  /* MM4000 */
tyGSAsynInit("serial5",  0, 4, 9600,'N',2,7,'N',"")  /* Omega meter */
tyGSAsynInit("serial6",  0, 5, 9600,'N',1,8,'N',"")  /* SMART PC */
tyGSAsynInit("serial7",  0, 6,19200,'N',1,8,'N',"")  /* Keithley 2000 */
tyGSAsynInit("serial8",  0, 7,19200,'N',1,8,'N',"")  /* Keithley 2000 */
# Second IP-Octal
tyGSAsynInit("serial9",  1, 0,19200,'N',1,8,'N',"")  /* Keithley 2000 */
tyGSAsynInit("serial10", 1, 1, 9600,'N',1,8,'N',"")  /* XIA shutter */
tyGSAsynInit("serial11", 1, 2,19200,'N',1,8,'N',"\r\n","\r\n")  /* Verdi Laser */
tyGSAsynInit("serial12", 1, 3, 9600,'N',1,8,'N',"")  /* Unused */
tyGSAsynInit("serial13", 1, 4, 9600,'N',1,8,'N',"")  /* Unused */
tyGSAsynInit("serial14", 1, 5, 9600,'N',1,8,'N',"")  /* Unused */
tyGSAsynInit("serial15", 1, 6, 9600,'N',1,8,'N',"")  /* Unused */
tyGSAsynInit("serial16", 1, 7, 9600,'N',1,8,'N',"")  /* Unused */

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


