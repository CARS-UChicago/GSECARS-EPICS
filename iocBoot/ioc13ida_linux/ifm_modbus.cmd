
# Use the following commands for TCP/IP
#drvAsynIPPortConfigure(const char *portName, 
#                       const char *hostInfo,
#                       unsigned int priority, 
#                       int noAutoConnect,
#                       int noProcessEos);
drvAsynIPPortConfigure("$(PORT)", "$(IPADDR):502", 0, 0, 0)
asynSetOption("$(PORT)", 0, "disconnectOnReadTimeout", "Y")

#modbusInterposeConfig(const char *portName, 
#                      modbusLinkType linkType,
#                      int timeoutMsec, 
#                      int writeDelayMsec)
modbusInterposeConfig("$(PORT)", 0, 5000, 0)

# Ports X01-X04
# Read 11 words starting at address 197.  Function code=3
drvModbusAsynConfigure("$(P)X01-X04_In",  "$(PORT)", 0, 3, 197, 11, 0, 100, "DL1342")

# Ports X05-X08
# Read 11 words starting at address 297.  Function code=3
drvModbusAsynConfigure("$(P)X05-X08_In",  "$(PORT)", 0, 3, 297, 11, 0, 100, "DL1342")

drvIFM_AL1342Configure("$(P)X01-X08_Config", $(PORT))
asynSetTraceIOMask("$(P)X01-X08_Config", -1, ESCAPE)
asynSetTraceMask("$(P)X01-X08_Config", -1, DRIVER|ERROR)
