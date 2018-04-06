rem This batch file starts the software for controlling Prosilica cameras from EPICS

rem start medm -x -macro "P=13IDDPS1:,R=cam1:" prosilica.adl

set PATH=C:\epics_windows_binaries\windows-x64-static;%PATH%
prosilicaApp st.cmd
pause

