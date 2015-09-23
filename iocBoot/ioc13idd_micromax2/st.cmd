< envPaths
errlogInit(20000)

dbLoadDatabase("$(ADROPER)/iocs/roperIOC/dbd/roperApp.dbd")

roperApp_registerRecordDeviceDriver(pdbbase) 

# Prefix for all records
epicsEnvSet("PREFIX", "13IDDRP2:")
# The port name for the detector
epicsEnvSet("PORT",   "ROPER1")
# The queue size for all plugins
epicsEnvSet("QSIZE",  "20")
# The maximim image width; used for row profiles in the NDPluginStats plugin
epicsEnvSet("XSIZE",  "1396")
# The maximim image height; used for column profiles in the NDPluginStats plugin
epicsEnvSet("YSIZE",  "1040")
# The maximum number of time seried points in the NDPluginStats plugin
epicsEnvSet("NCHANS", "2048")
# The maximum number of frames buffered in the NDPluginCircularBuff plugin
epicsEnvSet("CBUFFS", "500")
# The search path for database files
epicsEnvSet("EPICS_DB_INCLUDE_PATH", "$(ADCORE)/db")

roperConfig("$(PORT)", 50, 200000000)
asynSetTraceIOMask("$(PORT)",0,2)
#asynSetTraceMask("$(PORT)",0,9)
dbLoadRecords("$(ADROPER)/db/roper.template",   "P=$(PREFIX),R=cam1:,PORT=$(PORT),ADDR=0,TIMEOUT=1")

# Create a standard arrays plugin, set it to get data from the Roper driver.
NDStdArraysConfigure("Image1", 5, 0, "$(PORT)", 0, -1)
dbLoadRecords("$(ADCORE)/db/NDStdArrays.template", "P=$(PREFIX),R=image1:,PORT=Image1,ADDR=0,TIMEOUT=1,NDARRAY_PORT=$(PORT),TYPE=Int16,FTVL=SHORT,NELEMENTS=1500000")

# Load all other plugins using commonPlugins.cmd
< ../commonPlugins.cmd
set_requestfile_path("$(ADROPER)/roperApp/Db")

iocInit()

# save things every thirty seconds
create_monitor_set("auto_settings.req", 30,"P=$(PREFIX),D=cam1:")

