# Note: serial 5 and 6 (Keithley 2000) and serial 9 (Omega meter) have been moved to a 4 port terminal server
# for the LVP.  Now that the VME is gone they could be moved back to this terminal server?

iocshLoad ../asynIPPortConfig.cmd "PORT=serial1,  IPADDR=$(TS):4001, IEOS=\\r,     OEOS=\\r"    # SRS570;       9600,'N',2,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial2,  IPADDR=$(TS):4002, IEOS=\\r,     OEOS=\\r"    # SRS570;       9600,'N',2,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial3,  IPADDR=$(TS):4003, IEOS=\\n,     OEOS=\\r"    # Keithley     19200,'N',1,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial4,  IPADDR=$(TS):4004, IEOS=\\r,     OEOS=\\r"    # Laser power   4800,'N',1,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial5,  IPADDR=$(TS):4005, IEOS=\\n,     OEOS=\\r"    # Keithley     19200,'N',1,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial6,  IPADDR=$(TS):4006, IEOS=\\n,     OEOS=\\r"    # Keithley     19200,'N',1,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial7,  IPADDR=$(TS):4007, IEOS=\\r,     OEOS=\\r"    # SRS570;       9600,'N',2,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial8,  IPADDR=$(TS):4008, IEOS=\\r,     OEOS=\\r"    # Unused;       9600,'N',1,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial9,  IPADDR=$(TS):4009, IEOS=\\r,     OEOS=\\r"    # Omega meter;  9600,'N',2,7,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial10, IPADDR=$(TS):4010, IEOS=\\r,     OEOS=\\r"    # RSF encoder; 19200,'N',1,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial11, IPADDR=$(TS):4011, IEOS=>,       OEOS=\\r"    # Picomotor;   19200,'N',1,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial12, IPADDR=$(TS):4012, IEOS=\\r\\n,  OEOS=\\r\\n" # LQExcel;      9600,'N',1,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial13, IPADDR=$(TS):4013, IEOS=\\r,     OEOS=\\r"    # Pelco CM6700; 9600,'N',1,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial14, IPADDR=$(TS):4014, IEOS=\\r,     OEOS=\\r"    # YLR laser;   38400,'N',1,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial15, IPADDR=$(TS):4015, IEOS=\\r,     OEOS=\\r"    # YLR laser;   38400,'N',1,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial16, IPADDR=$(TS):4016, IEOS=\\r\\n,  OEOS=\\r\\n" # BNC 505;      9600,'N',1,8,'N'

# Set up 2 serial ports on Moxa terminal server which is inside the MCB-4B slit controller box
iocshLoad ../asynIPPortConfig.cmd "PORT=serial17, IPADDR=10.54.160.54:4001,   IEOS=\\r,     OEOS=\\r"    # MCB-4B slit ; 19200,'N',1,8,'N'
iocshLoad ../asynIPPortConfig.cmd "PORT=serial18, IPADDR=10.54.160.54:4002,   IEOS=\\r,     OEOS=\\r"    # MCB-4B slit ; 19200,'N',1,8,'N'

# Load asyn records on all ports
dbLoadTemplate("asynRecord.template")

dbLoadRecords("$(IP)/db/SR570.db",                      "P=$(P), PORT=serial1,  A=A1")
dbLoadRecords("$(IP)/db/SR570.db",                      "P=$(P), PORT=serial2,  A=A2")
dbLoadRecords("$(IP)/db/Keithley2kDMM_mf.db",           "P=$(P), PORT=serial3,  Dmm=DMM1")
dbLoadRecords("$(CARS)/db/lpc.db",                      "P=$(P), PORT=serial4,  L=LPC1_, DAC=DAC1_2")
dbLoadRecords("$(IP)/db/SR570.db",                      "P=$(P), PORT=serial7,  A=A3")
dbLoadRecords("$(CARS)/db/RSF715.db",                   "P=$(P), PORT=serial10, ENCODER=RSF715")
dbLoadTemplate("picoMotors.substitutions",              "P=$(P), PORT=serial11, S=pico"))
dbLoadRecords("$(CARS)/db/LQExcel.db",                  "P=$(P), PORT=serial12, R=LQE1")
dbLoadTemplate("$(CARS)/db/Pelco_CM6700.substitutions", "P=$(P), PORT=serial13, R=Pelco1"))
dbLoadRecords("$(CARS)/db/IPG_YLR_laser.db",            "P=$(P), PORT=serial14, R=Laser1,")
dbLoadRecords("$(CARS)/db/IPG_YLR_laser.db",            "P=$(P), PORT=serial15, R=Laser2")
dbLoadRecords("$(DELAYGEN)/db/BNC_505.db",              "P=$(P), PORT=serial16, R=BNC1:")
dbLoadRecords("$(DELAYGEN)/db/BNC_505_Pn.db",           "P=$(P), PORT=serial16, R=BNC1:, N=1")
dbLoadRecords("$(DELAYGEN)/db/BNC_505_Pn.db",           "P=$(P), PORT=serial16, R=BNC1:, N=2")
dbLoadRecords("$(DELAYGEN)/db/BNC_505_Pn.db",           "P=$(P), PORT=serial16, R=BNC1:, N=3")
dbLoadRecords("$(DELAYGEN)/db/BNC_505_Pn.db",           "P=$(P), PORT=serial16, R=BNC1:, N=4")
