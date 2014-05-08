start medm -x -macro "P=13LUANDOR:, R=cam1:" andor.adl &
start medm -x -macro "P=13LUANDOR:, R=sham1:" Shamrock.adl &
J:\epics\devel\areaDetector\ADAndor\iocs\andorIOC\bin\win32-x86\andorCCDApp st.cmd
pause

