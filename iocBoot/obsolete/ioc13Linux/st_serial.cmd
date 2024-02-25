errlogInit(5000)
< envPaths
# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in this build from CARS
dbLoadDatabase("../../dbd/CARSLinux.dbd")
CARSLinux_registerRecordDeviceDriver(pdbbase)

# Set up 2 local serial ports
drvAsynSerialPortConfigure("serial1", "/dev/ttyS0", 0, 0, 0)
drvAsynSerialPortConfigure("serial2", "/dev/ttyS1", 0, 0, 0)
# Set up last 2 ports on Moxa box
#drvAsynIPPortConfigure("serial3", "164.54.160.50:4003", 0, 0, 0)
#drvAsynIPPortConfigure("serial4", "164.54.160.50:4004", 0, 0, 0)

# Make these ports available from the iocsh command line
asynOctetConnect("serial1", "serial1", 0)
asynOctetSetInputEos("serial1", 0, "\r")
asynOctetSetOutputEos("serial1", 0, "\r")
asynOctetConnect("serial2", "serial2", 0)
asynOctetSetInputEos("serial2", 0, "\r")
asynOctetSetOutputEos("serial2", 0, "\r")
#asynOctetConnect("serial3", "serial3", 0)
#asynOctetConnect("serial4", "serial4", 0)

# Load asyn records on each of these ports
dbLoadTemplate("asynRecord.template") 

set_pass0_restoreFile("serial_settings.sav")
set_pass1_restoreFile("serial_settings.sav")
iocInit

### Start up the autosave task and tell it what to do.
# The task is actually named "save_restore".
# (See also, 'initHooks' above, which is the means by which the values that
# will be saved by the task we're starting here are going to be restored.
#
# Load the list of search directories for request files
< ../requestFileCommands

# save other things every thirty seconds
create_monitor_set("serial_settings.req", 30)
