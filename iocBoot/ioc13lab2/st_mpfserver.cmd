# This loads the MPF server stuff

routerInit
localMessageRouterStart(0)

ipacAddVIPC616_01("0x3000,0xa0000000")

tyGSOctalDrv 1
tyGSOctalModuleInit("GSIP_OCTAL232", 0x80, 0, 0)

# int tyGSMPFInit(char *server, int uart, int channel, int baud, char parity, int sbits, 
#                 int dbits, char handshake, char *eomstr)
tyGSMPFInit("serial1",  0, 0, 9600,'E',1,7,'N',"")  /* Digitel */
tyGSMPFInit("serial2",  0, 1, 9600,'E',1,8,'N',"")  /* MKS */
tyGSMPFInit("serial3",  0, 2,19200,'N',1,8,'N',"")  /* Keithley 2000 */
tyGSMPFInit("serial4",  0, 3, 9600,'N',1,8,'N',"")  /* MPC */
tyGSMPFInit("serial5",  0, 4, 9600,'N',1,8,'N',"")  /* LAE500 */
tyGSMPFInit("serial6",  0, 5, 9600,'N',1,8,'N',"")  /* Unused */
tyGSMPFInit("serial7",  0, 6, 9600,'N',2,8,'N',"")  /* SRS 570 */
tyGSMPFInit("serial8",  0, 7, 9600,'N',2,8,'N',"")  /* SRS 570 */
