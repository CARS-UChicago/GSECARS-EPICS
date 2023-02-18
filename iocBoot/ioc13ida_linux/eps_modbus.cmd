
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

# Read 300 bits starting at address 100.  Function code=1. MVI46 seems to interpret start address in bits, not words.
drvModbusAsynConfigure("MVI46_In_Bit",  "$(PORT)", 0, 1, 1600, 300, 0, 100, "MVI46")

# Write 200 bits starting at address 0.  Function code=5.
drvModbusAsynConfigure("MVI46_Out_Bit", "$(PORT)", 0, 5,    0, 200, 0, 100, "MVI46")

dbLoadRecords("$(CARS)/db/eps_valid.template", "P=$(P)")
dbLoadTemplate("eps_inputs.substitutions",     "P=$(P), PORT=MVI46_In_Bit")
dbLoadTemplate("eps_outputs.substitutions",    "P=$(P), PORT=MVI46_Out_Bit")
dbLoadTemplate("eps_valves.substitutions",     "P=$(P), IN_PORT=MVI46_In_Bit, OUT_PORT=MVI46_Out_Bit")
