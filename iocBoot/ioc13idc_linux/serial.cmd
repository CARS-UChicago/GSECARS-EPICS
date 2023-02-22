$ Joanne says that only 2 SR570 units are being used, B1 and B4.

iocshLoad ../asynIPPortConfig.cmd "PORT=serial1,  IPADDR=$(TS):4001, IEOS=\\r,     OEOS=\\r"    # SRS570;      9600,'N',2,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial2,  IPADDR=$(TS):4002, IEOS=\\r,     OEOS=\\r"    # SRS570;      9600,'N',2,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial3,  IPADDR=$(TS):4003, IEOS=\\r,     OEOS=\\r"    # SRS570;      9600,'N',2,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial4,  IPADDR=$(TS):4004, IEOS=\\r,     OEOS=\\r"    # SRS570;      9600,'N',2,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial5,  IPADDR=$(TS):4005, IEOS=\\r,     OEOS=\\r"    # Unused;      9600,'N',1,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial6,  IPADDR=$(TS):4006, IEOS=\\n,     OEOS=\\r"    # Keithley    19200,'N',1,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial7,  IPADDR=$(TS):4007, IEOS=\\r,     OEOS=\\r"    # Pelco CM6700 9600,'N',2,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial8,  IPADDR=$(TS):4008, IEOS=\\n,     OEOS=\\r"    # Keithley    19200,'N',1,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial9,  IPADDR=$(TS):4009, IEOS=\\r,     OEOS=\\r"    # SRS570;      9600,'N',2,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial10, IPADDR=$(TS):4010, IEOS=\\r,     OEOS=\\r"    # SRS570;      9600,'N',2,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial11, IPADDR=$(TS):4011, IEOS=\\r,     OEOS=\\r"    # SRS570;      9600,'N',2,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial12, IPADDR=$(TS):4012, IEOS=\\r,     OEOS=\\r"    # SRS570;      9600,'N',2,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial13, IPADDR=$(TS):4013, IEOS=\\r,     OEOS=\\r"    # Unused;      9600,'N',1,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial14, IPADDR=$(TS):4014, IEOS=\\r,     OEOS=\\r"    # Unused;      9600,'N',1,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial15, IPADDR=$(TS):4015, IEOS=\\r,     OEOS=\\r"    # Unused;      9600,'N',1,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial16, IPADDR=$(TS):4016, IEOS=\\r,     OEOS=\\r"    # Unused;      9600,'N',1,8,'N'

# Load asyn records on all ports
dbLoadTemplate("asynRecord.template")

dbLoadRecords("$(IP)/db/SR570.db",                       "P=$(P), PORT=serial1,  A=A1")
dbLoadRecords("$(IP)/db/SR570.db",                       "P=$(P), PORT=serial2,  A=A2")
dbLoadRecords("$(IP)/db/SR570.db",                       "P=$(P), PORT=serial3,  A=A3")
dbLoadRecords("$(IP)/db/SR570.db",                       "P=$(P), PORT=serial4,  A=A4")
dbLoadRecords("$(IP)/db/Keithley2kDMM_mf.db",            "P=$(P), PORT=serial6,  Dmm=DMM1")
dbLoadTemplate("$(CARS)/db/Pelco_CM6700.substitutions",  "P=$(P), PORT=serial7,  R=Pelco1")
dbLoadRecords("$(IP)/db/Keithley2kDMM_mf.db",            "P=$(P), PORT=serial8,  Dmm=DMM1")
dbLoadRecords("$(IP)/db/SR570.db",                       "P=$(P), PORT=serial9,  A=B1")
dbLoadRecords("$(IP)/db/SR570.db",                       "P=$(P), PORT=serial10, A=B2")
dbLoadRecords("$(IP)/db/SR570.db",                       "P=$(P), PORT=serial11, A=B3")
dbLoadRecords("$(IP)/db/SR570.db",                       "P=$(P), PORT=serial12, A=B4")
