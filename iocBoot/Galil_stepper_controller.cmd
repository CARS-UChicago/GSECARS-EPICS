# Generic command file for Galil stepper controller
# Macros:
# P       Prefix for this controller, e.g. 13BMC:Galil1:
# PORT    asyn port name, e.g. GALIL1
# M1-M8   Motor names, e.g, m1, m2, m3, m4, m5, m6, m7, m8

## Uncomment to see every command sent to galil
#epicsEnvSet("GALIL_DEBUG_FILE", "galil_debug.txt")

# GalilCreateController command parameters are:
#
# 1. Const char *portName 	- The name of the asyn port that will be created for this controller
# 2. Const char *address 	- The address of the controller
# 3. double updatePeriod	- The time in ms between datarecords 2ms min, 200ms max.  Async if controller + bus supports it, otherwise is polled/synchronous.
#                       	- Recommend 50ms or less for ethernet
#                       	- Specify negative updatePeriod < 0 to force synchronous tcp poll period.  Otherwise will try async udp mode first

# Create Galil controller
GalilCreateController($(PORT), $(IPADDR), 20)

# GalilCreateAxis command parameters are:
#
# 1. char *portName Asyn port for controller
# 2. char  axis A-H,
# 3. int   limits_as_home (0 off 1 on), 
# 4. char  *Motor interlock digital port number 1 to 8 eg. "1,2,4".  1st 8 bits are supported
# 5. int   Interlock switch type 0 normally open, all other values is normally closed interlock switch type

# Create the axis
GalilCreateAxis("$(PORT)","A",1,"",1)
GalilCreateAxis("$(PORT)","B",1,"",1)
GalilCreateAxis("$(PORT)","C",1,"",1)
GalilCreateAxis("$(PORT)","D",1,"",1)
GalilCreateAxis("$(PORT)","E",1,"",1)
GalilCreateAxis("$(PORT)","F",1,"",1)
GalilCreateAxis("$(PORT)","G",1,"",1)
GalilCreateAxis("$(PORT)","H",1,"",1)

# GalilCreateCSAxes command parameters are:
#
# 1. char *portName Asyn port for controller
#Create all CS axes (ie. I-P axis)
GalilCreateCSAxes("$(PORT)")

#Load digital IO databases
#dbLoadTemplate("$(TOP)/GalilTestApp/Db/galil_dmc_digital_ports.substitutions", "P=DMC01:, PORT=Galil")

#Load analog IO databases
#dbLoadTemplate("$(TOP)/GalilTestApp/Db/galil_dmc_analog_ports.substitutions", "P=DMC01:, PORT=Galil, PREC=3")

#Load user defined functions
#dbLoadTemplate("$(TOP)/GalilTestApp/Db/galil_userdef_records.substitutions")

#Load user defined array support
#dbLoadTemplate("$(TOP)/GalilTestApp/Db/galil_user_array.substitutions", "P=DMC01:, PORT=Galil, NELM=1000")

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
GalilStartController("$(PORT)", "", 1, 0)
# Start the controller
# Example using homing routine template assembly
GalilStartController("$(PORT)", "$(GALIL)/db/galil_Default_Header.dmc;$(GALIL)/db/galil_Home_RevLimit.dmc!$(GALIL)/db/galil_Home_ForwLimit.dmc!$(GALIL)/db/galil_Home_Home.dmc!$(GALIL)/db/galil_Home_ForwLimit.dmc!$(GALIL)/db/galil_Piezo_Home.dmc!$(GALIL)/db/galil_Piezo_Home.dmc!$(GALIL)/db/galil_Piezo_Home.dmc!$(GALIL)/db/galil_Piezo_Home.dmc;$(GALIL)/db/galil_Default_Footer.dmc", 0, 0, 3)

# GalilCreateProfile command parameters are:
#
# 1. char *portName Asyn port for controller
# 2. Int maxPoints in trajectory

# Create trajectory profiles
GalilCreateProfile("$(PORT)", 2000)

dbLoadRecords("$(GALIL)/db/galil_dmc_ctrl.template",     "P=$(P), PORT=$(PORT), SCAN=Passive, DEFAULT_HOMETYPE=1, DEFAULT_LIMITTYPE=1, PREC=5")

