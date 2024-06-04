# gse-galil24 In ID-E rack, 4140 drivers, Patch Panel A
iocshLoad("../Galil_stepper_controller.cmd", "P=$(P)Galil1:, PORT=GALIL1, IPADDR=10.54.160.134, M1=m1,  M2=m2,  M3=m3,  M4=m4,  M5=m5,  M6=m6,  M7=m7,  M8=m8")  

# gse-galil27 In ID-E rack, 4140 drivers, Patch Panel B
iocshLoad("../Galil_stepper_controller.cmd", "P=$(P)Galil2:, PORT=GALIL2, IPADDR=10.54.160.137, M1=m9,  M2=m10, M3=m11, M4=m12, M5=m13, M6=m14, M7=m15, M8=m16")  

# gse-galil28 In ID-E rack, 4140 drivers, Patch Panel C
iocshLoad("../Galil_stepper_controller.cmd", "P=$(P)Galil3:, PORT=GALIL3, IPADDR=10.54.160.138, M1=m17, M2=m18, M3=m19, M4=m20, M5=m21, M6=m22, M7=m23, M8=m24")  

# gse-galil25 In ID-E, 4040 drivers; CMAs for HERFD actuators
iocshLoad("../Galil_stepper_controller.cmd", "P=$(P)Galil4:, PORT=GALIL4, IPADDR=10.54.160.135, M1=m25, M2=m26, M3=m27, M4=m28, M5=m29, M6=m30, M7=m31, M8=m32")  

# gse-galil26 In ID-E, 4040 drivers; CMA and additional motors
iocshLoad("../Galil_stepper_controller.cmd", "P=$(P)Galil5:, PORT=GALIL5, IPADDR=10.54.160.136, M1=m33, M2=m34, M3=m35, M4=m36, M5=m37, M6=m38, M7=m39, M8=m40")  

#Load motor records for real motors
dbLoadTemplate("Galil_motors.template")

