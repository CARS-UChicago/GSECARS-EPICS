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
#CARS_SRCS += seq_test.st
CARS_SRCS += sncTest.stt
CARS_SRCS += coordTrans2D.st
CARS_SRCS += BMD_LVP_Detector.st
CARS_SRCS += IDD_LVP_Detector.st
CARS_SRCS += Energy_CC.st
CARS_SRCS += Energy.st
CARS_SRCS += BM13_Energy.st
CARS_SRCS += Analyzer.st
CARS_SRCS += trajectoryScan.st
CARS_SRCS += newport_table.st
CARS_SRCS += newport_table_support.c
CARS_SRCS += CARSRegister.c
CARS_SRCS += xps_c8_driver.cpp
CARS_SRCS += Socket.cpp

CARS_LIBS += seq pv
CARS_LIBS += $(EPICS_BASE_IOC_LIBS)

#===========================

# <name>.dbd will be created from <name>Include.dbd
DBD += CARS.dbd
DBD += CARSVX.dbd

#=============================
# build an ioc application

PROD_IOC = CARSApp

# <name>_registerRecordDeviceDriver.cpp will be created from <name>.dbd
CARSApp_SRCS_DEFAULT += CARS_registerRecordDeviceDriver.cpp
CARSApp_SRCS_vxWorks += CARSVX_registerRecordDeviceDriver.cpp
CARSApp_SRCS_DEFAULT += CARSMain.cpp
CARSApp_SRCS_vxWorks += -nil-
#The following adds support from base/src/vxWorks
CARSApp_OBJS_vxWorks += $(EPICS_BASE_BIN)/vxComLibrary

CARSApp_LIBS += CARS
CARSApp_LIBS += mca 
CARSApp_LIBS += mcaCanberra
CARSApp_LIBS_vxWorks += mcaSIS
CARSApp_LIBS += std
CARSApp_LIBS_vxWorks += ip330 devIp330
CARSApp_LIBS_vxWorks  += ipUnidig
CARSApp_LIBS_vxWorks  += dac128V
CARSApp_LIBS_vxWorks  += quadEM
CARSApp_LIBS += ip
CARSApp_LIBS += bruker
CARSApp_LIBS_vxWorks  += camac devCamac
CARSApp_LIBS_vxWorks += dxp xerxes
CARSApp_LIBS_Linux += dxp xerxes
CARSApp_LIBS += Acs Ims Mclennan motor motorCOM_mpf Newport softMotor
CARSApp_LIBS_vxWorks += oms
CARSApp_LIBS += mpf mpfEpics mpfSerial
CARSApp_LIBS_vxWorks += TyGSOctal Ipac
CARSApp_LIBS_vxWorks += allenBradley
CARSApp_LIBS += seq pv
CARSApp_LIBS += $(EPICS_BASE_IOC_LIBS)

CARSApp_SYS_LIBS_DEFAULT += net pcap
CARSApp_SYS_LIBS_vxWorks += -nil-

include $(TOP)/configure/RULES
#----------------------------------------
#  ADD RULES AFTER THIS LINE

