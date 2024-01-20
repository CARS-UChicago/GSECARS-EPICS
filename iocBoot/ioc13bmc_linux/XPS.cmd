################################################################################
# XPS Setup

# asyn port, IP address, IP port, number of axes, 
# active poll period (ms), idle poll period (ms), 
# enable set position, set position settling time (ms)
XPSCreateController("XPS1", "newport-xps8", 5001, 6, 10, 2000, 0, 500)
asynSetTraceIOMask("XPS1", 0, 2)
#asynSetTraceMask("XPS1", 0, 255)
XPSCreateController("XPS2", "newport-xps2", 5001, 8, 10, 500, 0, 500)
asynSetTraceIOMask("XPS2", 0, 2)
#asynSetTraceMask("XPS2", 0, 255)

# asynPort, IP address, IP port, poll period (ms)
#XPSAuxConfig("XPS_AUX1", "newport-xps8", 5001, 50)
#asynSetTraceIOMask("XPS_AUX1", 0, 2)
#asynSetTraceMask("XPS_AUX1", 0, 255)
#XPSAuxConfig("XPS_AUX2", "newport-xps2", 5001, 50)
#asynSetTraceIOMask("XPS_AUX1", 0, 2)
#asynSetTraceMask("XPS_AUX1", 0, 255)

# XPS asyn port,  axis, groupName.positionerName, stepSize
XPSCreateAxis("XPS1",0,"GROUP1.PHI",      "1000")
XPSCreateAxis("XPS1",1,"GROUP1.KAPPA",    "5000")
XPSCreateAxis("XPS1",2,"GROUP1.OMEGA",    "5000")
XPSCreateAxis("XPS1",3,"GROUP1.PSI",      "4000")
XPSCreateAxis("XPS1",4,"GROUP1.2THETA",  "10000")
XPSCreateAxis("XPS1",5,"GROUP1.NU",       "4000")

XPSCreateAxis("XPS2",0,"GROUP1.Y1_BASE",    "10000")
XPSCreateAxis("XPS2",1,"GROUP2.Y2_BASE",    "10000")
XPSCreateAxis("XPS2",2,"GROUP3.Y3_BASE",    "10000")
XPSCreateAxis("XPS2",3,"GROUP4.TRX_BASE",     "200")
XPSCreateAxis("XPS2",4,"GROUP5.THETA-Y_BASE", "200")
XPSCreateAxis("XPS2",5,"GROUP6.X_SAMPLE",    "3816")
XPSCreateAxis("XPS2",6,"GROUP7.Y_SAMPLE",    "3816")
XPSCreateAxis("XPS2",7,"GROUP8.Z_SAMPLE",    "3816")


# XPS asyn port,  max points, FTP username, FTP password
# Note: this must be done after configuring axes
XPSCreateProfile("XPS1", 2000, "Administrator", "Administrator")

################################################################################

# Motor records
dbLoadTemplate("XPS_motors.template")

# asyn record for debugging
drvAsynIPPortConfigure("xps", "newport-xps8:5001", 0, 0, 0)
asynSetTraceIOMask("xps",0,2)
asynSetTraceMask("xps",0,9)
dbLoadRecords("$(ASYN)/db/asynRecord.db", "P=13BMC:, R=trajAsyn1, PORT=xps, ADDR=0, OMAX=300, IMAX=32000")

#asynSetTraceIOMask(newport-xps8:5001:0,0,2)
#asynSetTraceIOMask(newport-xps8:5001:1,0,2)
#asynSetTraceIOMask(newport-xps8:5001:2,0,2)
#asynSetTraceMask(newport-xps8:5001:0,0,9)
#asynSetTraceMask(newport-xps8:5001:1,0,9)
#asynSetTraceMask(newport-xps8:5001:2,0,9)

# Set the NTM fields of the XPS motors to 0 (NO) so they don't get stopped when the motor changes direction due to PID
doAferIOCInit dbpf("13BMC:m33.NTM","0")
doAferIOCInit dbpf("13BMC:m34.NTM","0")
doAferIOCInit dbpf("13BMC:m35.NTM","0")
doAferIOCInit dbpf("13BMC:m36.NTM","0")
doAferIOCInit dbpf("13BMC:m37.NTM","0")
doAferIOCInit dbpf("13BMC:m38.NTM","0")
doAferIOCInit dbpf("13BMC:m39.NTM","0")
doAferIOCInit dbpf("13BMC:m40.NTM","0")
doAferIOCInit dbpf("13BMC:m41.NTM","0")
doAferIOCInit dbpf("13BMC:m42.NTM","0")
doAferIOCInit dbpf("13BMC:m43.NTM","0")
doAferIOCInit dbpf("13BMC:m44.NTM","0")
doAferIOCInit dbpf("13BMC:m45.NTM","0")
doAferIOCInit dbpf("13BMC:m46.NTM","0")

# Enable the mode where the XPS determines axis move complete by socket response, 
# not GroupStatusGet()
XPSEnableMovingMode XPS1

asynSetTraceIOMask newport-xps8:5001:0 0 ESCAPE
#asynSetTraceMask newport-xps8:5001:0 0 ERROR|DRIVER
#asynSetTraceFile newport-xps8:5001:0 0 /corvette/home/epics/logs/bmc_xps.txt
