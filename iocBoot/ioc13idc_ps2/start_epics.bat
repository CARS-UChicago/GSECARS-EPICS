rem start medm -x -macro "P=13IDCPS1:, R=cam1:" prosilica.adl
SET EPICS_CA_MAX_ARRAY_BYTES=4800000
call dllPath.bat
..\..\..\areaDetector\ADProsilica\iocs\prosilicaIOC\bin\win32-x86\prosilicaApp st.cmd.win32

