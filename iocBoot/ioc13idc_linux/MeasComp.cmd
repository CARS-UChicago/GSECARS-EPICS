# USB-1808X
epicsEnvSet("PORT",          "USB1808")
#epicsEnvSet("UNIQUE_ID",     "021514C5")
epicsEnvSet("UNIQUE_ID",     "02151405")
epicsEnvSet("MAX_POINTS",    "4096")
epicsEnvSet("USB1808_PREFIX",  "$(P)USB1808:")
## Configure port driver
# MultiFunctionConfig((portName,        # The name to give to this asyn port driver
#                      uniqueID,        # For USB the serial number.  For Ethernet the MAC address or IP address.
#                      maxInputPoints,  # Maximum number of input points for waveform digitizer
#                      maxOutputPoints) # Maximum number of output points for waveform generator

MultiFunctionConfig($(PORT), $(UNIQUE_ID), $(MAX_POINTS), $(MAX_POINTS))
dbLoadTemplate("$(MEASCOMP)/db/USB1808.substitutions", "P=$(USB1808_PREFIX), PORT=$(PORT), WDIG_POINTS=$(MAX_POINTS), WGEN_POINTS=$(MAX_POINTS)")

# USB3104
epicsEnvSet("PORT",           "USB3104")
#epicsEnvSet("UNIQUE_ID",      "0209CC85")
epicsEnvSet("UNIQUE_ID",      "0209CC90")
epicsEnvSet("USB3104_PREFIX", "$(P)USB3104:")
MultiFunctionConfig($(PORT), $(UNIQUE_ID), 1, 1)
dbLoadTemplate("$(MEASCOMP)/db/USB3104.substitutions", "P=$(USB3104_PREFIX), PORT=$(PORT)")
asynSetTraceIOMask($(PORT), -1, ESCAPE)
#asynSetTraceMask($(PORT), -1, DRIVER|ERROR)

