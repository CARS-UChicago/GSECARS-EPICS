# Example vxWorks startup file for SIS3820

iocsh

epicsEnvSet("PREFIX",                   "13LAB:SIS3820:")
epicsEnvSet("RNAME",                    "mca")
epicsEnvSet("MAX_SIGNALS",              "2")
epicsEnvSet("MAX_CHANS",                "10000")
epicsEnvSet("EPICS_CA_MAX_ARRAY_BYTES", "500000")
epicsEnvSet("PORT",                     "SIS3820/1")
# For MCA records FIELD=READ, for waveform records FIELD=PROC
epicsEnvSet("FIELD",                    "PROC")

#drvSIS3820Config("Port name",
#                  baseAddress,
#                  interruptVector, 
#                  int interruptLevel,
#                  channels,
#                  signals,
#                  use DMA
#                  fifoBufferWords)
drvSIS3820Config($(PORT), 0xA8000000, 224, 6, $(MAX_CHANS), $(MAX_SIGNALS), 1, 0x20000)

# This loads the scaler record and supporting records
dbLoadRecords("$(SCALER)/db/scaler32.db", "P=13LAB:, S=scaler3, DTYP=Asyn Scaler, OUT=@asyn($(PORT)), FREQ=50000000")

# This database provides the support for the MCS functions
dbLoadRecords("$(MCA)/db/SIS38XX.template", "P=$(PREFIX), PORT=$(PORT), SCALER=13LAB:scaler3")

# Load either MCA or waveform records below
# The number of records loaded must be the same as MAX_SIGNALS defined above

