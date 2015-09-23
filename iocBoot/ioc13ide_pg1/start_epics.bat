REM  start medm -x -macro "P=13IDEPG1:, R=cam1:" PointGrey.adl
call dllPath.bat
set EPICS_CA_MAX_ARRAY_BYTES=29333952
J:\epics\support\areaDetector\ADPointGrey\iocs\pointGreyIOC\bin\windows-x64-static\pointGreyApp.exe st.cmd
pause
