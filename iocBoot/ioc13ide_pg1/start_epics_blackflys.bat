REM  start medm -x -macro "P=13IDEPG1:, R=cam1:" PointGrey.adl

set EPICS_CA_MAX_ARRAY_BYTES=29333952
set EPICS_CA_MAX_ARRAY_BYTES=140100100

set PATH=C:\epics_windows_binaries\windows-x64-static;%PATH%
pointGreyApp st.cmd
pause
