rem This batch file starts the software for controlling Roper detectors from EPICS

rem Comment out the following line if you don't want the batch file to start WinView.
rem Edit it if WinSpec rather than WinView should be started
start WinView

rem Start the Roper server
start J:\epics\support\ccd\1-7beta\bin\win32-x86\roperServer.exe

rem Start MEDM
start medm -x -macro "P=13IDDMicroMax1:, C=det1:" ccd.adl

rem Start IOC
J:\epics\support\ccd\1-7beta\bin\win32-x86\roperCCDApp.exe st.cmd

