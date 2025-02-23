#MN newport-xsp4 = 10.54.160.180, XPS-C
# XPSCreateController("XPSC", "newport-xps4", 5001, 3, 10, 500, 0, 500)
XPSCreateController("XPSC", "10.54.160.180", 5001, 8, 10, 500, 0, 500)

#--  
#-- # XPS asyn port,  axis, groupName.positionerName, stepSize
#-- # card,  axis, groupName.positionerName, stepsPerUnit
XPSCreateAxis("XPSC", 0, "CFine.X",      "100000") # VP-25XL
XPSCreateAxis("XPSC", 1, "CFine.Theta",    "2000") # URS75CC
XPSCreateAxis("XPSC", 2, "CFocus.Pos",   "100000") # VP-25XA
XPSCreateAxis("XPSC", 3, "XRDX.Pos",        "400") # UTS150CC  xrddet_x
XPSCreateAxis("XPSC", 4, "XRDZ.Pos",        "400") # UTS150CC  xrddet_z
XPSCreateAxis("XPSC", 5, "XRDY.Pos",       "2000") # ILS200CC  xrddet_y
XPSCreateAxis("XPSC", 6, "ANAZ.Pos",       "2000") # ILS100PP  herfd_z (analyzer)
XPSCreateAxis("XPSC", 7, "CoarseY.Pos",    "5000") # IMS300V   coarse_y

XPSCreateProfile("XPSC", 8192, "Administrator", "Administrator")
#-- 


# asynSetTraceIOTruncateSize("XPSC",0,200)

