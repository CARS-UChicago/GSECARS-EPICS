cd topbin
# This loads the MPF server stuff
ld < mpfServLib 

routerInit
localMessageRouterStart(0)

carrier = "ipac"
ipacAddCarrier(&vipc616_01, "0x3000,0xa0000000")
initIpacCarrier(carrier, 0)

# Initialize GPIB stuff
#initGpibGsTi9914("GS-IP488-0",carrier,"IP_c",104)
#initGpibServer("GPIB0","GS-IP488-0",1024,1000)

# Initialize Octal UART stuff
initOctalUART("octalUart0",carrier,"IP_a",8,100)
initOctalUART("octalUart1",carrier,"IP_b",8,101)
# initOctalUARTPort(char* portName,char* moduleName,int port,int baud,
#                   char* parity,int stop_bits,int bits_char,char* flow_control)
# 'baud' is the baud rate. 1200, 2400, 4800, 9600, 19200, 38400
# 'parity' is "E" for even, "O" for odd, "N" for none.
# 'bits_per_character' = {5,6,7,8}
# 'stop_bits' = {1,2}
# 'flow_control' is "N" for none, "H" for hardware
initOctalUARTPort("UART[0]","octalUart0",0,19200,"E",1,8,"N") /* MKS */
initOctalUARTPort("UART[1]","octalUart0",1,19200,"E",1,8,"N") /* MKS */
initOctalUARTPort("UART[2]","octalUart0",2, 9600,"E",1,7,"N") /* Digitel */
initOctalUARTPort("UART[3]","octalUart0",3, 9600,"E",1,7,"N") /* Digitel */
initOctalUARTPort("UART[4]","octalUart0",4,19200,"E",1,8,"N") /* MKS */
initOctalUARTPort("UART[5]","octalUart0",5, 9600,"E",1,7,"N") /* Digitel */
initOctalUARTPort("UART[6]","octalUart0",6, 9600,"N",1,8,"N") /* MPC */
initOctalUARTPort("UART[7]","octalUart0",7, 9600,"E",1,7,"N") /* McClennan PM304 */
initSerialServer("a-Serial[0]","UART[0]",1000,20,"\r",1)
initSerialServer("a-Serial[1]","UART[1]",1000,20,"\r",1)
initSerialServer("a-Serial[2]","UART[2]",1000,20,"\r",1)
initSerialServer("a-Serial[3]","UART[3]",1000,20,"\r",1)
initSerialServer("a-Serial[4]","UART[4]",1000,20,"\r",1)
initSerialServer("a-Serial[5]","UART[5]",1000,20,"\r",1)
#initSerialServer("a-Serial[6]","UART[6]",1000,20,"\r",1)
initMPCServer("a-Serial[6]","UART[6]",20)
initSerialServer("a-Serial[7]","UART[7]",1000,20,"\r",1)

initOctalUARTPort("UART[8]", "octalUart1",0,19200,"N",1,8,"N") /* Keithley 2000 */
initOctalUARTPort("UART[9]", "octalUart1",1, 9600,"N",1,8,"N") /* Oxford ILM cryometer */
initOctalUARTPort("UART[10]","octalUart1",2,19200,"E",1,8,"N") /* MKS */
initOctalUARTPort("UART[11]","octalUart1",3, 9600,"N",1,8,"N") /* MPC */
initOctalUARTPort("UART[12]","octalUart1",4,19200,"N",1,8,"N") /* Keithley 2000 */
initSerialServer("b-Serial[0]","UART[8]", 1000,20,"\r",1)
initSerialServer("b-Serial[1]","UART[9]", 1000,20,"\r",1)
initSerialServer("b-Serial[2]","UART[10]",1000,20,"\r",1)
# b-Serial[3] uses the MPF server and needs a larger queue
initMPCServer("b-Serial[3]","UART[11]",60)
initSerialServer("b-Serial[4]","UART[12]", 1000,20,"\r",1)

# Initialize Systran DAC
# initDAC128V(char *serverName, char *carrierName, char *siteName,
#             int queueSize)
# serverName  = name to give this server
# carrierName = name of IPAC carrier from initIpacCarrier above
# siteName    = name of IP site, e.g. "IP_a"
# queueSize   = size of output queue for EPICS
#
pDAC128V = initDAC128V("d-DAC",carrier,"IP_d",20)

# DEBUGGING
#serialPortSniff("UART[3]",1000)

