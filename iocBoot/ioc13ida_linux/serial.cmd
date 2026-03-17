# gsets17.cars.aps.anl.gov is the Moxa NPort 6650-16 for 13-ID-A
iocshLoad ../asynIPPortConfig.cmd "PORT=serial1,  IPADDR=$(TS):4001, IEOS=\\r,     OEOS=\\r"   # MKS        19200,'E',1,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial2,  IPADDR=$(TS):4002, IEOS=\\r,     OEOS=\\r"   # MKS        19200,'E',1,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial3,  IPADDR=$(TS):4003, IEOS=\\n,     OEOS=\\r"   # Digitel     9600,'E',1,7,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial4,  IPADDR=$(TS):4004, IEOS=\\n,     OEOS=\\r"   # Digitel     9600,'E',1,7,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial5,  IPADDR=$(TS):4005, IEOS=\\r,     OEOS=\\r"   # MKS        19200,'E',1,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial6,  IPADDR=GSETS18:4006, IEOS=\\r,   OEOS=\\r"   # MPC         9600,'E',1,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial7,  IPADDR=$(TS):4007, IEOS=\\r,     OEOS=\\r"   # MPC         9600,'N',1,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial8,  IPADDR=$(TS):4008, IEOS=\\r,     OEOS=\\r"   # MPC         9600,'N',1,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial9,  IPADDR=$(TS):4009, IEOS=\\n,     OEOS=\\r"   # Keithley   19200,'N',1,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial10, IPADDR=$(TS):4010, IEOS=\\r,     OEOS=\\r"   # MKS        19200,'E',1,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial11, IPADDR=$(TS):4011, IEOS=\\r,     OEOS=\\r"   # MKS        19200,'E',1,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial12, IPADDR=GSETS2:4008, IEOS=\\r,    OEOS=\\r"   # MPC         9600,'N',1,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial13, IPADDR=$(TS):4013, IEOS=\\n,     OEOS=\\r"   # Keithley 2000; C/D vertical mirror temps; 19200,'N',1,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial14, IPADDR=$(TS):4014, IEOS=\\r,     OEOS=\\r"   # SR-570; E WBS/BPM blade current; 9600,'N',1,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial15, IPADDR=$(TS):4015, IEOS=\\r,     OEOS=\\r"   # MPC         9600,'N',1,8,'N'
# Serial 16 is COM port to Allen-Bradley PLC

epicsEnvSet(TS2, gsets24)
iocshLoad ../asynIPPortConfig.cmd "PORT=serial17, IPADDR=$(TS2):4001, IEOS=\\r,     OEOS=\\r"   # Oxford ILM cryometer; C/D mono; 9600,'N',1,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial18, IPADDR=$(TS2):4002, IEOS=\\r,     OEOS=\\r"   # Oxford ILM cryometer; E mono;   9600,'N',1,8,'N'

epicsEnvSet(QPC_PORT, "gse-gamma-qpc-1:23")
iocshLoad ../asynIPPortConfig.cmd "PORT=serial19, IPADDR=$(QPC_PORT), IEOS=\\n,     OEOS=\\n"   # Gamma QPC quad ion pump controller

# These are in the 13-ID-D terminal server
iocshLoad ../asynIPPortConfig.cmd "PORT=serial20, IPADDR=GSETS19:4013, IEOS=\\r,    OEOS=\\r"   # MPC         9600,'N',1,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial21, IPADDR=GSETS19:4014, IEOS=\\r,    OEOS=\\r"   # MKS        19200,'E',1,8,'N'

epicsEnvSet(MPC1_PORT, "gse-mpc1:23")
iocshLoad ../asynIPPortConfig.cmd "PORT=serial22, IPADDR=$(MPC1_PORT), IEOS=\\r>,     OEOS=\\r"   # Gamma MPCq ion pump controller


