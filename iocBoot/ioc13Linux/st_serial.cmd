errlogInit(5000)
< envPaths
# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in this build from CARS
dbLoadDatabase("../../dbd/CARS.dbd")
CARS_registerRecordDeviceDriver(pdbbase)

routerInit
localMessageRouterStart(0)

# Set up 2 serial ports
#initTtyPort("serial1", "/dev/ttyS0", 9600, "N", 1, 8, "N", 1000)
#initTtyPort("serial1", "/dev/ttyS0", 115200, "N", 1, 8, "N", 1000)
initTtyPort("serial2", "/dev/ttyS1", 19200, "N", 1, 8, "N", 1000)
#initSerialServer("serial1", "serial1", 1000, 20, "")
#initSerialServer("serial2", "serial2", 1000, 20, "")

initInetPort("moxa1","164.54.160.50",4001,1000) 
initSerialServer("serial3","moxa1",1000,20,"") 
  
dbLoadRecords("$(CARS)/CARSApp/Db/generic_serial.db", "P=13Linux:,R=ser3,C=0,SERVER=serial3") 

dbLoadRecords("$(CARS)/CARSApp/Db/spherosyn.db", "P=13Linux:, E=E1, C=0, SERVER=serial3")

set_pass0_restoreFile("serial_settings.sav")
set_pass0_restoreFile("serial_positons.sav")
set_pass1_restoreFile("serial_settings.sav")
iocInit

### Start up the autosave task and tell it what to do.
# The task is actually named "save_restore".
# (See also, 'initHooks' above, which is the means by which the values that
# will be saved by the task we're starting here are going to be restored.
#
# Load the list of search directories for request files
< ../requestFileCommands

# save positions every five seconds
create_monitor_set("serial_positions.req", 5)
# save other things every thirty seconds
create_monitor_set("serial_settings.req", 30)
