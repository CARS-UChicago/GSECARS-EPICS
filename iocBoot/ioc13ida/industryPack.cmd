ipacAddVIPC616_01("0x3000,0xa0000000")

# Initialize Octal UART stuff
tyGSOctalDrv 2
tyGSOctalModuleInit("GSIP_OCTAL232", 0x80, 0, 0)
tyGSOctalModuleInit("GSIP_OCTAL232", 0x81, 0, 1)

# Initialize Greenspring IP-Unidig
# initIpUnidig(char *portName,
#              int carrier,
#              int slot,
#              int msecPoll,
#              int intVec,
#              int risingMask,
#              int fallingMask)
# portName    = name to give this asyn port
# carrier     = IPAC carrier number (0, 1, etc.)
# slot        = IPAC slot (0,1,2,3, etc.)
# msecPoll    = polling time for input bits in msec.  Default=100.
# intVec      = interrupt vector
# risingMask  = mask of bits to generate interrupts on low to high (24 bits)
# fallingMask = mask of bits to generate interrupts on high to low (24 bits)
initIpUnidig("Unidig1", 0, 2, 2000, 116, 0x0, 0x0)

# Initialize Systran DAC
initDAC128V("DAC1",0,3)
