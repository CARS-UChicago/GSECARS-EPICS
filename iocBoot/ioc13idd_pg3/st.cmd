< envPaths
errlogInit(20000)

dbLoadDatabase("$(ADPOINTGREY)/iocs/pointGreyIOC/dbd/pointGreyApp.dbd")
pointGreyApp_registerRecordDeviceDriver(pdbbase) 

# Prefix for all records
epicsEnvSet("PREFIX", "13IDD_PG3:")
# This is the 13-ID-D Grasshopper3 GigE camera, gse-pointgrey3
epicsEnvSet("CAMERA_ID", "14481207")
# This is the 13-ID-D Grasshopper3 GigE camera, gse-pointgrey3
#epicsEnvSet("CAMERA_ID", "14481209")

# The port name for the detector
epicsEnvSet("PORT",   "PG1")
# Really large queue so we can stream to disk at full camera speed
epicsEnvSet("QSIZE",  "2000")   
# The maximim image width; used for row profiles in the NDPluginStats plugin
epicsEnvSet("XSIZE",  "2048")
# The maximim image height; used for column profiles in the NDPluginStats plugin
epicsEnvSet("YSIZE",  "2048")
# The maximum number of time series points in the NDPluginStats plugin
epicsEnvSet("NCHANS", "2048")
# The maximum number of frames buffered in the NDPluginCircularBuff plugin
epicsEnvSet("CBUFFS", "500")
# The search path for database files
epicsEnvSet("EPICS_DB_INCLUDE_PATH", "$(ADCORE)/db")
# Define NELEMENTS to be enough for a 1920x1200x3 (color) image
epicsEnvSet("NELEMENTS", "7000000")

pointGreyConfig("$(PORT)", $(CAMERA_ID), 0x0, 1)
asynSetTraceIOMask($(PORT), 0, 2)
#asynSetTraceMask($(PORT), 0, 0x29)
#asynSetTraceInfoMask($(PORT), 0, 0xf)

dbLoadRecords("$(ADPOINTGREY)/db/pointGrey.template", "P=$(PREFIX),R=cam1:,PORT=$(PORT),ADDR=0,TIMEOUT=1")
dbLoadTemplate("pointGrey.substitutions")

# Create a standard arrays plugin
NDStdArraysConfigure("Image1", 5, 0, "$(PORT)", 0, 0)
# Use this line for 8-bit data only
dbLoadRecords("$(ADCORE)/db/NDStdArrays.template", "P=$(PREFIX),R=image1:,PORT=Image1,ADDR=0,TIMEOUT=1,NDARRAY_PORT=$(PORT),TYPE=Int8,FTVL=CHAR,NELEMENTS=$(NELEMENTS)")
# Use this line for 8-bit or 16-bit data
#dbLoadRecords("$(ADCORE)/db/NDStdArrays.template", "P=$(PREFIX),R=image1:,PORT=Image1,ADDR=0,TIMEOUT=1,NDARRAY_PORT=$(PORT),TYPE=Int16,FTVL=SHORT,NELEMENTS=$(NELEMENTS)")

# Load all other plugins using commonPlugins.cmd
< $(ADCORE)/iocBoot/commonPlugins.cmd
set_requestfile_path("$(ADPOINTGREY)/pointGreyApp/Db")

iocInit()

# save things every thirty seconds
create_monitor_set("auto_settings.req", 30,"P=$(PREFIX)")


# Wait for enum callbacks to complete
epicsThreadSleep(1.0)

# Records with dynamic enums need to be processed again because the enum values are not available during iocInit.  
dbpf("$(PREFIX)cam1:Format7Mode.PROC", "1")
dbpf("$(PREFIX)cam1:PixelFormat.PROC", "1")

# Wait for callbacks on the property limits (DRVL, DRVH) to complete
epicsThreadSleep(1.0)

# Records that depend on the state of the dynamic enum records or property limits also need to be processed again
# Other property records may need to be added to this list
dbpf("$(PREFIX)cam1:FrameRate.PROC", "1")
dbpf("$(PREFIX)cam1:FrameRateValAbs.PROC", "1")
dbpf("$(PREFIX)cam1:AcquireTime.PROC", "1")

