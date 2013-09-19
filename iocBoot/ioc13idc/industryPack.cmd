# The first carrier in our system is a TEWS TVME200
# The argument to ipacAddTVME200 is the values of the 6 switches on the board
# In thise case 30 = base address 3000
#                2 = interrupt mapping 4, 5, 2, 1, 4, 5, 2, 1
#                F = A32 address space, 8MB per slot
#               A0 = A0000000 base address in A32 space
ipacAddTVME200("302FA0") 
#ipacAddVIPC616_01("0x3000,0xa0000000")
ipacAddVIPC616_01("0x3400,0xa2000000")

# Initialize Octal UART stuff
tyGSOctalDrv 2
tyGSOctalModuleInit("UART0", "232", 0x80, 0, 0)
tyGSOctalModuleInit("UART1", "232", 0x81, 0, 1)

# Initialize Acromag IP-330 ADC
# Ip330 *initIp330(
#   const char *portName, int carrier, int slot,
#   const char *typeString, const char *rangeString,
#   int firstChan, int lastChan,
#   int intVec)
# portName    = name to give this asyn port
# carrier     = IPAC carrier number (0, 1, etc.)
# slot        = IPAC slot (0,1,2,3, etc.)
# typeString  = "D" or "S" for differential or single-ended
# rangeString = "-5to5","-10to10","0to5", or "0to10"
#               This value must match hardware setting selected
# firstChan   = first channel to be digitized.  This must be in the range:
#               0 to 31 (single-ended)
#               0 to 15 (differential)
# lastChan    = last channel to be digitized
# intVec        Interrupt vector
initIp330("Ip330_1",0,2,"D","-5to5",0,15,120)

# int configIp330(
#   const char *portName,
#   int scanMode, const char *triggerString,
#   int microSecondsPerScan, int secondsBetweenCalibrate)
# portName    = name of aysn port created with initIp330
# scanMode    = scan mode:
#               0 = disable
#               1 = uniformContinuous
#               2 = uniformSingle
#               3 = burstContinuous (normally recommended)
#               4 = burstSingle
#               5 = convertOnExternalTriggerOnly
# triggerString = "Input" or "Output". Selects the direction of the external
#               trigger signal.
# microSecondsPerScan = repeat interval to digitize all channels
#               The minimum theoretical time is 15 microseconds times the
#               number of channels, but a practical limit is probably 100
#               microseconds.
# secondsBetweenCalibrate = number of seconds between calibration cycles.
#               If zero then there will be no periodic calibration, but
#               one calibration will still be done at initialization.
configIp330("Ip330_1", 3,"Input",1000,0)

# int initFastSweep(char *portName, char *inputName,
#                   int maxSignals, int maxPoints)
# portName   = asyn port name for this port
# inputName  = name of input port
# maxSignals = maximum number of input signals.
# maxPoints  = maximum number of points in a sweep.  The amount of memory
#              allocated will be maxPoints*maxSignals*4 bytes
initFastSweep("Ip330Sweep1","Ip330_1",4,2048)
dbLoadTemplate("Ip330_ADC.template")

#Initialize Greenspring IP-Unidig
# initIpUnidig(char *portName,
#              int carrier,
#              int slot,
#              int msecPoll,
#              int intVec,
#              int risingMask,
#              int fallingMask,
#              int biMask,
#              int maxClients)
# portName  = name to give this asyn port
# carrier     = IPAC carrier number (0, 1, etc.)
# slot        = IPAC slot (0,1,2,3, etc.)
# msecPoll    = polling time for input bits in msec.
# intVec      = interrupt vector
# risingMask  = mask of bits to generate interrupts on low to high (24 bits)
# fallingMask = mask of bits to generate interrupts on high to low (24 bits)
initIpUnidig("Unidig1", 0, 3, 100, 116, 0xffffff, 0xffffff)
initIpUnidig("Unidig2", 1, 1, 100, 117, 0xffffff, 0xffffff)
initIpUnidig("Unidig3", 1, 2, 100, 118, 0xffffff, 0xffffff)

dbLoadTemplate("ipUnidig.substitutions")
dbLoadTemplate("filter.substitutions")


# DAC in first slot on second board
# Initialize Systran DAC
# initDAC128V(char *portName, int carrier, int slot)
# portName  = name to give this asyn port
# carrier     = IPAC carrier number (0, 1, etc.)
# slot        = IPAC slot (0,1,2,3, etc.)
initDAC128V("DAC1", 1, 0)
dbLoadTemplate("DAC.template")

