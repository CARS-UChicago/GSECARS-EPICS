ipacAddVIPC616_01("0x3000,0xa0000000")

# Initialize Octal UART stuff
tyGSOctalDrv 2
tyGSOctalModuleInit("GSIP_OCTAL232", 0x80, 0, 0)
tyGSOctalModuleInit("GSIP_OCTAL232", 0x81, 0, 1)

# Initialize Systran DAC
initDAC128V("DAC1",0,3)
dbLoadTemplate "DAC.template"

