# gse-galil7 In BM-C rack, Step-Pak; Patch Panel A
iocshLoad("../Galil_stepper_controller.cmd", "P=$(P)Galil1:, PORT=GALIL1, IPADDR=10.54.160.114, M1=m63, M2=m64, M3=m65, M4=m66, M5=m67, M6=m68, M7=m69, M8=m70")  

# gse-galil12 In BM-C,  4040 drivers; K/B mirror
iocshLoad("../Galil_stepper_controller.cmd", "P=$(P)Galil2:, PORT=GALIL2, IPADDR=10.54.160.120, M1=m9,  M2=m10, M3=m11, M4=m12, M5=m13, M6=m14, M7=m15, M8=m16")  

# gse-galil13 In BM-C,  4040 drivers; detector slits
iocshLoad("../Galil_stepper_controller.cmd", "P=$(P)Galil3:, PORT=GALIL3, IPADDR=10.54.160.121, M1=m17, M2=m18, M3=m19, M4=m20, M5=m21, M6=m22, M7=m23, M8=m24")  

# gse-galil9  In BM-B rack, Step-Pak; BM-C Mono
iocshLoad("../Galil_stepper_controller.cmd", "P=$(P)Galil4:, PORT=GALIL4, IPADDR=10.54.160.117, M1=m25, M2=m26, M3=m27, M4=m28, M5=m29, M6=m30, M7=m31, M8=m32")  

# gse-galil8  In BM-B rack, Step-Pak; BM-C Mirror
iocshLoad("../Galil_stepper_controller.cmd", "P=$(P)Galil5:, PORT=GALIL5, IPADDR=10.54.160.116, M1=m47, M2=m48, M3=m49, M4=m50, M5=m51, M6=m52, M7=m53, M8=m54")  

# gse-galil6  In BM-C rack, Step-Pak; Patch Panel B
iocshLoad("../Galil_stepper_controller.cmd", "P=$(P)Galil6:, PORT=GALIL6, IPADDR=10.54.160.115, M1=m1,  M2=m2,  M3=m3,  M4=m4,  M5=m5,  M6=m6,  M7=m7,  M8=m8")  

# gse-galil29 In BM-C,  3140, 4040 drivers; cleanup slits, Navitar zoom, DAC viewer
iocshLoad("../Galil_stepper_controller.cmd", "P=$(P)Galil7:, PORT=GALIL7, IPADDR=10.54.160.139, M1=m71, M2=m72, M3=m73, M4=m74, M5=m75, M6=m76, M7=m77, M8=m78")  

#Load motor records for real motors
dbLoadTemplate("Galil_motors.template")

