# Example vxWorks iocsh startup file for SIS3801

epicsEnvSet("PREFIX",                   "13BMC:SIS1:")
epicsEnvSet("RNAME",                    "mca")
epicsEnvSet("MAX_SIGNALS",              "8")
epicsEnvSet("MAX_CHANS",                "2048")
epicsEnvSet("PORT",                     "SIS3801/1")
# For MCA records FIELD=READ, for waveform records FIELD=PROC
epicsEnvSet("FIELD",                    "READ")

#drvSIS3801Config("Port name",
#                  baseAddress,
#                  interruptVector, 
#                  int interruptLevel,
#                  channels,
#                  signals)
drvSIS3801Config($(PORT), 0x90000000, 220, 6, $(MAX_CHANS), $(MAX_SIGNALS))

# This loads the scaler record and supporting records
dbLoadRecords("$(STD)/db/scaler32.db", "P=13BMC:, S=scaler1, DTYP=Asyn Scaler, OUT=@asyn($(PORT)), FREQ=25000000")

# This database provides the support for the MCS functions
dbLoadRecords("$(MCA)/mcaApp/Db/SIS38XX.template", "P=$(PREFIX), PORT=$(PORT), SCALER=$(PREFIX)scaler1")

# Load either MCA or waveform records below
# The number of records loaded must be the same as MAX_SIGNALS defined above

# Load the MCA records
dbLoadRecords("$(MCA)/mcaApp/Db/simple_mca.db", "P=$(PREFIX), M=$(RNAME)1,  DTYP=asynMCA, INP=@asyn($(PORT) 0),  PREC=3, CHANS=$(MAX_CHANS)")
dbLoadRecords("$(MCA)/mcaApp/Db/simple_mca.db", "P=$(PREFIX), M=$(RNAME)2,  DTYP=asynMCA, INP=@asyn($(PORT) 1),  PREC=3, CHANS=$(MAX_CHANS)")
dbLoadRecords("$(MCA)/mcaApp/Db/simple_mca.db", "P=$(PREFIX), M=$(RNAME)3,  DTYP=asynMCA, INP=@asyn($(PORT) 2),  PREC=3, CHANS=$(MAX_CHANS)")
dbLoadRecords("$(MCA)/mcaApp/Db/simple_mca.db", "P=$(PREFIX), M=$(RNAME)4,  DTYP=asynMCA, INP=@asyn($(PORT) 3),  PREC=3, CHANS=$(MAX_CHANS)")
dbLoadRecords("$(MCA)/mcaApp/Db/simple_mca.db", "P=$(PREFIX), M=$(RNAME)5,  DTYP=asynMCA, INP=@asyn($(PORT) 4),  PREC=3, CHANS=$(MAX_CHANS)")
dbLoadRecords("$(MCA)/mcaApp/Db/simple_mca.db", "P=$(PREFIX), M=$(RNAME)6,  DTYP=asynMCA, INP=@asyn($(PORT) 5),  PREC=3, CHANS=$(MAX_CHANS)")
dbLoadRecords("$(MCA)/mcaApp/Db/simple_mca.db", "P=$(PREFIX), M=$(RNAME)7,  DTYP=asynMCA, INP=@asyn($(PORT) 6),  PREC=3, CHANS=$(MAX_CHANS)")
dbLoadRecords("$(MCA)/mcaApp/Db/simple_mca.db", "P=$(PREFIX), M=$(RNAME)8,  DTYP=asynMCA, INP=@asyn($(PORT) 7),  PREC=3, CHANS=$(MAX_CHANS)")

asynSetTraceIOMask($(PORT),0,4)
#asynSetTraceMask("$(PORT)",0,0x19)
