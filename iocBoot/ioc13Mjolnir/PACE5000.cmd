drvAsynIPPortConfigure("PACE5000", "gse-pace5000-5:5025", 0, 0, 0)
asynOctetSetInputEos ("PACE5000",0,"\r\n")
asynOctetSetOutputEos("PACE5000",0,"\r\n")

dbLoadRecords("$(IP)/db/PACE5000.db", "P=$(PACE_PREFIX),R=PC1:,PORT=PACE5000")
