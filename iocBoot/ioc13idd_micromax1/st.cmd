< envPaths
errlogInit(20000)
dbLoadDatabase("$(CCD)/dbd/roperCCDApp.dbd")
roperCCDAppWin32_registerRecordDeviceDriver(pdbbase) 
dbLoadRecords("$(CCD)/ccdApp/Db/ccd.db","P=13IDDMicroMax1:,C=det1:")

set_requestfile_path("./")
set_savefile_path("./autosave")
set_requestfile_path("$(CCD)/ccdApp/Db")
set_pass0_restoreFile("auto_settings.sav")
set_pass1_restoreFile("auto_settings.sav")
save_restoreSet_status_prefix("13IDDMicroMax1:")
dbLoadRecords("$(AUTOSAVE)/asApp/Db/save_restoreStatus.db", "P=13IDDMicroMax1:")

iocInit()

# save things every thirty seconds
create_monitor_set("auto_settings.req", 30)

seq(roperCCD,"P=13IDDMicroMax1:,C=det1:")
