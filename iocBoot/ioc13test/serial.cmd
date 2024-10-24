# BEGIN serial.cmd ------------------------------------------------------------

# Set up port on Digi box

#drvAsynIPPortConfigure("portName","hostInfo",priority,noAutoConnect,
#                        noProcessEos)
drvAsynIPPortConfigure("serial1", "gsets5:2101", 0, 0, 0)
asynOctetConnect("serial1", "serial1")
asynOctetSetInputEos("serial1",0,"\r")
asynOctetSetOutputEos("serial1",0,"\r")

# Load asynRecord records on all ports
dbLoadTemplate("asynRecord.substitutions")

# IPG laser
dbLoadRecords("$(CARS)/db/IPG_YLR_laser.db","P=13TEST:,R=Laser1,PORT=serial1")

# END serial.cmd --------------------------------------------------------------
