iocshLoad("Galil.cmd", "P=$(P)")

### Allstop, alldone
dbLoadRecords("$(MOTOR)/db/motorUtil.db","P=$(P)")

# A set of scan parameters for each positioner.  This is a convenience
# for the user.  It can contain an entry for each scannable thing in the
# crate.
dbLoadTemplate("scanParms.substitutions")

doAfterIocInit "motorUtilInit($(P))"
doAfterIocInit "seq BM13_Energy, 'E=$(P)E,MONO=$(P)m9,EXPTAB_Z=13BMD:m22,YXTAL=$(P)MON:,ZXTAL=$(P)m14'"
