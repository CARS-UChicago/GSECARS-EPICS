< envPaths

# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in this build.
dbLoadDatabase("$(DANTE)/dbd/mcaDanteApp.dbd")
mcaDanteApp_registerRecordDeviceDriver(pdbbase)

# The search path for database files
epicsEnvSet("EPICS_DB_INCLUDE_PATH", "$(ADCORE)/db")

# Prefix for all records
epicsEnvSet("PREFIX", "13BMD_Dante1:")
# The port name for the detector
epicsEnvSet("PORT",   "DANTE1")
# The queue size for all plugins
epicsEnvSet("QSIZE",  "20")
# The maximum image width; used to set the maximum size for row profiles in the NDPluginStats plugin
epicsEnvSet("XSIZE",  "1024")
# The maximum image height; used to set the maximum size for column profiles in the NDPluginStats plugin
epicsEnvSet("YSIZE",  "1024")
# The maximum number of time series points in the NDPluginStats plugin
epicsEnvSet("NCHANS", "2048")
# The maximum number of frames buffered in the NDPluginCircularBuff plugin
epicsEnvSet("CBUFFS", "500")
# The maximum number of threads for plugins which can run in multiple threads
epicsEnvSet("MAX_THREADS", "8")
# The search path for database files
epicsEnvSet("EPICS_DB_INCLUDE_PATH", "$(ADCORE)/db")

# DanteConfig(portName, ipAddress, numDetectors, maxBuffers, maxMemory)
#DanteConfig("$(PORT)",  164.54.160.185, 1, 0, 0)
DanteConfig("$(PORT)",  164.54.160.183, 1, 0, 0)

dbLoadTemplate("dante.substitutions")

# Load all other plugins using commonPlugins.cmd
< $(ADCORE)/iocBoot/commonPlugins.cmd

set_requestfile_path("$(DANTE)/danteApp/Db")
set_requestfile_path("$(MCA)/mcaApp/Db")

iocInit

### Start up the autosave task and tell it what to do.
# Save settings every thirty seconds
create_monitor_set("auto_settings.req", 30, "P=$(PREFIX), R=dante1:, M=mca1")
