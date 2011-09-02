REM Tell medm where to look for .adl files.  Edit the following line, or comment it
REM out if the environment variable is already set
REM set EPICS_DISPLAY_PATH=C:\epics_adls
REM Note that we must use the Windows "start" command or medm won't find X11 dlls
cd J:\epics\devel\dxp-3-0\dxpApp\op\adl
start medm -x -macro "P=13SDD1:, D=dxp, M=mca" 16element_dxp.adl
PATH=j:\epics\devel\areaDetector\bin\win32-x86;

cd J:\epics\devel\CARS\iocBoot\ioc13sdd1
..\..\bin\win32-x86\CARSApp.exe 4element.cmd
pause
