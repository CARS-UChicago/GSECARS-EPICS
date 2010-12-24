< envPaths
# Must define this manually for now, because ccd and areaDetector have a conflict on libmarCCD.so
epicsEnvSet("AREA_DETECTOR","/corvette/home/epics/devel/areaDetector/1-3")
errlogInit(20000)

###
# Load the EPICS database file
dbLoadDatabase("$(AREA_DETECTOR)/dbd/pilatusDetectorApp.dbd")
pilatusDetectorApp_registerRecordDeviceDriver(pdbbase) 

###
# Create the asyn port to talk to the Pilatus on port 41234.
drvAsynIPPortConfigure("camserver","GSE-PIL1:41234")
# Set the input and output terminators.
asynOctetSetInputEos("camserver", 0, "\030")
asynOctetSetOutputEos("camserver", 0, "\n")

pilatusDetectorConfig("Pil", "camserver", 487, 195, 50, 200000000)
dbLoadRecords("$(AREA_DETECTOR)/ADApp/Db/ADBase.template", "P=GSE-PIL1:,R=cam1:,PORT=Pil,ADDR=0,TIMEOUT=1")
dbLoadRecords("$(AREA_DETECTOR)/ADApp/Db/pilatus.template","P=GSE-PIL1:,R=cam1:,PORT=Pil,ADDR=0,TIMEOUT=1,CAMSERVER_PORT=camserver")
dbLoadRecords("$(AREA_DETECTOR)/ADApp/Db/NDFile.template", "P=GSE-PIL1:,R=cam1:,PORT=Pil,ADDR=0,TIMEOUT=1")

# Create a standard arrays plugin
drvNDStdArraysConfigure("PilImage", 5, 0, "Pil", 0, -1)
dbLoadRecords("$(AREA_DETECTOR)/ADApp/Db/NDPluginBase.template","P=GSE-PIL1:,R=image1:,PORT=PilImage,ADDR=0,TIMEOUT=1,NDARRAY_PORT=Pil,NDARRAY_ADDR=0")
dbLoadRecords("$(AREA_DETECTOR)/ADApp/Db/NDStdArrays.template", "P=GSE-PIL1:,R=image1:,PORT=PilImage,ADDR=0,TIMEOUT=1,SIZE=32,FTVL=LONG,NELEMENTS=94965")

# Create an ROI plugin
drvNDROIConfigure("PilROI", 5, 0, "Pil", 0, 10, 20, -1)
dbLoadRecords("$(AREA_DETECTOR)/ADApp/Db/NDPluginBase.template","P=GSE-PIL1:,R=ROI1:,  PORT=PilROI,ADDR=0,TIMEOUT=1,NDARRAY_PORT=Pil,NDARRAY_ADDR=0")
dbLoadRecords("$(AREA_DETECTOR)/ADApp/Db/NDROI.template",       "P=GSE-PIL1:,R=ROI1:,  PORT=PilROI,ADDR=0,TIMEOUT=1")
dbLoadRecords("$(AREA_DETECTOR)/ADApp/Db/NDROIN.template",      "P=GSE-PIL1:,R=ROI1:0:,PORT=PilROI,ADDR=0,TIMEOUT=1,HIST_SIZE=256")
dbLoadRecords("$(AREA_DETECTOR)/ADApp/Db/NDROIN.template",      "P=GSE-PIL1:,R=ROI1:1:,PORT=PilROI,ADDR=1,TIMEOUT=1,HIST_SIZE=256")
dbLoadRecords("$(AREA_DETECTOR)/ADApp/Db/NDROIN.template",      "P=GSE-PIL1:,R=ROI1:2:,PORT=PilROI,ADDR=2,TIMEOUT=1,HIST_SIZE=256")
dbLoadRecords("$(AREA_DETECTOR)/ADApp/Db/NDROIN.template",      "P=GSE-PIL1:,R=ROI1:3:,PORT=PilROI,ADDR=3,TIMEOUT=1,HIST_SIZE=256")
dbLoadRecords("$(AREA_DETECTOR)/ADApp/Db/NDROIN.template",      "P=GSE-PIL1:,R=ROI1:4:,PORT=PilROI,ADDR=3,TIMEOUT=1,HIST_SIZE=256")
dbLoadRecords("$(AREA_DETECTOR)/ADApp/Db/NDROIN.template",      "P=GSE-PIL1:,R=ROI1:5:,PORT=PilROI,ADDR=3,TIMEOUT=1,HIST_SIZE=256")
dbLoadRecords("$(AREA_DETECTOR)/ADApp/Db/NDROIN.template",      "P=GSE-PIL1:,R=ROI1:6:,PORT=PilROI,ADDR=3,TIMEOUT=1,HIST_SIZE=256")
dbLoadRecords("$(AREA_DETECTOR)/ADApp/Db/NDROIN.template",      "P=GSE-PIL1:,R=ROI1:7:,PORT=PilROI,ADDR=3,TIMEOUT=1,HIST_SIZE=256")

