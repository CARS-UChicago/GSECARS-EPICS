
# BEGIN serial.cmd ------------------------------------------------------------

# Set up 2 serial ports on terminal server

# serial 1 connected to Keithley2K DMM at 19200 baud
drvAsynIPPortConfigure("serial1", "gsets11:4001 COM", 0, 0, 0)
asynSetOption("serial1", 0, "baud", "19200")
asynSetOption("serial1", 0, "bits", "8")
asynSetOption("serial1", 0, "stop", "1")
asynSetOption("serial1", 0, "parity", "none")
asynOctetSetOutputEos("serial1",0,"\r\n")
asynOctetSetInputEos("serial1",0,"\r")
asynSetTraceIOMask("serial1",0,2)
#asynSetTraceMask("serial1",0,9)


# serial 2 connected to Agilent at 19200 baud
drvAsynIPPortConfigure("serial2", "gsets11:4002 COM", 0, 0, 0)
asynSetOption(serial2,0,baud,19200)
asynSetOption(serial2,0,bits,8)
asynSetOption(serial2,0,stop,1)
asynSetOption(serial2,0,parity,none)

#asynOctetSetInputEos(const char *portName, int addr,
#                     const char *eosin,const char *drvInfo)
asynOctetSetInputEos("serial2",0,"\n")
# asynOctetSetOutputEos(const char *portName, int addr,
#                       const char *eosin,const char *drvInfo)
asynOctetSetOutputEos("serial2",0,"\n")

# Keithley
dbLoadRecords("$(IP)/db/Keithley2kDMM_mf.db", "P=13PECELL:,Dmm=DMM1:,PORT=serial1")

# Agilent 66xxA GPIB (Power Supply)
epicsEnvSet ("STREAM_PROTOCOL_PATH","$(CARS)/db")
dbLoadRecords("$(CARS)/db/HP_AgilentPS66xxA_test.db","P=13PECELL:,S=PS1,PORT=serial2,ADDR=15")

# asyn record on each serial port
dbLoadTemplate("asynRecord.substitutions")

# END serial.cmd --------------------------------------------------------------
