#iocshLoad("XPS.cmd",   "P=$(P)")
iocshLoad("MCB4B.cmd", "P=$(P)")
iocshLoad("Galil.cmd", "P=$(P)")

### Allstop, alldone
dbLoadRecords("$(MOTOR)/db/motorUtil.db","P=$(LINUX_PREFIX)")
doAfterIocInit('motorUtilInit("13IDD_Linux:")')

# A set of scan parameters for each positioner.  This is a convenience
# for the user.  It can contain an entry for each scannable thing in the
# crate.
dbLoadTemplate("scanParms.template", "P=$(P)")
