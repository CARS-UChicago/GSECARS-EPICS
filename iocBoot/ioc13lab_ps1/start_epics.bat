rem This batch file starts the software for controlling Prosilica cameras from EPICS

rem Start MEDM
start medm -x -macro "P=13LABPS1:,R=cam1:" prosilica.adl

rem Start TC window
start medm -x -macro "P=13LABPS1:,R=TC:" test.adl

rem Start IOC
set PATH=C:\epics_windows_binaries\windows-x64-static;%PATH%
prosilicaApp st.cmd

pause

