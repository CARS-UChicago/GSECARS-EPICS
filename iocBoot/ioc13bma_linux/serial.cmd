iocshLoad ../asynIPPortConfig.cmd "PORT=serial1,  IPADDR=$(TS):4001, IEOS=,        OEOS=\\r"   # Digitel,    9600,'E',1,7,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial2,  IPADDR=$(TS):4002, IEOS=\\r,     OEOS=\\r"   # MKS        19200,'E',1,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial3,  IPADDR=$(TS):4003, IEOS=,        OEOS=\\r"   # Digitel     9600,'E',1,7,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial4,  IPADDR=$(TS):4004, IEOS=\\r,     OEOS=\\r"   # MKS        19200,'E',1,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial5,  IPADDR=$(TS):4005, IEOS=\\r,     OEOS=\\r"   # MKS        19200,'E',1,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial6,  IPADDR=$(TS):4006, IEOS=,        OEOS=\\r"   # Digitel     9600,'E',1,7,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial7,  IPADDR=$(TS):4007, IEOS=\\r,     OEOS=\\r"   # MKS        19200,'E',1,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial8,  IPADDR=$(TS):4008, IEOS=,        OEOS=\\r"   # Digitel     9600,'E',1,7,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial9,  IPADDR=$(TS):4009, IEOS=\\r\\n,  OEOS=\\r"   # McClennan   9600,'E',1,7,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial10, IPADDR=$(TS):4010, IEOS=\\n,     OEOS=\\r"   # Keithley   19200,'N',1,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial11, IPADDR=$(TS):4011, IEOS=\\r,     OEOS=\\r"   # MPC         9600,'N',1,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial12, IPADDR=$(TS):4012, IEOS=\\r,     OEOS=\\r"   # MKS        19200,'E',1,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial13, IPADDR=$(TS):4013, IEOS=\\n,     OEOS=\\r"   # Keithley   19200,'N',1,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial14, IPADDR=$(TS):4014, IEOS=\\r,     OEOS=\\r"   # Unused      9600,'N',1,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial15, IPADDR=$(TS):4015, IEOS=\\r,     OEOS=\\r"   # Unused      9600,'N',1,8,'N'
# Port 16 is RealCom port for Allen-Bradley SLC5/05 RS-232 programming

dbLoadRecords("$(IP)/db/Digitel.db",          "P=$(P), PORT=serial1,  PUMP=ip1")
dbLoadRecords("$(IP)/db/MKS.db",              "P=$(P), PORT=serial2,  CC1=cc1, CC2=cc3, PR1=pr1, PR2=pr3")
dbLoadRecords("$(IP)/db/Digitel.db",          "P=$(P), PORT=serial3,  PUMP=ip7")
dbLoadRecords("$(IP)/db/MKS.db",              "P=$(P), PORT=serial4,  CC1=cc7, CC2=cc8, PR1=pr7, PR2=pr8")
dbLoadRecords("$(IP)/db/MKS.db",              "P=$(P), PORT=serial5,  CC1=cc9, CC2=cc10, PR1=pr9, PR2=pr10")
dbLoadRecords("$(IP)/db/Digitel.db",          "P=$(P), PORT=serial6,  PUMP=ip10")
dbLoadRecords("$(IP)/db/MKS.db",              "P=$(P), PORT=serial7,  CC1=cc2, CC2=cc11, PR1=pr2, PR2=pr11")
dbLoadRecords("$(IP)/db/Digitel.db",          "P=$(P), PORT=serial8,  PUMP=ip2")
# serial9 is PM304 below
dbLoadRecords("$(IP)/db/Keithley2kDMM_mf.db", "P=$(P), PORT=serial10, Dmm=DMM1")
dbLoadRecords("$(IP)/db/MPC.db",              "P=$(P), PORT=serial11, PUMP=ip8, PA=0, PN=1")
dbLoadRecords("$(IP)/db/MPC.db",              "P=$(P), PORT=serial11, PUMP=ip9, PA=0,PN=2")
dbLoadRecords("$(IP)/db/TSP.db",              "P=$(P), PORT=serial11, TSP=tsp1, PA=0")
dbLoadRecords("$(IP)/db/MKS.db",              "P=$(P), PORT=serial12, CC1=cc4, CC2=ccyyyy, PR1=pr4, PR2=pryyyy")
dbLoadRecords("$(IP)/db/Keithley2kDMM_mf.db", "P=$(P), PORT=serial13, Dmm=DMM2")

# PM304 driver setup parameters:
#     (1) maximum # of controllers,
#     (2) motor task polling rate (min=1Hz, max=60Hz)
#PM304Setup(1, 10)

# PM304 driver configuration parameters:
#     (1) controller
#     (2) asyn port
#     (3) MAX axes
# Example:
#   PM304Config(0, "serial1", 1)
#PM304Config(0, "serial9", 1)

# Load asynRecords on all ports
dbLoadTemplate("asynRecord.template", "P=$(P)")

# Debug MKS
#asynSetTraceMask("serial2",   0, ERROR|DRIVER)
#asynSetTraceIOMask("serial2", 0, ESCAPE)

# Debug McClennan
asynSetTraceMask("serial9",   0, ERROR|DRIVER)
asynSetTraceIOMask("serial9", 0, ESCAPE)
