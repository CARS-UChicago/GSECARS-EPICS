<envPaths

errlogInit(20000)

dbLoadDatabase("$(AREA_DETECTOR)/dbd/prosilicaApp.dbd")

prosilicaApp_registerRecordDeviceDriver(pdbbase) 

prosilicaConfig("PS1", 50110, 50, 200000000)
asynSetTraceIOMask("PS1",0,2)
#asynSetTraceMask("PS1",0,255)
dbLoadRecords("$(AREA_DETECTOR)/ADApp/Db/ADBase.template",   "P=13BMDPS1:,R=cam1:,PORT=PS1,ADDR=0,TIMEOUT=1")
dbLoadRecords("$(AREA_DETECTOR)/ADApp/Db/NDFile.template",   "P=13BMDPS1:,R=cam1:,PORT=PS1,ADDR=0,TIMEOUT=1")
dbLoadRecords("$(AREA_DETECTOR)/ADApp/Db/prosilica.template","P=13BMDPS1:,R=cam1:,PORT=PS1,ADDR=0,TIMEOUT=1")

# Create a standard arrays plugin, set it to get data from first Prosilica driver.
NDStdArraysConfigure("PS1Image", 5, 0, "PS1", 0, -1)
dbLoadRecords("$(AREA_DETECTOR)/ADApp/Db/NDPluginBase.template","P=13BMDPS1:,R=image1:,PORT=PS1Image,ADDR=0,TIMEOUT=1,NDARRAY_PORT=PS1,NDARRAY_ADDR=0")
dbLoadRecords("$(AREA_DETECTOR)/ADApp/Db/NDStdArrays.template", "P=13BMDPS1:,R=image1:,PORT=PS1Image,ADDR=0,TIMEOUT=1,TYPE=Int8,SIZE=8,FTVL=UCHAR,NELEMENTS=4177920")
# Load the database to use with Stephen Mudie's IDL code
#dbLoadRecords("$(AREA_DETECTOR)/ADApp/Db/EPICS_AD_Viewer.template", "P=13BMDPS1:, R=image1:")

# Create a netCDF file saving plugin
NDFileNetCDFConfigure("PS1FileNetCDF", 5, 0, "PS1", 0)
dbLoadRecords("$(AREA_DETECTOR)/ADApp/Db/NDPluginBase.template","P=13BMDPS1:,R=netCDF1:,PORT=PS1FileNetCDF,ADDR=0,TIMEOUT=1,NDARRAY_PORT=PS1,NDARRAY_ADDR=0")
dbLoadRecords("$(AREA_DETECTOR)/ADApp/Db/NDFile.template",      "P=13BMDPS1:,R=netCDF1:,PORT=PS1FileNetCDF,ADDR=0,TIMEOUT=1")
dbLoadRecords("$(AREA_DETECTOR)/ADApp/Db/NDFileNetCDF.template","P=13BMDPS1:,R=netCDF1:,PORT=PS1FileNetCDF,ADDR=0,TIMEOUT=1")

# Create a TIFF file saving plugin
NDFileTIFFConfigure("PS1FileTIFF", 5, 0, "PS1", 0)
dbLoadRecords("$(AREA_DETECTOR)/ADApp/Db/NDPluginBase.template","P=13BMDPS1:,R=TIFF1:,PORT=PS1FileTIFF,ADDR=0,TIMEOUT=1,NDARRAY_PORT=PS1,NDARRAY_ADDR=0")
dbLoadRecords("$(AREA_DETECTOR)/ADApp/Db/NDFile.template",      "P=13BMDPS1:,R=TIFF1:,PORT=PS1FileTIFF,ADDR=0,TIMEOUT=1")
dbLoadRecords("$(AREA_DETECTOR)/ADApp/Db/NDFileTIFF.template",  "P=13BMDPS1:,R=TIFF1:,PORT=PS1FileTIFF,ADDR=0,TIMEOUT=1")

