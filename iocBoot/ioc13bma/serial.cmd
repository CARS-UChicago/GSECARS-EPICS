# int tyGSAsynInit(char *server, int uart, int channel, int baud, char parity, int sbits,
#                 int dbits, char handshake, char *eomstr)
tyGSAsynInit("serial1",  0, 0,  9600,'E',1,7,'N',"\r") /* Digitel */
tyGSAsynInit("serial2",  0, 1, 19200,'E',1,8,'N',"\r")  /* MKS */
tyGSAsynInit("serial3",  0, 2,  9600,'E',1,7,'N',"\r")  /* Digitel */
tyGSAsynInit("serial4",  0, 3, 19200,'E',1,8,'N',"\r")  /* MKS */
tyGSAsynInit("serial5",  0, 4, 19200,'E',1,8,'N',"\r")  /* MKS */
tyGSAsynInit("serial6",  0, 5,  9600,'E',1,7,'N',"\r")  /* Digitel */
tyGSAsynInit("serial7",  0, 6, 19200,'E',1,8,'N',"\r")  /* MKS */
tyGSAsynInit("serial8",  0, 7,  9600,'E',1,7,'N',"\r")  /* Digitel */
tyGSAsynInit("serial9",  1, 0,  9600,'E',1,7,'N',"\r")  /* McClennan */
tyGSAsynInit("serial10", 1, 1, 19200,'N',1,8,'N',"\r")  /* Keithley 2000 */
tyGSAsynInit("serial11", 1, 2,  9600,'N',1,8,'N',"\r")  /* MPC */
tyGSAsynInit("serial12", 1, 3, 19200,'E',1,8,'N',"\r")  /* MKS */
tyGSAsynInit("serial13", 1, 4, 19200,'N',1,8,'N',"\r")  /* Keithley 2000 */
tyGSAsynInit("serial14", 1, 5,  9600,'N',1,8,'N',"\r")  /* Unused */
tyGSAsynInit("serial15", 1, 6,  9600,'N',1,8,'N',"\r")  /* Unused */
tyGSAsynInit("serial16", 1, 7,  9600,'N',1,8,'N',"\r")  /* Unused */

# Debug MPC
#asynSetTraceMask("serial11",0,255)
#asynSetTraceIOMask("serial11",0,2)

# Debug McClennan
#asynSetTraceMask("serial9",0,9)
#asynSetTraceIOMask("serial9",0,2)

# Load asynRecords on all ports
dbLoadTemplate("asynRecord.template")

dbLoadRecords("$(IP)/ipApp/Db/Digitel.db","P=13BMA:,PUMP=ip1,PORT=serial1")
dbLoadRecords("$(IP)/ipApp/Db/MKS.db","P=13BMA:,PORT=serial2,CC1=cc1,CC2=cc3,PR1=pr1,PR2=pr3")
dbLoadRecords("$(IP)/ipApp/Db/Digitel.db","P=13BMA:,PUMP=ip7,PORT=serial3")
dbLoadRecords("$(IP)/ipApp/Db/MKS.db","P=13BMA:,PORT=serial4,CC1=cc7,CC2=ccy,PR1=pr7,PR2=pry")
dbLoadRecords("$(IP)/ipApp/Db/MKS.db","P=13BMA:,PORT=serial5,CC1=cc9,CC2=cc10,PR1=pr9,PR2=pr10")
dbLoadRecords("$(IP)/ipApp/Db/Digitel.db","P=13BMA:,PUMP=ip10,PORT=serial6")
dbLoadRecords("$(IP)/ipApp/Db/MKS.db","P=13BMA:,PORT=serial7,CC1=cc2,CC2=ccyyy,PR1=pr2,PR2=pryyy")
dbLoadRecords("$(IP)/ipApp/Db/Digitel.db","P=13BMA:,PUMP=ip2,PORT=serial8")
# PM304 driver setup parameters:
#     (1) maximum # of controllers,
#     (2) motor task polling rate (min=1Hz, max=60Hz)
PM304Setup(1, 10)

# PM304 driver configuration parameters:
#     (1) controller
#     (2) asyn port
#     (3) MAX axes
# Example:
#   PM304Config(0, "serial1", 1)
PM304Config(0, "serial9", 1)
dbLoadRecords("$(IP)/ipApp/Db/Keithley2kDMM_mf.db","P=13BMA:,Dmm=DMM1,PORT=serial10")
dbLoadRecords("$(IP)/ipApp/Db/MPC.db","P=13BMA:,PUMP=ip8,PORT=serial11,PA=0,PN=1")
dbLoadRecords("$(IP)/ipApp/Db/MPC.db","P=13BMA:,PUMP=ip9,PORT=serial11,PA=0,PN=2")
dbLoadRecords("$(IP)/ipApp/Db/TSP.db","P=13BMA:,TSP=tsp1,PORT=serial11,PA=0")
dbLoadRecords("$(IP)/ipApp/Db/MKS.db","P=13BMA:,PORT=serial12,CC1=cc8,CC2=ccyyyy,PR1=pr8,PR2=pryyyy")
dbLoadRecords("$(IP)/ipApp/Db/Keithley2kDMM_mf.db","P=13BMA:,Dmm=DMM2,PORT=serial13")

