rem This batch file starts the software for controlling Prosilica cameras from EPICS

rem Start MEDM
rem start medm -x -macro "P=13IDCPS1:, R=cam1:, I=image1:, F=file1:, ROI=ROI1" ADBase.adl

rem Start IOC
J:\epics\support\areaDetector\1-5\bin\win32-x86\prosilicaApp st.cmd.win32

rem Pause for user in case there is an error message to be observed
pause

