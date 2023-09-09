## uncomment to see every command sent to galil
#epicsEnvSet("GALIL_DEBUG_FILE", "galil_debug.txt")

# GalilCreateController command parameters are:
#
# 1. Const char *portName 	- The name of the asyn port that will be created for this controller
# 2. Const char *address 	- The address of the controller
# 3. double updatePeriod	- The time in ms between datarecords 2ms min, 200ms max.  Async if controller + bus supports it, otherwise is polled/synchronous.
#                       	- Recommend 50ms or less for ethernet
#                       	- Specify negative updatePeriod < 0 to force synchronous tcp poll period.  Otherwise will try async udp mode first

# Create Galil controllers
GalilCreateController("GALIL1", "10.54.160.69", 8)

# GalilCreateAxis command parameters are:
#
# 1. char *portName Asyn port for controller
# 2. char  axis A-H,
# 3. int   limits_as_home (0 off 1 on), 
# 4. char  *Motor interlock digital port number 1 to 8 eg. "1,2,4".  1st 8 bits are supported
# 5. int   Interlock switch type 0 normally open, all other values is normally closed interlock switch type

# Create the axis
GalilCreateAxis("GALIL1","A",1,"",1)
GalilCreateAxis("GALIL1","B",1,"",1)
GalilCreateAxis("GALIL1","C",1,"",1)
GalilCreateAxis("GALIL1","D",1,"",1)
GalilCreateAxis("GALIL1","E",1,"",1)
GalilCreateAxis("GALIL1","F",1,"",1)
GalilCreateAxis("GALIL1","G",1,"",1)
GalilCreateAxis("GALIL1","H",1,"",1)

#Create all CS axes (ie. I-P axis)
GalilCreateCSAxes("GALIL1")

#Load motor records for real and coordinate system (CS) motors
dbLoadTemplate("Galil_motors.template")

#Remote control input
dbLoadTemplate("remoteControl.substitutions", "P=$(P)")

#Load digital IO databases
dbLoadTemplate("$(GALIL)/db/galil_dmc_digital_ports.substitutions", "P=$(P), PORT=GALIL1")

#Load analog IO databases
#dbLoadTemplate("$(TOP)/GalilTestApp/Db/galil_dmc_analog_ports.substitutions", "P=$(P), PORT=Galil, PREC=3")

#Load user defined functions
#dbLoadTemplate("$(TOP)/GalilTestApp/Db/galil_userdef_records.substitutions")

#Load user defined array support
#dbLoadTemplate("$(TOP)/GalilTestApp/Db/galil_user_array.substitutions", "P=$(P), PORT=Galil, NELM=1000")

#Load profiles
#dbLoadTemplate("$(TOP)/GalilTestApp/Db/galil_profileMoveController.substitutions")
#dbLoadTemplate("$(TOP)/GalilTestApp/Db/galil_profileMoveAxis.substitutions")

# GalilAddCode command parameters are:
# Add custom code to generated code
# 1. char *portName Asyn port for controller
# 2. int section = code section to add custom code into 0 = card code, 1 = thread code, 2 = limits code, 3 = digital code
# 3. char *code_file custom code file
#GalilAddCode("Galil", 1, "customcode.dmc")

# GalilReplaceHomeCode command parameters are:
# Replace generated axis home code with custom code
# 1. char *portName Asyn port for controller
# 2. char *Axis A-H
# 3. char *code_file custom code file
#GalilReplaceHomeCode("Galil", "C", "customhoming.dmc")

# GalilCreateCSAxes command parameters are:
#
# 1. char *portName Asyn port for controller

#Create all CS axes (ie. I-P axis)
GalilCreateCSAxes("GALIL1")

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
GalilStartController("GALIL1", "", 1, 0)

# Start the controller
# Example using homing routine template assembly
GalilStartController("GALIL1", "$(GALIL)/db/galil_Default_Header.dmc;$(GALIL)/db/galil_Home_RevLimit.dmc!$(GALIL)/db/galil_Home_ForwLimit.dmc!$(GALIL)/db/galil_Home_Home.dmc!$(GALIL)/db/galil_Home_ForwLimit.dmc!$(GALIL)/db/galil_Piezo_Home.dmc!$(GALIL)/db/galil_Piezo_Home.dmc!$(GALIL)/db/galil_Piezo_Home.dmc!$(GALIL)/db/galil_Piezo_Home.dmc;$(GALIL)/db/galil_Default_Footer.dmc", 0, 0, 3)

# GalilCreateProfile command parameters are:
#
# 1. char *portName Asyn port for controller
# 2. Int maxPoints in trajectory

# Create trajectory profiles
GalilCreateProfile("GALIL1", 2000)

