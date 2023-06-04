################################################################################
# XPS Setup

# asyn port, IP address, IP port, number of axes, 
# active poll period (ms), idle poll period (ms), 
# enable set position, set position settling time (ms)
XPSCreateController("XPS1", "newport-xps9", 5001, 8, 10, 500, 0, 500)
#asynSetTraceIOMask("XPS1", 0, 2)
#asynSetTraceMask("XPS1", 0, 255)
XPSCreateController("XPS2", "newport-xps7", 5001, 8, 10, 500, 0, 500)
#asynSetTraceIOMask("XPS2", 0, 2)
#asynSetTraceMask("XPS2", 0, 255)

# asynPort, IP address, IP port, poll period (ms)
#XPSAuxConfig("XPS_AUX1", "newport-xps9", 5001, 50)
#asynSetTraceIOMask("XPS_AUX1", 0, 2)
#asynSetTraceMask("XPS_AUX1", 0, 255)
#XPSAuxConfig("XPS_AUX2", "newport-xps7", 5001, 50)
#asynSetTraceIOMask("XPS_AUX1", 0, 2)
#asynSetTraceMask("XPS_AUX1", 0, 255)

# XPS for the Rotations
# XPS asyn port,  axis, groupName.positionerName, stepSize
#XPSCreateAxis("XPS1",0,"GROUP1.KPHI",      "1000")
#XPSCreateAxis("XPS1",1,"GROUP1.KAPPA",   "10000")
#XPSCreateAxis("XPS1",2,"GROUP1.KETA",   "10000")
#XPSCreateAxis("XPS1",3,"GROUP1.MU",      "4000")
#XPSCreateAxis("XPS1",4,"GROUP1.DEL",  "10000")
#XPSCreateAxis("XPS1",5,"GROUP1.NU",       "4000")
#XPSCreateAxis("XPS1",6,"GROUP2.LX",      "100000")
#XPSCreateAxis("XPS1",7,"GROUP3.LY",      "100000")

XPSCreateAxis("XPS1",0,"GROUP1.KPHI",      "1000")
XPSCreateAxis("XPS1",1,"GROUP2.KAPPA",   "10000")
XPSCreateAxis("XPS1",2,"GROUP3.KETA",   "10000")
XPSCreateAxis("XPS1",3,"GROUP4.MU",      "4000")
XPSCreateAxis("XPS1",4,"GROUP5.DEL",  "10000")
XPSCreateAxis("XPS1",5,"GROUP6.NU",       "4000")
#XPSCreateAxis("XPS1",6,"GROUP7.LX",      "100000")
#XPSCreateAxis("XPS1",7,"GROUP8.LY",      "100000")

XPSCreateAxis("XPS2",0,"GROUP1.Y1_BASE",    "10000")
XPSCreateAxis("XPS2",1,"GROUP2.Y2_BASE",    "10000")
XPSCreateAxis("XPS2",2,"GROUP3.Y3_BASE",    "10000")
XPSCreateAxis("XPS2",3,"GROUP4.THETAY",       "200")
XPSCreateAxis("XPS2",4,"GROUP5.TRX",          "200")
XPSCreateAxis("XPS2",5,"GROUP6.X",          "74627")
XPSCreateAxis("XPS2",6,"GROUP7.Y",          "74627")
XPSCreateAxis("XPS2",7,"GROUP8.Z",         "100000")

dbLoadTemplate("XPS_motors.template")

# XPS asyn port,  max points, FTP username, FTP password
# Note: this must be done after configuring axes
XPSCreateProfile("XPS1", 10010, "Administrator", "Administrator")

# Disable setting position from motor record
XPSEnableSetPosition(0) 

# Auxillary I/O records
#dbLoadTemplate("XPSAux.substitutions")

# asyn record for debugging
drvAsynIPPortConfigure("xps", "newport-xps9:5001", 0, 0, 0)
asynSetTraceIOMask("xps",0,2)
asynSetTraceMask("xps",0,9)
dbLoadRecords("$(ASYN)/db/asynRecord.db", "P=$(P), R=trajAsyn1, PORT=xps, ADDR=0, OMAX=300, IMAX=32000")

# Enable the mode where the XPS determines axis move complete by socket response, not GroupStatusGet()
doAfterIocInit 'XPSEnableMovingMode XPS1'

# Set the NTM fields of the XPS motors to 0 (NO) so they don't get stopped when the motor changes direction due to PID
doAfterIocInit 'dbpf("$(P)m25.NTM","0")'
doAfterIocInit 'dbpf("$(P)m26.NTM","0")'
doAfterIocInit 'dbpf("$(P)m27.NTM","0")'
doAfterIocInit 'dbpf("$(P)m28.NTM","0")'
doAfterIocInit 'dbpf("$(P)m29.NTM","0")'
doAfterIocInit 'dbpf("$(P)m30.NTM","0")'
doAfterIocInit 'dbpf("$(P)m31.NTM","0")'
doAfterIocInit 'dbpf("$(P)m32.NTM","0")'
doAfterIocInit 'dbpf("$(P)m33.NTM","0")'
doAfterIocInit 'dbpf("$(P)m34.NTM","0")'
doAfterIocInit 'dbpf("$(P)m35.NTM","0")'
doAfterIocInit 'dbpf("$(P)m36.NTM","0")'
doAfterIocInit 'dbpf("$(P)m37.NTM","0")'
doAfterIocInit 'dbpf("$(P)m38.NTM","0")'
doAfterIocInit 'dbpf("$(P)m39.NTM","0")'
doAfterIocInit 'dbpf("$(P)m40.NTM","0")'
