routerInit
localMessageRouterStart(0)

ipacAddVIPC616_01("0x3000,0xa0000000")

# Initialize Octal UART stuff
tyGSOctalDrv 2
tyGSOctalModuleInit("GSIP_OCTAL232", 0x80, 0, 0)
tyGSOctalModuleInit("GSIP_OCTAL232", 0x81, 0, 1)

# int tyGSMPFInit(char *server, int uart, int channel, int baud, char parity, int sbits, 
#                 int dbits, char handshake, char *eomstr)
tyGSMPFInit("serial1",  0, 0,  9600,'E',1,7,'N',"") /* Digitel */
tyGSMPFInit("serial2",  0, 1, 19200,'E',1,8,'N',"")  /* MKS */
tyGSMPFInit("serial3",  0, 2,  9600,'E',1,7,'N',"")  /* Digitel */
tyGSMPFInit("serial4",  0, 3, 19200,'E',1,8,'N',"")  /* MKS */
tyGSMPFInit("serial5",  0, 4, 19200,'E',1,8,'N',"")  /* MKS */
tyGSMPFInit("serial6",  0, 5,  9600,'E',1,7,'N',"")  /* Digitel */
tyGSMPFInit("serial7",  0, 6, 19200,'E',1,8,'N',"")  /* MKS */
tyGSMPFInit("serial8",  0, 7,  9600,'E',1,7,'N',"")  /* Digitel */
tyGSMPFInit("serial9",  1, 0,  9600,'E',1,7,'N',"")  /* McClennan */
tyGSMPFInit("serial10", 1, 1, 19200,'N',1,8,'N',"")  /* Keithley 2000 */
tyGSMPFInit("serial11", 1, 2,  9600,'N',1,8,'N',"")  /* MPC */
tyGSMPFInit("serial12", 1, 3, 19200,'E',1,8,'N',"")  /* MKS */
tyGSMPFInit("serial13", 1, 4, 19200,'N',1,8,'N',"")  /* Keithley 2000 */
tyGSMPFInit("serial14", 1, 5,  9600,'N',1,8,'N',"")  /* Unused */
tyGSMPFInit("serial15", 1, 6,  9600,'N',1,8,'N',"")  /* Unused */
tyGSMPFInit("serial16", 1, 7,  9600,'N',1,8,'N',"")  /* Unused */

# Initialize Systran DAC
initDAC128V("DAC1",0,3,20)

# DEBUGGING
#serialPortSniff("UART[12]",1000)
