# BEGIN serial.cmd ------------------------------------------------------------

# Set up port on Digi box

#drvAsynIPPortConfigure("portName","hostInfo",priority,noAutoConnect,
#                        noProcessEos)
#drvAsynIPPortConfigure("serial1", "gsets4:2101", 0, 0, 0)

asynOctetConnect("serial1", "serial1")
asynOctetSetInputEos("serial1",0,"\r\n")
asynOctetSetOutputEos("serial1",0,"\r\n")

# Load asynRecord records on all ports
dbLoadTemplate("asynRecord.substitutions")

# Laser Quantum Excel laser
dbLoadRecords("$(CARS)/CARSApp/Db/LQExcel.db", "P=13LQE1:,R=L1,PORT=serial1")

# END serial.cmd --------------------------------------------------------------
