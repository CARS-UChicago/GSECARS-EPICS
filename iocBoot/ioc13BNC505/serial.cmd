# BEGIN serial.cmd ------------------------------------------------------------

# Set up port on Digi box

#drvAsynIPPortConfigure("portName","hostInfo",priority,noAutoConnect,
#                        noProcessEos)
#drvAsynIPPortConfigure("serial1", "gsets4:2101", 0, 0, 0)
drvAsynIPPortConfigure("serial1", "gsets5:2101", 0, 0, 0)
asynOctetConnect("serial1", "serial1")
asynOctetSetInputEos("serial1",0,"\r\n")
asynOctetSetOutputEos("serial1",0,"\r\n")

# Load asynRecord records on all ports
dbLoadTemplate("asynRecord.substitutions")

# BNC-505 Pulse/Delay Generator
dbLoadTemplate("BNC_505.substitutions")

# END serial.cmd --------------------------------------------------------------
