#MN newport-xsp4 = 10.54.160.180, XPS-C
XPSCreateController("XPSC", "10.54.160.180", 5001, 6, 10, 500, 0, 500)

#--  
#-- # XPS asyn port,  axis, groupName.positionerName, stepSize
#-- # card,  axis, groupName.positionerName, stepsPerUnit
#XPSCreateAxis("XPSC", 0, "CFine.X",      "100000") # VP-25XL
#XPSCreateAxis("XPSC", 1, "CFine.Theta",    "2000") # URS75CC
#XPSCreateAxis("XPSC", 2, "CFocus.Pos",   "100000") # VP-25XA
XPSCreateAxis("XPSC", 0, "XRDX.Pos",        "400") # UTS150CC  xrddet_x
XPSCreateAxis("XPSC", 1, "XRDZ.Pos",        "400") # UTS150CC  xrddet_z
XPSCreateAxis("XPSC", 2, "XRDY.Pos",       "2000") # ILS150CC  xrddet_y
XPSCreateAxis("XPSC", 3, "AnaX.Pos",       "2000") # ILS150CC  herfd_x
XPSCreateAxis("XPSC", 4, "AnaY.Pos",       "2000") # ILS150CC  herfd_y
XPSCreateAxis("XPSC", 5, "CoarseY.Pos",    "5000") # IMS300V   coarse_y

XPSCreateProfile("XPSC", 8192, "Administrator", "Administrator")
#-- 

# asynSetTraceIOTruncateSize("XPSC",0,200)

