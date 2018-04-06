rem This batch file starts the software for controlling Prosilica cameras from EPICS

rem Start MEDM
REM  start medm -x -macro "P=13IDEPS1:,R=cam1:" prosilica.adl

set PATH=C:\epics_windows_binaries\windows-x64-static;%PATH%
prosilicaApp st.cmd
pause

