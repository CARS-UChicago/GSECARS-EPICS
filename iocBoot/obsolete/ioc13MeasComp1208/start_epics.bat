rem start medm -x -macro "P=13USB1208:, R=cam1: USB1208LS_module.adl
set PATH=C:\epics_windows_binaries\windows-x64-static;%PATH%
measCompApp st.cmd
pause

