# This loads the MPF server stuff

cd topbin
ld <mpfServLib 

cd startup

routerInit
localMessageRouterStart(0)

carrier0 = "ipac0"
carrier1 = "ipac1"
ipacAddCarrier(&vipc616_01, "0x3000,0xa0000000")
ipacAddCarrier(&vipc616_01, "0x3400,0xa2000000")
initIpacCarrier(carrier0, 0)
initIpacCarrier(carrier1, 1)

# Initialize GPIB stuff
#initGpibGsTi9914("GS-IP488-0",carrier,"IP_c",104)
#initGpibServer("GPIB0","GS-IP488-0",1024,1000)

# Initialize Octal UART stuff
initOctalUART("octalUart0",carrier0,"IP_a",8,100)
initOctalUART("octalUart1",carrier0,"IP_b",8,101)

# initOctalUARTPort(char* portName,char* moduleName,int port,int baud,
#                   char* parity,int stop_bits,int bits_char,char* flow_control)
# 'baud' is the baud rate. 1200, 2400, 4800, 9600, 19200, 38400
# 'parity' is "E" for even, "O" for odd, "N" for none.
# 'bits_per_character' = {5,6,7,8}
# 'stop_bits' = {1,2}
# 'flow_control' is "N" for none, "H" for hardware
# Port 0 is Generic Serial Record
initOctalUARTPort("UART[0]","octalUart0",0, 9600,"N",2,8,"N") /* SRS570 */
initOctalUARTPort("UART[1]","octalUart0",1, 9600,"N",2,8,"N") /* SRS570 */
initOctalUARTPort("UART[2]","octalUart0",2,38400,"N",1,8,"N") /* Unused */
initOctalUARTPort("UART[3]","octalUart0",3,38400,"N",1,8,"N") /* Unused */
initOctalUARTPort("UART[4]","octalUart0",4, 9600,"N",2,8,"N") /* SRS570 */
initOctalUARTPort("UART[5]","octalUart0",5,19200,"N",1,8,"N") /* Keithley 2000 */
initOctalUARTPort("UART[6]","octalUart0",6, 9600,"N",1,8,"N") /* Unused */
initOctalUARTPort("UART[7]","octalUart0",7, 9600,"N",2,8,"N") /* SR570 */
initSerialServer("a-Serial[0]","UART[0]",1000,20,"\r",1)
initSerialServer("a-Serial[1]","UART[1]",1000,20,"\r",1)
initSerialServer("a-Serial[2]","UART[2]",1000,20,"\r",1)
initSerialServer("a-Serial[3]","UART[3]",1000,20,"\r",1)
initSerialServer("a-Serial[4]","UART[4]",1000,20,"\r",1)
initSerialServer("a-Serial[5]","UART[5]",1000,20,"\r",1)
initSerialServer("a-Serial[6]","UART[6]",1000,20,"\r",1)
initSerialServer("a-Serial[7]","UART[7]",1000,20,"\r",1)
initOctalUARTPort("UART[8]", "octalUart1",0, 9600,"N",2,8,"N") /* SRS570 */
initOctalUARTPort("UART[9]", "octalUart1",1, 9600,"N",2,8,"N") /* SRS570 */
initOctalUARTPort("UART[10]","octalUart1",2,38400,"N",1,8,"N") /* MM4000 */
initOctalUARTPort("UART[11]","octalUart1",3,38400,"N",1,8,"N") /* MM4000 */
initOctalUARTPort("UART[12]","octalUart1",4, 9600,"N",1,8,"N") /* SMART PC */
initOctalUARTPort("UART[13]","octalUart1",5, 9600,"N",2,8,"N") /* SRS570 */
initOctalUARTPort("UART[14]","octalUart1",6, 9600,"N",2,8,"N") /* SRS570 */
initOctalUARTPort("UART[15]","octalUart1",7, 9600,"N",1,8,"N") /* Unused */
initSerialServer("b-Serial[0]","UART[8]",1000,20,"\r",1)
initSerialServer("b-Serial[1]","UART[9]",1000,20,"\r",1)
initSerialServer("b-Serial[2]","UART[10]",1000,20,"\r",1)
initSerialServer("b-Serial[3]","UART[11]",1000,20,"\r",1)
initSerialServer("b-Serial[4]","UART[12]",1000,20,"\r",1)
initSerialServer("b-Serial[5]","UART[13]",1000,20,"\r",1)
initSerialServer("b-Serial[6]","UART[14]",1000,20,"\r",1)
initSerialServer("b-Serial[7]","UART[15]",1000,20,"\r",1)

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
pIp330 = initIp330("c-Ip330", carrier0,"IP_c","D","-5to5",0,15,10,120)


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
configIp330(pIp330, 3,"Input",1000,0)

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
initIp330Scan(pIp330,"c-Ip330Scan",0,15,100,20)

# int initIp330Sweep(Ip330 *pIp330, char *serverName, int firstChan, int lastChan,
#              int maxPoints, int queueSize)
# pIp330     = pointer returned by initIp330 above
# serverName = name to give this server
# firstChan  = first channel to be used by Ip330Sweep.  This must be in the
#              range firstChan to lastChan specified in initIp330
# lastChan   = last channel to be used by Ip330Sweep.  This must be in the
#              range firstChan to lastChan specified in initIp330
# maxPoints  = maximum number of points in a sweep.  The amount of memory
#              allocated will be maxPoints*(lastChan-firstChan+1)*4 bytes
# queueSize  = size of output queue for EPICS
initIp330Sweep(pIp330,"c-Ip330Sweep",0,3,2048,200)

# Initialize Greenspring IP-Unidig
# initIpUnidig(char *serverName, char *carrierName, char *siteName,
#              int queueSize)
# serverName  = name to give this server
# carrierName = name of IPAC carrier from initIpacCarrier above
# siteName    = name of IP site, e.g. "IP_a"
# queueSize   = size of output queue for EPICS
initIpUnidig("d-Unidig", carrier0, "IP_d", 20)

# Initialize Systran DAC
pDAC128V = initDAC128V("e-DAC",carrier1,"IP_a",20)

# Initialize second Greenspring IP-Unidig
# initIpUnidig(char *serverName, char *carrierName, char *siteName,
#              int queueSize)
# serverName  = name to give this server
# carrierName = name of IPAC carrier from initIpacCarrier above
# siteName    = name of IP site, e.g. "IP_a"
# queueSize   = size of output queue for EPICS
initIpUnidig("f-Unidig", carrier1, "IP_b", 20)

