# gse-galil52 D3547 amp, m1-m4 stepper with DB-25, m5-m6 servo, m7-m8 3-phase
#iocshLoad("../Galil_stepper_controller.cmd", "P=$(P)Galil1:, PORT=GALIL1, IPADDR=10.54.160.215, M1=m1,  M2=m2,  M3=m3,  M4=m4,  M5=m5,  M6=m6,  M7=m7,  M8=m8")  
#dbLoadTemplate("Galil_motors.template.D3547.stepper")
#dbLoadTemplate("Galil_motors.template.D3547.servo")

# gse-galil51 D3547 amp, m1-m4 stepper with DB-25, m5-m6 servo, m7-m8 3-phase
#iocshLoad("../Galil_stepper_controller.cmd", "P=$(P)Galil1:, PORT=GALIL1, IPADDR=10.54.160.214, M1=m1,  M2=m2,  M3=m3,  M4=m4,  M5=m5,  M6=m6,  M7=m7,  M8=m8")  
#dbLoadTemplate("Galil_motors.template.D3547.stepper")
#dbLoadTemplate("Galil_motors.template.D3547.servo")

# gse-galil53 D3140, D4040 amps, m1-m4 servo with DB-25, m5-m8 stepper with Elco
#iocshLoad("../Galil_stepper_controller.cmd", "P=$(P)Galil1:, PORT=GALIL1, IPADDR=10.54.160.217, M1=m1,  M2=m2,  M3=m3,  M4=m4,  M5=m5,  M6=m6,  M7=m7,  M8=m8")  
#dbLoadTemplate("Galil_motors.template.D3140_D4040")

# gse-galil54 D3140, D4040 amps, m1-m4 servo with DB-25, m5-m8 stepper with DB-25
#iocshLoad("../Galil_stepper_controller.cmd", "P=$(P)Galil1:, PORT=GALIL1, IPADDR=10.54.160.219, M1=m1,  M2=m2,  M3=m3,  M4=m4,  M5=m5,  M6=m6,  M7=m7,  M8=m8")  
#dbLoadTemplate("Galil_motors.template.D3140_D4040")
#dbLoadTemplate("Galil_motors.template.tomo")

# gse-galil50 D4140 amps, m1-m8 stepper with DB-25 and Elco
iocshLoad("../Galil_stepper_controller.cmd", "P=$(P)Galil1:, PORT=GALIL1, IPADDR=10.54.160.213, M1=m1,  M2=m2,  M3=m3,  M4=m4,  M5=m5,  M6=m6,  M7=m7,  M8=m8")  
dbLoadTemplate("Galil_motors.template.D4140_D4140")

# gse-galil14 D4040 amps, m1-m8 stepper with Elco
#iocshLoad("../Galil_stepper_controller.cmd", "P=$(P)Galil1:, PORT=GALIL1, IPADDR=10.54.160.122, M1=m1,  M2=m2,  M3=m3,  M4=m4,  M5=m5,  M6=m6,  M7=m7,  M8=m8")  
#dbLoadTemplate("Galil_motors.template.D4040_D4040")

asynSetTraceIOMask("GALILSYNC1",0,ESCAPE)
#asynSetTraceMask("GALILSYNC1",0,ERROR|DRIVER)
#asynSetTraceFile("GALILSYNC1",0,"Galil1_TCP.txt")

#asynSetTraceIOMask("GALILASYNC1",0,HEX)
#asynSetTraceMask("GALILASYNC1",0,ERROR|DRIVER)
#asynSetTraceFile("GALILASYNC1",0,"Galil1_UDP.txt")

