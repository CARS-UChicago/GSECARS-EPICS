drvAsynIPPortConfigure("Click","164.54.160.220:502",0,0,1)
asynWaitConnect("Click",2)
asynSetOption("Click",0, "disconnectOnReadTimeout", "Y")
asynSetQueueLockPortTimeout("Click", 1)
modbusInterposeConfig("Click",0,0)

# NOTE: We use hex numbers for the start address to be consistent with the Click nomenclature.  

# The Click has bit access to the Xn inputs at Modbus offset 0x0000
# Read 128 bits (X001-X332).  Function code=2.
drvModbusAsynConfigure("C1_Xn_Bit",        "Click", 0, 2, 0x0000, 128, "UINT16", 100, "Click")

# The Click has bit access to the Cn bits at Modbus offset 0x4000
# Access 112 bits (C1-C112) as inputs.  Function code=1.
drvModbusAsynConfigure("C1_Cn_In_Bit",     "Click", 0, 1, 0x4000, 112, "UINT16", 100, "Click")

# Access the same 112 bits (C1-C112) as outputs.  Function code=5.
drvModbusAsynConfigure("C1_Cn_Out_Bit",    "Click", 0, 5, 0x4000, 112, "UINT16",   1, "Click")

# The Click has word access to the DSn words at Modbus offset 0x0000
# Access the first 25 words as inputs.  Function code=3
drvModbusAsynConfigure("C1_DSn1_In_Word",  "Click", 0, 3, 0x0000,  25, "UINT16", 100, "Click")

# Access the first 25 words as outputs.  Function code=6
drvModbusAsynConfigure("C1_DSn1_Out_Word", "Click", 0, 6, 0x0000,  25, "UINT16",   1, "Click")

# Access 40 words starting at 0x63 (99) as inputs.  Function code=3
drvModbusAsynConfigure("C1_DSn2_In_Word",  "Click", 0, 3, 0x0063,  40, "UINT16", 100, "Click")

# Access 40 words starting at 0x63 (99) as outputs.  Function code=6
drvModbusAsynConfigure("C1_DSn2_Out_Word", "Click", 0, 6, 0x0063,  40, "UINT16",   1, "Click")

# The Click has word access to the DDn words at Modbus offset 0x4000
# Access the first 2 words as inputs.  Function code=3
drvModbusAsynConfigure("C1_DDn1_In_Word",  "Click", 0, 3, 0x4000,   6, "UINT16", 20, "Click")

# The Click has word access to the DFn words at Modbus offset 0x7000
# Access the first 100 words as inputs.  Function code=3
drvModbusAsynConfigure("C1_DFn1_In_Word",  "Click", 0, 3, 0x7000, 125, "UINT16", 100, "Click")

# Access the next 44 words as inputs.  Function code=3
drvModbusAsynConfigure("C1_DFn2_In_Word",  "Click", 0, 3, 0x7064,  44, "UINT16", 100, "Click")

# Hex trace format on TCP server
asynSetTraceIOMask("Click",0,HEX)
# Turn on asynError and asynTraceIODriver on TCP server
#asynSetTraceMask("Click",0,ERROR|DRIVER)

dbLoadTemplate("Click.substitutions", "P=$(P)")
