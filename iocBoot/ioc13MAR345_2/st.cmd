< envPaths
errlogInit(20000)

dbLoadDatabase("$(ADMAR345)/iocs/mar345IOC/dbd/mar345App.dbd")
mar345App_registerRecordDeviceDriver(pdbbase) 

# Prefix for all records
epicsEnvSet("PREFIX", "13MAR345_2:")
# The port name for the detector
epicsEnvSet("PORT",   "MAR")
# The queue size for all plugins
epicsEnvSet("QSIZE",  "20")
# The maximim image width; used for row profiles in the NDPluginStats plugin
epicsEnvSet("XSIZE",  "3450")
# The maximim image height; used for column profiles in the NDPluginStats plugin
epicsEnvSet("YSIZE",  "3450")
# The maximum number of time seried points in the NDPluginStats plugin
epicsEnvSet("NCHANS", "2048")
# The maximum number of frames buffered in the NDPluginCircularBuff plugin
epicsEnvSet("CBUFFS", "500")
# The search path for database files
epicsEnvSet("EPICS_DB_INCLUDE_PATH", "$(ADCORE)/db")

###
# Create the asyn port to talk to the MAR on port 5001
drvAsynIPPortConfigure("marServer","gse-marip2.cars.aps.anl.gov:5001")
# Set the input and output terminators.
asynOctetSetInputEos("marServer", 0, "\n")
asynOctetSetOutputEos("marServer", 0, "\n")
asynSetTraceIOMask("marServer",0,2)
#asynSetTraceMask("marServer",0,255)

mar345Config("$(PORT)", "marServer", 0, 0)
asynSetTraceIOMask("$(PORT)",0,2)
#asynSetTraceMask("$(PORT)",0,255)
dbLoadRecords("$(ADMAR345)/db/mar345.template","P=$(PREFIX),R=cam1:,PORT=$(PORT),ADDR=0,TIMEOUT=1,MARSERVER_PORT=marServer")

# Create a standard arrays plugin
NDStdArraysConfigure("Image1", 5, 0, "$(PORT)", 0, 0)
dbLoadRecords("$(ADCORE)/db/NDStdArrays.template", "P=$(PREFIX),R=image1:,PORT=Image1,ADDR=0,TIMEOUT=1,NDARRAY_PORT=$(PORT),TYPE=Int16,FTVL=SHORT,NELEMENTS=12000000")

# Load all other plugins using commonPlugins.cmd
< $(ADCORE)/iocBoot/commonPlugins.cmd
set_requestfile_path("$(ADMAR345)/mar345App/Db")

#asynSetTraceMask("$(PORT)",0,3)
#asynSetTraceIOMask("$(PORT)",0,4)

iocInit()

# save things every thirty seconds
create_monitor_set("auto_settings.req", 30,"P=$(PREFIX)")
