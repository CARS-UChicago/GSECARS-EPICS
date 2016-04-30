REM Note that we must use the Windows "start" command or medm won't find X11 dlls
start medm -x -macro "P=13Saturn1:, D=dxp1:, M=mca1"  dxpSaturn.adl
call dllPath.bat
J:\epics\support\dxp\bin\win32-x86-static\dxpApp.exe st.cmd
REM Put a pause so user can see any error messages when IOC closes
pause

