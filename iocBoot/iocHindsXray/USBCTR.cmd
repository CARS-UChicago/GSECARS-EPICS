epicsEnvSet("USBCTR_PREFIX"             "$(PREFIX)USBCTR:")
epicsEnvSet("MCS_PREFIX"                "$(USBCTR_PREFIX)MCS:")
epicsEnvSet("UNIQUE_ID",                "01954963")
epicsEnvSet("RNAME",                    "mca")
epicsEnvSet("MAX_COUNTERS",             "9")
epicsEnvSet("MAX_POINTS",               "2048")
epicsEnvSet("PORT",                     "USBCTR")
epicsEnvSet("POLL_TIME",                "0.01")
# For MCA records FIELD=READ, for waveform records FIELD=PROC
epicsEnvSet("FIELD",                    "PROC")

## Configure port driver
# USBCTRConfig(portName,       # The name to give to this asyn port driver
#              uniqueID,       # Device serial number.
#              maxTimePoints,  # Maximum number of time points for MCS
#              pollTime,       # Time to sleep between polls
USBCTRConfig("$(PORT)", "$(UNIQUE_ID)", $(MAX_POINTS), $(POLL_TIME))

#asynSetTraceMask($(PORT), 0, TRACE_ERROR|TRACE_FLOW|TRACEIO_DRIVER)

dbLoadTemplate("$(MEASCOMP)/db/USBCTR.substitutions", "P=$(USBCTR_PREFIX), PORT=$(PORT)")

# This loads the scaler record and supporting records
dbLoadRecords("$(SCALER)/db/scaler.db", "P=$(USBCTR_PREFIX), S=scaler1, DTYP=Asyn Scaler, OUT=@asyn(USBCTR), FREQ=10000000")

# This database provides the support for the MCS functions
dbLoadRecords("$(MEASCOMP)/db/measCompMCS.template", "P=$(MCS_PREFIX), PORT=$(PORT), MAX_POINTS=$(MAX_POINTS)")

# The number of records loaded must be the same as MAX_COUNTERS defined above
dbLoadRecords("$(MCA)/db/SIS38XX_waveform.template", "P=$(MCS_PREFIX), R=$(RNAME)1,  INP=@asyn($(PORT) 0),  CHANS=$(MAX_POINTS)")
dbLoadRecords("$(MCA)/db/SIS38XX_waveform.template", "P=$(MCS_PREFIX), R=$(RNAME)2,  INP=@asyn($(PORT) 1),  CHANS=$(MAX_POINTS)")
dbLoadRecords("$(MCA)/db/SIS38XX_waveform.template", "P=$(MCS_PREFIX), R=$(RNAME)3,  INP=@asyn($(PORT) 2),  CHANS=$(MAX_POINTS)")
dbLoadRecords("$(MCA)/db/SIS38XX_waveform.template", "P=$(MCS_PREFIX), R=$(RNAME)4,  INP=@asyn($(PORT) 3),  CHANS=$(MAX_POINTS)")
dbLoadRecords("$(MCA)/db/SIS38XX_waveform.template", "P=$(MCS_PREFIX), R=$(RNAME)5,  INP=@asyn($(PORT) 4),  CHANS=$(MAX_POINTS)")
dbLoadRecords("$(MCA)/db/SIS38XX_waveform.template", "P=$(MCS_PREFIX), R=$(RNAME)6,  INP=@asyn($(PORT) 5),  CHANS=$(MAX_POINTS)")
dbLoadRecords("$(MCA)/db/SIS38XX_waveform.template", "P=$(MCS_PREFIX), R=$(RNAME)7,  INP=@asyn($(PORT) 6),  CHANS=$(MAX_POINTS)")
dbLoadRecords("$(MCA)/db/SIS38XX_waveform.template", "P=$(MCS_PREFIX), R=$(RNAME)8,  INP=@asyn($(PORT) 7),  CHANS=$(MAX_POINTS)")
dbLoadRecords("$(MCA)/db/SIS38XX_waveform.template", "P=$(MCS_PREFIX), R=$(RNAME)9,  INP=@asyn($(PORT) 8),  CHANS=$(MAX_POINTS)")

asynSetTraceIOMask($(PORT),0,2)

