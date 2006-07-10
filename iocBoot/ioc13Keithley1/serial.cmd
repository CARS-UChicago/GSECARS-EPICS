# BEGIN serial.cmd ------------------------------------------------------------

# Set up ports 1 on Moxa box

# serial 3 is connected to the ACS MCB-4B at 9600 baud
#drvAsynIPPortConfigure("portName","hostInfo",priority,noAutoConnect,
#                        noProcessEos)
drvAsynIPPortConfigure("serial1", "164.54.160.50:4001", 0, 0, 0)
asynOctetConnect("serial1", "serial1")

# Load asynRecord records on all ports
dbLoadTemplate("asynRecord.substitutions")

# Keithley 2700 DMM
dbLoadRecords("$(IP)/ipApp/Db/Keithley2kDMM_mf.db","P=13Keithley1:,Dmm=DMM1,PORT=serial1")

# END serial.cmd --------------------------------------------------------------
