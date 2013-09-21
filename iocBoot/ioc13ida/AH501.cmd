epicsEnvSet("PREFIX", "13IDA:")
epicsEnvSet("PORT", "QE2")
epicsEnvSet("MODEL","AH501")
epicsEnvSet("QSIZE", "20")
epicsEnvSet("RING_SIZE", "8000")
epicsEnvSet("TSPOINTS", "1000")
epicsEnvSet("IP", "164.54.160.11:10001")

#drvAsynIPPortConfigure("portName","hostInfo",priority,noAutoConnect,
#                        noProcessEos)
drvAsynIPPortConfigure("IP_$(PORT)", "$(IP)", 0, 0, 0)
asynOctetSetInputEos("IP_$(PORT)",0,"\r\n")
asynOctetSetOutputEos("IP_$(PORT)",0,"\r")

# Set both TRACE_IO_ESCAPE (for ASCII command/response) and TRACE_IO_HEX (for binary data)
asynSetTraceIOMask("IP_$(PORT)",0,6)
#asynSetTraceFile("IP_$(PORT)",0,"AHxxx.out")
#asynSetTraceMask("IP_$(PORT)",0,9)

# Load asynRecord record
dbLoadRecords("$(ASYN)/db/asynRecord.db", "P=$(PREFIX), R=$(PORT)asyn1,PORT=IP_$(PORT),ADDR=0,OMAX=256,IMAX=256")

drvAHxxxConfigure("$(PORT)", "IP_$(PORT)", $(RING_SIZE))
dbLoadRecords("$(QUADEM)/quadEMApp/Db/quadEM.template", "P=$(PREFIX), R=$(PORT):, PORT=$(PORT)")
dbLoadRecords("$(QUADEM)/quadEMApp/Db/$(MODEL).template", "P=$(PREFIX), R=$(PORT):, PORT=$(PORT)")

asynSetTraceIOMask("$(PORT)",0,2)
#asynSetTraceMask("$(PORT)",0,9)

# initFastSweep(portName, inputName, maxSignals, maxPoints)
#  portName = asyn port name for this new port (string)
#  inputName = name of asynPort providing data
#  maxSignals  = maximum number of signals (spectra)
#  maxPoints  = maximum number of channels per spectrum
#  dataString  = drvInfo string for current and position data
#  intervalString  = drvInfo string for time interval per point
initFastSweep("$(PORT)TS", "$(PORT)", 11, 2048, "QE_INT_ARRAY_DATA", "QE_SAMPLE_TIME")
dbLoadRecords("$(QUADEM)/quadEMApp/Db/quadEM_TimeSeries.template", "P=$(PREFIX),R=$(PORT)_TS:,NUM_TS=2048,NUM_FREQ=1024,PORT=$(PORT)TS")

< commonPlugins.cmd