# Load the MCA records
#dbLoadRecords("$(MCA)/db/simple_mca.db", "P=$(PREFIX), M=$(RNAME)1,  DTYP=asynMCA, INP=@asyn($(PORT) 0),  PREC=3, CHANS=$(MAX_CHANS)")
#dbLoadRecords("$(MCA)/db/simple_mca.db", "P=$(PREFIX), M=$(RNAME)2,  DTYP=asynMCA, INP=@asyn($(PORT) 1),  PREC=3, CHANS=$(MAX_CHANS)")
#dbLoadRecords("$(MCA)/db/simple_mca.db", "P=$(PREFIX), M=$(RNAME)3,  DTYP=asynMCA, INP=@asyn($(PORT) 2),  PREC=3, CHANS=$(MAX_CHANS)")
#dbLoadRecords("$(MCA)/db/simple_mca.db", "P=$(PREFIX), M=$(RNAME)4,  DTYP=asynMCA, INP=@asyn($(PORT) 3),  PREC=3, CHANS=$(MAX_CHANS)")
#dbLoadRecords("$(MCA)/db/simple_mca.db", "P=$(PREFIX), M=$(RNAME)5,  DTYP=asynMCA, INP=@asyn($(PORT) 4),  PREC=3, CHANS=$(MAX_CHANS)")
#dbLoadRecords("$(MCA)/db/simple_mca.db", "P=$(PREFIX), M=$(RNAME)6,  DTYP=asynMCA, INP=@asyn($(PORT) 5),  PREC=3, CHANS=$(MAX_CHANS)")
#dbLoadRecords("$(MCA)/db/simple_mca.db", "P=$(PREFIX), M=$(RNAME)7,  DTYP=asynMCA, INP=@asyn($(PORT) 6),  PREC=3, CHANS=$(MAX_CHANS)")
#dbLoadRecords("$(MCA)/db/simple_mca.db", "P=$(PREFIX), M=$(RNAME)8,  DTYP=asynMCA, INP=@asyn($(PORT) 7),  PREC=3, CHANS=$(MAX_CHANS)")
#dbLoadRecords("$(MCA)/db/simple_mca.db", "P=$(PREFIX), M=$(RNAME)9,  DTYP=asynMCA, INP=@asyn($(PORT) 8),  PREC=3, CHANS=$(MAX_CHANS)")
#dbLoadRecords("$(MCA)/db/simple_mca.db", "P=$(PREFIX), M=$(RNAME)10, DTYP=asynMCA, INP=@asyn($(PORT) 9),  PREC=3, CHANS=$(MAX_CHANS)")
#dbLoadRecords("$(MCA)/db/simple_mca.db", "P=$(PREFIX), M=$(RNAME)11, DTYP=asynMCA, INP=@asyn($(PORT) 10), PREC=3, CHANS=$(MAX_CHANS)")
#dbLoadRecords("$(MCA)/db/simple_mca.db", "P=$(PREFIX), M=$(RNAME)12, DTYP=asynMCA, INP=@asyn($(PORT) 11), PREC=3, CHANS=$(MAX_CHANS)")
#dbLoadRecords("$(MCA)/db/simple_mca.db", "P=$(PREFIX), M=$(RNAME)13, DTYP=asynMCA, INP=@asyn($(PORT) 12), PREC=3, CHANS=$(MAX_CHANS)")
#dbLoadRecords("$(MCA)/db/simple_mca.db", "P=$(PREFIX), M=$(RNAME)14, DTYP=asynMCA, INP=@asyn($(PORT) 13), PREC=3, CHANS=$(MAX_CHANS)")
#dbLoadRecords("$(MCA)/db/simple_mca.db", "P=$(PREFIX), M=$(RNAME)15, DTYP=asynMCA, INP=@asyn($(PORT) 14), PREC=3, CHANS=$(MAX_CHANS)")
#dbLoadRecords("$(MCA)/db/simple_mca.db", "P=$(PREFIX), M=$(RNAME)16, DTYP=asynMCA, INP=@asyn($(PORT) 15), PREC=3, CHANS=$(MAX_CHANS)")
#dbLoadRecords("$(MCA)/db/simple_mca.db", "P=$(PREFIX), M=$(RNAME)17, DTYP=asynMCA, INP=@asyn($(PORT) 16), PREC=3, CHANS=$(MAX_CHANS)")
#dbLoadRecords("$(MCA)/db/simple_mca.db", "P=$(PREFIX), M=$(RNAME)18, DTYP=asynMCA, INP=@asyn($(PORT) 17), PREC=3, CHANS=$(MAX_CHANS)")
#dbLoadRecords("$(MCA)/db/simple_mca.db", "P=$(PREFIX), M=$(RNAME)19, DTYP=asynMCA, INP=@asyn($(PORT) 18), PREC=3, CHANS=$(MAX_CHANS)")
#dbLoadRecords("$(MCA)/db/simple_mca.db", "P=$(PREFIX), M=$(RNAME)20, DTYP=asynMCA, INP=@asyn($(PORT) 19), PREC=3, CHANS=$(MAX_CHANS)")
#dbLoadRecords("$(MCA)/db/simple_mca.db", "P=$(PREFIX), M=$(RNAME)21, DTYP=asynMCA, INP=@asyn($(PORT) 20), PREC=3, CHANS=$(MAX_CHANS)")
#dbLoadRecords("$(MCA)/db/simple_mca.db", "P=$(PREFIX), M=$(RNAME)22, DTYP=asynMCA, INP=@asyn($(PORT) 21), PREC=3, CHANS=$(MAX_CHANS)")
#dbLoadRecords("$(MCA)/db/simple_mca.db", "P=$(PREFIX), M=$(RNAME)23, DTYP=asynMCA, INP=@asyn($(PORT) 22), PREC=3, CHANS=$(MAX_CHANS)")
#dbLoadRecords("$(MCA)/db/simple_mca.db", "P=$(PREFIX), M=$(RNAME)24, DTYP=asynMCA, INP=@asyn($(PORT) 23), PREC=3, CHANS=$(MAX_CHANS)")
#dbLoadRecords("$(MCA)/db/simple_mca.db", "P=$(PREFIX), M=$(RNAME)25, DTYP=asynMCA, INP=@asyn($(PORT) 24), PREC=3, CHANS=$(MAX_CHANS)")
#dbLoadRecords("$(MCA)/db/simple_mca.db", "P=$(PREFIX), M=$(RNAME)26, DTYP=asynMCA, INP=@asyn($(PORT) 25), PREC=3, CHANS=$(MAX_CHANS)")
#dbLoadRecords("$(MCA)/db/simple_mca.db", "P=$(PREFIX), M=$(RNAME)27, DTYP=asynMCA, INP=@asyn($(PORT) 26), PREC=3, CHANS=$(MAX_CHANS)")
#dbLoadRecords("$(MCA)/db/simple_mca.db", "P=$(PREFIX), M=$(RNAME)28, DTYP=asynMCA, INP=@asyn($(PORT) 27), PREC=3, CHANS=$(MAX_CHANS)")
#dbLoadRecords("$(MCA)/db/simple_mca.db", "P=$(PREFIX), M=$(RNAME)29, DTYP=asynMCA, INP=@asyn($(PORT) 28), PREC=3, CHANS=$(MAX_CHANS)")
#dbLoadRecords("$(MCA)/db/simple_mca.db", "P=$(PREFIX), M=$(RNAME)30, DTYP=asynMCA, INP=@asyn($(PORT) 29), PREC=3, CHANS=$(MAX_CHANS)")
#dbLoadRecords("$(MCA)/db/simple_mca.db", "P=$(PREFIX), M=$(RNAME)31, DTYP=asynMCA, INP=@asyn($(PORT) 30), PREC=3, CHANS=$(MAX_CHANS)")
#dbLoadRecords("$(MCA)/db/simple_mca.db", "P=$(PREFIX), M=$(RNAME)32, DTYP=asynMCA, INP=@asyn($(PORT) 31), PREC=3, CHANS=$(MAX_CHANS)")