# P - Motion device
# M - Motor name
# PORT - Asyn port of controller
# ADDR - Axis number 0-7
# PREC - Precision of analog records
# SCAN - Scan period for monitor records.  Use passive when only epics will change value (default)
#      - Periodic scan will slow controller update performance (poller)
# MTRTYPE - motor type =
#               0 - Servo
#               1 - Reverse servo
#               2 - High active stepper
#               3 - Low active stepper
#               4 - Reverse high active stepper
#               5 - Reverse low active stepper
# MTRON - motor off 0, motor on 1
dbLoadRecords("$(GALIL)/db/galil_motor_extras.template", "P=$(P), PORT=$(PORT), ADDR=0, M=$(M1), SCAN=Passive, MTRTYPE=3, MTRON=1, EGU=mm,  PREC=5")
dbLoadRecords("$(GALIL)/db/galil_motor_extras.template", "P=$(P), PORT=$(PORT), ADDR=1, M=$(M2), SCAN=Passive, MTRTYPE=3, MTRON=1, EGU=mm,  PREC=5")
dbLoadRecords("$(GALIL)/db/galil_motor_extras.template", "P=$(P), PORT=$(PORT), ADDR=2, M=$(M3), SCAN=Passive, MTRTYPE=3, MTRON=1, EGU=mm,  PREC=5")
dbLoadRecords("$(GALIL)/db/galil_motor_extras.template", "P=$(P), PORT=$(PORT), ADDR=3, M=$(M4), SCAN=Passive, MTRTYPE=3, MTRON=1, EGU=mm,  PREC=5")
dbLoadRecords("$(GALIL)/db/galil_motor_extras.template", "P=$(P), PORT=$(PORT), ADDR=4, M=$(M5), SCAN=Passive, MTRTYPE=3, MTRON=1, EGU=mm,  PREC=5")
dbLoadRecords("$(GALIL)/db/galil_motor_extras.template", "P=$(P), PORT=$(PORT), ADDR=5, M=$(M6), SCAN=Passive, MTRTYPE=3, MTRON=1, EGU=mm,  PREC=5")
dbLoadRecords("$(GALIL)/db/galil_motor_extras.template", "P=$(P), PORT=$(PORT), ADDR=6, M=$(M7), SCAN=Passive, MTRTYPE=3, MTRON=1, EGU=mm,  PREC=5")
dbLoadRecords("$(GALIL)/db/galil_motor_extras.template", "P=$(P), PORT=$(PORT), ADDR=7, M=$(M8), SCAN=Passive, MTRTYPE=3, MTRON=1, EGU=mm,  PREC=5")

# P - Motion device
# M - Motor name
# PORT - Asyn port of controller
# ADDR - Axis number 0-7
# PREC - Precision of analog records
# SCAN - Scan period for monitor records.  Use passive when only epics will change value (default)
#      - Periodic scan will slow controller update performance (poller)
dbLoadRecords("$(GALIL)/db/galil_csmotor_extras.template", "P=$(P), PORT=$(PORT), ADDR=8,  M=$(M1), SCAN=Passive, EGU=mm,  PREC=3")
dbLoadRecords("$(GALIL)/db/galil_csmotor_extras.template", "P=$(P), PORT=$(PORT), ADDR=9,  M=$(M2), SCAN=Passive, EGU=mm,  PREC=3")
dbLoadRecords("$(GALIL)/db/galil_csmotor_extras.template", "P=$(P), PORT=$(PORT), ADDR=10, M=$(M3), SCAN=Passive, EGU=mm,  PREC=3")
dbLoadRecords("$(GALIL)/db/galil_csmotor_extras.template", "P=$(P), PORT=$(PORT), ADDR=11, M=$(M4), SCAN=Passive, EGU=mm,  PREC=3")
dbLoadRecords("$(GALIL)/db/galil_csmotor_extras.template", "P=$(P), PORT=$(PORT), ADDR=12, M=$(M5), SCAN=Passive, EGU=mm,  PREC=3")
dbLoadRecords("$(GALIL)/db/galil_csmotor_extras.template", "P=$(P), PORT=$(PORT), ADDR=13, M=$(M6), SCAN=Passive, EGU=mm,  PREC=3")
dbLoadRecords("$(GALIL)/db/galil_csmotor_extras.template", "P=$(P), PORT=$(PORT), ADDR=14, M=$(M7), SCAN=Passive, EGU=mm,  PREC=3")
dbLoadRecords("$(GALIL)/db/galil_csmotor_extras.template", "P=$(P), PORT=$(PORT), ADDR=15, M=$(M8), SCAN=Passive, EGU=mm,  PREC=3")


