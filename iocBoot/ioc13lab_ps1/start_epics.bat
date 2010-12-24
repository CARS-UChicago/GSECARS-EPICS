rem This batch file starts the software for controlling Prosilica cameras from EPICS

rem Start MEDM
start medm -x -macro "P=13LABPS1:,R=cam1:,I=image1:,NETCDF=netCDF1:,JPEG=JPEG1:,TIFF=TIFF1:,ROI=ROI1:" prosilica.adl

rem Start IOC
J:\epics\support\areaDetector\1-5\bin\win32-x86\prosilicaApp st.cmd

pause

