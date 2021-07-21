epicsEnvSet("PORT", "VINDUM")
epicsEnvSet("POLL_MS", "1000")
epicsEnvSet("TIMEOUT_MS", "2000")

# Use the following commands for TCP/IP
#drvAsynIPPortConfigure(const char *portName, 
#                       const char *hostInfo,
#                       unsigned int priority, 
#                       int noAutoConnect,
#                       int noProcessEos);

# Change IP address for your device
drvAsynIPPortConfigure("$(PORT)", "10.54.160.222:502", 0, 0, 0)

# Enable ASYN_TRACEIO_HEX on octet server
asynSetTraceIOMask("$(PORT)", 0, HEX)

# Enable ASYN_TRACE_ERROR and ASYN_TRACEIO_DRIVER on octet server
asynSetTraceMask("$(PORT)", 0, ERROR|DRIVER)

# Set maximum number of bytes to save
asynSetTraceIOTruncateSize("$(PORT)", 0, 256)

# Send output to a text file
asynSetTraceFile("$(PORT)", 0, "Vindum_Modbus_comms.txt")

#asynSetOption($(PORT), 0, "disconnectOnReadTimeout", "Y")

#modbusInterposeConfig(const char *portName, 
#                      modbusLinkType linkType,
#                      int timeoutMsec,
#                      int writeDelayMsec)

modbusInterposeConfig("$(PORT)", 0, $(TIMEOUT_MS), 0)

### The syringe pump supports the following modbus function codes:
#    01 - read discrete output coils
#    03 - read analog output holding registers
#    05 - write single discrete output coil
#    15 - write multiple discrete output coils
#    16 - write multiple analog output holding registers

# drvModbusAsynConfigure(
#   char *portName,
#   char *octetPortName,
#   int modbusSlave,
#   int modbusFunction,
#   int modbusStartAddress,
#   int modbusLength,
#   modbusDataType dataType,
#   int pollMsec,
#   char *plcType)

# Access 124 16-bit input registers starting at 0 as inputs. Function code=3. Default data type=UINT16
drvModbusAsynConfigure("$(PORT)_ReadInputRegs", "$(PORT)", 1, 4, 0, 124, UINT16, $(POLL_MS), "Anybus")

# Load the substitutions files for the Modbus read holding registers records
dbLoadTemplate("$(SYRINGEPUMP)/db/VindumReadInputRegisters.substitutions", "P=$(VINDUM_PREFIX), PORT=$(PORT)_ReadInputRegs")

# Access 25 16-bit holding registers starting at 0 as outputs. Function code=16. Default data type=UINT16
# Note that with this function code these map to Asynbus addresss starting at 0x200.
drvModbusAsynConfigure("$(PORT)_WriteHoldingRegs", "$(PORT)", 1, 16, 0, 25, UINT16, 1, "Anybus")

# Load the substitutions files for the Modbus write holding registers records
dbLoadTemplate("$(SYRINGEPUMP)/db/VindumWriteHoldingRegisters.substitutions", "P=$(VINDUM_PREFIX), PORT=$(PORT)_WriteHoldingRegs")

# Access 25 16-bit holding registers starting at 0 as inputs. Function code=3. Default data type=UINT16
# Note that with this function code these map to Asynbus addresss starting at 0x200.
drvModbusAsynConfigure("$(PORT)_ReadHoldingRegs", "$(PORT)", 1, 3, 0, 25, UINT16, $(POLL_MS), "Anybus")

# Load the substitutions files for the Modbus read holding registers records
dbLoadTemplate("$(SYRINGEPUMP)/db/VindumReadHoldingRegisters.substitutions", "P=$(VINDUM_PREFIX), PORT=$(PORT)_ReadHoldingRegs")

# Load the database files for the other records
dbLoadRecords("$(SYRINGEPUMP)/db/VindumController.template", "P=$(VINDUM_PREFIX)")
dbLoadRecords("$(SYRINGEPUMP)/db/VindumPumpN.template", "P=$(VINDUM_PREFIX), PUMP=A:")
dbLoadRecords("$(SYRINGEPUMP)/db/VindumPumpN.template", "P=$(VINDUM_PREFIX), PUMP=B:")

