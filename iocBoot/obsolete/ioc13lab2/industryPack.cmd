ipacAddMVME162("A:m=0x90000000,1024 l=5")

# Initialize Octal UART stuff
tyGSOctalDrv 1
tyGSOctalModuleInit("UART0", "232", 0x80, 0, 0)

