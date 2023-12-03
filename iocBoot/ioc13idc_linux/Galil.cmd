# gse-galil1  In ID-C rack, Step-Pak, patch panel K
iocshLoad("../Galil_stepper_controller.cmd", "P=$(P)Galil1:, PORT=GALIL1, IPADDR=10.54.160.43, M1=m9,  M2=m10, M3=m11, M4=m12, M5=m13, M6=m14, M7=m15, M8=m16")  

# gse-galil3 In ID-C rack,  Step-Pak, patch panel C, PE cell
iocshLoad("../Galil_stepper_controller.cmd", "P=$(P)Galil2:, PORT=GALIL2, IPADDR=10.54.160.65, M1=m57, M2=m58, M3=m59, M4=m60, M5=m61, M6=m62, M7=m63, M8=m64")  

# gse-galil2 In IDC station, D4040 drives, diffractometer bench slits
iocshLoad("../Galil_stepper_controller.cmd", "P=$(P)Galil3:, PORT=GALIL3, IPADDR=10.54.160.66, M1=m1,  M2=m2,  M3=m3,  M4=m4,  M5=m5,  M6=m6,  M7=m7,  M8=m8")  

# gse-galil4 In IDC station, D4040 drives, detector slots slits
iocshLoad("../Galil_stepper_controller.cmd", "P=$(P)Galil4:, PORT=GALIL4, IPADDR=10.54.160.67, M1=m17, M2=m18, M3=m19, M4=m20, M5=m21, M6=m22, M7=m23, M8=m24")

dbLoadTemplate("Galil_motors.template")
