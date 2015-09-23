< envPaths
errlogInit(20000)

dbLoadDatabase("$(ADMARCCD)/iocs/marCCDIOC/dbd/marCCDApp.dbd")
marCCDApp_registerRecordDeviceDriver(pdbbase) 

# Prefix for all records
epicsEnvSet("PREFIX", "13MARCCD2:")
# The port name for the detector
epicsEnvSet("PORT",   "MAR")
# The queue size for all plugins
epicsEnvSet("QSIZE",  "20")
# The maximim image width; used for row profiles in the NDPluginStats plugin
epicsEnvSet("XSIZE",  "2048")
# The maximim image height; used for column profiles in the NDPluginStats plugin
epicsEnvSet("YSIZE",  "2048")
# The maximum number of time seried points in the NDPluginStats plugin
epicsEnvSet("NCHANS", "2048")
# The maximum number of frames buffered in the NDPluginCircularBuff plugin
epicsEnvSet("CBUFFS", "500")
# The search path for database files
epicsEnvSet("EPICS_DB_INCLUDE_PATH", "$(ADCORE)/db")

###
# Create the asyn port to talk to the MAR on port 2222
drvAsynIPPortConfigure("marServer","gse-marccd2.cars.aps.anl.gov:2222")
# Set the input and output terminators.
asynOctetSetInputEos("marServer", 0, "\n")
asynOctetSetOutputEos("marServer", 0, "\n")
#asynSetTraceMask("marServer",0,255)
asynSetTraceIOMask("marServer",0,2)

marCCDConfig("$(PORT)", "marServer", 0, 0)
dbLoadRecords("$(ADMARCCD)/db/marCCD.template","P=$(PREFIX),R=cam1:,PORT=$(PORT),ADDR=0,TIMEOUT=1,MARSERVER_PORT=marServer")

# Create a standard arrays plugin
NDStdArraysConfigure("Image1", 5, 0, "$(PORT)", 0, 0)
# Make NELEMENTS in the following be a little bigger than 2048*2048
dbLoadRecords("$(ADCORE)/db/NDStdArrays.template", "P=$(PREFIX),R=image1:,PORT=Image1,ADDR=0,TIMEOUT=1,NDARRAY_PORT=$(PORT),TYPE=Int16,FTVL=SHORT,NELEMENTS=4200000")

# Load all other plugins using commonPlugins.cmd
< ../commonPlugins.cmd
set_requestfile_path("$(ADMARCCD)/marCCDApp/Db")

#asynSetTraceMask("$(PORT)",0,3)
#asynSetTraceIOMask("$(PORT)",0,4)

iocInit()

# save things every thirty seconds
create_monitor_set("auto_settings.req", 30,"P=$(PREFIX)")