# Create "fastSweep" drivers for the MCA record to do on-the-fly scanning of ROI data
initFastSweep("PilSweepTotal", "PilROI", 8, 2048, "TOTAL_ARRAY", "CALLBACK_PERIOD")
initFastSweep("PilSweepNet", "PilROI", 8, 2048, "NET_ARRAY", "CALLBACK_PERIOD")

# Load MCA records for the fast sweep drivers
dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=GSE-PIL1:,M=ROI1:0:TotalArray,DTYP=asynMCA,NCHAN=2048,INP=@asyn(PilSweepTotal 0)")
dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=GSE-PIL1:,M=ROI1:1:TotalArray,DTYP=asynMCA,NCHAN=2048,INP=@asyn(PilSweepTotal 1)")
dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=GSE-PIL1:,M=ROI1:2:TotalArray,DTYP=asynMCA,NCHAN=2048,INP=@asyn(PilSweepTotal 2)")
dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=GSE-PIL1:,M=ROI1:3:TotalArray,DTYP=asynMCA,NCHAN=2048,INP=@asyn(PilSweepTotal 3)")
dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=GSE-PIL1:,M=ROI1:4:TotalArray,DTYP=asynMCA,NCHAN=2048,INP=@asyn(PilSweepTotal 4)")
dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=GSE-PIL1:,M=ROI1:5:TotalArray,DTYP=asynMCA,NCHAN=2048,INP=@asyn(PilSweepTotal 5)")
dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=GSE-PIL1:,M=ROI1:6:TotalArray,DTYP=asynMCA,NCHAN=2048,INP=@asyn(PilSweepTotal 6)")
dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=GSE-PIL1:,M=ROI1:7:TotalArray,DTYP=asynMCA,NCHAN=2048,INP=@asyn(PilSweepTotal 7)")

dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=GSE-PIL1:,M=ROI1:0:NetArray,DTYP=asynMCA,NCHAN=2048,INP=@asyn(PilSweepNet 0)")
dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=GSE-PIL1:,M=ROI1:1:NetArray,DTYP=asynMCA,NCHAN=2048,INP=@asyn(PilSweepNet 1)")
dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=GSE-PIL1:,M=ROI1:2:NetArray,DTYP=asynMCA,NCHAN=2048,INP=@asyn(PilSweepNet 2)")
dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=GSE-PIL1:,M=ROI1:3:NetArray,DTYP=asynMCA,NCHAN=2048,INP=@asyn(PilSweepNet 3)")
dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=GSE-PIL1:,M=ROI1:4:NetArray,DTYP=asynMCA,NCHAN=2048,INP=@asyn(PilSweepNet 4)")
dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=GSE-PIL1:,M=ROI1:5:NetArray,DTYP=asynMCA,NCHAN=2048,INP=@asyn(PilSweepNet 5)")
dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=GSE-PIL1:,M=ROI1:6:NetArray,DTYP=asynMCA,NCHAN=2048,INP=@asyn(PilSweepNet 6)")
dbLoadRecords("$(MCA)/mcaApp/Db/mca.db", "P=GSE-PIL1:,M=ROI1:7:NetArray,DTYP=asynMCA,NCHAN=2048,INP=@asyn(PilSweepNet 7)")


#asynSetTraceMask("Pil",0,255)
#asynSetTraceMask("PilROI",0,3)
#asynSetTraceIOMask("PilROI",0,4)

# Load scan records for scanning energy threshold
dbLoadRecords("$(SSCAN)/sscanApp/Db/scan.db", "P=GSE-PIL1:cam1:,MAXPTS1=2000,MAXPTS2=200,MAXPTS3=20,MAXPTS4=10,MAXPTSH=10")

###
# Specify where save files should be
set_savefile_path(".", "autosave")

###
# Specify directories in which to to search for included request files
set_requestfile_path("./")
set_savefile_path("./autosave")
set_requestfile_path("$(AREA_DETECTOR)/ADApp/Db")
set_requestfile_path("$(SSCAN)/sscanApp/Db")
set_pass0_restoreFile("auto_settings.sav")
set_pass1_restoreFile("auto_settings.sav")
save_restoreSet_status_prefix("GSE-PIL1:")

###
# Load the save/restore status PVs
dbLoadRecords("$(AUTOSAVE)/asApp/Db/save_restoreStatus.db", "P=GSE-PIL1:")

# Start the IOC
iocInit

###
# Save settings every thirty seconds
create_monitor_set("auto_settings.req", 30, "P=GSE-PIL1:")

