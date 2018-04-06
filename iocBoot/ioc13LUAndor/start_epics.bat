start medm -x -macro "P=13LUANDOR:, R=cam1:" andor.adl &
start medm -x -macro "P=13LUANDOR:, R=sham1:" Shamrock.adl &
set PATH=C:\epics_windows_binaries\win32-x86-static;%PATH%
andorCCDApp st.cmd
pause