dbLoadRecords("$(IP)/db/MKS.db",              "P=$(P), PORT=serial1,  CC1=cc1, CC2=cc2, PR1=pr1, PR2=pr2")
dbLoadRecords("$(IP)/db/MKS.db",              "P=$(P), PORT=serial2,  CC1=cc3, CC2=cc4, PR1=pr3, PR2=pr4")
#dbLoadRecords("$(IP)/db/Digitel_stream.db",   "P=$(P), PORT=serial3,  PUMP=ip1")
#dbLoadRecords("$(IP)/db/Digitel_stream.db",   "P=$(P), PORT=serial3,  PUMP=ip5")
#dbLoadRecords("$(IP)/db/Digitel_stream.db",   "P=$(P), PORT=serial4,  PUMP=ip3")
dbLoadRecords("$(IP)/db/MKS.db",              "P=$(P), PORT=serial5,  CC1=cc5, CC2=cc6, PR1=pr5, PR2=pr6")
#dbLoadRecords("$(IP)/db/MPC.db",               "P=$(P), PORT=serial6,  PUMP=ip6, PA=0, PN=1")
#dbLoadRecords("$(IP)/db/MPC.db",               "P=$(P), PORT=serial6,  PUMP=ip7, PA=0, PN=2")
#dbLoadRecords("$(IP)/db/MPC.db",              "P=$(P), PORT=serial7,  PUMP=ip2, PA=0, PN=2")
#dbLoadRecords("$(IP)/db/MPC.db",              "P=$(P), PORT=serial7,  PUMP=ip4,  PA=0, PN=1")
dbLoadRecords("$(IP)/db/MPC.db",              "P=$(P), PORT=serial8,  PUMP=ip9,  PA=0 ,PN=1")
dbLoadRecords("$(IP)/db/MPC.db",              "P=$(P), PORT=serial8,  PUMP=ip10, PA=0, PN=2")
dbLoadRecords("$(IP)/db/Keithley2kDMM_mf.db", "P=$(P), PORT=serial9,  Dmm=DMM1")
dbLoadRecords("$(IP)/db/MKS.db",              "P=$(P), PORT=serial10, CC1=cc9, CC2=cc10, PR1=pr9, PR2=pr10")
dbLoadRecords("$(IP)/db/MKS.db",              "P=$(P), PORT=serial11, CC1=cc7, CC2=cc8, PR1=pr7, PR2=pr8")
dbLoadRecords("$(IP)/db/MPC.db",              "P=$(P), PORT=serial12, PUMP=ip8,  PA=0, PN=1")
dbLoadRecords("$(IP)/db/MPC.db",              "P=$(P), PORT=serial12, PUMP=ip11, PA=0, PN=2")
#dbLoadRecords("$(IP)/db/TSP.db",              "P=$(P), PORT=serial12, TSP=tsp1,  PA=0")
#dbLoadRecords("$(IP)/db/Digitel_stream.db",   "P=$(P), PORT=serial12, PUMP=ip8")
#dbLoadRecords("$(IP)/db/Digitel_stream.db",   "P=$(P), PORT=serial12, PUMP=ip11")
dbLoadRecords("$(IP)/db/Keithley2kDMM_mf.db", "P=$(P), PORT=serial13, Dmm=DMM2")
dbLoadRecords("$(IP)/db/SR570.db",            "P=$(P), PORT=serial14, A=A1,")
#dbLoadRecords("$(IP)/db/SR570.db",            "P=$(P), PORT=serial17, A=A2,")
dbLoadRecords("$(IP)/db/MPC.db",              "P=$(P), PORT=serial15,  PUMP=ip1,  PA=0, PN=2")
dbLoadRecords("$(IP)/db/MPC.db",              "P=$(P), PORT=serial15,  PUMP=ip2,  PA=0, PN=1")
dbLoadRecords("$(CARS)/db/ILM200.db",         "P=$(P), PORT=serial17, R=ILM200_1,")
dbLoadRecords("$(CARS)/db/ILM200.db",         "P=$(P), PORT=serial18, R=ILM200_2")
dbLoadRecords("$(VAC)/db/QPC-device_streams.db", "P=$(P), PORT=serial19, PROTO=QPC-eth")
dbLoadRecords("$(VAC)/db/QPCstreams.db",      "P=$(P), PORT=serial19, PROTO=QPC-eth, PMP=ip3, SPLY=1, SPT=1")
dbLoadRecords("$(VAC)/db/QPCstreams.db",      "P=$(P), PORT=serial19, PROTO=QPC-eth, PMP=ip4, SPLY=2, SPT=2")
dbLoadRecords("$(VAC)/db/QPCstreams.db",      "P=$(P), PORT=serial19, PROTO=QPC-eth, PMP=ip5, SPLY=3, SPT=3")
dbLoadRecords("$(IP)/db/MPC.db",              "P=$(P), PORT=serial20, PUMP=ip12, PA=0, PN=1")
dbLoadRecords("$(IP)/db/MKS.db",              "P=$(P), PORT=serial21, CC1=cc11, CC2=cc12, PR1=pr11, PR2=pr12")
dbLoadRecords("$(IP)/db/MPC_Ethernet.template","P=$(P), PORT=serial22, PUMP=ip6, PN=1")
dbLoadRecords("$(IP)/db/MPC_Ethernet.template","P=$(P), PORT=serial22, PUMP=ip7, PN=2")

# Load asyn records on all serial ports
dbLoadTemplate("asynRecord.template", P=$(P))

# Disable error messages from MPC controllers.  WHY?
asynSetTraceMask("serial7",0,0)
asynSetTraceMask("serial8",0,0)
asynSetTraceMask("serial12",0,0)

asynSetTraceIOMask("serial11",0,ESCAPE)
#asynSetTraceMask("serial11",0,ERROR|DRIVER)

asynSetTraceIOMask("serial9",0,ESCAPE)
asynSetTraceMask("serial9",0,ERROR|DRIVER)
asynSetTraceFile("serial9",0,"keithly9.txt")



