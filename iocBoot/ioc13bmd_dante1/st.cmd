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
# The maximum number of channels in the MCA records
epicsEnvSet("MCA_CHANS", 4096)
# The maximum number of points in the ADC trace waveform records
epicsEnvSet("TRACE_LEN", 16384)
# The search path for database files
epicsEnvSet("EPICS_DB_INCLUDE_PATH", "$(ADCORE)/db")

# DanteConfig(portName, ipAddress, numDetectors, maxBuffers, maxMemory)
#DanteConfig("$(PORT)",  164.54.160.185, 1, 0, 0)
DanteConfig("$(PORT)",  164.54.160.183, 1, 0, 0)

dbLoadTemplate($(DANTE)/db/"dante1.substitutions", "P=$(PREFIX), NCHAN=$(MCA_CHANS), TRACE_LEN=$(TRACE_LEN)")

# Load all other plugins using commonPlugins.cmd
< $(ADCORE)/iocBoot/commonPlugins.cmd

set_requestfile_path("$(DANTE)/danteApp/Db")
set_requestfile_path("$(MCA)/mcaApp/Db")

iocInit

### Start up the autosave task and tell it what to do.
# Save settings every thirty seconds
create_monitor_set("auto_settings.req", 30, "P=$(PREFIX), R=dante1:, M=mca1")

# Wait 1 seconds for all records with PINI=YES to process
epicsThreadSleep(1)

# Enable downloading configurations
dbpf("$(PREFIX)dante1:EnableConfigure", "Enable")

# There is a problem with the GatingMode record.
# Even though it has PINI=YES and has already processed and written the value to the Dante,
# the value appears to have been changed, and it need to be processed again.  
# This needs to be tracked down.
dbpf("$(PREFIX)dante1:GatingMode.PROC", "1")
