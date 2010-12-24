# BEGIN serial.cmd ------------------------------------------------------------

# Set up port on Digi box

#drvAsynIPPortConfigure("portName","hostInfo",priority,noAutoConnect,
#                        noProcessEos)
#drvAsynIPPortConfigure("serial1", "164.54.160.155:1394", 0, 0, 0)

#drvAsynIPPortConfigure("serial1", "164.54.160.154:2001", 0, 0, 0)
#drvAsynIPPortConfigure("serial2", "164.54.160.154:2001", 0, 0, 0)
#drvAsynIPPortConfigure("serial3", "164.54.160.154:2001", 0, 0, 0)
drvAsynIPPortConfigure("serial4", "164.54.160.154:2001", 0, 0, 0)

#asynOctetConnect("serial1", "serial1")
#asynOctetConnect("serial2", "serial2")
#asynOctetConnect("serial3", "serial3")
asynOctetConnect("serial4", "serial4")

# Load asynRecord records on all ports
dbLoadTemplate("asynRecord.template")

# Instek power supply
#asynOctetSetInputEos("serial2",0,"\r")
#asynOctetSetOutputEos("serial2",0,"\r")

#asynOctetSetInputEos("serial3",0,"\r")
#asynOctetSetOutputEos("serial3",0,"\r")

asynOctetSetInputEos("serial4",0,"\r\n")
asynOctetSetOutputEos("serial4",0,"\r")


# Keithley 2700 DMM
dbLoadRecords("$(IP)/ipApp/Db/Keithley2kDMM_mf.db","P=13DAC_piezo:,Dmm=DMM1,PORT=serial1")

# END serial.cmd --------------------------------------------------------------
