# Allocate 96MB of memory so we load everything else into low memory
mem = malloc(1024*1024*96)
< cdCommands
< ../nfsCommandsGSE
cd topbin
ld < CARSApp.munch
cd startup
sscanRecordDebug=20
dbLoadDatabase("$(CARS)/dbd/CARSVX.dbd")
CARSVX_registerRecordDeviceDriver(pdbbase)
dbLoadRecords("$(STD)/stdApp/Db/scan.db.CA", "P=13LAB:,MAXPTS1=2000,MAXPTS2=200,MAXPTS3=20,MAXPTS4=10,MAXPTSH=10")
iocInit
free(mem)
