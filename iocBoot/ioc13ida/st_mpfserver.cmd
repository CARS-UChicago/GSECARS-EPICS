routerInit
localMessageRouterStart(0)

ipacAddVIPC616_01("0x3000,0xa0000000")

# Initialize Octal UART stuff
tyGSOctalDrv 2
tyGSOctalModuleInit("GSIP_OCTAL232", 0x80, 0, 0)
tyGSOctalModuleInit("GSIP_OCTAL232", 0x81, 0, 1)

tyGSMPFInit("serial1",   0, 0,19200,'E',1,8,'N',"") /* MKS */
tyGSMPFInit("serial2",   0, 1,19200,'E',1,8,'N',"") /* MKS */
tyGSMPFInit("serial3",   0, 2, 9600,'E',1,7,'N',"") /* Digitel */
tyGSMPFInit("serial4",   0, 3, 9600,'E',1,7,'N',"") /* Digitel */
tyGSMPFInit("serial5",   0, 4,19200,'E',1,8,'N',"") /* MKS */
tyGSMPFInit("serial6",   0, 5, 9600,'E',1,7,'N',"") /* Digitel */
tyGSMPFInit("serial7",   0, 6, 9600,'N',1,8,'N',"") /* MPC */
tyGSMPFInit("serial8",   0, 7, 9600,'E',1,7,'N',"") /* McClennan PM304 */
tyGSMPFInit("serial9",   1, 0,19200,'N',1,8,'N',"") /* Keithley 2000 */
tyGSMPFInit("serial10",  1, 1, 9600,'N',1,8,'N',"") /* Oxford ILM cryometer */
tyGSMPFInit("serial11",  1, 2,19200,'E',1,8,'N',"") /* MKS */
tyGSMPFInit("serial12",  1, 3, 9600,'N',1,8,'N',"") /* MPC */
tyGSMPFInit("serial13",  1, 4,19200,'N',1,8,'N',"") /* Keithley 2000 */

# Initialize Greenspring IP-Unidig
# initIpUnidig(char *serverName,
#              int carrier,
#              int slot,
#              int queueSize,
#              int msecPoll,
#              int intVec,
#              int risingMask,
#              int fallingMask,
#              int biMask,
#              int maxClients)
# serverName  = name to give this server
# carrier     = IPAC carrier number (0, 1, etc.)
# slot        = IPAC slot (0,1,2,3, etc.)
# queueSize   = size of output queue for EPICS
# msecPoll    = polling time for input bits in msec.  Default=100.
# intVec      = interrupt vector
# risingMask  = mask of bits to generate interrupts on low to high (24 bits)
# fallingMask = mask of bits to generate interrupts on high to low (24 bits)
# biMask      = mask of bits to generate callbacks to bi record support
#               This can be a subset of (risingMask | fallingMask)
# maxClients  = Maximum number of callback tasks which will attach to this
#               IpUnidig server.  This
#               does not refer to the number of EPICS clients.  A value of
#               10 should certainly be safe.
initIpUnidig("Unidig1", 0, 2, 20, 2000, 116, 0x0, 0x0, 0x0, 10)

# Initialize Systran DAC
initDAC128V("DAC1",0,3,20)


# DEBUGGING
#serialPortPeek("serial1",1000)

