routerInit
localMessageRouterStart(0)

ipacAddVIPC616_01("0x3000,0xa0000000")
ipacAddVIPC616_01("0x3400,0xa2000000")

ipacReport(2)

# Set up GPIB as an MPF serial server.  
# This will allow communication, but not control operations.  It is limited to a single address.
gsIP488Configure("gpib1",1,1,0x69,0,0) 
initSerialServer("gpib1:2","gpib1",2,1000,10,"") 
# GPIB addresses: 1=Tektronix scope, 2=Keithley 2000, 3=Fluke meter
asynConnect("gpib1:1", "gpib1", 1, "", "\n", 1, 80)
asynConnect("gpib1:2", "gpib1", 2, "", "\n", 1, 80)
asynConnect("gpib1:3", "gpib1", 3, "\r", "\r", 1, 80)
     
tyGSOctalDrv 2
tyGSOctalModuleInit("GSIP_OCTAL232", 0x80, 0, 0)
tyGSOctalModuleInit("GSIP_OCTAL232", 0x81, 1, 2)
# int tyGSMPFInit(char *server, int uart, int channel, int baud, char parity, int sbits,
#                 int dbits, char handshake, char *eomstr)
tyGSMPFInit("serial1",   0, 0, 9600,'N',1,8,'N',"\r")  /* SMART PC */
tyGSMPFInit("serial2",   0, 1, 9600,'N',1,8,'N',"\r")  /* LAE 500 */
tyGSMPFInit("serial3",   0, 2,19200,'E',1,8,'N',"\r")  /* MKS */
#tyGSMPFInit("serial3",   0, 2,19200,'N',1,8,'N',"\r")  /* RSF715 */
tyGSMPFInit("serial4",   0, 3,19200,'N',1,8,'N',"\r")  /* ACS MCB4B */
tyGSMPFInit("serial5",   0, 4,19200,'N',1,8,'N',"\n")  /* Keithley 2000 */
tyGSMPFInit("serial6",   0, 5,19200,'N',1,8,'N',"\n")  /* Keithley 2000 */
tyGSMPFInit("serial7",   0, 6,38400,'N',1,8,'N',"\r")  /* MM4000 */
tyGSMPFInit("serial8",   0, 7, 9600,'N',1,8,'N',"\r")  /* SRS 570 */
tyGSMPFInit("serial9" ,  1, 0, 9600,'N',1,8,'N',"\r")  /* Unused */
tyGSMPFInit("serial10",  1, 1, 9600,'N',1,8,'N',"\r")  /* Unused */
tyGSMPFInit("serial11",  1, 2, 9600,'N',1,8,'N',"\r")  /* Unused */
tyGSMPFInit("serial12",  1, 3, 9600,'N',1,8,'N',"\r")  /* Unused */
tyGSMPFInit("serial13",  1, 4, 9600,'N',1,8,'N',"\r")  /* Unused */
tyGSMPFInit("serial14",  1, 5, 9600,'N',1,8,'N',"\r")  /* Unused */
tyGSMPFInit("serial15",  1, 6, 9600,'N',1,8,'N',"\r")  /* Unused */
tyGSMPFInit("serial16",  1, 7, 9600,'N',1,8,'N',"\r")  /* Unused */

# Set up first 2 ports on Moxa box
drvAsynTCPPortConfigure("serial20", "164.54.160.50:4001", 0, 0)
drvAsynTCPPortConfigure("serial21", "164.54.160.50:4002", 0, 0)
# Make these ports available from the iocsh command line
asynConnect("serial20", "serial20", 0, "\r", "\r")
asynConnect("serial21", "serial21", 0, "\r", "\r")
# Create MPF servers for these ports
initSerialServer("serial20","serial20",0,1000,10,"") 
initSerialServer("serial21","serial21",0,1000,10,"") 

# Debugging
#asynSetTraceMask("gpib1",3,0xff)
#asynSetTraceIOMask("gpib1",3,2)
#asynSetTraceMask("serial3",0,0xff)
#asynSetTraceIOMask("serial3",0,2)
#asynSetTraceMask("serial20",0,0xff)
#asynSetTraceIOMask("serial20",0,2)

