tyGSAsynInit("serial1",   0, 0,19200,'E',1,8,'N',"") /* MKS */
tyGSAsynInit("serial2",   0, 1,19200,'E',1,8,'N',"") /* MKS */
tyGSAsynInit("serial3",   0, 2, 9600,'E',1,7,'N',"") /* Digitel */
tyGSAsynInit("serial4",   0, 3, 9600,'E',1,7,'N',"") /* Digitel */
tyGSAsynInit("serial5",   0, 4,19200,'E',1,8,'N',"") /* MKS */
tyGSAsynInit("serial6",   0, 5, 9600,'E',1,7,'N',"") /* Digitel */
tyGSAsynInit("serial7",   0, 6, 9600,'N',1,8,'N',"") /* MPC */
tyGSAsynInit("serial8",   0, 7, 9600,'E',1,7,'N',"") /* McClennan PM304 */
tyGSAsynInit("serial9",   1, 0,19200,'N',1,8,'N',"") /* Keithley 2000 */
tyGSAsynInit("serial10",  1, 1, 9600,'N',1,8,'N',"") /* Oxford ILM cryometer */
tyGSAsynInit("serial11",  1, 2,19200,'E',1,8,'N',"") /* MKS */
tyGSAsynInit("serial12",  1, 3, 9600,'N',1,8,'N',"") /* MPC */
tyGSAsynInit("serial13",  1, 4,19200,'N',1,8,'N',"") /* Keithley 2000 */
tyGSAsynInit("serial14",  1, 5, 9600,'N',1,8,'N',"") /* Unused */
tyGSAsynInit("serial15",  1, 6, 9600,'N',1,8,'N',"") /* Unused */
tyGSAsynInit("serial16",  1, 7, 9600,'N',1,8,'N',"") /* Unused */

# Load asyn records on all serial ports
dbLoadTemplate("asynRecord.template")

dbLoadRecords("$(IP)/ipApp/Db/MKS.db","P=13IDA:,PORT=serial1,CC1=cc1,CC2=cc3,PR1=pr1,PR2=pr3")
dbLoadRecords("$(IP)/ipApp/Db/MKS.db","P=13IDA:,PORT=serial2,CC1=cc2,CC2=ccA,PR1=pr2,PR2=prA")
dbLoadRecords("$(IP)/ipApp/Db/Digitel.db","P=13IDA:,PUMP=ip1,PORT=serial3")
dbLoadRecords("$(IP)/ipApp/Db/Digitel.db","P=13IDA:,PUMP=ip3,PORT=serial4")
dbLoadRecords("$(IP)/ipApp/Db/MKS.db","P=13IDA:,PORT=serial5,CC1=cc5,CC2=cc6,PR1=pr5,PR2=pr6")
dbLoadRecords("$(IP)/ipApp/Db/Digitel.db","P=13IDA:,PUMP=ip5,PORT=serial6")
dbLoadRecords("$(IP)/ipApp/Db/MPC.db","P=13IDA:,PUMP=ip2,PORT=serial7,PA=0,PN=1", ip)
# serial8 is McClennan PM-304 motor controller
# PM304 driver setup parameters:
#     (1) maximum # of controllers,
#     (2) motor task polling rate (min=1Hz, max=60Hz)
PM304Setup(1, 10)

# PM304 driver configuration parameters:
#     (1) controller
#     (2) asyn port
#     (3) # axes
# Example:
#   PM304Config(0, "serial4", 1)
PM304Config(0, "serial8", 1)
dbLoadRecords("$(IP)/ipApp/Db/Keithley2kDMM_mf.db","P=13IDA:,Dmm=DMM1,PORT=serial9")
dbLoadRecords("$(CARS)/CARSApp/Db/ILM200.db","P=13IDA:,R=ILM200,PORT=serial10")
dbLoadRecords("$(IP)/ipApp/Db/MKS.db","P=13IDA:,PORT=serial11,CC1=cc7,CC2=ccB,PR1=pr7,PR2=prB")
dbLoadRecords("$(IP)/ipApp/Db/MPC.db","P=13IDA:,PUMP=ip6,PORT=serial12,PA=0,PN=1")
dbLoadRecords("$(IP)/ipApp/Db/MPC.db","P=13IDA:,PUMP=ip7,PORT=serial12,PA=0,PN=2")
dbLoadRecords("$(IP)/ipApp/Db/TSP.db","P=13IDA:,TSP=tsp1,PORT=serial12,PA=0")
dbLoadRecords("$(IP)/ipApp/Db/Keithley2kDMM_mf.db","P=13IDA:,Dmm=DMM2,PORT=serial13")


