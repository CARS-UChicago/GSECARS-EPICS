#start medm -x -macro "P=13PE1:, R=cam1:" PerkinElmer.adl
set PATH=C:\epics_windows_binaries\windows-x64-static;%PATH%
PerkinElmerApp st.cmd
pause
