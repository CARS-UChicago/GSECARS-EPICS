#!/bin/sh
# general procserv wrapper

PORT=20398
NAME=13IDA_PS1

BOOTDIR=ioc13ida_ps1

WORKDIR=/home/epics/support/CARS/iocBoot/$BOOTDIR

IOCAPP=/home/epics/support/areaDetector/bin/linux-x86/prosilicaApp
STCMD=st.cmd 

LOGFILE=/home/epics/logs/ioc$NAME.log

cd $WORKDIR
/usr/local/bin/procServ -n $NAME -Q ^E -L $LOGFILE $PORT $IOCAPP $STCMD
telnet localhost $PORT
