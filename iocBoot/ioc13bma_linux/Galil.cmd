# gse-galil11  In BM-A rack, Step-Pak; Monochromator
iocshLoad("../Galil_stepper_controller.cmd", "P=$(P)Galil1:, PORT=GALIL1, IPADDR=10.54.160.119, M1=m9,  M2=m10,  M3=m11,  M4=m12,  M5=m13,  M6=m14,  M7=m15,  M8=m16")  

#Load motor records for real motors
dbLoadTemplate("Galil_motors.template")
