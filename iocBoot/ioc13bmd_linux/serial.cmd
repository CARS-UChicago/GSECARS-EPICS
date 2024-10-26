iocshLoad ../asynIPPortConfig.cmd "PORT=serial1,  IPADDR=$(TS):4001, IEOS=\\r,     OEOS=\\r"    # Pelco CM6700 9600,'N',1,8,'N'  PP A01
iocshLoad ../asynIPPortConfig.cmd "PORT=serial2,  IPADDR=$(TS):4002, IEOS=\\r,     OEOS=\\r"    # SRS570;      9600,'N',2,8,'N'  PP A02
iocshLoad ../asynIPPortConfig.cmd "PORT=serial3,  IPADDR=$(TS):4003, IEOS=\\n,     OEOS=\\r"    # SRS570;      9600,'N',2,8,'N'  PP A03
iocshLoad ../asynIPPortConfig.cmd "PORT=serial4,  IPADDR=$(TS):4004, IEOS=\\r,     OEOS=\\r"    # SRS570;      9600,'N',2,8,'N'  PP A04
iocshLoad ../asynIPPortConfig.cmd "PORT=serial5,  IPADDR=$(TS):4005, IEOS=\\r,     OEOS=\\r"    # Unused;      9600,'N',1,8,'N'  PP A05
iocshLoad ../asynIPPortConfig.cmd "PORT=serial6,  IPADDR=$(TS):4006, IEOS=\\r,     OEOS=\\r"    # Unused;      9600,'N',1,8,'N'  PP A06
iocshLoad ../asynIPPortConfig.cmd "PORT=serial7,  IPADDR=$(TS):4007, IEOS=\\r,     OEOS=\\r"    # Unused;      9600,'N',1,8,'N'  NC B01 cable not found
iocshLoad ../asynIPPortConfig.cmd "PORT=serial8,  IPADDR=$(TS):4008, IEOS=\\n,     OEOS=\\r"    # Unused       9600,'N',1,8,'N'  NC B02 cable not found
iocshLoad ../asynIPPortConfig.cmd "PORT=serial9,  IPADDR=$(TS):4009, IEOS=\\n,     OEOS=\\r"    # Keithley    19200,'N',1,8,'N'  PP B03
iocshLoad ../asynIPPortConfig.cmd "PORT=serial10, IPADDR=$(TS):4010, IEOS=\\n,     OEOS=\\r"    # Keithley    19200,'N',1,8,'N'  PP B04 Not present
iocshLoad ../asynIPPortConfig.cmd "PORT=serial11, IPADDR=$(TS):4011, IEOS=\\r\\n,  OEOS=\\r\\n" # Mitutoyo     9600,'N',1,8,'N'  PP B05
iocshLoad ../asynIPPortConfig.cmd "PORT=serial12, IPADDR=$(TS):4012, IEOS=\\r\\n,  OEOS=\\r\\n" # Verdi laser 19200,'N',1,8,'N'  PP B06
iocshLoad ../asynIPPortConfig.cmd "PORT=serial13, IPADDR=$(TS):4013, IEOS=\\r,     OEOS=\\r"    # Unused;      9600,'N',1,8,'N'
# This port is used by ioc13bma_linux for Ion Pump 10
#iocshLoad ../asynIPPortConfig.cmd "PORT=serial14, IPADDR=$(TS):4014, IEOS=\\r,     OEOS=\\r"    # Unused;      9600,'N',1,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial15, IPADDR=$(TS):4015, IEOS=\\r,     OEOS=\\r"    # Omega meter; 9600,'N',2,7,'N'  LVP serial
#iocshLoad ../asynIPPortConfig.cmd "PORT=serial16, IPADDR=$(TS):4016, IEOS=\\r,     OEOS=\\r"    # VME console; 9600,'N',1,8,'N'  VME console

# Set up 2 serial ports on Moxa terminal server which is inside the MCB-4B slit controller box
# These are currently run by ioc13bmd_LVP_XPS
#iocshLoad ../asynIPPortConfig.cmd "PORT=serial17, IPADDR=10.54.160.57:4001,   IEOS=\\r,     OEOS=\\r"    # MCB-4B slit ; 19200,'N',1,8,'N'
#iocshLoad ../asynIPPortConfig.cmd "PORT=serial18, IPADDR=10.54.160.57:4002,   IEOS=\\r,     OEOS=\\r"    # MCB-4B slit ; 19200,'N',1,8,'N'

# Load asyn records on all ports
dbLoadTemplate("asynRecord.template", "P=$(P)")

dbLoadTemplate("$(CARS)/db/Pelco_CM6700.substitutions", "P=$(P), PORT=serial1,  R=Pelco1")
dbLoadRecords("$(IP)/db/SR570.db",                      "P=$(P), PORT=serial2,  A=A1")
dbLoadRecords("$(IP)/db/SR570.db",                      "P=$(P), PORT=serial3,  A=A2")
dbLoadRecords("$(IP)/db/SR570.db",                      "P=$(P), PORT=serial4,  A=A3")
#dbLoadRecords("$(IP)/db/Keithley2kDMM_mf.db",           "P=$(P), PORT=serial10,  Dmm=DMM1")
dbLoadRecords("$(IP)/db/Keithley2kDMM_mf.db",          "P=$(P), PORT=serial9, Dmm=DMM2")
dbLoadRecords("$(CARS)/db/lvp_dmm.db",                 "P=$(P), Dmm=DMM2,      DLY=0.1")
dbLoadRecords("$(CARS)/db/Mitutoyo_Digimatic.db",       "P=$(P), PORT=serial11, R=Mitu")
dbLoadRecords("$(CARS)/db/VerdiLaser.db",               "P=$(P), PORT=serial12, R=Verdi1:")
dbLoadTemplate "LVP_pressure_control.template"          "P=$(P), PORT=serial15, R=Press_")

#doAfterIocInit 'seq &Keithley2kDMM, "P=13BMD:, Dmm=DMM1, channels=20, model=2700, stack=10000"'
doAfterIocInit 'seq &Keithley2kDMM, "P=13BMD:, Dmm=DMM2, channels=10, model=2000, stack=10000"'
