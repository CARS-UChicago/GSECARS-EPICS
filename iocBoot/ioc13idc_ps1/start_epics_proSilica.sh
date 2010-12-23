#!/bin/sh

medm -x -macro "P=13IDCPS1:, R=cam1:, I=image1:, F=file1:, ROI=ROI1"  ADBase.adl & 
/home/epics/support/areaDetector/1-5/bin/linux-x86/prosilicaApp st.cmd &

