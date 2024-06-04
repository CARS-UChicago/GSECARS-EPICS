# gse-galil17  In ID-A rack, Step-Pak; White beam slits
iocshLoad("../Galil_stepper_controller.cmd", "P=$(P)Galil1:, PORT=GALIL1, IPADDR=10.54.160.126, M1=m1,  M2=m2,  M3=m3,  M4=m4,  M5=m5,  M6=m6,  M7=m7,  M8=m8")
# gse-galil18  In ID-A rack, Step-Pak; E mirrors
iocshLoad("../Galil_stepper_controller.cmd", "P=$(P)Galil2:, PORT=GALIL2, IPADDR=10.54.160.127, M1=m9,  M2=m10, M3=m11, M4=m12, M5=m13, M6=m14, M7=m15, M8=m16")  
# gse-galil21  In ID-A rack, Step-Pak; E mirrors, BeamViewer in Pinhole tank
iocshLoad("../Galil_stepper_controller.cmd", "P=$(P)Galil3:, PORT=GALIL3, IPADDR=10.54.160.130, M1=m17, M2=m18, M3=m19, M4=m20, M5=m21, M6=m22, M7=m23, M8=m24")  
# gse-galil22  In ID-A rack, Step-Pak; Pinhole
iocshLoad("../Galil_stepper_controller.cmd", "P=$(P)Galil4:, PORT=GALIL4, IPADDR=10.54.160.132, M1=m25, M2=m26, M3=m27, M4=m28, M5=m29, M6=m30, M7=m31, M8=m32")  
# gse-galil43  In ID-B rack, Step-Pak; SSA
iocshLoad("../Galil_stepper_controller.cmd", "P=$(P)Galil5:, PORT=GALIL5, IPADDR=10.54.160.159, M1=m33, M2=m34, M3=m35, M4=m36, M5=m37, M6=m38, M7=m39, M8=m40")  
# gse-galil42  In ID-B rack, Step-Pak; Vertical mirror
iocshLoad("../Galil_stepper_controller.cmd", "P=$(P)Galil6:, PORT=GALIL6, IPADDR=10.54.160.158, M1=m41, M2=m42, M3=m43, M4=m44, M5=m45, M6=m46, M7=m47, M8=m48")  
# gse-galil39  In ID-B rack, Step-Pak; Horizontal mirror
iocshLoad("../Galil_stepper_controller.cmd", "P=$(P)Galil7:, PORT=GALIL7, IPADDR=10.54.160.155, M1=m49, M2=m50, M3=m51, M4=m52, M5=m53, M6=m54, M7=m55, M8=m56")  
# gse-galil38  In ID-B rack, Step-Pak; New Vertical mirror
iocshLoad("../Galil_stepper_controller.cmd", "P=$(P)Galil8:, PORT=GALIL8, IPADDR=10.54.160.154, M1=m73, M2=m74, M3=m75, M4=m76, M5=m77, M6=m78, M7=m79, M8=m80")  

#Load motor records for real motors
dbLoadTemplate("Galil_motors.template")