# USBCTR
epicsEnvSet("PORT",          "USBCTR")
#epicsEnvSet("UNIQUE_ID",     "0213F59E")
epicsEnvSet("UNIQUE_ID",     "0214D588")
epicsEnvSet("USBCTR_PREFIX", "$(P)USBCTR:")
epicsEnvSet("MCS_PREFIX",    "$(P)MCS1:")
epicsEnvSet("SCALER_PREFIX", "$(P)"
epicsEnvSet("SCALER_NAME",   "scaler1")
epicsEnvSet("RNAME",         "mca")
epicsEnvSet("MAX_COUNTERS",  "9")
epicsEnvSet("MAX_POINTS",    "4096")
epicsEnvSet("POLL_TIME",     "0.01")
# For MCA records FIELD=READ, for waveform records FIELD=PROC
epicsEnvSet("FIELD",         "PROC")

## Configure port driver
# USBCTRConfig(portName,       # The name to give to this asyn port driver
#              uniqueID,       # Device serial number.
#              maxTimePoints,  # Maximum number of time points for MCS
#              pollTime,       # Time to sleep between polls
USBCTRConfig($(PORT), $(UNIQUE_ID), $(MAX_POINTS), $(POLL_TIME))
dbLoadTemplate("$(MEASCOMP)/db/USBCTR.substitutions", "P=$(USBCTR_PREFIX),PORT=$(PORT)")

# This loads the scaler record and supporting records
# We use the IOC prefix, without the USBCTR: for backwards compatibility
dbLoadRecords("$(SCALER)/db/scaler.db", "P=$(SCALER_PREFIX), S=$(SCALER_NAME), DTYP=Asyn Scaler, OUT=@asyn($(PORT)), FREQ=10000000")

# This database provides the support for the MCS functions
dbLoadRecords("$(MEASCOMP)/db/measCompMCS.template", "P=$(MCS_PREFIX), PORT=$(PORT), MAX_POINTS=$(MAX_POINTS)")

# Load either MCA or waveform records below

# Load the MCA records
#dbLoadRecords("$(MCA)/mcaApp/Db/simple_mca.db", "P=$(MCS_PREFIX), M=$(RNAME)1,  DTYP=asynMCA, INP=@asyn($(PORT) 0),  PREC=3, CHANS=$(MAX_POINTS)")
#dbLoadRecords("$(MCA)/mcaApp/Db/simple_mca.db", "P=$(MCS_PREFIX), M=$(RNAME)2,  DTYP=asynMCA, INP=@asyn($(PORT) 1),  PREC=3, CHANS=$(MAX_POINTS)")
#dbLoadRecords("$(MCA)/mcaApp/Db/simple_mca.db", "P=$(MCS_PREFIX), M=$(RNAME)3,  DTYP=asynMCA, INP=@asyn($(PORT) 2),  PREC=3, CHANS=$(MAX_POINTS)")
#dbLoadRecords("$(MCA)/mcaApp/Db/simple_mca.db", "P=$(MCS_PREFIX), M=$(RNAME)4,  DTYP=asynMCA, INP=@asyn($(PORT) 3),  PREC=3, CHANS=$(MAX_POINTS)")
#dbLoadRecords("$(MCA)/mcaApp/Db/simple_mca.db", "P=$(MCS_PREFIX), M=$(RNAME)5,  DTYP=asynMCA, INP=@asyn($(PORT) 4),  PREC=3, CHANS=$(MAX_POINTS)")
#dbLoadRecords("$(MCA)/mcaApp/Db/simple_mca.db", "P=$(MCS_PREFIX), M=$(RNAME)6,  DTYP=asynMCA, INP=@asyn($(PORT) 5),  PREC=3, CHANS=$(MAX_POINTS)")
#dbLoadRecords("$(MCA)/mcaApp/Db/simple_mca.db", "P=$(MCS_PREFIX), M=$(RNAME)7,  DTYP=asynMCA, INP=@asyn($(PORT) 6),  PREC=3, CHANS=$(MAX_POINTS)")
#dbLoadRecords("$(MCA)/mcaApp/Db/simple_mca.db", "P=$(MCS_PREFIX), M=$(RNAME)8,  DTYP=asynMCA, INP=@asyn($(PORT) 7),  PREC=3, CHANS=$(MAX_POINTS)")
#dbLoadRecords("$(MCA)/mcaApp/Db/simple_mca.db", "P=$(MCS_PREFIX), M=$(RNAME)9,  DTYP=asynMCA, INP=@asyn($(PORT) 8),  PREC=3, CHANS=$(MAX_POINTS)")

# This loads the waveform records
dbLoadRecords("$(MCA)/mcaApp/Db/SIS38XX_waveform.template", "P=$(MCS_PREFIX), R=$(RNAME)1,  INP=@asyn($(PORT) 0),  CHANS=$(MAX_POINTS)")
dbLoadRecords("$(MCA)/mcaApp/Db/SIS38XX_waveform.template", "P=$(MCS_PREFIX), R=$(RNAME)2,  INP=@asyn($(PORT) 1),  CHANS=$(MAX_POINTS)")
dbLoadRecords("$(MCA)/mcaApp/Db/SIS38XX_waveform.template", "P=$(MCS_PREFIX), R=$(RNAME)3,  INP=@asyn($(PORT) 2),  CHANS=$(MAX_POINTS)")
dbLoadRecords("$(MCA)/mcaApp/Db/SIS38XX_waveform.template", "P=$(MCS_PREFIX), R=$(RNAME)4,  INP=@asyn($(PORT) 3),  CHANS=$(MAX_POINTS)")
dbLoadRecords("$(MCA)/mcaApp/Db/SIS38XX_waveform.template", "P=$(MCS_PREFIX), R=$(RNAME)5,  INP=@asyn($(PORT) 4),  CHANS=$(MAX_POINTS)")
dbLoadRecords("$(MCA)/mcaApp/Db/SIS38XX_waveform.template", "P=$(MCS_PREFIX), R=$(RNAME)6,  INP=@asyn($(PORT) 5),  CHANS=$(MAX_POINTS)")
dbLoadRecords("$(MCA)/mcaApp/Db/SIS38XX_waveform.template", "P=$(MCS_PREFIX), R=$(RNAME)7,  INP=@asyn($(PORT) 6),  CHANS=$(MAX_POINTS)")
dbLoadRecords("$(MCA)/mcaApp/Db/SIS38XX_waveform.template", "P=$(MCS_PREFIX), R=$(RNAME)8,  INP=@asyn($(PORT) 7),  CHANS=$(MAX_POINTS)")
dbLoadRecords("$(MCA)/mcaApp/Db/SIS38XX_waveform.template", "P=$(MCS_PREFIX), R=$(RNAME)9,  INP=@asyn($(PORT) 8),  CHANS=$(MAX_POINTS)")

doAfterIocInit 'seq(USBCTR_SNL, "P=$(MCS_PREFIX), R=$(RNAME), NUM_COUNTERS=$(MAX_COUNTERS), FIELD=$(FIELD)")'

# EDIO24
epicsEnvSet("PORT",          "EDIO24")
epicsEnvSet("UNIQUE_ID",     "gse-edio24-3.cars.aps.anl.gov")
epicsEnvSet("MAX_POINTS",    "1")
epicsEnvSet("EDIO24_PREFIX",  "$(P)EDIO24_1:")
## Configure port driver
# MultiFunctionConfig((portName,        # The name to give to this asyn port driver
#                      uniqueID,        # For USB the serial number.  For Ethernet the MAC address or IP address.
#                      maxInputPoints,  # Maximum number of input points for waveform digitizer
#                      maxOutputPoints) # Maximum number of output points for waveform generator

MultiFunctionConfig($(PORT), $(UNIQUE_ID), $(MAX_POINTS), 1)
dbLoadTemplate("$(MEASCOMP)/db/EDIO24.substitutions", "P=$(EDIO24_PREFIX), PORT=$(PORT), WDIG_POINTS=$(MAX_POINTS)")

dbLoadTemplate("MeasCompAliases.substitutions")
