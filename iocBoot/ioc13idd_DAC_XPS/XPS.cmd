################################################################################
# XPS Setup

# asyn port, IP address, IP port, number of axes, 
# active poll period (ms), idle poll period (ms), 
# enable set position, set position settling time (ms)
XPSCreateController("XPS1", "newport-xps16", 5001, 8, 10, 500, 1, 500)
asynSetTraceIOMask("XPS1", 0, 8)
#asynSetTraceMask("XPS1", 0, 255)

# asynPort, IP address, IP port, poll period (ms)
#XPSAuxConfig("XPS_AUX1", "newport-xps16", 5001, 50)
#asynSetTraceIOMask("XPS_AUX1", 0, 2)
#asynSetTraceMask("XPS_AUX1", 0, 255)

# XPS asyn port,  axis, groupName.positionerName, stepSize
XPSCreateAxis("XPS1",0,"G1.HUB-Y",  "500000")
XPSCreateAxis("XPS1",1,"G2.HUB-Z",  "10000")
XPSCreateAxis("XPS1",2,"G3.HUB-X",  "10000")  
XPSCreateAxis("XPS1",3,"G4.ST-Z",   "10000")  
XPSCreateAxis("XPS1",4,"G5.ST-Y",   "50000")  
XPSCreateAxis("XPS1",5,"G6.ST-X",   "10000")  
XPSCreateAxis("XPS1",6,"G7.PIN-Y",  "10000")  
XPSCreateAxis("XPS1",7,"G8.PIN-X",  "10000")  

# XPS asyn port,  max points, FTP username, FTP password
# Note: this must be done after configuring axes
XPSCreateProfile("XPS1", 10010, "Administrator", "Administrator")

# Disable setting position from motor record
XPSEnableSetPosition(0) 

################################################################################
# Motor records
dbLoadTemplate("XPS_motors.template")

# Auxillary I/O records
#dbLoadTemplate("XPSAux.substitutions")

# asyn record for debugging
drvAsynIPPortConfigure("xps", "newport-xps16:5001", 0, 0, 0)
asynSetTraceIOMask("xps",0,2)
asynSetTraceMask("xps",0,9)
dbLoadRecords("$(ASYN)/db/asynRecord.db", "P=13IDD:, R=trajAsyn1, PORT=xps, ADDR=0, OMAX=300, IMAX=32000")

