ipacAddVIPC616_01("0x3000,0xa0000000")

# Initialize Octal UART stuff
tyGSOctalDrv 2
# Initialize IP Octal modules.
# ----------------------------
# tyGSOctalModuleInit(char *moduleID, char *ModuleType, int irq_num,
#                     char *carrier#, int slot#)
#   moduleID   - assign the IP module a name for future reference.
#   ModuleType - "232", "422", or "485".
#   irq_num    - interrupt request number.
#   carrier#   - carrier# assigned from the ipacAddCarrierType() call.
#   slot#      - slot number on carrier; slot[A,B,C,D] -> slot#[0,1,2,3].
tyGSOctalModuleInit("UART0", "232", 0x80, 0, 0)
tyGSOctalModuleInit("UART1", "232", 0x81, 0, 1)

# Initialize Systran DAC
# initDAC128V(char *portName, int carrier, int slot)
# portName  = name to give this asyn port
# carrier     = IPAC carrier number (0, 1, etc.)
# slot        = IPAC slot (0,1,2,3, etc.)
initDAC128V("DAC1",0,3)
dbLoadTemplate "DAC.template"

# Initialize Greenspring IP-Unidig
# initIpUnidig(char *portName,
#              int carrier,
#              int slot,
#              int msecPoll,
#              int intVec,
#              int risingMask,
#              int fallingMask)
# portName  = name to give this asyn port
# carrier     = IPAC carrier number (0, 1, etc.)
# slot        = IPAC slot (0,1,2,3, etc.)
# msecPoll    = polling time for input bits that don't use interrupts in msec.
# intVec      = interrupt vector
# risingMask  = mask of bits to generate interrupts on low to high (24 bits)
# fallingMask = mask of bits to generate interrupts on high to low (24 bits)

# Note: We have the quadEM connected to channel 0.  Its driver will
# enable interrupts on one edge of the pulses, so we don't need to do it here.  All other
# inputs generate interrupts on both rising and falling edge
initIpUnidig("Unidig1", 0, 2, 2000, 116, 0xfffffe, 0xfffffe)
dbLoadTemplate "ipUnidig.substitutions"
