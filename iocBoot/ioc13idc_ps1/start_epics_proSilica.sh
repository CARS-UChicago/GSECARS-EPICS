#!/bin/sh

app=../../../../areaDetector/1-5/bin/linux-x86/prosilicaApp
medm -x -macro "P=13IDCPS1:, R=cam1:, I=image1:, F=file1:, ROI=ROI1"  ADBase.adl & 

$app st.cmd
