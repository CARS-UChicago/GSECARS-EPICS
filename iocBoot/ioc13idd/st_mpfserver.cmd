< cdCommands

< ../nfsServerCommandsGSE

cd topbin
# topbin is for the primary CPU arch, need to move to AUX CPU arch
ld < ../mv162/mpfLib 
ld < ../mv162/mpfServLib 

Ip330Debug=0
Ip330SweepDebug=0
Ip330SweepServerDebug=0
Ip330PIDServerDebug=0

carrier = "ipac"
ipacAddCarrier(&ipmv162, "A:l=3,3 m=0xe0000000,64;B:l=3,3 m=0xe0010000,64;C:l=3,3 m=0xe0020000,64;D:l=3,3 m=0xe0030000,64")
initIpacCarrier(carrier, 0)

routerInit
tcpMessageRouterServerStart(1,9900,"164.54.160.125",10000,100)

# Initialize GPIB stuff
#initGpibGsTi9914("GS-IP488-0",carrier,"IP_c",104)
#initGpibServer("GPIB0","GS-IP488-0",4096,1000)

# Initialize Octal UART stuff
initOctalUART("octalUart0",carrier,"IP_a",8,100)
#initOctalUART("octalUart1",carrier,"IP_b",8,101)
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
initSerialServer("a-Serial[0]","UART[0]",1000,20,"\r",1)
initSerialServer("a-Serial[1]","UART[1]",1000,20,"\r",1)
initSerialServer("a-Serial[2]","UART[2]",1000,20,"\r",1)
initSerialServer("a-Serial[3]","UART[3]",1000,20,"\r",1)
initSerialServer("a-Serial[4]","UART[4]",1000,20,"\r",1)
initSerialServer("a-Serial[5]","UART[5]",1000,20,"\r",1)
initSerialServer("a-Serial[6]","UART[6]",1000,20,"\r",1)
initSerialServer("a-Serial[7]","UART[7]",1000,20,"\r",1)

# Initialize Systran DAC
pDAC128V = initDAC128V("d-DAC",carrier,"IP_d",20)

# Initialize Acromag IP-330 ADC
pIp330 = initIp330("b-Ip330", carrier,"IP_b","D","-5to5",0,15,10,120)
configIp330(pIp330, 3,"Input",1000,0)

initIp330Scan(pIp330,"b-Ip330Scan",0,15,100,20)

initIp330Sweep(pIp330,"b-Ip330Sweep",0,3,2048,100)

pIp330PID = initIp330PID("Ip330PID_1", pIp330, 0, pDAC128V, 1, 20)
configIp330PID(pIp330PID, .1, 10., 0., 1000, 0, 500, 1500)

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
