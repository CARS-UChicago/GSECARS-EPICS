#!/bin/sh
medm -x -macro "P=13IDCPS1:, R=cam1:"  prosilica.adl & 
/home/epics/support/areaDetector/bin/linux-x86/prosilicaApp st.cmd 
