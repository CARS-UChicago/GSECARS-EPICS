iocshLoad ../asynIPPortConfig.cmd "PORT=serial1,  IPADDR=$(TS):4001, IEOS=\\r,     OEOS=\\r"    # SRS570;      9600,'N',2,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial2,  IPADDR=$(TS):4002, IEOS=\\r,     OEOS=\\r"    # SRS570;      9600,'N',2,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial3,  IPADDR=$(TS):4003, IEOS=\\r,     OEOS=\\r"    # SRS570;      9600,'N',2,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial4,  IPADDR=$(TS):4004, IEOS=\\r,     OEOS=\\r"    # SRS570;      9600,'N',2,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial5,  IPADDR=$(TS):4005, IEOS=\\r,     OEOS=\\r"    # SRS570;      9600,'N',2,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial6,  IPADDR=$(TS):4006, IEOS=\\n,     OEOS=\\r"    # Linkam      19200,'N',1,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial7,  IPADDR=$(TS):4007, IEOS=\\r,     OEOS=\\r"    # Pelco CM6700 9600,'N',2,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial8,  IPADDR=$(TS):4008, IEOS=\\n,     OEOS=\\r"    # Keithley    19200,'N',1,8,'N'

# Load asyn records on all ports
dbLoadTemplate("asynRecord.template", P="$(P)")

dbLoadRecords("$(IP)/db/SR570.db",                       "P=$(P), PORT=serial1,A=A1")
dbLoadRecords("$(IP)/db/SR570.db",                       "P=$(P), PORT=serial2,A=A2")
dbLoadRecords("$(IP)/db/SR570.db",                       "P=$(P), PORT=serial3,A=A3")
dbLoadRecords("$(IP)/db/SR570.db",                       "P=$(P), PORT=serial4,A=A4")
dbLoadRecords("$(IP)/db/SR570.db",                       "P=$(P), PORT=serial5,A=A5")
dbLoadTemplate("$(CARS)/db/Pelco_CM6700.substitutions",  "P=$(P), PORT=serial7, R=Pelco1")
# Port 8 can either be the LAE or the Keithley 
#dbLoadRecords("$(IP)/db/Newport_LAE500.db",              "P=$(P), PORT=serial8, R=LAE500")
dbLoadRecords("$(IP)/db/Keithley2kDMM_mf.db",            "P=$(P), PORT=serial8, Dmm=DMM1")
