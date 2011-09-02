rem This batch file starts the software for controlling Prosilica cameras from EPICS

rem Start MEDM
rem start medm -x -macro "P=13BMDPS1:, R=cam1:" ADBase.adl
start medm -x -macro "P=13BMDPS1:,R=cam1:" prosilica.adl

rem Start TC window
start medm -x -macro "P=13BMDPS1: ,R=TC:" test.adl

rem Start IOC
J:\epics\support\areaDetector\bin\win32-x86\prosilicaApp st.cmd


