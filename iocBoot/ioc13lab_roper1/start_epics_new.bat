cd J:\epics\devel\areaDetector-1-6\ADApp\op\adl
start medm -x -macro "P=13LABRP1:, R=cam1:" Roper.adl
cd J:\epics\support\CARS\1-5\iocBoot\ioc13lab_roper1
J:\epics\devel\areaDetector-1-6\bin\win32-x86\roperApp st.cmd
pause

