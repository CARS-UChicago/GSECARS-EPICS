< envPaths

## Register all support components
dbLoadDatabase "$(MEASCOMP)/dbd/measCompApp.dbd"
measCompApp_registerRecordDeviceDriver pdbbase

# Configure port driver
# MultiFunctionConfig(portName,        # The name to give to this asyn port driver
#                     boardNum,        # The number of this board assigned by the Measurement Computing Instacal program 
#                     maxInputPoints,  # Maximum number of input points for waveform digitizer
#                     maxOutputPoints) # Maximum number of output points for waveform generator
MultiFunctionConfig("USB1208_1", 0, 1048576, 1048576)

dbLoadTemplate("USB1208.substitutions")

#asynSetTraceMask USB1208_1 -1 255

< ../save_restore_IOCSH.cmd
save_restoreSet_status_prefix("13USB1208:")
dbLoadRecords("$(AUTOSAVE)/asApp/Db/save_restoreStatus.db", "P=13USB1208:")

iocInit

create_monitor_set("auto_settings.req",30)

# Seem to need to process binary direction records to get them to work
dbpf 13USB1208:Bd1.PROC 1
dbpf 13USB1208:Bd2.PROC 1
