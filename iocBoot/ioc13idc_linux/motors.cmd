#iocshLoad("XPS.cmd",   "P=$(P)")
iocshLoad("Galil.cmd", "P=$(P)")

### Allstop, alldone
dbLoadRecords("$(MOTOR)/db/motorUtil.db","P=$(P)")

### Scan-support software
# crate-resident scan.  This executes 1D, 2D, 3D, and 4D scans, and caches
# 1D data, but it doesn't store anything to disk.  (You need the data catcher
# or the equivalent for that.)  This database is configured to use the
# "alldone" database (above) to figure out when motors have stopped moving
# and it's time to trigger detectors.

dbLoadRecords("$(SSCAN)/db/scan.db","P=$(P),MAXPTS1=2000,MAXPTS2=500,MAXPTS3=20,MAXPTS4=5,MAXPTSH=10")

# A set of scan parameters for each positioner.  This is a convenience
# for the user.  It can contain an entry for each scannable thing in the
# crate.
dbLoadTemplate("scanParms.template")
