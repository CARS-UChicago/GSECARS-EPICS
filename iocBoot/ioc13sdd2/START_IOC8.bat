REM Tell medm where to look for .adl files.  Edit the following line, or comment it
REM out if the environment variable is already set
REM set EPICS_DISPLAY_PATH=C:\epics_adls
REM Note that we must use the Windows "start" command or medm won't find X11 dlls
start medm -x -macro "P=13SDD2:, D=dxp, M=mca" 16element_dxp.adl
set PATH=C:\epics_windows_binaries\win32-x86-static;%PATH%
dxpApp.exe 8element.cmd
pause
