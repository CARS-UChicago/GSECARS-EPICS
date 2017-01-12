TOP=../..

include $(TOP)/configure/CONFIG
#----------------------------------------
#  ADD MACRO DEFINITIONS AFTER THIS LINE
#=============================

#==================================================
# build a support library

LIBRARY_IOC += CARS

CARS_Common_LIBS += busy
CARS_Common_LIBS += mca 
CARS_Common_LIBS += mcaCanberra
CARS_Common_LIBS += calc
CARS_Common_LIBS += sscan
CARS_Common_LIBS += autosave
CARS_Common_LIBS += optics
CARS_Common_LIBS += std
CARS_Common_LIBS += busy
CARS_Common_LIBS += ip
CARS_Common_LIBS += quadEM
CARS_Common_LIBS += pmacAsynMotor pmacAsynIPPort
CARS_Common_LIBS += ACRMotor Aerotech Acs Faulhaber Ims Mclennan Newport Parker motorSimSupport softMotor motor
CARS_Common_LIBS += stream streamSynApps
CARS_Common_LIBS += modbus
CARS_Common_LIBS += ADBase
CARS_Common_LIBS += asyn
CARS_Common_LIBS += seq pv
CARS_Common_LIBS += devIocStats
CARS_Common_LIBS += $(EPICS_BASE_IOC_LIBS)

# The following are compiled and added to the Support library
CARS_SRCS += coordTrans2D.st
CARS_SRCS += BMD_LVP_Detector.st
CARS_SRCS += IDD_LVP_Detector.st
CARS_SRCS += Energy_CC.st
CARS_SRCS += Energy.st
CARS_SRCS += GSE_MonoEnergy.st
CARS_SRCS += tomoCollect.st
CARS_SRCS += GSE_MonoSupport.cpp
CARS_SRCS += BM13_Energy.st
CARS_SRCS += Analyzer.st
CARS_SRCS += newport_table.st
CARS_SRCS += newport_table_support.c
CARS_SRCS += splint.c
CARS_SRCS_Linux   += testIpac.c
CARS_SRCS_vxWorks += testIpac.c

#===========================

# <name>.dbd will be created from <name>Include.dbd
DBD += CARS.dbd
DBD += CARSMini.dbd
DBD += CARSVX.dbd
DBD += CARSLinux.dbd
DBD += CARSWin32.dbd

#=============================
# build an ioc application

PROD_IOC = CARSApp
PROD_NAME = CARSApp
PROD_IOC_vxWorks = CARSAppMini

# <name>_registerRecordDeviceDriver.cpp will be created from <name>.dbd
CARSApp_SRCS_DEFAULT += CARS_registerRecordDeviceDriver.cpp CARSMain.cpp
CARSApp_SRCS_Linux   += CARSLinux_registerRecordDeviceDriver.cpp CARSMain.cpp
CARSApp_SRCS_WIN32   += CARSWin32_registerRecordDeviceDriver.cpp CARSMain.cpp
CARSApp_SRCS_vxWorks += CARSVX_registerRecordDeviceDriver.cpp

CARSAppMini_SRCS += CARSMini_registerRecordDeviceDriver.cpp

CARS_vxWorks_LIBS += allenBradley
CARS_vxWorks_LIBS += SIS38XX
CARS_vxWorks_LIBS += ip330
CARS_vxWorks_LIBS += ipUnidig
CARS_vxWorks_LIBS += dac128V
CARS_vxWorks_LIBS += camac devCamac
CARS_vxWorks_LIBS += dxp handel
CARS_vxWorks_LIBS += oms
CARS_vxWorks_LIBS += vme
CARS_vxWorks_LIBS += TyGSOctal Ipac
CARS_vxWorks_LIBS += softGlue
#The following adds support from base/src/vxWorks
CARSApp_OBJS_vxWorks += $(EPICS_BASE_BIN)/vxComLibrary

CARS_Linux_LIBS        += ip330
CARS_Linux_LIBS        += ipUnidig
CARS_Linux_LIBS        += dac128V
CARS_Linux_LIBS        += softGlue
CARS_Linux_LIBS        += Ipac
#CARS_Linux_LIBS        += Hy8522Asyn
CARS_Linux_SYS_LIBS    += net pcap
CARS_Linux_SYS_LIBS    += usb

CARS_WIN32_LIBS        += wpcap Packet 
CARS_WIN32_LIBS        += measComp
ifeq (win32-x86, $(findstring win32-x86, $(T_A)))
CARS_WIN32_LIBS        += cbw32
else ifeq (windows-x64, $(findstring windows-x64, $(T_A)))
CARS_WIN32_LIBS        += cbw64
endif

CARS_Cygwin_SYS_LIBS   += wpcap Packet
CARS_Cygwin_SYS_LIBS   += $(CYGWIN_RPC_LIB)

include $(ADCORE)/ADApp/commonDriverMakefile

CARSApp_LIBS_DEFAULT       = CARS                         $(CARS_Common_LIBS)                            
LIB_LIBS_DEFAULT          +=                              $(CARS_Common_LIBS)                            
CARSApp_LIBS_vxWorks       = CARS $(CARS_vxWorks_LIBS)    $(CARS_Common_LIBS)
LIB_LIBS_vxWorks          +=      $(CARS_vxWorks_LIBS)    $(CARS_Common_LIBS)
CARSApp_LIBS_Linux         = CARS $(CARS_Linux_LIBS)      $(CARS_Common_LIBS)
CARSApp_SYS_LIBS_Linux    +=      $(CARS_Linux_SYS_LIBS)
LIB_LIBS_Linux            +=      $(CARS_Linux_LIBS)      $(CARS_Common_LIBS)
LIB_SYS_LIBS_Linux        +=      $(CARS_Linux_SYS_LIBS)
CARSApp_LIBS_cygwin32      = CARS                         $(CARS_Common_LIBS)
CARSApp_SYS_LIBS_cygwin32 +=      $(CARS_Cygwin_SYS_LIBS)
LIB_LIBS_cygwin32         +=                              $(CARS_Common_LIBS)
LIB_SYS_LIBS_cygwin32     +=      $(CARS_Cygwin_SYS_LIBS)
CARSApp_LIBS_WIN32         = CARS $(CARS_WIN32_LIBS)      $(CARS_Common_LIBS)
LIB_LIBS_WIN32            +=      $(CARS_WIN32_LIBS)      $(CARS_Common_LIBS)

CARSAppMini_LIBS += busy
CARSAppMini_LIBS += mca 
CARSAppMini_LIBS += SIS38XX
CARSAppMini_LIBS += calc
CARSAppMini_LIBS += sscan
CARSAppMini_LIBS += autosave
CARSAppMini_LIBS += optics
CARSAppMini_LIBS += std
CARSAppMini_LIBS += busy
CARSAppMini_LIBS += ip
CARSAppMini_LIBS += oms softMotor motor
CARSAppMini_LIBS += asyn
CARSAppMini_LIBS += seq pv
CARSAppMini_LIBS += TyGSOctal Ipac
CARSAppMini_LIBS += devIocStats
CARSAppMini_LIBS += $(EPICS_BASE_IOC_LIBS)
#The following adds support from base/src/vxWorks
CARSAppMini_OBJS_vxWorks += $(EPICS_BASE_BIN)/vxComLibrary


include $(TOP)/configure/RULES
#----------------------------------------
#  ADD RULES AFTER THIS LINE

