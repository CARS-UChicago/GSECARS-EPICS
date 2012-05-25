#!/bin/sh
# general procserv wrapper

PORT=20399
NAME=13IDA_PS2

BOOTDIR=ioc13ida_ps2

WORKDIR=/home/epics/support/CARS/iocBoot/$BOOTDIR

IOCAPP=/home/epics/support/areaDetector/bin/linux-x86/prosilicaApp
STCMD=st.cmd 

LOGFILE=/home/epics/logs/ioc$NAME.log

cd $WORKDIR
/usr/local/bin/procServ -n $NAME -Q ^E -L $LOGFILE $PORT $IOCAPP $STCMD
telnet localhost $PORT
