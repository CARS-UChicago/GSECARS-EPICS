tyGSAsynInit("serial1",  0, 0,  9600,'N',2,8,'N',"") /* SRS570 */
tyGSAsynInit("serial2",  0, 1,  9600,'N',2,8,'N',"") /* SRS570 */
tyGSAsynInit("serial3",  0, 2,  9600,'N',2,8,'N',"") /* SRS570 */
tyGSAsynInit("serial4",  0, 3,  9600,'N',2,8,'N',"") /* SRS570 */
tyGSAsynInit("serial5",  0, 4,  9600,'N',2,8,'N',"") /* SRS570 */
tyGSAsynInit("serial6",  0, 5,  9600,'N',2,8,'N',"") /* SRS570 */
tyGSAsynInit("serial7",  0, 6,  9600,'N',2,8,'N',"") /* Unused */
tyGSAsynInit("serial8",  0, 7, 19200,'N',1,8,'N',"") /* Keithley 2000 */
tyGSAsynInit("serial9",  1, 0,  9600,'N',2,8,'N',"") /* SRS570 */
tyGSAsynInit("serial10", 1, 1,  9600,'N',2,8,'N',"") /* SRS570 */
tyGSAsynInit("serial11", 1, 2,  9600,'N',2,8,'N',"") /* SRS570 */
tyGSAsynInit("serial12", 1, 3,  9600,'N',2,8,'N',"") /* SRS570 */
tyGSAsynInit("serial13", 1, 4, 38400,'N',1,8,'N',"") /* MM4000 */
tyGSAsynInit("serial14", 1, 5, 38400,'N',1,8,'N',"") /* MM4000 */
tyGSAsynInit("serial15", 1, 6,  9600,'N',2,8,'N',"") /* Unused */
tyGSAsynInit("serial16", 1, 7,  9600,'N',1,8,'N',"") /* SMART PC */

# Load asyn records on all serial ports
dbLoadTemplate("asynRecord.template")

# First Octal UART for microprobe experiments
dbLoadRecords("$(IP)/ipApp/Db/SR570.db", "P=13IDC:,A=A1,PORT=serial1")
dbLoadRecords("$(IP)/ipApp/Db/SR570.db", "P=13IDC:,A=A2,PORT=serial2")
dbLoadRecords("$(IP)/ipApp/Db/SR570.db", "P=13IDC:,A=A3,PORT=serial3")
dbLoadRecords("$(IP)/ipApp/Db/SR570.db", "P=13IDC:,A=A4,PORT=serial4")
dbLoadRecords("$(IP)/ipApp/Db/SR570.db", "P=13IDC:,A=A5,PORT=serial5")
dbLoadRecords("$(IP)/ipApp/Db/SR570.db", "P=13IDC:,A=A6,PORT=serial6")

dbLoadRecords("$(IP)/ipApp/Db/Keithley2kDMM_mf.db", "P=13IDC:,Dmm=DMM1,PORT=serial8")

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
MM4000Setup(2, 8, 10)

# MM4000 driver configuration parameters:
#     (1) controller
#     (2) asyn port name (e.g. serial1 or gpib1)
#     (3) GPIB address (0 for serial)
MM4000Config(0, "serial13", 0)
MM4000Config(1, "serial14", 0)

# Database for trajectory scanning with the MM4005/GPD
# The required command string is longer than the vxWorks command line, must use malloc and strcpy, strcat
str = malloc(300)
strcpy(str, "P=13IDC:,R=traj1,NAXES=6,NELM=1000,NPULSE=1000,PORT=serial13,")
strcat(str, ",DONPV=13IDC:str:EraseStart,DONV=1,DOFFPV=13IDC:str:StopAll,DOFFV=1")
dbLoadRecords("$(CARS)/CARSApp/Db/trajectoryScan.db", str)
strcpy(str, "P=13IDC:,R=traj2,NAXES=8,NELM=1000,NPULSE=1000,PORT=serial14,")
strcat(str, ",DONPV=13IDC:str:EraseStart,DONV=1,DOFFPV=13IDC:str:StopAll,DOFFV=1")
strcat(str, ",M1=Y1,M2=Y2,M3=Y3,M4=Rotation AY,M5=X translation,M6=Sample X,M7=Sample Y,M8=Sample Z")
dbLoadRecords("$(CARS)/CARSApp/Db/trajectoryScan.db", str)

# Serial port 16 is for the SMART PC
str=malloc(256)
strcpy(str,"P=13IDC:,R=smart1,PORT=serial16,")
strcat(str,"FSHUT=UnidigBo0,TRIG=UnidigBo1,SSHUT=UnidigBo2")
dbLoadRecords("$(CCD)/ccdApp/Db/smartControl.db",str)

