< cdCommands

< ../nfsServerCommandsGSE

cd topbin
# topbin is for the primary CPU arch, need to move to AUX CPU arch
ld < ../mv162/mpfLib 
ld < ../mv162/mpfServLib 

carrier = "ipac"
ipacAddCarrier(&ipmv162, "A:l=3,3 m=0xe0000000,64;B:l=3,3 m=0xe0010000,64;C:l=3,3 m=0xe0020000,64;D:l=3,3 m=0xe0030000,64")
initIpacCarrier(carrier, 0)

routerInit
tcpMessageRouterServerStart(1,9900,"164.54.160.118",10000,100)

# Initialize Octal UART stuff
# initOctalUART(char *moduleName, char *carrierName, char *siteName, 
#               int nports, int intVec)
# moduleName  = name to give this module
# carrierName = name of IPAC carrier from initIpacCarrier above
# siteName    = name of IP site, e.g. "IP_a"
# nports      = number of ports
# intVec      = interrupt vector. Remember to give each module a different
#               interrupt vector
initOctalUART("octalUart0",carrier,"IP_a",8,100)

# initOctalUARTPort(char* portName,char* moduleName,int port,int baud,
#                   char* parity,int stop_bits,int bits_char,char* flow_control)
# portName     = name to give this port
# moduleName   = name given in initOctalUART above
# baud         = baud rate (1200, 2400, 4800, 9600, 19200, or 38400)
# parity       = "E" for even, "O" for odd, "N" for none
# stop_bits    = 1 or 2
# bits_char    = bit per character (5,6,7, or 8)
# flow_control = "N" for none, "H" for hardware
initOctalUARTPort("UART[0]","octalUart0",0, 9600,"N",1,8,"N") /* SMART PC */
initOctalUARTPort("UART[1]","octalUart0",1, 9600,"N",1,8,"N") /* LAE500 */
initOctalUARTPort("UART[2]","octalUart0",2,19200,"E",1,8,"N") /* MKS */
initOctalUARTPort("UART[3]","octalUart0",3,19200,"N",1,8,"N") /* RSF715 */
initOctalUARTPort("UART[4]","octalUart0",4,19200,"E",1,8,"N") /* MKS */
initOctalUARTPort("UART[5]","octalUart0",5, 9600,"N",1,8,"N") /* Keithley 2000 */
initOctalUARTPort("UART[6]","octalUart0",6, 9600,"N",1,8,"N") /* Keithley 2000 */
initOctalUARTPort("UART[7]","octalUart0",7, 9600,"N",1,8,"N") /* SRS */

# initSerialServer(char *serverName,char *portName,int bufSize,
#                  int queueSize, char *eomstr, 
#                  int circularBufferMode)
# serverName = name to give this server
# portName   = name given in initOctalUARTPort above
# bufSize    = size of input buffer
# queueSize  = size of output queue for EPICS
# eomstr     = input string terminator
# circularBufferMode = 0 to disable, 1 to enable
initSerialServer("a-Serial[0]","UART[0]",1000,20,"\r",1)
initSerialServer("a-Serial[1]","UART[1]",1000,20,"\r",1)
initSerialServer("a-Serial[2]","UART[2]",1000,20,"\r",1)
initSerialServer("a-Serial[3]","UART[3]",1000,20,"\r",1)
initSerialServer("a-Serial[4]","UART[4]",1000,20,"\r",1)
initSerialServer("a-Serial[5]","UART[5]",1000,20,"\r",1)
initSerialServer("a-Serial[6]","UART[6]",1000,20,"\r",1)
initSerialServer("a-Serial[7]","UART[7]",1000,20,"\r",1)

# DEBUGGING
#serialPortSniff("UART[0]",1000)
