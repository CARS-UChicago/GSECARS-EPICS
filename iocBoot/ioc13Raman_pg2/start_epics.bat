rem start medm -x -macro "P=13RamanPG2:, R=cam1:" PointGrey.adl
set PATH=C:\epics_windows_binaries\windows-x64-static;%PATH%
set EPICS_CA_MAX_ARRAY_BYTES=32010203
pointGreyApp st.cmd
pause
