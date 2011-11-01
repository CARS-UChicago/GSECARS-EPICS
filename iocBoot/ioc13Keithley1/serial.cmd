# BEGIN serial.cmd ------------------------------------------------------------

# Set up port on Digi box

#drvAsynIPPortConfigure("portName","hostInfo",priority,noAutoConnect,
#                        noProcessEos)
drvAsynIPPortConfigure("serial1", "164.54.160.156:1394", 0, 0, 0)
#drvAsynIPPortConfigure("serial1", "164.54.160.154:2001", 0, 0, 0)
#asynSetTraceIOMask serial1 0 2
#asynSetTraceMask serial1 0 255
asynOctetSetInputEos("serial1",0,"\n")
asynOctetSetOutputEos("serial1",0,"\n")
asynOctetConnect("serial1", "serial1")
# Load asynRecord records on all ports
dbLoadTemplate("asynRecord.template")

# Keithley 2700 DMM
dbLoadRecords("$(IP)/ipApp/Db/Keithley2kDMM_mf.db","P=13Keithley1:,Dmm=DMM1,PORT=serial1")

# END serial.cmd --------------------------------------------------------------
