< envPaths

### Register all support components
dbLoadDatabase("$(DXP)/dbd/dxp.dbd")
dxp_registerRecordDeviceDriver(pdbbase)

# Set EPICS_CA_MAX_ARRAY_BYTES large enough for the trace buffers
epicsEnvSet EPICS_CA_MAX_ARRAY_BYTES 100000

# On Linux execute the following command so that libusb uses /dev/bus/usb
# as the file system for the USB device.  
# On some Linux systems it uses /proc/bus/usb instead, but udev
# sets the permissions on /dev, not /proc.
epicsEnvSet USB_DEVFS_PATH /dev/bus/usb

# Initialize the XIA software
# Set logging level (1=ERROR, 2=WARNING, 3=XXX, 4=DEBUG)
xiaSetLogLevel(2)
# Edit saturn.ini to match your Saturn speed (20 or 40 MHz), 
# pre-amp type (reset or RC), and interface type (EPP, USB 1.0, USB 2.0)
xiaInit("saturn.ini")
xiaStartSystem

NDDxpConfig("DXP1", 1, 10, 42000000)
asynSetTraceIOMask("DXP1", 0, 2)
#asynSetTraceMask("DXP1", 0, 255)

dbLoadRecords("$(DXP)/db/dxpSystem.template",   "P=13Saturn1:, R=dxp1:,IO=@asyn(DXP1 0 1)")
dbLoadRecords("$(DXP)/db/dxpHighLevel.template","P=13Saturn1:, R=dxp1:,IO=@asyn(DXP1 0 1)")
dbLoadRecords("$(DXP)/db/dxpSaturn.template",   "P=13Saturn1:, R=dxp1:,IO=@asyn(DXP1 0 1)")
dbLoadRecords("$(DXP)/db/dxpLowLevel.template", "P=13Saturn1:, R=dxp1:,IO=@asyn(DXP1 0 1)")
dbLoadRecords("$(DXP)/db/dxpSCA_16.template",   "P=13Saturn1:, R=dxp1:,IO=@asyn(DXP1 0 1)")
dbLoadRecords("$(DXP)/db/mcaCallback.template", "P=13Saturn1:, R=mca1, IO=@asyn(DXP1 0 1)")
dbLoadRecords("$(MCA)/db/mca.db",               "P=13Saturn1:, M=mca1, DTYP=asynMCA,INP=@asyn(DXP1 0),NCHAN=2048")

# Template to copy MCA ROIs to DXP SCAs
dbLoadTemplate("roi_to_sca.substitutions")

# Setup for save_restore
< ../save_restore_IOCSH.cmd
save_restoreSet_status_prefix("13Saturn1:")
dbLoadRecords("$(AUTOSAVE)/db/save_restoreStatus.db", "P=13Saturn1:")

### Scan-support software
# crate-resident scan.  This executes 1D, 2D, 3D, and 4D scans, and caches
# 1D data, but it doesn't store anything to disk.  (See 'saveData' below for that.)
dbLoadRecords("$(SSCAN)/db/scan.db","P=13Saturn1:,MAXPTS1=2000,MAXPTS2=1000,MAXPTS3=10,MAXPTS4=10,MAXPTSH=2048")

iocInit()

### Start up the autosave task and tell it what to do.
# Save settings every thirty seconds
create_monitor_set("auto_settings.req", 30, P=13Saturn1:)

### Start the saveData task.
saveData_Init("saveData.req", "P=13Saturn1:")

