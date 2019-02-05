< envPaths

## Register all support components
dbLoadDatabase "../../dbd/CARSLinux.dbd"
CARSLinux_registerRecordDeviceDriver pdbbase

epicsEnvSet(INPUT_POINTS, "4096")
epicsEnvSet(OUTPUT_POINTS, "4096")

epicsEnvSet("PREFIX", "13E1608_1:")

cbAddBoard("E-1608", "164.54.160.216")

## Configure port driver
# MultiFunctionConfig((portName,        # The name to give to this asyn port driver
#                      boardNum,        # The number of this board assigned by the Measurement Computing Instacal program 
#                      maxInputPoints,  # Maximum number of input points for waveform digitizer
#                      maxOutputPoints) # Maximum number of output points for waveform generator
MultiFunctionConfig("E1608_1", 0, $(INPUT_POINTS), $(OUTPUT_POINTS))

#asynSetTraceMask E1608_1 -1 255

dbLoadTemplate("E1608.substitutions")
dbLoadTemplate("pid_slow.substitutions")

< ../calc_GSECARS.iocsh

### Scan-support software
dbLoadRecords("$(SSCAN)/sscanApp/Db/scan.db", "P=1$(PREFIX),MAXPTS1=2000,MAXPTS2=200,MAXPTS3=20,MAXPTS4=10,MAXPTSH=10")

< ../save_restore_IOCSH.cmd

iocInit

create_monitor_set("auto_settings.req",30,"P=$(PREFIX)")

# Need to force the time arrays to process because the records are scan=I/O Intr
# but asynPortDriver does not do array callbacks before iocInit.

dbpf $(PREFIX)WaveDigDwell.PROC 1
