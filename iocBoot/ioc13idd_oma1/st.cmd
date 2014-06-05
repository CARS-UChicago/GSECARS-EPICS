< envPaths
errlogInit(20000)

dbLoadDatabase("$(ADROPER)/iocs/roperIOC/dbd/roperApp.dbd")

roperApp_registerRecordDeviceDriver(pdbbase) 

epicsEnvSet("PREFIX", "13IDD_OMA1:")
epicsEnvSet("PORT",   "ROPER1")
epicsEnvSet("QSIZE",  "20")
epicsEnvSet("XSIZE",  "1396")
epicsEnvSet("YSIZE",  "1040")
epicsEnvSet("NCHANS", "2048")

roperConfig("$(PORT)", 50, 200000000)
asynSetTraceIOMask("$(PORT)",0,2)
#asynSetTraceMask("$(PORT)",0,9)
dbLoadRecords("$(ADCORE)/db/ADBase.template",   "P=$(PREFIX),R=cam1:,PORT=$(PORT),ADDR=0,TIMEOUT=1")
dbLoadRecords("$(ADCORE)/db/NDFile.template",   "P=$(PREFIX),R=cam1:,PORT=$(PORT),ADDR=0,TIMEOUT=1")
dbLoadRecords("$(ADROPER)/db/roper.template",   "P=$(PREFIX),R=cam1:,PORT=$(PORT),ADDR=0,TIMEOUT=1")

# Create a standard arrays plugin, set it to get data from the Roper driver.
NDStdArraysConfigure("Image1", 5, 0, "$(PORT)", 0, -1)
dbLoadRecords("$(ADCORE)/db/NDPluginBase.template","P=$(PREFIX),R=image1:,PORT=Image1,ADDR=0,TIMEOUT=1,NDARRAY_PORT=$(PORT),NDARRAY_ADDR=0")
dbLoadRecords("$(ADCORE)/db/NDStdArrays.template", "P=$(PREFIX),R=image1:,PORT=Image1,ADDR=0,TIMEOUT=1,TYPE=Int16,FTVL=SHORT,NELEMENTS=1500000")

# Load all other plugins using commonPlugins.cmd
< ../commonPlugins.cmd
set_requestfile_path("$(ADROPER)/roperApp/Db")

iocInit()

# save things every thirty seconds
create_monitor_set("auto_settings.req", 30,"P=$(PREFIX),D=cam1:")

