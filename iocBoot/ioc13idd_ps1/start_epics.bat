rem This batch file starts the software for controlling Prosilica cameras from EPICS

rem Start MEDM
rem start medm -x -macro "P=13IDDPS2:, R=cam2:" ADBase.adl

rem Start IOC
J:\epics\devel\areaDetector\1-4\bin\win32-x86\prosilicaApp st.cmd

