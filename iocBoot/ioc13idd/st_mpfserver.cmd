cd topbin
# This loads the MPF server stuff
ld < mpfServLib 

routerInit
localMessageRouterStart(0)

carrier0 = "ipac0"
carrier1 = "ipac1"
ipacAddCarrier(&vipc616_01, "0x3000,0xa0000000")
ipacAddCarrier(&vipc616_01, "0x3400,0xa2000000")
initIpacCarrier(carrier0, 0)
initIpacCarrier(carrier1, 1)

# Initialize GPIB stuff
# REMOVED to make room for Unidig Binary I/O
#initGpibGsTi9914("GS-IP488-0",carrier0,"IP_c",104)
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
initOctalUARTPort("UART[0]","octalUart0",0, 9600,"N",2,8,"N") /* SRS 570 */
initOctalUARTPort("UART[1]","octalUart0",1, 9600,"N",2,8,"N") /* SRS 570 */
initOctalUARTPort("UART[2]","octalUart0",2,19200,"N",1,8,"N") /* Keithley 2000 */
initOctalUARTPort("UART[3]","octalUart0",3, 4800,"N",1,8,"N") /* Generic serial / LPC */
initOctalUARTPort("UART[4]","octalUart0",4,19200,"N",1,8,"N") /* Keithley 2000 */
initOctalUARTPort("UART[5]","octalUart0",5,19200,"N",1,8,"N") /* Keithley 2000 */
initOctalUARTPort("UART[6]","octalUart0",6, 9600,"N",2,8,"N") /* SRS 570 */
initOctalUARTPort("UART[7]","octalUart0",7, 9600,"N",1,8,"N") /* SMART PC */
initOctalUARTPort("UART[8]","octalUart1",0, 9600,"N",2,7,"N") /* Omega meter */
initOctalUARTPort("UART[9]","octalUart1",1, 9600,"N",1,8,"N") /* Unused */
initOctalUARTPort("UART[10]","octalUart1",2, 9600,"N",1,8,"N") /* Unused */
initOctalUARTPort("UART[11]","octalUart1",3, 9600,"N",1,8,"N") /* Unused */
initOctalUARTPort("UART[12]","octalUart1",4, 9600,"N",1,8,"N") /* Unused */
initOctalUARTPort("UART[13]","octalUart1",5, 9600,"N",1,8,"N") /* Unused */
initOctalUARTPort("UART[14]","octalUart1",6, 9600,"N",1,8,"N") /* Unused */
initOctalUARTPort("UART[15]","octalUart1",7, 9600,"N",1,8,"N") /* Unused */
initSerialServer("a-Serial[0]","UART[0]",1000,20,"\r",1)
initSerialServer("a-Serial[1]","UART[1]",1000,20,"\r",1)
initSerialServer("a-Serial[2]","UART[2]",1000,20,"\r",1)
initSerialServer("a-Serial[3]","UART[3]",1000,20,"\r",1)
initSerialServer("a-Serial[4]","UART[4]",1000,20,"\r",1)
initSerialServer("a-Serial[5]","UART[5]",1000,20,"\r",1)
initSerialServer("a-Serial[6]","UART[6]",1000,20,"\r",1)
initSerialServer("a-Serial[7]","UART[7]",1000,20,"\r",1)
initSerialServer("b-Serial[0]","UART[8]",1000,20,"\r",1)
initSerialServer("b-Serial[1]","UART[9]",1000,20,"\r",1)
initSerialServer("b-Serial[2]","UART[10]",1000,20,"\r",1)
initSerialServer("b-Serial[3]","UART[11]",1000,20,"\r",1)
initSerialServer("b-Serial[4]","UART[12]",1000,20,"\r",1)
initSerialServer("b-Serial[5]","UART[13]",1000,20,"\r",1)
initSerialServer("b-Serial[6]","UART[14]",1000,20,"\r",1)
initSerialServer("b-Serial[7]","UART[15]",1000,20,"\r",1)

# Initialize Systran DAC
pDAC128V = initDAC128V("d-DAC",carrier1,"IP_d",20)

# Initialize Acromag IP-330 ADC
pIp330 = initIp330("b-Ip330", carrier0,"IP_d","D","-5to5",0,15,10,120)
configIp330(pIp330, 3,"Input",1000,0)

initIp330Scan(pIp330,"b-Ip330Scan",0,15,100,20)

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
pIp330PID = initIp330PID("Ip330PID_1", pIp330, 0, pDAC128V, 1, 20)

# Initialize Greenspring IP-Unidig
# initIpUnidig(char *serverName, char *carrierName, char *siteName,
#              int queueSize)
# serverName  = name to give this server
# carrierName = name of IPAC carrier from initIpacCarrier above
# siteName    = name of IP site, e.g. "IP_a"
# queueSize   = size of output queue for EPICS
initIpUnidig("c-Unidig", carrier0, "IP_c", 20)

# DEBUGGING
#serialPortSniff("UART[3]",1000)
