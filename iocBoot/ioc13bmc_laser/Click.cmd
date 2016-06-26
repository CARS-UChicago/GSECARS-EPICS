drvAsynIPPortConfigure("Click","164.54.160.98:502",0,0,1)
asynWaitConnect("Click",2)
modbusInterposeConfig("Click",0,0)

# The Click has bit access to the Cn bits at Modbus offset 16484 (Dec)
# Access 256 bits (C100-C200) as inputs.  Function code=1.
drvModbusAsynConfigure("Click1_Cn_In_Bit",   "Click", 0, 1,  16483, 256,   0,  100, "Click")

# Access the same 256 bits (C100-C200) as outputs.  Function code=5.
drvModbusAsynConfigure("Click1_Cn_Out_Bit",  "Click", 0, 5,  16483, 256,   0,  1,  "Click")

# Hex trace format on TCP server
asynSetTraceIOMask("Click",0,4)
# Turn on asynError and asynTraceIODriver on TCP server
#asynSetTraceMask("Click",0,9)

dbLoadTemplate("Click.substitutions")
