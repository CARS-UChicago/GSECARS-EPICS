epicsEnvSet("PORT", "VINDUM")
epicsEnvSet("POLL_MS", "100")
epicsEnvSet("TIMEOUT_MS", "2000")

# We are using a terminal server to connect to the serial port on the pump.
# Use the following commands for TCP/IP
#drvAsynIPPortConfigure(const char *portName, 
#                       const char *hostInfo,
#                       unsigned int priority, 
#                       int noAutoConnect,
#                       int noProcessEos);

# The terminal server should be set to 38400, 8, 1, N
# Change IP address for your device
drvAsynIPPortConfigure("$(PORT)", "gsets22:4002", 0, 0, 0)

# This is for a COM port on Windows
#drvAsynSerialPortConfigure("$(PORT)", "COM2", 0, 0, 0)

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

modbusInterposeConfig("$(PORT)", 1, $(TIMEOUT_MS), 0)

### The VP pump supports the following modbus function codes
#    01 - read discrete coils
#    04 - read analog input registers
#    05 - write single discrete output coil
#    06 - write single register
#    16 - write multiple registers (limited to single parameter)

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

# Read 31 bits starting at address 0. Function code=1. Default data type=UINT16
drvModbusAsynConfigure("$(PORT)_ReadCoils", "$(PORT)", 1, 1, 0, 31, UINT16, $(POLL_MS), "Vindum")
dbLoadTemplate("$(SYRINGEPUMP)/db/VindumReadCoils.substitutions", "P=$(VINDUM_PREFIX), PORT=$(PORT)_ReadCoils")

# Write 31 bits starting at address 0. Function code=5. Default data type=UINT16
drvModbusAsynConfigure("$(PORT)_WriteCoils", "$(PORT)", 1, 5, 0, 31, UINT16, $(POLL_MS), "Vindum")
dbLoadTemplate("$(SYRINGEPUMP)/db/VindumWriteCoils.substitutions", "P=$(VINDUM_PREFIX), PORT=$(PORT)_WriteCoils")

# Read 6 bits starting at address 0. Function code=2. Default data type=UINT16
drvModbusAsynConfigure("$(PORT)_ReadContacts", "$(PORT)", 1, 2, 0, 6, UINT16, $(POLL_MS), "Vindum")
dbLoadTemplate("$(SYRINGEPUMP)/db/VindumReadContacts.substitutions", "P=$(VINDUM_PREFIX), PORT=$(PORT)_ReadContacts")

# Read 42 16-bit analog input registers starting at 0. Function code=4. Default data type=UINT16
drvModbusAsynConfigure("$(PORT)_ReadInputRegs", "$(PORT)", 1, 4, 0, 42, UINT16, $(POLL_MS), "Vindum")
dbLoadTemplate("$(SYRINGEPUMP)/db/VindumReadInputRegisters.substitutions", "P=$(VINDUM_PREFIX), PORT=$(PORT)_ReadInputRegs")

# Read 38 16-bit holding registers starting at 0. Function code=3. Default data type=UINT16
drvModbusAsynConfigure("$(PORT)_ReadHoldingRegs", "$(PORT)", 1, 3, 0, 38, UINT16, $(POLL_MS), "Vindum")
dbLoadTemplate("$(SYRINGEPUMP)/db/VindumReadHoldingRegisters.substitutions", "P=$(VINDUM_PREFIX), PORT=$(PORT)_ReadHoldingRegs")

# Write 38 16-bit holding registers starting at 0. Function code=16. Default data type=UINT16
drvModbusAsynConfigure("$(PORT)_WriteHoldingRegs", "$(PORT)", 1, 16, 0, 38, UINT16, $(POLL_MS), "Vindum")
dbLoadTemplate("$(SYRINGEPUMP)/db/VindumWriteHoldingRegisters.substitutions", "P=$(VINDUM_PREFIX), PORT=$(PORT)_WriteHoldingRegs")

dbLoadRecords("$(SYRINGEPUMP)/db/VindumController.template", "P=$(VINDUM_PREFIX), PORT=$(PORT)")
dbLoadRecords("$(SYRINGEPUMP)/db/VindumPumpN.template", "P=$(VINDUM_PREFIX), PORT=$(PORT), PUMP=A:")
dbLoadRecords("$(SYRINGEPUMP)/db/VindumPumpN.template", "P=$(VINDUM_PREFIX), PORT=$(PORT), PUMP=B:")
