epicsEnvSet("PORT", "MVI46_2")
# Use the following commands for TCP/IP
#drvAsynIPPortConfigure(const char *portName, 
#                       const char *hostInfo,
#                       unsigned int priority, 
#                       int noAutoConnect,
#                       int noProcessEos);
drvAsynIPPortConfigure("$(PORT)","gse-mvi46-mnet-2:502",0,0,0)
asynSetOption("$(PORT)",0, "disconnectOnReadTimeout", "Y")
#modbusInterposeConfig(const char *portName, 
#                      modbusLinkType linkType,
#                      int timeoutMsec, 
#                      int writeDelayMsec)
modbusInterposeConfig("$(PORT)",0,5000,0)

# Read 10 words at address 100.  Function code=3.
drvModbusAsynConfigure("MVI46_In_Word", "$(PORT)", 0, 3, 100, 10, 0,  100, "MVI46")

# Read 200 bits starting at address 100.  Function code=1. MVI46 seems to interpret start address in bits, not works.
drvModbusAsynConfigure("MVI46_In_Bit", "$(PORT)", 0, 1, 1600, 200, 0,  100, "MVI46")

# Write 10 words at address 0.  Function code=6.
drvModbusAsynConfigure("MVI46_Out_Word", "$(PORT)", 0, 6, 0, 10, 0, 100, "MVI46")

# Write 200 bits starting at address 0.  Function code=5.
drvModbusAsynConfigure("MVI46_Out_Bit", "$(PORT)", 0, 5, 0, 200, 0, 100, "MVI46")

dbLoadRecords("$(CARS)/db/eps_valid.db", "P=$(PREFIX)")
dbLoadTemplate("eps_inputs.substitutions", "P=$(PREFIX), PORT=MVI46_In_Bit")
dbLoadTemplate("eps_outputs.substitutions", "P=$(PREFIX), PORT=MVI46_Out_Bit")
dbLoadTemplate("eps_valves.substitutions", "P=$(PREFIX), IN_PORT=MVI46_In_Bit, OUT_PORT=MVI46_Out_Bit")
