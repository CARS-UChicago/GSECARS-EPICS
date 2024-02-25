start medm -x -macro "P=13ESP:,M1=m1,M2=m2,M3=m3,TITLE=Portable_Ruby_Motors" 3motors.adl
set PATH=C:\epics_windows_binaries\windows-x64-static;%PATH%
CARSApp st.cmd
pause