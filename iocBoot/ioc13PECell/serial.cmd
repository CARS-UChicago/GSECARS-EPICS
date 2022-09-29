
# BEGIN serial.cmd ------------------------------------------------------------

# Set up 2 ports

# serial 1 connected to Keithley2K DMM over Ethernet
drvAsynIPPortConfigure("serial1", "gsekeithley3:1394", 0, 0, 0)
asynOctetSetOutputEos("serial1",0,"\r\n")
asynOctetSetInputEos("serial1",0,"\r")
asynSetTraceIOMask("serial1",0,2)
#asynSetTraceMask("serial1",0,9)


# serial 2 connected to Prologix Ethernet to GPIB conveter and an HP/Agilent power supply
#prologixGPIBConfigure("serial2", "gse-prologix:1234", 0, 0)
vxi11Configure("serial2", "164.54.160.16", 0, 0, "gpib0", 0, 0)
# The power supply is at GPIB address 15, used in these asynTrace commands
asynSetTraceIOMask("serial2",15,2)
#asynSetTraceMask("serial2",15,9)

# Keithley
dbLoadRecords("$(IP)/db/Keithley2kDMM_mf.db", "P=13PECELL:,Dmm=DMM1:,PORT=serial1")

# Agilent 66xxA GPIB (Power Supply)
epicsEnvSet ("STREAM_PROTOCOL_PATH","$(IP)/db")
dbLoadRecords("$(IP)/db/HP_Agilent_PS66xxA.db","P=13PECELL:,R=HP_PS1:,PORT=serial2,ADDR=15")

# asyn record on each serial port
dbLoadTemplate("asynRecord.substitutions")

# END serial.cmd --------------------------------------------------------------
