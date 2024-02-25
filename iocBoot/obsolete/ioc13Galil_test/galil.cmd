## uncomment to see every command sent to galil
#epicsEnvSet("GALIL_DEBUG_FILE", "galil_debug.txt")

epicsEnvSet(PORT, Galil)
epicsEnvSet(TRAJ_POINTS 1000)

#Load motor records for real and coordinate system (CS) motors
dbLoadTemplate("motors.template")

#Load DMC controller features (eg.  Limit switch type, home switch type, output compare, message consoles)
dbLoadRecords("$(GALIL)/db/galil_dmc_ctrl.template", "P=$(PREFIX), PORT=$(PORT), SCAN=Passive, DEFAULT_HOMETYPE=1, DEFAULT_LIMITTYPE=1, PREC=5")

#Load digital IO databases
dbLoadTemplate("$(GALIL)/db/galil_dmc_digital_ports.substitutions", "P=$(PREFIX), PORT=$(PORT)")

#Load analog IO databases
dbLoadTemplate("$(GALIL)/db/galil_dmc_analog_ports.substitutions", "P=$(PREFIX), PORT=$(PORT), PREC=3")

#Load user defined array support
dbLoadTemplate("$(GALIL)/db/galil_user_array.substitutions", "P=DMC01:, PORT=$(PORT), NELM=1000")

#Load profiles
dbLoadRecords("$(MOTOR)/db/profileMoveController.template",       "P=$(PREFIX), R=Prof1:, PORT=$(PORT), NAXES=8, NPOINTS=$(TRAJ_POINTS), NPULSES=$(TRAJ_POINTS), TIMEOUT=1")
dbLoadRecords("$(GALIL)/db/galil_profileMoveController.template", "P=$(PREFIX), R=Prof1:, PORT=$(PORT), TIMEOUT=1")
dbLoadTemplate("profileMoveAxis.substitutions",                   "P=$(PREFIX), R=Prof1:, PORT=$(PORT), NPOINTS=1$(TRAJ_POINTS), NREADBACK=$(TRAJ_POINTS)")

# GalilCreateController command parameters are:
#
# 1. Const char *portName 	- The name of the asyn port that will be created for this controller
# 2. Const char *address 	- The address of the controller
# 3. double updatePeriod	- The time in ms between datarecords 2ms min, 200ms max.  Async if controller + bus supports it, otherwise is polled/synchronous.
#                       	- Recommend 50ms or less for ethernet
#                       	- Specify negative updatePeriod < 0 to force synchronous tcp poll period.  Otherwise will try async udp mode first

# Create a Galil controller
GalilCreateController("Galil", "10.54.160.67", 8)

# GalilCreateAxis command parameters are:
#
# 1. char *portName Asyn port for controller
# 2. char  axis A-H,
# 3. int   limits_as_home (0 off 1 on), 
# 4. char  *Motor interlock digital port number 1 to 8 eg. "1,2,4".  1st 8 bits are supported
# 5. int   Interlock switch type 0 normally open, all other values is normally closed interlock switch type

# Create the axis
GalilCreateAxis("Galil", "A", 1, "", 1)
GalilCreateAxis("Galil", "B", 1, "", 1)
GalilCreateAxis("Galil", "C", 1, "", 1)
GalilCreateAxis("Galil", "D", 1, "", 1)
GalilCreateAxis("Galil", "E", 1, "", 1)
GalilCreateAxis("Galil", "F", 1, "", 1)
GalilCreateAxis("Galil", "G", 1, "", 1)
GalilCreateAxis("Galil", "H", 1, "", 1)

# GalilCreateCSAxes command parameters are:
#
# 1. char *portName Asyn port for controller

#Create all CS axes (ie. I-P axis)
GalilCreateCSAxes("Galil")

# GalilStartController command parameters are:
#
# 1. char *portName Asyn port for controller
# 2. char *code file(s) to deliver to the controller we are starting. "" = use generated code (recommended)
#             Specify a single file or to use templates use: headerfile;bodyfile1!bodyfile2!bodyfileN;footerfile
# 3. int   Burn program to EEPROM conditions
#             0 = transfer code if differs from eeprom, dont burn code to eeprom, then finally execute code thread 0
#             1 = transfer code if differs from eeprom, burn code to eeprom, then finally execute code thread 0
#             It is asssumed thread 0 starts all other required threads
# 4. int   Thread mask.  Check these threads are running after controller code start.  Bit 0 = thread 0 and so on
#             if thread mask < 0 nothing is checked
#             if thread mask = 0 and GalilCreateAxis appears > 0 then threads 0 to number of GalilCreateAxis is checked (good when using the generated code)

# Start the controller
GalilStartController("Galil", "", 1, 0)

# Start the controller
# Example using homing routine template assembly
GalilStartController("Galil", "$(GALIL)/db/galil_Default_Header.dmc;$(GALIL)/db/galil_Home_RevLimit.dmc!$(GALIL)/db/galil_Home_ForwLimit.dmc!$(GALIL)/db/galil_Home_Home.dmc!$(GALIL)/db/galil_Home_ForwLimit.dmc!$(GALIL)/db/galil_Piezo_Home.dmc!$(GALIL)/db/galil_Piezo_Home.dmc!$(GALIL)/db/galil_Piezo_Home.dmc!$(GALIL)/db/galil_Piezo_Home.dmc;$(GALIL)/db/galil_Default_Footer.dmc", 0, 0, 3)

# GalilCreateProfile command parameters are:
#
# 1. char *portName Asyn port for controller
# 2. Int maxPoints in trajectory

# Create trajectory profiles
GalilCreateProfile("Galil", $(TRAJ_POINTS))
