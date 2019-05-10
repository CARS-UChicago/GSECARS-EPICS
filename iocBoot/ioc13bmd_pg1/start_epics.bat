rem start medm -x -macro "P=13BMDPG1:, R=cam1:" PointGrey.adl
set PATH=C:\epics_windows_binaries\windows-x64-static;%PATH%
pointGreyApp st.cmd
pause

