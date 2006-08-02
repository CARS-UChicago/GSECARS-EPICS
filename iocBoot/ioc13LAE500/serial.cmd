# BEGIN serial.cmd ------------------------------------------------------------

# Set up port on Digi box

#drvAsynIPPortConfigure("portName","hostInfo",priority,noAutoConnect,
#                        noProcessEos)
drvAsynIPPortConfigure("serial1", "gsets4:2101", 0, 0, 0)
asynOctetConnect("serial1", "serial1")
asynOctetSetInputEos("serial1",0,"\r")
asynOctetSetOutputEos("serial1",0,"\r")

# Load asynRecord records on all ports
dbLoadTemplate("asynRecord.substitutions")

# Newport LAE500
dbLoadRecords("$(IP)/ipApp/Db/Newport_LAE500.db","P=13LAE500:,R=LAE500,PORT=serial1")

# END serial.cmd --------------------------------------------------------------
