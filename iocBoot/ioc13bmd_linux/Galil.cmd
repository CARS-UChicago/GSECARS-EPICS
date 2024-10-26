# gse-galil31 BM-D roof; 4140 drivers, Patch Panel D
iocshLoad("../Galil_stepper_controller.cmd", "P=$(P)Galil1:, PORT=GALIL1, IPADDR=10.54.160.146, M1=m1,  M2=m2,  M3=m3,  M4=m4,  M5=m5,  M6=m6,  M7=m7,  M8=m8")  

# gse-galil35 BM-D roof; 4140 drivers, Patch Panel B
iocshLoad("../Galil_stepper_controller.cmd", "P=$(P)Galil2:, PORT=GALIL2, IPADDR=10.54.160.151, M1=m17, M2=m18, M3=m19, M4=m20, M5=m21, M6=m22, M7=m23, M8=m24")  

# gse-galil33 BM-D roof; 4140 drivers, Patch Panel C
iocshLoad("../Galil_stepper_controller.cmd", "P=$(P)Galil3:, PORT=GALIL3, IPADDR=10.54.160.149, M1=m25, M2=m26, M3=m27, M4=m28, M5=m29, M6=m30, M7=m31, M8=m32")  

# gse-galil34 BM-D roof; 4140 drivers, Patch Panel A
iocshLoad("../Galil_stepper_controller.cmd", "P=$(P)Galil4:, PORT=GALIL4, IPADDR=10.54.160.150, M1=m33, M2=m34, M3=m35, M4=m36, M5=m37, M6=m38, M7=m39, M8=m40")  

# gse-galil19 BM-D roof  4040 drivers; K/B mirror
iocshLoad("../Galil_stepper_controller.cmd", "P=$(P)Galil5:, PORT=GALIL5, IPADDR=10.54.160.128, M1=m41, M2=m42, M3=m43, M4=m44, M5=m45, M6=m46, M7=m47, M8=m48")  

# gse-galil30 BM-D roof; 4140 drivers, Patch Panel F
iocshLoad("../Galil_stepper_controller.cmd", "P=$(P)Galil6:, PORT=GALIL6, IPADDR=10.54.160.145, M1=m57, M2=m58, M3=m59, M4=m60, M5=m61, M6=m62, M7=m63, M8=m64")  

# gse-galil32 BM-D roof; 4140 drivers, Patch Panel X
iocshLoad("../Galil_stepper_controller.cmd", "P=$(P)Galil7:, PORT=GALIL7, IPADDR=10.54.160.148, M1=m65, M2=m66, M3=m67, M4=m68, M5=m69, M6=m70, M7=m71, M8=m72")  

# gse-galil47 In BM-D,  4040 drivers; Brillouin motors
iocshLoad("../Galil_stepper_controller.cmd", "P=$(P)Galil8:, PORT=GALIL8, IPADDR=10.54.160.164, M1=m73, M2=m74, M3=m75, M4=m76, M5=m77, M6=m78, M7=m79, M8=m80")  

#Load motor records for real motors
dbLoadTemplate("Galil_motors.template")

