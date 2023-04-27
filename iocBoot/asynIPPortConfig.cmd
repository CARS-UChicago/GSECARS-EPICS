drvAsynIPPortConfigure($(PORT), $(IPADDR), 0, 0, 0)
asynOctetSetInputEos($(PORT),  0, "$(IEOS)")
asynOctetSetOutputEos($(PORT), 0, "$(OEOS)")