# This loads the waveform records
dbLoadRecords("$(MCA)/db/SIS38XX_waveform.template", "P=$(PREFIX), R=$(RNAME)1,  INP=@asyn($(PORT) 0),  CHANS=$(MAX_CHANS)")
dbLoadRecords("$(MCA)/db/SIS38XX_waveform.template", "P=$(PREFIX), R=$(RNAME)2,  INP=@asyn($(PORT) 1),  CHANS=$(MAX_CHANS)")
#dbLoadRecords("$(MCA)/db/SIS38XX_waveform.template", "P=$(PREFIX), R=$(RNAME)3,  INP=@asyn($(PORT) 2),  CHANS=$(MAX_CHANS)")
#dbLoadRecords("$(MCA)/db/SIS38XX_waveform.template", "P=$(PREFIX), R=$(RNAME)4,  INP=@asyn($(PORT) 3),  CHANS=$(MAX_CHANS)")
#dbLoadRecords("$(MCA)/db/SIS38XX_waveform.template", "P=$(PREFIX), R=$(RNAME)5,  INP=@asyn($(PORT) 4),  CHANS=$(MAX_CHANS)")
#dbLoadRecords("$(MCA)/db/SIS38XX_waveform.template", "P=$(PREFIX), R=$(RNAME)6,  INP=@asyn($(PORT) 5),  CHANS=$(MAX_CHANS)")
#dbLoadRecords("$(MCA)/db/SIS38XX_waveform.template", "P=$(PREFIX), R=$(RNAME)7,  INP=@asyn($(PORT) 6),  CHANS=$(MAX_CHANS)")
#dbLoadRecords("$(MCA)/db/SIS38XX_waveform.template", "P=$(PREFIX), R=$(RNAME)8,  INP=@asyn($(PORT) 7),  CHANS=$(MAX_CHANS)")
#dbLoadRecords("$(MCA)/db/SIS38XX_waveform.template", "P=$(PREFIX), R=$(RNAME)9,  INP=@asyn($(PORT) 8),  CHANS=$(MAX_CHANS)")
#dbLoadRecords("$(MCA)/db/SIS38XX_waveform.template", "P=$(PREFIX), R=$(RNAME)10, INP=@asyn($(PORT) 9),  CHANS=$(MAX_CHANS)")
#dbLoadRecords("$(MCA)/db/SIS38XX_waveform.template", "P=$(PREFIX), R=$(RNAME)11, INP=@asyn($(PORT) 10), CHANS=$(MAX_CHANS)")
#dbLoadRecords("$(MCA)/db/SIS38XX_waveform.template", "P=$(PREFIX), R=$(RNAME)12, INP=@asyn($(PORT) 11), CHANS=$(MAX_CHANS)")
#dbLoadRecords("$(MCA)/db/SIS38XX_waveform.template", "P=$(PREFIX), R=$(RNAME)13, INP=@asyn($(PORT) 12), CHANS=$(MAX_CHANS)")
#dbLoadRecords("$(MCA)/db/SIS38XX_waveform.template", "P=$(PREFIX), R=$(RNAME)14, INP=@asyn($(PORT) 13), CHANS=$(MAX_CHANS)")
#dbLoadRecords("$(MCA)/db/SIS38XX_waveform.template", "P=$(PREFIX), R=$(RNAME)15, INP=@asyn($(PORT) 14), CHANS=$(MAX_CHANS)")
#dbLoadRecords("$(MCA)/db/SIS38XX_waveform.template", "P=$(PREFIX), R=$(RNAME)16, INP=@asyn($(PORT) 15), CHANS=$(MAX_CHANS)")
#dbLoadRecords("$(MCA)/db/SIS38XX_waveform.template", "P=$(PREFIX), R=$(RNAME)17, INP=@asyn($(PORT) 16), CHANS=$(MAX_CHANS)")
#dbLoadRecords("$(MCA)/db/SIS38XX_waveform.template", "P=$(PREFIX), R=$(RNAME)18, INP=@asyn($(PORT) 17), CHANS=$(MAX_CHANS)")
#dbLoadRecords("$(MCA)/db/SIS38XX_waveform.template", "P=$(PREFIX), R=$(RNAME)19, INP=@asyn($(PORT) 18), CHANS=$(MAX_CHANS)")
#dbLoadRecords("$(MCA)/db/SIS38XX_waveform.template", "P=$(PREFIX), R=$(RNAME)20, INP=@asyn($(PORT) 19), CHANS=$(MAX_CHANS)")
#dbLoadRecords("$(MCA)/db/SIS38XX_waveform.template", "P=$(PREFIX), R=$(RNAME)21, INP=@asyn($(PORT) 20), CHANS=$(MAX_CHANS)")
#dbLoadRecords("$(MCA)/db/SIS38XX_waveform.template", "P=$(PREFIX), R=$(RNAME)22, INP=@asyn($(PORT) 21), CHANS=$(MAX_CHANS)")
#dbLoadRecords("$(MCA)/db/SIS38XX_waveform.template", "P=$(PREFIX), R=$(RNAME)23, INP=@asyn($(PORT) 22), CHANS=$(MAX_CHANS)")
#dbLoadRecords("$(MCA)/db/SIS38XX_waveform.template", "P=$(PREFIX), R=$(RNAME)24, INP=@asyn($(PORT) 23), CHANS=$(MAX_CHANS)")
#dbLoadRecords("$(MCA)/db/SIS38XX_waveform.template", "P=$(PREFIX), R=$(RNAME)25, INP=@asyn($(PORT) 24), CHANS=$(MAX_CHANS)")
#dbLoadRecords("$(MCA)/db/SIS38XX_waveform.template", "P=$(PREFIX), R=$(RNAME)26, INP=@asyn($(PORT) 25), CHANS=$(MAX_CHANS)")
#dbLoadRecords("$(MCA)/db/SIS38XX_waveform.template", "P=$(PREFIX), R=$(RNAME)27, INP=@asyn($(PORT) 26), CHANS=$(MAX_CHANS)")
#dbLoadRecords("$(MCA)/db/SIS38XX_waveform.template", "P=$(PREFIX), R=$(RNAME)28, INP=@asyn($(PORT) 27), CHANS=$(MAX_CHANS)")
#dbLoadRecords("$(MCA)/db/SIS38XX_waveform.template", "P=$(PREFIX), R=$(RNAME)29, INP=@asyn($(PORT) 28), CHANS=$(MAX_CHANS)")
#dbLoadRecords("$(MCA)/db/SIS38XX_waveform.template", "P=$(PREFIX), R=$(RNAME)30, INP=@asyn($(PORT) 20), CHANS=$(MAX_CHANS)")
#dbLoadRecords("$(MCA)/db/SIS38XX_waveform.template", "P=$(PREFIX), R=$(RNAME)31, INP=@asyn($(PORT) 30), CHANS=$(MAX_CHANS)")
#dbLoadRecords("$(MCA)/db/SIS38XX_waveform.template", "P=$(PREFIX), R=$(RNAME)32, INP=@asyn($(PORT) 31), CHANS=$(MAX_CHANS)")

asynSetTraceIOMask($(PORT),0,2)
#asynSetTraceMask("$(PORT)",0,0xff)

# Exit iocsh
exit
