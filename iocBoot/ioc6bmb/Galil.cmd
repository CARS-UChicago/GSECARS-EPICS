# 6bm-galil1  In BM-B roof rack
iocshLoad("../Galil_stepper_controller.cmd", "P=$(P)Galil1:, PORT=GALIL1, IPADDR=164.54.110.51, M1=m1,  M2=m2,  M3=m3,  M4=m4,  M5=m5,  M6=m6,  M7=m7,  M8=m8")
# 6bm-galil2  In BM-B roof rack
iocshLoad("../Galil_stepper_controller.cmd", "P=$(P)Galil2:, PORT=GALIL2, IPADDR=164.54.110.52, M1=m9,  M2=m10, M3=m11, M4=m12, M5=m13, M6=m14, M7=m15, M8=m16")  
# 6bm-galil3  In BM-B roof rack
iocshLoad("../Galil_stepper_controller.cmd", "P=$(P)Galil3:, PORT=GALIL3, IPADDR=164.54.110.53, M1=m17, M2=m18, M3=m19, M4=m20, M5=m21, M6=m22, M7=m23, M8=m24")  

#Load motor records
dbLoadTemplate("Galil_motors.template")