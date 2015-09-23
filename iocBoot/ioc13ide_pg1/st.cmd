< envPaths
errlogInit(20000)

dbLoadDatabase("$(ADPOINTGREY)/iocs/pointGreyIOC/dbd/pointGreyApp.dbd")
pointGreyApp_registerRecordDeviceDriver(pdbbase) 

epicsEnvSet("PREFIX", "13IDEPG1:")

# Use this line for the first Point Grey camera in the system
#epicsEnvSet("CAMERA_ID", "0")
# Use this line for a specific camera by serial number, in this case a Flea2 Firewire camera
#epicsEnvSet("CAMERA_ID", "9211601")
# Use this line for a specific camera by serial number, in this case a Grasshopper3 USB-3.0 cameras
# epicsEnvSet("CAMERA_ID", "13510305")
# Use this line for a specific camera by serial number, in this case a BlackFly GigE cameras
#epicsEnvSet("CAMERA_ID", "13481965")

# Use this line for a specific camera by serial number, in this case a Flea3 GigE camera

epicsEnvSet("CAMERA_ID", "14273040")

epicsEnvSet("PORT",   "PG1")
# Really large queue so we can stream to disk at full camera speed
epicsEnvSet("QSIZE",  "20")   
epicsEnvSet("XSIZE",  "1928")
epicsEnvSet("YSIZE",  "1448")
epicsEnvSet("NCHANS", "2048")
# The maximum number of frames buffered in the NDPluginCircularBuff plugin
epicsEnvSet("CBUFFS", "500")
# The search path for database files
epicsEnvSet("EPICS_DB_INCLUDE_PATH", "$(ADCORE)/db")


# Define NELEMENTS to be enough for a 1928x1448x3 (color) image
epicsEnvSet("NELEMENTS", "8375232")

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
< ../commonPlugins.cmd
set_requestfile_path("$(ADPOINTGREY)/pointGreyApp/Db")

iocInit()

# save things every thirty seconds
create_monitor_set("auto_settings.req", 30,"P=$(PREFIX)")


# There is a problem with some records for which PINI=YES does not work because of timing or ordering
# For those records to process after iocInit

dbpf("$(PREFIX)cam1:PixelFormat.PROC", "1")
dbpf("$(PREFIX)cam1:FrameRate.PROC", "1")
dbpf("$(PREFIX)cam1:FrameRateValAbs.PROC", "1")