# Forward kinematic transform equations for CS motors
#
# 8 forward equations per controller.
# 1 forward equation per CS motor I-P (8-15) = 8 in total
#
# Eg. I=(A+B)/2 - Forward equations for CS motor I (8)
#
# P    - PV prefix
# M    - CSMotor name
# PORT - Asyn port name
# ADDR - CS Motor I-P (8-15)
dbLoadRecords("$(GALIL)/db/galil_forward_transform.template", "P=$(P), PORT=$(PORT), ADDR=8,   M=$(M1)")
dbLoadRecords("$(GALIL)/db/galil_forward_transform.template", "P=$(P), PORT=$(PORT), ADDR=9,   M=$(M2)")
dbLoadRecords("$(GALIL)/db/galil_forward_transform.template", "P=$(P), PORT=$(PORT), ADDR=10,  M=$(M3)")
dbLoadRecords("$(GALIL)/db/galil_forward_transform.template", "P=$(P), PORT=$(PORT), ADDR=11,  M=$(M4)")
dbLoadRecords("$(GALIL)/db/galil_forward_transform.template", "P=$(P), PORT=$(PORT), ADDR=12,  M=$(M5)")
dbLoadRecords("$(GALIL)/db/galil_forward_transform.template", "P=$(P), PORT=$(PORT), ADDR=13,  M=$(M6)")
dbLoadRecords("$(GALIL)/db/galil_forward_transform.template", "P=$(P), PORT=$(PORT), ADDR=14,  M=$(M7)")
dbLoadRecords("$(GALIL)/db/galil_forward_transform.template", "P=$(P), PORT=$(PORT), ADDR=15,  M=$(M8)")

# Reverse kinematic transform equations for CS motors
#
# 8 reverse equations per CS Motor that represent real motors A-H
# 64 reverse equations per controller in total as there are 8 CS motors I-P (8-15)
#
# Eg. A=I-J/2 - Reverse equation A for CS motor I (8)
#
# P    - PV prefix
# M    - CSMotor name
# PORT - Asyn port name
# ADDR - CS Motor I-P (8-15)
dbLoadRecords("$(GALIL)/db/galil_reverse_transforms.template", "P=$(P), PORT=$(PORT), ADDR=8,   M=$(M1)")
dbLoadRecords("$(GALIL)/db/galil_reverse_transforms.template", "P=$(P), PORT=$(PORT), ADDR=9,   M=$(M2)")
dbLoadRecords("$(GALIL)/db/galil_reverse_transforms.template", "P=$(P), PORT=$(PORT), ADDR=10,  M=$(M3)")
dbLoadRecords("$(GALIL)/db/galil_reverse_transforms.template", "P=$(P), PORT=$(PORT), ADDR=11,  M=$(M4)")
dbLoadRecords("$(GALIL)/db/galil_reverse_transforms.template", "P=$(P), PORT=$(PORT), ADDR=12,  M=$(M5)")
dbLoadRecords("$(GALIL)/db/galil_reverse_transforms.template", "P=$(P), PORT=$(PORT), ADDR=13,  M=$(M6)")
dbLoadRecords("$(GALIL)/db/galil_reverse_transforms.template", "P=$(P), PORT=$(PORT), ADDR=14,  M=$(M7)")
dbLoadRecords("$(GALIL)/db/galil_reverse_transforms.template", "P=$(P), PORT=$(PORT), ADDR=15,  M=$(M8)")

# Coordinate system status
#
# P    - PV prefix
# R    - Record Name
# PORT - Asyn port name
# ADDR - Hardware port to read
# SCAN - Scan period for monitor records
dbLoadRecords("$(GALIL)/db/galil_coordinate_system.template", "P=$(P), PORT=$(PORT), ADDR=0, R=S, SCAN=.1 second,  M=$(M1)")
dbLoadRecords("$(GALIL)/db/galil_coordinate_system.template", "P=$(P), PORT=$(PORT), ADDR=1, R=T, SCAN=.1 second,  M=$(M1)")
