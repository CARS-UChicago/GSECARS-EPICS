# gse-galil23 Step-Pak in ID-D rack 2, 4140 drivers; Patch Panel T
iocshLoad("../Galil_stepper_controller.cmd", "P=$(P)Galil4:, PORT=GALIL4, IPADDR=10.54.160.133, M1=m25, M2=m26, M3=m27, M4=m28, M5=m29, M6=m30, M7=m31, M8=m32")  

# gse-galil46 Step-Pak in ID-D, rack 2 4140 drivers; Patch panel U
iocshLoad("../Galil_stepper_controller.cmd", "P=$(P)Galil5:, PORT=GALIL5, IPADDR=10.54.160.162, M1=m33, M2=m34, M3=m35, M4=m36, M5=m37, M6=m38, M7=m39, M8=m40")  

# gse-galil10 Phytron in ID-D, rack 2 4140 drivers; Patch panel V
iocshLoad("../Galil_stepper_controller.cmd", "P=$(P)Galil6:, PORT=GALIL6, IPADDR=10.54.160.118, M1=m41, M2=m42, M3=m43, M4=m44, M5=m45, M6=m46, M7=m47, M8=m48")  

# gse-galil52 DB-25 in ID-D rack 3547 drivers, LVP pumps and vertical press motion (future)
iocshLoad("../Galil_stepper_controller.cmd", "P=$(P)Galil7:, PORT=GALIL7, IPADDR=10.54.160.215, M1=m49, M2=m50, M3=m51, M4=m52, M5=m53, M6=m54, M7=m55, M8=m56")  

# gse-galil59 DB-25 in ID-D, station 4040 drivers, LVP slits
iocshLoad("../Galil_stepper_controller.cmd", "P=$(P)Galil12:, PORT=GALIL12, IPADDR=10.54.161.8, M1=m85, M2=m86, M3=m87, M4=m88, M5=m89, M6=m90, M7=m91, M8=m92")  

#Load motor records for real motors
dbLoadTemplate("Galil_motors.template")

