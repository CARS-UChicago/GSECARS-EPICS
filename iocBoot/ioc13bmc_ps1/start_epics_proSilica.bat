rem This batch file starts the software for controlling Prosilica cameras from EPICS

rem Start MEDM
start medm -x -macro "P=13BMCPS1:,R=cam1:" prosilica.adl

rem Start IOC
J:\epics\support\areaDetector\bin\win32-x86\prosilicaApp st.cmd

pause 20

