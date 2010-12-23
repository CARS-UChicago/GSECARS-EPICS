# BEGIN softGlue.cmd ----------------------------------------------------------
# This must run after industryPack.cmd

#devAsynSoftGlueDebug=1
#drvIP_EP201Debug=1

# Write content to the FPGA.    This command will fail if the FPGA already has
# content loaded, as it will after a soft reboot.  To load new FPGA content,
# you must power cycle the ioc.
# initIP_EP200_FPGA(ushort_t carrier, ushort_t slot, char *filename)

# Standard softGlue 2.1
initIP_EP200_FPGA(1, 2, "$(SOFTGLUE)/softGlueApp/Db/SoftGlue_2_1.hex")
# SoftGlue 2.0 with octupole additions (shift registers)
#initIP_EP200_FPGA(1, 2, "$(SOFTGLUE)/softGlueApp/Db/SoftGlue_2_0_1_Octupole_0_0.hex")

# Each instance of a fieldIO_registerSet component is initialized as follows:
#
#int initIP_EP201(const char *portName, ushort_t carrier, ushort_t slot,
#	int msecPoll, int dataDir, int sopcOffset, int interruptVector,
#	int risingMask, int fallingMask)
# Note that while the addresses and interrupt vector look adjustable, they
# really are not.  Also note that the user can overwrite risingMask and
# fallingMask, and probably has these registers autosaved.
#
# dataDir: bits 0 and 8 are the only ones that matter.  The meaning depends on
# which IP module is in use.
#     IP-EP201:
#         If bit 0 is set, I/O bits 0...7 are outputs, else they're inputs.
#         If bit 8 is set, I/O bits 8...15 are outputs, else they're inputs.

# bits 1-16 are inputs
initIP_EP201("SGIO_1",1,2,1000000,0x0000,0x800000,0x90,0x00,0x00)
# bits 33-48 are outputs
initIP_EP201("SGIO_2",1,2,1000000,0x0101,0x800010,0x91,0x00,0x00)
initIP_EP201("SGIO_3",1,2,1000000,0x0101,0x800020,0x92,0x00,0x00)

# All instances of a single-register component are initialized with a single
# call, as follows:
#
#initIP_EP201SingleRegisterPort(const char *portName, ushort_t carrier,
#	ushort_t slot)
#
# For example:
# initIP_EP201SingleRegisterPort("SOFTGLUE", 0, 2)
initIP_EP201SingleRegisterPort("SOFTGLUE", 1, 2)

dbLoadTemplate("softGlue.substitutions")
# END softGlue.cmd ------------------------------------------------------------
