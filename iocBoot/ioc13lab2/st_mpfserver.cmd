# This loads the MPF server stuff

routerInit
localMessageRouterStart(0)

ipacAddVIPC616_01("0x3000,0xa0000000")

tyGSOctalDrv 1
tyGSOctalModuleInit("GSIP_OCTAL232", 0x80, 0, 0)

# int tyGSMPFInit(char *server, int uart, int channel, int baud, char parity, int sbits, 
#                 int dbits, char handshake, char *eomstr)
tyGSMPFInit("serial1",  0, 0,19200,'N',1,8,'N',"")  /* Keithley */
tyGSMPFInit("serial2",  0, 1, 9600,'N',2,8,'N',"")  /* SRS 570 */
tyGSMPFInit("serial3",  0, 2, 9600,'N',2,8,'N',"")  /* SRS 570 */
tyGSMPFInit("serial4",  0, 3, 9600,'N',1,8,'N',"")  /* LAE500 */
tyGSMPFInit("serial5",  0, 4, 9600,'N',1,8,'N',"")  /* Unused */
tyGSMPFInit("serial6",  0, 5, 9600,'N',1,8,'N',"")  /* Unused */
tyGSMPFInit("serial7",  0, 6, 9600,'N',2,8,'N',"")  /* Unused */
tyGSMPFInit("serial8",  0, 7, 9600,'N',2,8,'N',"")  /* Unused */

# Initialize Acromag IP-330 ADC
# Ip330 *initIp330(
#   const char *moduleName, int carrier, int slot,
#   const char *typeString, const char *rangeString,
#   int firstChan, int lastChan,
#   int maxClients, int intVec)
# function return value  = pointer to the Ip330 object, needed by configIp330
#                          and to initialize the application-specific classes
# serverName  = name to give this server
# carrier     = IPAC carrier number (0, 1, etc.)
# slot        = IPAC slot (0,1,2,3, etc.)
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
initIp330("Ip330_1",0,1,"D","-5to5",0,15,10,120)

# int configIp330(
#   Ip330 *pIp330,
#   int scanMode, const char *triggerString,
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
configIp330("Ip330_1", 3,"Input",500,0)

# int initIp330Scan(
#      Ip330 *pIp330, const char *serverName, int firstChan, int lastChan,
#      int queueSize)
# pIp330     = pointer returned by initIp330 above
# serverName = name to give this server.  Must match the INP parm field in
#              EPICS records
# firstChan  = first channel to be used by Ip330Scan.  This must be in the
#              range firstChan to lastChan specified in initIp330
# lastChan   = last channel to be used by Ip330Scan.  This must be in the range
#              firstChan to lastChan specified in initIp330
# queueSize  = size of output queue for MPF. Make this the maximum number
#              of ai records attached to this server.
initIp330Scan("Ip330_1","Ip330Scan1",0,15,100)

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
initIp330Sweep("Ip330_1","Ip330Sweep1",0,3,2048,100)

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
#initIp330PID("Ip330PID1", "Ip330_1", 0, "DAC1", 0, 20)
