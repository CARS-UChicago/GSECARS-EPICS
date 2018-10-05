# BEGIN serial.cmd ------------------------------------------------------------

# Set up port on Digi box

#drvAsynIPPortConfigure("portName","hostInfo",priority,noAutoConnect,
#                        noProcessEos)
#drvAsynIPPortConfigure("serial1", "164.54.160.156:1394", 0, 0, 0)
#drvAsynIPPortConfigure("serial1", "164.54.160.154:2001", 0, 0, 0)
drvAsynIPPortConfigure("serial1", "gsets4.cars.aps.anl.gov:2001", 0, 0, 0)
asynOctetConnect("serial1", "serial1")

# Load asynRecord records on all ports
dbLoadTemplate("asynRecord.template")

# Keithley 2700 DMM
# Baud:19200, Data:8, Parity None, Stop: 1
dbLoadRecords("$(IP)/ipApp/Db/Keithley2kDMM_mf.db","P=13Keithley3:,Dmm=DMM1,PORT=serial1")

# END serial.cmd --------------------------------------------------------------