# Create a JPEG file saving plugin
NDFileJPEGConfigure("PS1FileJPEG", 5, 0, "PS1", 0)
dbLoadRecords("$(AREA_DETECTOR)/ADApp/Db/NDPluginBase.template","P=13BMDPS1:,R=JPEG1:,PORT=PS1FileJPEG,ADDR=0,TIMEOUT=1,NDARRAY_PORT=PS1,NDARRAY_ADDR=0")
dbLoadRecords("$(AREA_DETECTOR)/ADApp/Db/NDFile.template",      "P=13BMDPS1:,R=JPEG1:,PORT=PS1FileJPEG,ADDR=0,TIMEOUT=1")
dbLoadRecords("$(AREA_DETECTOR)/ADApp/Db/NDFileJPEG.template",  "P=13BMDPS1:,R=JPEG1:,PORT=PS1FileJPEG,ADDR=0,TIMEOUT=1")

# Create an ROI plugin
NDROIConfigure("PS1ROI", 5, 0, "PS1", 0, 10, 20, -1)
dbLoadRecords("$(AREA_DETECTOR)/ADApp/Db/NDPluginBase.template","P=13BMDPS1:,R=ROI1:,  PORT=PS1ROI,ADDR=0,TIMEOUT=1,NDARRAY_PORT=PS1,NDARRAY_ADDR=0")
dbLoadRecords("$(AREA_DETECTOR)/ADApp/Db/NDROI.template",       "P=13BMDPS1:,R=ROI1:,  PORT=PS1ROI,ADDR=0,TIMEOUT=1")
dbLoadRecords("$(AREA_DETECTOR)/ADApp/Db/NDROIN.template",      "P=13BMDPS1:,R=ROI1:0:,PORT=PS1ROI,ADDR=0,TIMEOUT=1,HIST_SIZE=256")
dbLoadRecords("$(AREA_DETECTOR)/ADApp/Db/NDROIN.template",      "P=13BMDPS1:,R=ROI1:1:,PORT=PS1ROI,ADDR=1,TIMEOUT=1,HIST_SIZE=256")
dbLoadRecords("$(AREA_DETECTOR)/ADApp/Db/NDROIN.template",      "P=13BMDPS1:,R=ROI1:2:,PORT=PS1ROI,ADDR=2,TIMEOUT=1,HIST_SIZE=256")
dbLoadRecords("$(AREA_DETECTOR)/ADApp/Db/NDROIN.template",      "P=13BMDPS1:,R=ROI1:3:,PORT=PS1ROI,ADDR=3,TIMEOUT=1,HIST_SIZE=256")

# Create 2 color conversion plugins
NDColorConvertConfigure("PS1CC1", 5, 0, "PS1", 0, 20, -1)
dbLoadRecords("$(AREA_DETECTOR)/ADApp/Db/NDPluginBase.template","   P=13BMDPS1:,R=CC1:,  PORT=PS1CC1,ADDR=0,TIMEOUT=1,NDARRAY_PORT=PS1,NDARRAY_ADDR=0")
dbLoadRecords("$(AREA_DETECTOR)/ADApp/Db/NDColorConvert.template", "P=13BMDPS1:,R=CC1:,  PORT=PS1CC1,ADDR=0,TIMEOUT=1")
NDColorConvertConfigure("PS1CC2", 5, 0, "PS1", 0, 20, -1)
dbLoadRecords("$(AREA_DETECTOR)/ADApp/Db/NDPluginBase.template","   P=13BMDPS1:,R=CC2:,  PORT=PS1CC2,ADDR=0,TIMEOUT=1,NDARRAY_PORT=PS1CC1,NDARRAY_ADDR=0")
dbLoadRecords("$(AREA_DETECTOR)/ADApp/Db/NDColorConvert.template", "P=13BMDPS1:,R=CC2:,  PORT=PS1CC2,ADDR=0,TIMEOUT=1")


#asynSetTraceMask("PS1",0,255)

set_requestfile_path("./")
set_savefile_path("./autosave")
set_requestfile_path("$(AREA_DETECTOR)/ADApp/Db")
set_pass0_restoreFile("auto_settings.sav")
set_pass1_restoreFile("auto_settings.sav")
save_restoreSet_status_prefix("13BMDPS1:")
dbLoadRecords("$(AUTOSAVE)/asApp/Db/save_restoreStatus.db", "P=13BMDPS1:")

iocInit()

#asynSetTraceMask("PS1",0,1)

# save things every thirty seconds
create_monitor_set("auto_settings.req", 30,"P=13BMDPS1:,D=cam1:")
