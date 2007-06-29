TOP=../..

include $(TOP)/configure/CONFIG
#----------------------------------------
#  ADD MACRO DEFINITIONS AFTER THIS LINE
#=============================

#==================================================
# build a support library

LIBRARY_IOC += CARS

# The following are compiled and added to the Support library
CARS_SRCS_vxWorks += devAoAvme9210.c
CARS_SRCS_vxWorks  += drvAvme9210.c
#CARS_SRCS += devXxDg535Gpib.c
#CARS_SRCS += devLib.c
#CARS_SRCS += iVecShow.c
#CARS_SRCS += ppcveclist.c
CARS_SRCS += coordTrans2D.st
CARS_SRCS += BMD_LVP_Detector.st
CARS_SRCS += IDD_LVP_Detector.st
CARS_SRCS += Energy_CC.st
CARS_SRCS += Energy.st
CARS_SRCS += BM13_Energy.st
CARS_SRCS += Analyzer.st
CARS_SRCS += newport_table.st
CARS_SRCS += newport_table_support.c

CARS_LIBS += asyn seq pv
CARS_LIBS += $(EPICS_BASE_IOC_LIBS)

#===========================

# <name>.dbd will be created from <name>Include.dbd
DBD += CARS.dbd
DBD += CARSVX.dbd
DBD += CARSLinux.dbd

#=============================
# build an ioc application

PROD_IOC = CARSApp

# <name>_registerRecordDeviceDriver.cpp will be created from <name>.dbd
CARSApp_SRCS_DEFAULT += CARS_registerRecordDeviceDriver.cpp CARSMain.cpp
CARSApp_SRCS_Linux   += CARSLinux_registerRecordDeviceDriver.cpp CARSMain.cpp
CARSApp_SRCS_vxWorks += CARSVX_registerRecordDeviceDriver.cpp

CARSApp_Common_LIBS += CARS
CARSApp_Common_LIBS += mca 
CARSApp_Common_LIBS += calc
CARSApp_Common_LIBS += sscan
CARSApp_Common_LIBS += autosave
CARSApp_Common_LIBS += optics
CARSApp_Common_LIBS += vme
CARSApp_Common_LIBS += std
CARSApp_Common_LIBS += love
CARSApp_Common_LIBS += ip
CARSApp_Common_LIBS += brukerCCD marCCD roperCCD
CARSApp_Common_LIBS += Acs Ims Mclennan Newport Faulhaber Parker softMotor motorSimSupport motor
CARSApp_Common_LIBS += stream streamSynApps
CARSApp_Common_LIBS += modbus
CARSApp_Common_LIBS += asyn
CARSApp_Common_LIBS += seq pv
CARSApp_Common_LIBS += $(EPICS_BASE_IOC_LIBS)

CARSApp_vxWorks_LIBS += allenBradley
CARSApp_vxWorks_LIBS += mcaSIS
CARSApp_vxWorks_LIBS += mcaCanberra
CARSApp_vxWorks_LIBS += ip330
CARSApp_vxWorks_LIBS += ipUnidig
CARSApp_vxWorks_LIBS += dac128V
CARSApp_vxWorks_LIBS += quadEM
CARSApp_vxWorks_LIBS += camac devCamac
CARSApp_vxWorks_LIBS += dxp handelSrc
CARSApp_vxWorks_LIBS += oms
CARSApp_vxWorks_LIBS += TyGSOctal Ipac
CARSApp_vxWorks_LIBS += vxStats
#The following adds support from base/src/vxWorks
CARSApp_OBJS_vxWorks += $(EPICS_BASE_BIN)/vxComLibrary

CARSApp_Linux_LIBS += dxp handelSrc
CARSApp_Linux_LIBS += mcaCanberra

CARSApp_cygwin32_LIBS += dxp handelSrc

CARSApp_WIN32_LIBS    += dxp handelSrc

CARSApp_LIBS_DEFAULT  = $(CARSApp_Common_LIBS)
CARSApp_LIBS_vxWorks  = $(CARSApp_vxWorks_LIBS)  $(CARSApp_Common_LIBS)
CARSApp_LIBS_Linux    = $(CARSApp_Linux_LIBS)    $(CARSApp_Common_LIBS)
CARSApp_LIBS_cygwin32 = $(CARSApp_cygwin32_LIBS) $(CARSApp_Common_LIBS)
CARSApp_LIBS_WIN32    = $(CARSApp_WIN32_LIBS)   $(CARSApp_Common_LIBS)

CARSApp_SYS_LIBS_Linux    += net pcap
CARSApp_SYS_LIBS_cygwin32 += rpc DLPORTIO
CARSApp_LIBS_WIN32        += DLPORTIO

BIN_INSTALLS_vxWorks += printf_test.o

include $(TOP)/configure/RULES
#----------------------------------------
#  ADD RULES AFTER THIS LINE

