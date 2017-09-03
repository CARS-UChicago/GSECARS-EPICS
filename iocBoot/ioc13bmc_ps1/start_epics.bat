rem This batch file starts the software for controlling Prosilica cameras from EPICS

rem Start MEDM
start medm -x -macro "P=13BMCPS1:,R=cam1:" prosilica.adl

call dllPath.bat

rem Start IOC
J:\epics\support\areaDetector\ADProsilica\iocs\prosilicaIOC\bin\windows-x64-static\prosilicaApp st.cmd
pause

