# This loads the MPF server stuff

cd topbin
ld < mpfServLib 

routerInit
localMessageRouterStart(0)

carrier = "ipac"
ipacAddCarrier(&vipc616_01, "0x6000,0xa0000000")
initIpacCarrier(carrier, 0)

# Initialize Octal UART stuff
initOctalUART("octalUart0",carrier,"IP_a",8,100)
# initOctalUARTPort(char* portName,char* moduleName,int port,int baud,
#                   char* parity,int stop_bits,int bits_char,char* flow_control)
# 'baud' is the baud rate. 1200, 2400, 4800, 9600, 19200, 38400
# 'parity' is "E" for even, "O" for odd, "N" for none.
# 'bits_per_character' = {5,6,7,8}
# 'stop_bits' = {1,2}
# 'flow_control' is "N" for none, "H" for hardware
initOctalUARTPort("UART[0]","octalUart0",0, 9600,"E",1,7,"N") /* Digitel */
initOctalUARTPort("UART[1]","octalUart0",1,19200,"E",1,8,"N") /* MKS */
initOctalUARTPort("UART[2]","octalUart0",2,19200,"N",1,8,"N") /* Keithley 2000 */
initOctalUARTPort("UART[3]","octalUart0",3, 9600,"N",1,8,"N") /* MPC */
initOctalUARTPort("UART[4]","octalUart0",4, 9600,"N",1,8,"N") /* LAE500 */
initOctalUARTPort("UART[5]","octalUart0",5,19200,"N",1,8,"N") /* unused */
initOctalUARTPort("UART[6]","octalUart0",6, 9600,"N",1,8,"N") /* unused */
initOctalUARTPort("UART[7]","octalUart0",7, 9600,"N",1,8,"N") /* unused */
initSerialServer("a-Serial[0]","UART[0]",1000,20,"\r",1)
#initMPCServer("a-Serial[0]","UART[0]",20)
initSerialServer("a-Serial[1]","UART[1]",1000,20,"\r",1)
initSerialServer("a-Serial[2]","UART[2]",1000,20,"\r",1)
initMPCServer("a-Serial[3]","UART[3]",20)
#initSerialServer("a-Serial[3]","UART[3]",1000,20,"\r",1)
initSerialServer("a-Serial[4]","UART[4]",1000,20,"\r",1)
initSerialServer("a-Serial[5]","UART[5]",1000,20,"\r",1)
initSerialServer("a-Serial[6]","UART[6]",1000,20,"\r",1)
initSerialServer("a-Serial[7]","UART[7]",1000,20,"\r",1)
