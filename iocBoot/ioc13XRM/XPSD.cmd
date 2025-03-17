# asyn port, IP address, IP port, number of axes, 
# active poll period (ms), idle poll period (ms), 
# enable set position, set position settling time (ms)
#MN newport-xsp14 = 10.54.160.210, newport-xps14, XPS-D
XPSCreateController("XPSD", "newport-xps14", 5001, 8, 10, 500, 0, 500)

# XPS asyn port,  axis, groupName.positionerName, stepSize
# card,  axis, groupName.positionerName, stepsPerUnit
XPSCreateAxis("XPSD", 0, "Fine.X",     "100000") # VP25-XL  fine_x
XPSCreateAxis("XPSD", 1, "Fine.Y",      "50000") # VP5Z-A   fine_y
XPSCreateAxis("XPSD", 2, "Focus.Pos"   "100000") # VP25-XA  focus_z
XPSCreateAxis("XPSD", 3, "CoarseX.Pos",  "2000") # ILS150CC coarse_x
XPSCreateAxis("XPSD", 4, "AnaX.Pos",     "2000") # ILS150CC herfd_x (det)
XPSCreateAxis("XPSD", 5, "AnaY.Pos",     "2000") # ILS150CC herfd_y (det)
XPSCreateAxis("XPSD", 6, "AnaZ.Pos",     "2000") # ILS100PP  herfd_z (analyzer)
XPSCreateAxis("XPSD", 7, "AnaTH.Pos",    "1000") # RV160CC  herfd_th (analyzer)

# asynSetTraceIOMask("XPSD", 0, 2)
# asynSetTraceMask("XPSD", 0, 255)

# asynPort, IP address, IP port, poll period (ms)
# XPSAuxConfig("XPSD_AUX", "newport-xps14", 5001, 50)

asynSetTraceIOMask("XPSD",0,2)
#asynSetTraceMask("XPSD",0,0x3)


# XPS asyn port,  max points, FTP username, FTP password
# Note: this must be done after configuring axes
XPSCreateProfile("XPSD", 8192, "Administrator", "Administrator")



# Disable setting position
# XPSEnableSetPosition(0)
