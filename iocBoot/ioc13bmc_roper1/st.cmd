< envPaths
errlogInit(20000)

dbLoadDatabase("$(AREA_DETECTOR)/dbd/roperApp.dbd")

roperApp_registerRecordDeviceDriver(pdbbase) 

roperConfig("ROPER1", 50, 200000000)
asynSetTraceIOMask("ROPER1",0,2)
#asynSetTraceMask("ROPER1",0,9)
dbLoadRecords("$(AREA_DETECTOR)/ADApp/Db/ADBase.template",   "P=13BMCRP1:,R=cam1:,PORT=ROPER1,ADDR=0,TIMEOUT=1")
dbLoadRecords("$(AREA_DETECTOR)/ADApp/Db/NDFile.template",   "P=13BMCRP1:,R=cam1:,PORT=ROPER1,ADDR=0,TIMEOUT=1")
dbLoadRecords("$(AREA_DETECTOR)/ADApp/Db/roper.template",    "P=13BMCRP1:,R=cam1:,PORT=ROPER1,ADDR=0,TIMEOUT=1")

# Create a standard arrays plugin, set it to get data from the Roper driver.
NDStdArraysConfigure("ROPER1Image", 5, 0, "ROPER1", 0, -1)
dbLoadRecords("$(AREA_DETECTOR)/ADApp/Db/NDPluginBase.template","P=13BMCRP1:,R=image1:,PORT=ROPER1Image,ADDR=0,TIMEOUT=1,NDARRAY_PORT=ROPER1,NDARRAY_ADDR=0")
dbLoadRecords("$(AREA_DETECTOR)/ADApp/Db/NDStdArrays.template", "P=13BMCRP1:,R=image1:,PORT=ROPER1Image,ADDR=0,TIMEOUT=1,TYPE=Int16,FTVL=SHORT,NELEMENTS=1500000")
# Load the database to use with Stephen Mudie's IDL code
dbLoadRecords("$(AREA_DETECTOR)/ADApp/Db/EPICS_AD_Viewer.template", "P=13BMCRP1:, R=image1:")

# Create a netCDF file saving plugin
NDFileNetCDFConfigure("ROPER1FileNetCDF", 450, 0, "ROPER1", 0)
dbLoadRecords("$(AREA_DETECTOR)/ADApp/Db/NDPluginBase.template","P=13BMCRP1:,R=netCDF1:,PORT=ROPER1FileNetCDF,ADDR=0,TIMEOUT=1,NDARRAY_PORT=ROPER1,NDARRAY_ADDR=0")
dbLoadRecords("$(AREA_DETECTOR)/ADApp/Db/NDFile.template",      "P=13BMCRP1:,R=netCDF1:,PORT=ROPER1FileNetCDF,ADDR=0,TIMEOUT=1")
dbLoadRecords("$(AREA_DETECTOR)/ADApp/Db/NDFileNetCDF.template","P=13BMCRP1:,R=netCDF1:,PORT=ROPER1FileNetCDF,ADDR=0,TIMEOUT=1")

# Create a TIFF file saving plugin
NDFileTIFFConfigure("ROPER1FileTIFF", 20, 0, "ROPER1", 0)
dbLoadRecords("$(AREA_DETECTOR)/ADApp/Db/NDPluginBase.template","P=13BMCRP1:,R=TIFF1:,PORT=ROPER1FileTIFF,ADDR=0,TIMEOUT=1,NDARRAY_PORT=ROPER1,NDARRAY_ADDR=0")
dbLoadRecords("$(AREA_DETECTOR)/ADApp/Db/NDFile.template",      "P=13BMCRP1:,R=TIFF1:,PORT=ROPER1FileTIFF,ADDR=0,TIMEOUT=1")
dbLoadRecords("$(AREA_DETECTOR)/ADApp/Db/NDFileTIFF.template",  "P=13BMCRP1:,R=TIFF1:,PORT=ROPER1FileTIFF,ADDR=0,TIMEOUT=1")

# Create a JPEG file saving plugin
NDFileJPEGConfigure("ROPER1FileJPEG", 20, 0, "ROPER1", 0)
dbLoadRecords("$(AREA_DETECTOR)/ADApp/Db/NDPluginBase.template","P=13BMCRP1:,R=JPEG1:,PORT=ROPER1FileJPEG,ADDR=0,TIMEOUT=1,NDARRAY_PORT=ROPER1,NDARRAY_ADDR=0")
dbLoadRecords("$(AREA_DETECTOR)/ADApp/Db/NDFile.template",      "P=13BMCRP1:,R=JPEG1:,PORT=ROPER1FileJPEG,ADDR=0,TIMEOUT=1")
dbLoadRecords("$(AREA_DETECTOR)/ADApp/Db/NDFileJPEG.template",  "P=13BMCRP1:,R=JPEG1:,PORT=ROPER1FileJPEG,ADDR=0,TIMEOUT=1")

# Create an ROI plugin
NDROIConfigure("ROPER1ROI", 5, 0, "ROPER1", 0, 10, 20, -1)
dbLoadRecords("$(AREA_DETECTOR)/ADApp/Db/NDPluginBase.template","P=13BMCRP1:,R=ROI1:,  PORT=ROPER1ROI,ADDR=0,TIMEOUT=1,NDARRAY_PORT=ROPER1,NDARRAY_ADDR=0")
dbLoadRecords("$(AREA_DETECTOR)/ADApp/Db/NDROI.template",       "P=13BMCRP1:,R=ROI1:,  PORT=ROPER1ROI,ADDR=0,TIMEOUT=1")
dbLoadRecords("$(AREA_DETECTOR)/ADApp/Db/NDROIN.template",      "P=13BMCRP1:,R=ROI1:0:,PORT=ROPER1ROI,ADDR=0,TIMEOUT=1,HIST_SIZE=256")
dbLoadRecords("$(AREA_DETECTOR)/ADApp/Db/NDROIN.template",      "P=13BMCRP1:,R=ROI1:1:,PORT=ROPER1ROI,ADDR=1,TIMEOUT=1,HIST_SIZE=256")
dbLoadRecords("$(AREA_DETECTOR)/ADApp/Db/NDROIN.template",      "P=13BMCRP1:,R=ROI1:2:,PORT=ROPER1ROI,ADDR=2,TIMEOUT=1,HIST_SIZE=256")
dbLoadRecords("$(AREA_DETECTOR)/ADApp/Db/NDROIN.template",      "P=13BMCRP1:,R=ROI1:3:,PORT=ROPER1ROI,ADDR=3,TIMEOUT=1,HIST_SIZE=256")

# Load scan records
dbLoadRecords("$(SSCAN)/sscanApp/Db/scan.db", "P=13BMCRP1:,MAXPTS1=2000,MAXPTS2=200,MAXPTS3=20,MAXPTS4=10,MAXPTSH=10")

set_requestfile_path("./")
set_savefile_path("./autosave")
set_requestfile_path("$(SSCAN)/sscanApp/Db")
set_requestfile_path("$(AREA_DETECTOR)/ADApp/Db")
set_pass0_restoreFile("auto_settings.sav")
set_pass1_restoreFile("auto_settings.sav")
save_restoreSet_status_prefix("13BMCRP1:")
dbLoadRecords("$(AUTOSAVE)/asApp/Db/save_restoreStatus.db", "P=13BMCRP1:")

iocInit()

# save things every thirty seconds
create_monitor_set("auto_settings.req", 30,"P=13BMCRP1:,D=cam1:")