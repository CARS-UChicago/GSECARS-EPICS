rem This batch file starts the software for controlling Prosilica cameras from EPICS

rem Start MEDM
rem start medm -x -macro "P=13BMDPS1:,R=cam1:" prosilica.adl

call dllPath.bat

rem Start IOC
J:\epics\support\areaDetector\ADProsilica\iocs\prosilicaIOC\bin\win32-x86-static\prosilicaApp st.cmd


