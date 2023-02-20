iocshLoad ../asynIPPortConfig.cmd "PORT=serial1,  IPADDR=$(TS):4001, IEOS=\\r,     OEOS=\\r"    # SRS570;      9600,'N',2,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial2,  IPADDR=$(TS):4002, IEOS=\\n,     OEOS=\\r"    # Keithley    19200,'N',1,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial3,  IPADDR=$(TS):4003, IEOS=\\r,     OEOS=\\r"    # SRS570;      9600,'N',2,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial4,  IPADDR=$(TS):4004, IEOS=\\r,     OEOS=\\r"    # SRS570;      9600,'N',2,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial5,  IPADDR=$(TS):4005, IEOS=\\r,     OEOS=\\r"    # Omega meter; 9600,'N',2,7,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial6,  IPADDR=$(TS):4006, IEOS=\\r,     OEOS=\\r"    # Unused;      9600,'N',1,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial7,  IPADDR=$(TS):4007, IEOS=\\n,     OEOS=\\r"    # Keithley    19200,'N',1,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial8,  IPADDR=$(TS):4008, IEOS=\\n,     OEOS=\\r"    # Keithley    19200,'N',1,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial9,  IPADDR=$(TS):4009, IEOS=\\n,     OEOS=\\r"    # Keithley    19200,'N',1,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial10, IPADDR=$(TS):4010, IEOS=\\r,     OEOS=\\r"    # XIA shutter  9600,'N',1,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial11, IPADDR=$(TS):4011, IEOS=\\r\\n,  OEOS=\\r\\n" # Verdi laser 19200,'N',1,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial12, IPADDR=$(TS):4012, IEOS=\\r,     OEOS=\\r"    # Pelco CM6700 9600,'N',1,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial13, IPADDR=$(TS):4013, IEOS=\\r,     OEOS=\\r"    # Unused;      9600,'N',1,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial14, IPADDR=$(TS):4014, IEOS=\\r,     OEOS=\\r"    # Unused;      9600,'N',1,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial15, IPADDR=$(TS):4015, IEOS=\\r,     OEOS=\\r"    # Unused;      9600,'N',1,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial16, IPADDR=$(TS):4016, IEOS=\\r,     OEOS=\\r"    # Unused;      9600,'N',1,8,'N'

# Set up 2 serial ports on Moxa terminal server which is inside the MCB-4B slit controller box
iocshLoad ../asynIPPortConfig.cmd "PORT=serial17, IPADDR=10.54.160.57:4001,   IEOS=\\r,     OEOS=\\r"    # MCB-4B slit ; 19200,'N',1,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial18, IPADDR=10.54.160.57:4002,   IEOS=\\r,     OEOS=\\r"    # MCB-4B slit ; 19200,'N',1,8,'N'

# Serial port for Mitutoyo Digimatic
iocshLoad ../asynIPPortConfig.cmd "PORT=serial19, IPADDR=164.54.160.123:4006, IEOS=\\r,     OEOS=\\r\\n" # Mitutoyo Digimatic ; ??

# Load asyn records on all ports
dbLoadTemplate("asynRecord.template")

dbLoadRecords("$(IP)/db/SR570.db",            "P=$(P), PORT=serial1,  A=A1")
dbLoadRecords("$(IP)/db/Keithley2kDMM_mf.db", "P=$(P), PORT=serial2,  Dmm=DMM3")
dbLoadRecords("$(IP)/db/SR570.db",            "P=$(P), PORT=serial3,  A=A2")
dbLoadRecords("$(IP)/db/SR570.db",            "P=$(P), PORT=serial4,  A=A3")
# LVP Omega meter on serial 5
dbLoadTemplate "LVP_pressure_control.template"
dbLoadRecords("$(IP)/db/Keithley2kDMM_mf.db", "P=$(P), PORT=serial7,  Dmm=DMM2")
dbLoadRecords("$(CARS)/db/lvp_dmm.db",        "P=$(P), Dmm=DMM2,      DLY=0.1")
dbLoadRecords("$(IP)/db/Keithley2kDMM_mf.db", "P=$(P), PORT=serial8,  Dmm=DMM1")
dbLoadRecords("$(IP)/db/Keithley2kDMM_mf.db", "P=$(P), PORT=serial9,  Dmm=DMM4")
dbLoadRecords("$(OPTICS)/db/XIA_shutter.db",  "P=$(P), PORT=serial10, S=filter1, ADDRESS=1")
dbLoadRecords("$(CARS)/db/VerdiLaser.db",     "P=$(P), PORT=serial11, R=Verdi1:")

# Serial 12 is Pelco CM6700 video switch
dbLoadTemplate("Pelco_CM6700.substitutions",  "P=$(P), PORT=serial12, R=Pelco1")

# Serial 19 is Mitutoyo Digimatic
dbLoadRecords("$(CARS)/db/Mitutoyo_Digimatic.db","P=$(P), PORT=serial19, R=Mitu")
