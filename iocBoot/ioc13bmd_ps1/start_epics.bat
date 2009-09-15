rem This batch file starts the software for controlling Prosilica cameras from EPICS

rem Start MEDM
rem start medm -x -macro "P=13BMDPS1:, R=cam1:" ADBase.adl

rem Start IOC
J:\epics\devel\areaDetector\1-5beta\bin\win32-x86\prosilicaApp st.cmd

