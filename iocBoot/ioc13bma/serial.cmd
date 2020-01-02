# int tyGSAsynInit(char *port, int uart, int channel, int baud, char parity, int sbits,
#                 int dbits, char handshake, char *inputEos, char *outputEos)
tyGSAsynInit("serial1",  "UART0", 0,  9600,'E',1,7,'N',"",  "\r") /* Digitel */
tyGSAsynInit("serial2",  "UART0", 1, 19200,'E',1,8,'N',"\r","\r")  /* MKS */
tyGSAsynInit("serial3",  "UART0", 2,  9600,'E',1,7,'N',"",  "\r")  /* Digitel */
tyGSAsynInit("serial4",  "UART0", 3, 19200,'E',1,8,'N',"\r","\r")  /* MKS */
tyGSAsynInit("serial5",  "UART0", 4, 19200,'E',1,8,'N',"\r","\r")  /* MKS */
tyGSAsynInit("serial6",  "UART0", 5,  9600,'E',1,7,'N',"",  "\r")  /* Digitel */
tyGSAsynInit("serial7",  "UART0", 6, 19200,'E',1,8,'N',"\r","\r")  /* MKS */
tyGSAsynInit("serial8",  "UART0", 7,  9600,'E',1,7,'N',"",  "\r")  /* Digitel */
tyGSAsynInit("serial9",  "UART1", 0,  9600,'E',1,7,'N',"\r\n","\r")  /* McClennan */
tyGSAsynInit("serial10", "UART1", 1, 19200,'N',1,8,'N',"\n","\r")  /* Keithley 2000 */
tyGSAsynInit("serial11", "UART1", 2,  9600,'N',1,8,'N',"\r","\r")  /* MPC */
tyGSAsynInit("serial12", "UART1", 3, 19200,'E',1,8,'N',"\r","\r")  /* MKS */
tyGSAsynInit("serial13", "UART1", 4, 19200,'N',1,8,'N',"\n","\r")  /* Keithley 2000 */
tyGSAsynInit("serial14", "UART1", 5,  9600,'N',1,8,'N',"\r","\r")  /* Unused */
tyGSAsynInit("serial15", "UART1", 6,  9600,'N',1,8,'N',"\r","\r")  /* Unused */
tyGSAsynInit("serial16", "UART1", 7,  9600,'N',1,8,'N',"\r","\r")  /* Unused */

# Debug MKS
#asynSetTraceMask("serial2",0,255)
#asynSetTraceIOMask("serial2",0,2)

# Debug McClennan
#asynSetTraceMask("serial9",0,9)
#asynSetTraceIOMask("serial9",0,2)

# Load asynRecords on all ports
dbLoadTemplate("asynRecord.template")

dbLoadRecords("$(IP)/db/Digitel.db","P=13BMA:,PUMP=ip1,PORT=serial1")
dbLoadRecords("$(IP)/db/MKS.db","P=13BMA:,PORT=serial2,CC1=cc1,CC2=cc3,PR1=pr1,PR2=pr3")
dbLoadRecords("$(IP)/db/Digitel.db","P=13BMA:,PUMP=ip7,PORT=serial3")
dbLoadRecords("$(IP)/db/MKS.db","P=13BMA:,PORT=serial4,CC1=cc7,CC2=cc8,PR1=pr7,PR2=pr8")
dbLoadRecords("$(IP)/db/MKS.db","P=13BMA:,PORT=serial5,CC1=cc9,CC2=cc10,PR1=pr9,PR2=pr10")
dbLoadRecords("$(IP)/db/Digitel.db","P=13BMA:,PUMP=ip10,PORT=serial6")
dbLoadRecords("$(IP)/db/MKS.db","P=13BMA:,PORT=serial7,CC1=cc2,CC2=cc11,PR1=pr2,PR2=pr11")
dbLoadRecords("$(IP)/db/Digitel.db","P=13BMA:,PUMP=ip2,PORT=serial8")
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
dbLoadRecords("$(IP)/db/Keithley2kDMM_mf.db","P=13BMA:,Dmm=DMM1,PORT=serial10")
dbLoadRecords("$(IP)/db/MPC.db","P=13BMA:,PUMP=ip8,PORT=serial11,PA=0,PN=1")
dbLoadRecords("$(IP)/db/MPC.db","P=13BMA:,PUMP=ip9,PORT=serial11,PA=0,PN=2")
dbLoadRecords("$(IP)/db/TSP.db","P=13BMA:,TSP=tsp1,PORT=serial11,PA=0")
dbLoadRecords("$(IP)/db/MKS.db","P=13BMA:,PORT=serial12,CC1=cc4,CC2=ccyyyy,PR1=pr4,PR2=pryyyy")
dbLoadRecords("$(IP)/db/Keithley2kDMM_mf.db","P=13BMA:,Dmm=DMM2,PORT=serial13")

