epicsEnvSet("PREFIX",    "13IDA:")
epicsEnvSet("RECORD",    "QE1:")
epicsEnvSet("PORT",      "QE1")
epicsEnvSet("TEMPLATE",  "TetrAMM")
epicsEnvSet("QSIZE",     "20")
epicsEnvSet("RING_SIZE", "10000")
epicsEnvSet("TSPOINTS",  "2048")
epicsEnvSet("IP",        "164.54.160.164:10001")

#drvAsynIPPortConfigure("portName","hostInfo",priority,noAutoConnect,
#                        noProcessEos)
drvAsynIPPortConfigure("IP_$(PORT)", "$(IP)", 0, 0, 0)
asynOctetSetInputEos("IP_$(PORT)",  0, "\r\n")
asynOctetSetOutputEos("IP_$(PORT)", 0, "\r")

# Set both TRACE_IO_ESCAPE (for ASCII command/response) and TRACE_IO_HEX (for binary data)
asynSetTraceIOMask("IP_$(PORT)", 0, 6)
#asynSetTraceFile("IP_$(PORT)",   0, "TetrAMM.out")
#asynSetTraceMask("IP_$(PORT)",   0,  9)
asynSetTraceIOTruncateSize("IP_$(PORT)", 0, 4000)

# Load asynRecord record
dbLoadRecords("$(ASYN)/db/asynRecord.db", "P=$(PREFIX), R=asyn1,PORT=IP_$(PORT),ADDR=0,OMAX=256,IMAX=256")

drvTetrAMMConfigure("$(PORT)", "IP_$(PORT)", $(RING_SIZE))
dbLoadRecords("$(QUADEM)/db/$(TEMPLATE).template", "P=$(PREFIX), R=$(RECORD), PORT=$(PORT), ADDR=0, TIMEOUT=1")

asynSetTraceIOMask("$(PORT)",0,2)
#asynSetTraceMask("$(PORT)",  0,9)

< ../quadEMCommonPlugins.cmd
