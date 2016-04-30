rem start medm -x -macro "P=13RamanPG1:, R=cam1:" PointGrey.adl
call dllPath.bat
set EPICS_CA_MAX_ARRAY_BYTES=32010203
# set EPICS_CA_MAX_ARRAY_BYTES=20000000
J:\epics\support\areaDetector\ADPointGrey\iocs\pointGreyIOC\bin\windows-x64-static\pointGreyApp st.cmd
pause

