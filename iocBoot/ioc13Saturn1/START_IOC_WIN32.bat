REM Note that we must use the Windows "start" command or medm won't find X11 dlls
start medm -x -macro "P=13Saturn1:, D=dxp1:, M=mca1"  dxpSaturn.adl
REM Put areaDetector\bin\win32-x86 in the path so the file plugin DLLs can be found
PATH=J:\epics\support\areaDetector\bin\win32-x86
J:\epics\support\dxp\bin\win32-x86\dxpApp.exe st.cmd
REM Put a pause so user can see any error messages when IOC closes
pause

