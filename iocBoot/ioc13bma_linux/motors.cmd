iocshLoad("Galil.cmd", "P=$(P)")

### Allstop, alldone
dbLoadRecords("$(MOTOR)/db/motorUtil.db","P=$(P)")
doAfterIocInit "motorUtilInit($(P))"

# A set of scan parameters for each positioner.  This is a convenience
# for the user.  It can contain an entry for each scannable thing in the
# crate.
dbLoadTemplate("scanParms.template")
