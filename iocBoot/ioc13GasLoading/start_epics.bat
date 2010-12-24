start medm -x 13GasLoading.adl 
rem Must add mca\bin\win32-x86 to the PATH so it finds needed DLLs
set PATH=%PATH%;..\..\..\mca\bin\win32-x86
..\..\bin\win32-x86\CARSApp st.cmd
pause
