# $(TS).cars.aps.anl.gov is the Moxa NPort 6650-16 for 13-ID-A
iocshLoad ../asynIPPortConfig.cmd "PORT=serial1,  IPADDR=$(TS):4001, IEOS=\\r,     OEOS=\\r"   # MKS        19200,'E',1,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial2,  IPADDR=$(TS):4002, IEOS=\\r,     OEOS=\\r"   # MKS        19200,'E',1,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial3,  IPADDR=$(TS):4003, IEOS=,        OEOS=\\r"   # Digitel     9600,'E',1,7,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial4,  IPADDR=$(TS):4004, IEOS=,        OEOS=\\r"   # Digitel     9600,'E',1,7,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial5,  IPADDR=$(TS):4005, IEOS=\\r,     OEOS=\\r"   # MKS        19200,'E',1,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial6,  IPADDR=$(TS):4006, IEOS=,        OEOS=\\r"   # Digitel     9600,'E',1,7,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial7,  IPADDR=$(TS):4007, IEOS=\\r,     OEOS=\\r"   # MPC         9600,'N',1,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial8,  IPADDR=$(TS):4008, IEOS=\\r,     OEOS=\\r"   # MPC         9600,'N',1,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial9,  IPADDR=$(TS):4009, IEOS=\\n,     OEOS=\\r"   # Keithley   19200,'N',1,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial10, IPADDR=$(TS):4010, IEOS=\\r,     OEOS=\\r"   # Oxford ILM cryometer; C/D mono; 9600,'N',1,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial11, IPADDR=$(TS):4011, IEOS=\\r,     OEOS=\\r"   # MKS        19200,'E',1,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial12, IPADDR=$(TS):4012, IEOS=\\r,     OEOS=\\r"   # MPC         9600,'N',1,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial13, IPADDR=$(TS):4013, IEOS=\\n,     OEOS=\\r"   # Keithley 2000; C/D vertical mirror temps; 19200,'N',1,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial14, IPADDR=$(TS):4014, IEOS=\\r,     OEOS=\\r"   # Oxford ILM cryometer; E mono;             9600,'N',1,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial15, IPADDR=$(TS):4015, IEOS=\\r,     OEOS=\\r"   # MKS        19200,'E',1,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial16, IPADDR=$(TS):4016, IEOS=\\r,     OEOS=\\r"   # SR-570; E WBS/BPM blade current; 9600,'N',1,8,'N'
#iocshLoad ../asynIPPortConfig.cmd "PORT=serial17, IPADDR=$(TS):4017, IEOS=\\r,     OEOS=\\r"   # SR-570; C/D pinhole BPM blade current;  9600,'N',1,8,'N'


dbLoadRecords("$(IP)/db/MKS.db",              "P=$(P), PORT=serial1,  CC1=cc1, CC2=cc2, PR1=pr1, PR2=pr2")
dbLoadRecords("$(IP)/db/MKS.db",              "P=$(P), PORT=serial2,  CC1=cc3, CC2=cc4, PR1=pr3, PR2=pr4")
dbLoadRecords("$(IP)/db/Digitel.db",          "P=$(P), PORT=serial3,  PUMP=ip1")
dbLoadRecords("$(IP)/db/Digitel.db",          "P=$(P), PORT=serial3,  PUMP=ip5")
dbLoadRecords("$(IP)/db/Digitel.db",          "P=$(P), PORT=serial4,  PUMP=ip3")
dbLoadRecords("$(IP)/db/MKS.db",              "P=$(P), PORT=serial5,  CC1=cc5, CC2=cc6, PR1=pr5, PR2=pr6")
dbLoadRecords("$(IP)/db/Digitel.db",          "P=$(P), PORT=serial6,  PUMP=ip6")
dbLoadRecords("$(IP)/db/Digitel.db",          "P=$(P), PORT=serial6,  PUMP=ip7")
dbLoadRecords("$(IP)/db/MPC.db",              "P=$(P), PORT=serial7,  PUMP=ip2, PA=0, PN=2")
dbLoadRecords("$(IP)/db/MPC.db",              "P=$(P), PORT=serial7,  PUMP=ip4, PA=0, PN=1")
dbLoadRecords("$(IP)/db/MPC.db",              "P=$(P), PORT=serial8,  PUMP=ip9,   PA=0 ,PN=1")
dbLoadRecords("$(IP)/db/MPC.db",              "P=$(P), PORT=serial8,  PUMP=ip10, PORT=serial8, PA=0, PN=2")
dbLoadRecords("$(IP)/db/Keithley2kDMM_mf.db", "P=$(P), PORT=serial9,  Dmm=DMM1")
dbLoadRecords("$(CARS)/db/ILM200.db",         "P=$(P), PORT=serial10, R=ILM200_1,")
dbLoadRecords("$(IP)/db/MKS.db",              "P=$(P), PORT=serial11, CC1=cc7, CC2=cc8, PR1=pr7, PR2=pr8")
dbLoadRecords("$(IP)/db/MPC.db",              "P=$(P), PORT=serial12, PUMP=ip8,  PA=0, PN=1")
dbLoadRecords("$(IP)/db/MPC.db",              "P=$(P), PORT=serial12, PUMP=ip11, PA=0, PN=2")
dbLoadRecords("$(IP)/db/TSP.db",              "P=$(P), PORT=serial12, TSP=tsp1,  PA=0")
dbLoadRecords("$(IP)/db/Keithley2kDMM_mf.db", "P=$(P), PORT=serial13, Dmm=DMM2")
dbLoadRecords("$(CARS)/db/ILM200.db",         "P=$(P), PORT=serial14, R=ILM200_2")
dbLoadRecords("$(IP)/db/MKS.db",              "P=$(P), PORT=serial15, CC1=cc9, CC2=cc10, PR1=pr9, PR2=pr10")
dbLoadRecords("$(IP)/db/SR570.db",            "P=$(P), PORT=serial16, A=A1,")
#dbLoadRecords("$(IP)/db/SR570.db",            "P=$(P), PORT=serial17, A=A2,")

# Load asyn records on all serial ports
dbLoadTemplate("asynRecord.template", P=$(P))

# Disable error messages from MPC controllers.  WHY?
asynSetTraceMask("serial7",0,0)
asynSetTraceMask("serial8",0,0)
asynSetTraceMask("serial12",0,0)
