< envPaths
errlogInit(20000)

dbLoadDatabase("$(ADPOINTGREY)/iocs/pointGreyIOC/dbd/pointGreyApp.dbd")
pointGreyApp_registerRecordDeviceDriver(pdbbase) 


# Use this line for the first Point Grey camera in the system
#epicsEnvSet("CAMERA_ID", "0")
# Use this line for a specific camera by serial number, in this case the tomography Grasshopper3 USB-3.0 cameras
#epicsEnvSet("CAMERA_ID", "13510305")
# Use this line for a specific camera by serial number, in this case the LVP Grasshopper3 USB-3.0 cameras
epicsEnvSet("CAMERA_ID", "15452742")

# Prefix for all records
epicsEnvSet("PREFIX", "13BMDPG2:")
# The port name for the detector
epicsEnvSet("PORT",   "PG1")
# The queue size for all plugins. Really large queue so we can stream to disk at full camera speed
epicsEnvSet("QSIZE",  "2000")
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

# Define NELEMENTS to be enough for a 2048x2048x3 (color) image
epicsEnvSet("NELEMENTS", "12592912")

pointGreyConfig("$(PORT)", $(CAMERA_ID), 0x0, 0)
asynSetTraceIOMask($(PORT), 0, 2)
#asynSetTraceMask($(PORT), 0, 0x29)
#asynSetTraceInfoMask($(PORT), 0, 0xf)

dbLoadRecords("$(ADPOINTGREY)/db/pointGrey.template", "P=$(PREFIX),R=cam1:,PORT=$(PORT),ADDR=0,TIMEOUT=1")
dbLoadTemplate("pointGrey.substitutions")

# Create a standard arrays plugin
NDStdArraysConfigure("Image1", 5, 0, "$(PORT)", 0, 0)
# Use this line for 8-bit data only
#dbLoadRecords("$(ADCORE)/db/NDStdArrays.template", "P=$(PREFIX),R=image1:,PORT=Image1,ADDR=0,TIMEOUT=1,NDARRAY_PORT=$(PORT),TYPE=Int8,FTVL=CHAR,NELEMENTS=$(NELEMENTS)")
# Use this line for 8-bit or 16-bit data
dbLoadRecords("$(ADCORE)/db/NDStdArrays.template", "P=$(PREFIX),R=image1:,PORT=Image1,ADDR=0,TIMEOUT=1,NDARRAY_PORT=$(PORT),TYPE=Int16,FTVL=SHORT,NELEMENTS=$(NELEMENTS)")

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

