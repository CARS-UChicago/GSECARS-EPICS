rem This batch file starts the software for controlling Prosilica cameras from EPICS

rem Start MEDM
start medm -x -macro "P=13BMCPS1:, R=cam1:, I=image1:, F=file1:, ROI=ROI1" ADBase.adl

rem Start IOC
J:\epics\devel\areaDetector\1-5beta\bin\win32-x86\prosilicaApp st.cmd