# Initialize Greenspring IP-Unidig
# initIpUnidig(char *serverName, 
#              int carrier, 
#              int slot,
#              int queueSize, 
#              int msecPoll,
#              int intVec, 
#              int risingMask, 
#              int fallingMask,
#              int biMask,
#              int maxClients)
# serverName  = name to give this server
# carrier     = IPAC carrier number (0, 1, etc.)
# slot        = IPAC slot (0,1,2,3, etc.)
# queueSize   = size of output queue for EPICS
# msecPoll    = polling time for input bits in msec.  Default=100.
# intVec      = interrupt vector
# risingMask  = mask of bits to generate interrupts on low to high (24 bits)
# fallingMask = mask of bits to generate interrupts on high to low (24 bits)
# biMask      = mask of bits to generate callbacks to bi record support
#               This can be a subset of (risingMask | fallingMask)
# maxClients  = Maximum number of callback tasks which will attach to this
#               IpUnidig server.  This
#               does not refer to the number of EPICS clients.  A value of
#               10 should certainly be safe.
initIpUnidig("Unidig1", 0, 1, 20, 2000, 116, 1, 1, 0xffff, 10)

# Initialize Systran DAC
# initDAC128V(char *serverName, int carrier, int slot, int queueSize)
# serverName  = name to give this server
# carrier     = IPAC carrier number (0, 1, etc.)
# slot        = IPAC slot (0,1,2,3, etc.)
# queueSize   = size of output queue for EPICS
#
initDAC128V("DAC1", 0, 3, 20)


# Initialize Acromag IP-330 ADC
# Ip330 *initIp330(
#   const char *moduleName, int carrier, int slot,
#   const char *typeString, const char *rangeString,
#   int firstChan, int lastChan,
#   int maxClients, int intVec)
# function return value  = pointer to the Ip330 object, needed by configIp330
#                          and to initialize the application-specific classes
# serverName  = name to give this server
# carrier     = IPAC carrier number (0, 1, etc.)
# slot        = IPAC slot (0,1,2,3, etc.)
# typeString  = "D" or "S" for differential or single-ended
# rangeString = "-5to5","-10to10","0to5", or "0to10"
#               This value must match hardware setting selected
# firstChan   = first channel to be digitized.  This must be in the range:
#               0 to 31 (single-ended)
#               0 to 15 (differential)
# lastChan    = last channel to be digitized
# maxClients =  Maximum number of Ip330 tasks which will attach to this
#               Ip330 module.  For example Ip330Scan, Ip330Sweep, etc.  This
#               does not refer to the number of EPICS clients.  A value of
#               10 should certainly be safe.
# intVec        Interrupt vector
initIp330("Ip330_1",0,2,"D","-5to5",0,15,10,120)

# int configIp330(
#   Ip330 *pIp330,
#   int scanMode, const char *triggerString,
#   int microSecondsPerScan, int secondsBetweenCalibrate)
# pIp330      = pointer to the Ip330 object, returned by initIp330 above
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
# NOTE Selected burstSingle for testing
configIp330("Ip330_1", 3,"Input",500,0)

# int initIp330Scan(
#      Ip330 *pIp330, const char *serverName, int firstChan, int lastChan,
#      int queueSize)
# pIp330     = pointer returned by initIp330 above
# serverName = name to give this server.  Must match the INP parm field in
#              EPICS records
# firstChan  = first channel to be used by Ip330Scan.  This must be in the
#              range firstChan to lastChan specified in initIp330
# lastChan   = last channel to be used by Ip330Scan.  This must be in the range
#              firstChan to lastChan specified in initIp330
# queueSize  = size of output queue for MPF. Make this the maximum number 
#              of ai records attached to this server.
initIp330Scan("Ip330_1","Ip330Scan1",0,15,100)

# int initIp330Sweep(Ip330 *pIp330, char *serverName, int firstChan, 
#     int lastChan, int maxPoints, int queueSize)
# pIp330     = pointer returned by initIp330 above
# serverName = name to give this server
# firstChan  = first channel to be used by Ip330Sweep.  This must be in the
#              range firstChan to lastChan specified in initIp330
# lastChan   = last channel to be used by Ip330Sweep.  This must be in the
#              range firstChan to lastChan specified in initIp330
# maxPoints  = maximum number of points in a sweep.  The amount of memory
#              allocated will be maxPoints*(lastChan-firstChan+1)*4 bytes
# queueSize  = size of output queue for EPICS
initIp330Sweep("Ip330_1","Ip330Sweep1",0,3,2048,100)

# Ip330PID *initIp330PID(const char *serverName,
#        Ip330 *pIp330, int ADCChannel, DAC128V *pDAC128V, int DACChannel,
#        int queueSize)
# serverName = name to give this server
# pIp330     = pointer returned by initIp330 above
# ADCChannel = ADC channel to be used by Ip330PID as its readback source.  
#              This must be in the range firstChan to lastChan specified in 
#              initIp330
# pDAC128V   = pointer returned by initDAC128V
# DACChannel = DAC channel to be used by Ip330PID as its control output.  This
#              must be in the range 0-7.
# queueSize  = size of output queue for EPICS
initIp330PID("Ip330PID1", "Ip330_1", 0, "DAC1", 0, 20)
