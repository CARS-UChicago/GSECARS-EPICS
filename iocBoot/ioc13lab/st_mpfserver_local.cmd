cd topbin
# This loads the MPF server stuff
ld < mpfServLib

routerInit
localMessageRouterStart(0)

carrier = "ipac"
ipacAddCarrier(&vipc616_01, "0x3000,0xa0000000")
initIpacCarrier(carrier, 0)

Ip330Debug=0
Ip330SweepDebug=0
Ip330SweepServerDebug=0
Ip330PIDServerDebug=0

# Initialize GPIB stuff
initGpibGsTi9914("GPIB0",carrier,"IP_c",104)
#initGpibServer("GPIB0","GS-IP488-0",4096,1000)

# Initialize Systran DAC
# initDAC128V(char *serverName, char *carrierName, char *siteName,
#             int queueSize)
# serverName  = name to give this server
# carrierName = name of IPAC carrier from initIpacCarrier above
# siteName    = name of IP site, e.g. "IP_a"
# queueSize   = size of output queue for EPICS
#
pDAC128V = initDAC128V("d-DAC",carrier,"IP_d",20)

# Initialize Greenspring IP-Unidig
# initIpUnidig(char *serverName, char *carrierName, char *siteName,
#              int queueSize)
# serverName  = name to give this server
# carrierName = name of IPAC carrier from initIpacCarrier above
# siteName    = name of IP site, e.g. "IP_a"
# queueSize   = size of output queue for EPICS
initIpUnidig("b-Unidig", carrier, "IP_b", 20)

# Initialize Acromag IP-330 ADC
# Ip330 *initIp330(
#   const char *moduleName, const char *carrierName, const char *siteName,
#   const char *typeString, const char *rangeString,
#   int firstChan, int lastChan,
#   int maxClients, int intVec)
# function return value  = pointer to the Ip330 object, needed by configIp330
#                          and to initialize the application-specific classes
# serverName  = name to give this server
# carrierName = name of IPAC carrier from initIpacCarrier above
# siteName    = name of IP site, e.g. "IP_a"
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
pIp330 = initIp330("a-Ip330", carrier,"IP_a","D","-5to5",0,15,10,120)

# int configIp330(
#   Ip330 *pIp330,
#   scanModeType scanMode, const char *triggerString,
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
configIp330(pIp330, 3,"Input",500,0)

# int initIp330Scan(
#      Ip330 *pIp330, const char *serverName, int firstChan, int lastChan,
#      int milliSecondsToAverage, int queueSize)
# pIp330     = pointer returned by initIp330 above
# serverName = name to give this server.  Must match the INP parm field in
#              EPICS records
# firstChan  = first channel to be used by Ip330Scan.  This must be in the
#              range firstChan to lastChan specified in initIp330
# lastChan   = last channel to be used by Ip330Scan.  This must be in the range
#              firstChan to lastChan specified in initIp330
# milliSecondsToAverage = number of milliseconds to average readings
# queueSize  = size of output queue for MPF. Make this the maximum number 
#              of ai records attached to this server.
initIp330Scan(pIp330,"a-Ip330Scan",0,15,100,20)

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
initIp330Sweep(pIp330,"a-Ip330Sweep",0,3,2048,100)

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
pIp330PID = initIp330PID("Ip330PID_1", pIp330, 0, pDAC128V, 0, 20)

# int configIp330PID(Ip330PID *pIp330PID,
#        double KP, double KI, double KD,
#        int interval, int feedbackOn, int lowLimit, int highLimit)
# pIp330PID  = pointer returned by initIp330PID above
# KP         = proportional gain
# KI         = integral gain
# KD         = derivative gain
# interval   = microseconds per feedback loop
# feedbackOn = 0 for feedback off, 1 for feedback on
# lowLimit   = low limit on DAC output
# highLimit  = high limit on DAC output
configIp330PID(pIp330PID, .1, 10., 0., 1000, 0, 500, 1500)
