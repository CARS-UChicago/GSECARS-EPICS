# gse-galil5 
iocshLoad("../Galil_stepper_controller.cmd", "P=$(P)Galil1:, PORT=GALIL1, IPADDR=10.54.160.69, M1=m1, M2=m2, M3=m3, M4=m4, M5=m5, M6=m6, M7=m7, M8=m8")  
#Load motor records for real motors
dbLoadTemplate("Galil_motors.template")

#Remote control input
dbLoadTemplate("remoteControl.substitutions", "P=$(P)")

#Load digital IO databases
dbLoadTemplate("$(GALIL)/GalilTestApp/Db/galil_dmc_digital_ports.substitutions", "P=$(P)Galil1:, PORT=GALIL1")

#Load analog IO databases
dbLoadTemplate("$(GALIL)/GalilTestApp/Db/galil_dmc_analog_ports.substitutions", "P=$(P)Galil1:, PORT=GALIL1, PREC=3")
