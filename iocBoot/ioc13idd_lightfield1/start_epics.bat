start medm -x -macro "P=13IDDLF1:, R=cam1:" LightField.adl
call J:\epics\support\areaDetector\ADLightField\iocs\lightFieldIOC\iocBoot\iocLightField\dllPath.bat
J:\epics\support\areaDetector\ADLightField\iocs\lightFieldIOC\bin\windows-x64\LightFieldApp st.cmd
pause


