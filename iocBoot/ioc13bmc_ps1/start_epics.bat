rem start medm -x -macro "P=13BMCPS1:,R=cam1:" prosilica.adl

set PATH=C:\epics_windows_binaries\windows-x64-static;%PATH%
prosilicaApp st.cmd
pause

