cd topbin
# This loads the MPF server stuff
ld < mpfServLib 

routerInit
localMessageRouterStart(0)

carrier = "ipac"
ipacAddCarrier(&vipc616_01, "0x3000,0xa0000000")
initIpacCarrier(carrier, 0)

# Initialize GPIB stuff
# REMOVED 9/17/00 to make room for Unidig Binary I/O
#initGpibGsTi9914("GS-IP488-0",carrier,"IP_c",104)
#initGpibServer("GPIB0","GS-IP488-0",1024,1000)

# Initialize Octal UART stuff
initOctalUART("octalUart0",carrier,"IP_a",8,100)
#initOctalUART("octalUart1",carrier,"IP_b",8,101)
# initOctalUARTPort(char* portName,char* moduleName,int port,int baud,
#                   char* parity,int stop_bits,int bits_char,char* flow_control)
# 'baud' is the baud rate. 1200, 2400, 4800, 9600, 19200, 38400
# 'parity' is "E" for even, "O" for odd, "N" for none.
# 'stop_bits' = {1,2}
# 'bits_per_character' = {5,6,7,8}
# 'flow_control' is "N" for none, "H" for hardware
initOctalUARTPort("UART[0]","octalUart0",0, 9600,"N",2,8,"N") /* SRS 570 */
initOctalUARTPort("UART[1]","octalUart0",1,19200,"N",1,8,"N") /* Keithley 2000 */
initOctalUARTPort("UART[2]","octalUart0",2, 9600,"N",2,8,"N") /* SRS 570 */
initOctalUARTPort("UART[3]","octalUart0",3, 9600,"N",2,8,"N") /* SRS 570 */
initOctalUARTPort("UART[4]","octalUart0",4,19200,"N",1,8,"N") /* MM4000 */
initOctalUARTPort("UART[5]","octalUart0",5, 9600,"N",1,8,"N") /* SMART PC */
initOctalUARTPort("UART[6]","octalUart0",6, 9600,"N",1,8,"N") /* Keithley 2000 */
initOctalUARTPort("UART[7]","octalUart0",7, 9600,"N",1,8,"N") /* Keithley 2000 */
initSerialServer("a-Serial[0]","UART[0]",1000,20,"\r",1)
initSerialServer("a-Serial[1]","UART[1]",1000,20,"\r",1)
initSerialServer("a-Serial[2]","UART[2]",1000,20,"\r",1)
initSerialServer("a-Serial[3]","UART[3]",1000,20,"\r",1)
initSerialServer("a-Serial[4]","UART[4]",1000,20,"\r",1)
initSerialServer("a-Serial[5]","UART[5]",1000,20,"\r",1)
initSerialServer("a-Serial[6]","UART[6]",1000,20,"\r",1)
initSerialServer("a-Serial[7]","UART[7]",1000,20,"\r",1)

# Initialize Systran DAC
initDAC128V("d-DAC",carrier,"IP_d",20)

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
pIp330 = initIp330("b-Ip330", carrier,"IP_b","D","-5to5",0,15,10,120)

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
initIp330Scan(pIp330,"b-Ip330Scan",0,15,100,20)

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
initIp330Sweep(pIp330,"b-Ip330Sweep",0,3,2048,100)

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
#pIp330PID = initIp330PID("Ip330PID_1", pIp330, 0, pDAC128V, 0, 20)

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
#configIp330PID(pIp330PID, .1, 10., 0., 1000, 0, 500, 1500)

# Initialize Greenspring IP-Unidig
# initIpUnidig(char *serverName, char *carrierName, char *siteName,
#              int queueSize)
# serverName  = name to give this server
# carrierName = name of IPAC carrier from initIpacCarrier above
# siteName    = name of IP site, e.g. "IP_a"
# queueSize   = size of output queue for EPICS
initIpUnidig("c-Unidig", carrier, "IP_c", 20)


# DEBUGGING
#serialPortSniff("UART[3]",1000)
