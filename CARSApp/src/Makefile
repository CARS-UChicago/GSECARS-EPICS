TOP=../..

include $(TOP)/configure/CONFIG
#----------------------------------------
#  ADD MACRO DEFINITIONS AFTER THIS LINE
#=============================

# For Kate Feng's implementation of devScaler.c, which uses Till
# Straumann's basicIoOps.h to bridge any mismatch between endianness
# of Joerger scaler hardware and endianness of processor.
#USR_CFLAGS += -DHAS_IOOPS_H

LIBRARY_IOC += CARS

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


#=============================
# build an ioc application

PROD_IOC = CARSApp

# Note that the order in which .dbd files and libraries are added to a list
# variable is important.  For .dbd files, things must be defined before they
# are referenced by a later .dbd file.  For libraries, things must be referenced
# before they are searched for; otherwise they won't be included.

##################################################################
# First, define CARS_Common_DBD and CARS_Common_LIBS from the modules
# defined in RELEASE
##################################################################
DBD += CARS_Common.dbd
CARS_Common_DBD += base.dbd

#ifdef TDS3000
#	CARS_Common_DBD += devTDS3000.dbd
#	CARS_Common_LIBS := devTDS3000 $(CARS_Common_LIBS)
#endif

#ifdef CAPUTLOG
#	CARS_Common_DBD += caPutLog.dbd
#	CARS_Common_LIBS := caPutLog $(CARS_Common_LIBS)
#endif

ifdef CAPUTRECORDER
	CARS_Common_DBD += caputRecorder.dbd
	CARS_Common_LIBS := caputRecorder $(CARS_Common_LIBS)
endif

ifdef SNCSEQ
	ifeq (seq-2-1, $(findstring seq-2-1, $(SNCSEQ)))
		CARS_Common_DBD += devSequencer.dbd
		CARS_Common_LIBS := seqDev seq pv $(CARS_Common_LIBS)
	else ifeq (seq-2.1, $(findstring seq-2.1, $(SNCSEQ)))
		CARS_Common_DBD += devSequencer.dbd
		CARS_Common_LIBS := seqDev seq pv $(CARS_Common_LIBS)
	else
		# seq 2.2.
		CARS_Common_LIBS := seq pv $(CARS_Common_LIBS)
	endif
endif

ifdef ASYN
	CARS_Common_DBD += asyn.dbd drvAsynSerialPort.dbd
	CARS_Common_DBD += drvAsynIPPort.dbd drvVxi11.dbd devGpib.dbd
	CARS_Common_LIBS := asyn $(CARS_Common_LIBS)
endif

ifdef STD
	CARS_Common_DBD += stdSupport.dbd
	CARS_Common_LIBS := std $(CARS_Common_LIBS)
endif

ifdef CALC
	CARS_Common_DBD += calcSupport.dbd
	CARS_Common_LIBS := calc $(CARS_Common_LIBS)
endif

ifdef BUSY
	CARS_Common_DBD += busySupport.dbd
	CARS_Common_LIBS := busy $(CARS_Common_LIBS)
endif

ifdef SSCAN
	CARS_Common_DBD += sscanSupport.dbd
	CARS_Common_LIBS := sscan $(CARS_Common_LIBS)
	ifdef SNCSEQ
		CARS_Common_DBD += sscanProgressSupport.dbd
		CARS_Common_LIBS := scanProgress $(CARS_Common_LIBS)
	endif
endif

ifdef AUTOSAVE
	CARS_Common_DBD += asSupport.dbd
	CARS_Common_LIBS := autosave $(CARS_Common_LIBS)
endif

ifdef OPTICS
	CARS_Common_DBD += opticsSupport.dbd
	CARS_Common_LIBS := optics $(CARS_Common_LIBS)
endif

ifdef MCA
	CARS_Common_DBD += mcaSupport.dbd
	CARS_Common_LIBS := mca $(CARS_Common_LIBS)
endif

ifdef IP
	CARS_Common_DBD += ipSupport.dbd
	CARS_Common_LIBS := ip $(CARS_Common_LIBS)
endif

ifdef MODBUS
	CARS_Common_DBD += modbusSupport.dbd
	CARS_Common_LIBS := modbus $(CARS_Common_LIBS)
endif

ifdef MOTOR
	CARS_Common_DBD += motorSupport.dbd ACRMotorSupport.dbd devAcsMotor.dbd devAerotech.dbd
	CARS_Common_DBD += devAttocube.dbd devFaulhaberMotor.dbd devImsMotor.dbd
	CARS_Common_DBD += devKohzuMotor.dbd devMclennanMotor.dbd devMicos.dbd
	CARS_Common_DBD += devMicroMo.dbd devNewFocus.dbd devNewport.dbd
  ifdef SNCSEQ
	CARS_Common_DBD += devAerotechSeq.dbd devNewportSeq.dbd
  endif
	CARS_Common_DBD += devOriel.dbd devPC6K.dbd devPIJena.dbd devPIMotor.dbd
	CARS_Common_DBD += devSPiiPlus.dbd devSmartMotorMotor.dbd devSoftMotor.dbd
	CARS_Common_DBD += devThorLabs.dbd motorSimSupport.dbd

	CARS_Common_LIBS := motor $(CARS_Common_LIBS)
	CARS_Common_LIBS := ACRMotor Acs acsTech80 Aerotech Attocube Faulhaber Ims KohzuMotor $(CARS_Common_LIBS)
	CARS_Common_LIBS := Mclennan Micos MicroMo NewFocus Newport Oriel PI PIJena $(CARS_Common_LIBS)
	CARS_Common_LIBS := Parker SmartMotor ThorLabs softMotor motorSimSupport $(CARS_Common_LIBS)
endif

ifdef STREAM
	CARS_Common_DBD += stream.dbd streamSynApps.dbd
	CARS_Common_LIBS := stream streamSynApps $(CARS_Common_LIBS)
endif

ifdef DEVIOCSTATS
	CARS_Common_DBD += devIocStats.dbd iocAdmin.dbd
	CARS_Common_LIBS := devIocStats $(CARS_Common_LIBS)
endif

ifdef ETHERIP
	CARS_Common_DBD += ether_ip.dbd
	CARS_Common_LIBS := ether_ip $(CARS_Common_LIBS)
endif

ifdef ALIVE
	CARS_Common_DBD += aliveSupport.dbd
	CARS_Common_LIBS := alive $(CARS_Common_LIBS)
endif

ifdef DELAYGEN
	CARS_Common_DBD += delaygenSupport.dbd
	CARS_Common_LIBS := delaygen $(CARS_Common_LIBS)
endif

ifdef VAC
	CARS_Common_DBD += vacSupport.dbd
	CARS_Common_LIBS := vac $(CARS_Common_LIBS)
endif

ifdef AREA_DETECTOR
  # areaDetector provides a Makefile for things it needs and supplies
	PROD_NAME = CARSApp
	-include $(ADCORE)/ADApp/commonDriverMakefile
	CARS_Common_DBD += ADSupport.dbd NDPluginSupport.dbd
endif

ifdef QUADEM
  CARS_Common_DBD += drvAHxxx.dbd drvTetrAMM.dbd
	CARS_Common_LIBS += quadEM
endif

ifdef TPMAC
  CARS_Common_DBD += pmacAsynMotor.dbd
	CARS_Common_LIBS += pmacAsynMotor pmacAsynIPPort
endif

#ifdef FLY
#	CARS_Common_DBD += flySupport.dbd
#	CARS_Common_LIBS := fly $(CARS_Common_LIBS)
#endif


ifdef CARS
  CARS_Common_DBD += CARSSupport.dbd
	CARS_Common_LIBS += CARS
endif

CARS_Common_LIBS := $(CARS_Common_LIBS) $(EPICS_BASE_IOC_LIBS)

##################################################################
# Things we can build on both 32-bit and 64-bit Windows

ifeq ($(OS_CLASS), WIN32)
  DBD  += CARSWin32.dbd
  CARSWin32_DBD += CARS_Common.dbd

  ifdef MEASCOMP
    CARSWin32_DBD += measCompSupport.dbd
	  CARSApp_LIBS_WIN32 += measComp
    ifeq (win32-x86, $(findstring win32-x86, $(T_A)))
      CARSApp_LIBS_WIN32 += cbw32
    else ifeq (windows-x64, $(findstring windows-x64, $(T_A)))
      CARSApp_LIBS_WIN32 += cbw64
    endif
  endif

	ifdef MCA
		# If your host supports libpcap and libnet and you want to build
		# Canberra network support uncomment the following lines
		CARSWin32_DBD += mcaCanberraSupport.dbd
		CARSApp_LIBS_WIN32 += mcaCanberra
		CARSApp_LIBS_WIN32 += wpcap Packet
		
		CARSWin32_DBD += mcaAmptekSupport.dbd
    CARSApp_LIBS_WIN32 += mcaAmptek
    CARSApp_LIBS_WIN32 += libusb-1.0

	endif
endif

ifeq ($(OS_CLASS), vxWorks)
	DBD  += CARSVX.dbd
	CARS_VX_DBD += CARS_Common.dbd

	ifdef ALLEN_BRADLEY
		CARS_VX_DBD += allenBradley.dbd
		CARSApp_LIBS_vxWorks += allenBradley
	endif

	ifdef VME
		CARS_VX_DBD += vmeVXSupport.dbd
		CARSApp_LIBS_vxWorks += vme
	endif

	ifdef STD
		CARS_VX_DBD += stdVXSupport.dbd
	endif

	ifdef IP
		CARS_VX_DBD += ipVXSupport.dbd
	endif

	ifdef MCA
		CARS_VX_DBD += SIS38XXSupport.dbd
		CARS_VX_DBD += mcaCanberraSupport.dbd
		CARSApp_LIBS_vxWorks += SIS38XX
		CARSApp_LIBS_vxWorks += mcaCanberra
	endif

	ifdef IPUNIDIG
		CARS_VX_DBD += ipUnidigSupport.dbd
		CARSApp_LIBS_vxWorks += ipUnidig
	endif

	ifdef DAC128V
		CARS_VX_DBD += dac128VSupport.dbd
		CARSApp_LIBS_vxWorks += dac128V
	endif

	ifdef IP330
		CARS_VX_DBD += ip330Support.dbd
		CARSApp_LIBS_vxWorks += ip330
	endif

	ifdef CAMAC
		CARS_VX_DBD += camacSupport.dbd
		CARS_VX_DBD += devCamacSupport.dbd
		CARSApp_LIBS_vxWorks += camac devCamac
	endif

	ifdef LOVE
		CARS_VX_DBD += devLove.dbd
		CARSApp_LIBS_vxWorks += love
	endif

	ifdef IPAC
		CARS_VX_DBD += tyGSOctal.dbd
		CARS_VX_DBD += drvIpac.dbd
		CARSApp_LIBS_vxWorks += TyGSOctal Ipac
		CARS_VX_DBD += IP520.dbd
		CARSApp_LIBS_vxWorks += IP520
	endif

	ifdef ASYN
		CARS_VX_DBD += drvGsIP488.dbd
	endif

	ifdef SOFTGLUE
		CARS_VX_DBD += softGlueSupport.dbd
		CARSApp_LIBS_vxWorks += softGlue
	endif

	ifdef MOTOR
		CARS_VX_DBD += devDeltaTau.dbd
		CARS_VX_DBD += devOms.dbd
		CARSApp_LIBS_vxWorks += oms DeltaTau
	endif

#	ifdef FLY
#		CARS_VX_DBD += flyVXSupport.dbd
#		CARSApp_LIBS_vxWorks += fly
#	endif

endif

ifeq ($(OS_CLASS), Linux)
	DBD  += CARSLinux.dbd
	CARSLinux_DBD += CARS_Common.dbd


	ifdef MCA
		# If your host supports libpcap and libnet and you want to build Canberra network
		# support, set LINUX_NET_INSTALLED to YES in <synApps>/configure/CONFIG_SITE.
		ifeq ($(LINUX_NET_INSTALLED), YES)
			CARSLinux_DBD += mcaCanberraSupport.dbd
			CARSApp_LIBS_Linux += mcaCanberra
			CARSApp_SYS_LIBS_Linux += net pcap
		endif
		
		ifeq ($(LINUX_USB1.0_INSTALLED), YES)
	    CARSLinux_DBD += mcaAmptekSupport.dbd
      CARSApp_LIBS_Linux += mcaAmptek
      CARSApp_SYS_LIBS_Linux += libusb-1.0
    endif
	endif

	ifdef IPAC
		CARSLinux_DBD += drvIpac.dbd
		CARSApp_LIBS_Linux += Ipac
	endif

	ifdef IPUNIDIG
		CARSLinux_DBD += ipUnidigSupport.dbd
		CARSApp_LIBS_Linux += ipUnidig
	endif

	ifdef DAC128V
		CARSLinux_DBD += dac128VSupport.dbd
		CARSApp_LIBS_Linux += dac128V
	endif

	ifdef IP330
		CARSLinux_DBD += ip330Support.dbd
		CARSApp_LIBS_Linux += ip330
	endif

	ifdef SOFTGLUE
		CARSLinux_DBD += softGlueSupport.dbd
		CARSApp_LIBS_Linux += softGlue
	endif
endif

ifeq ($(OS_CLASS), Darwin)
	DBD  += CARSDarwin.dbd
	CARSDarwin_DBD += CARS_Common.dbd
endif

# <name>_registerRecordDeviceDriver.cpp will be created from <name>.dbd
CARSApp_SRCS_vxWorks  += CARSVX_registerRecordDeviceDriver.cpp
CARSApp_SRCS_Linux    += CARSLinux_registerRecordDeviceDriver.cpp     CARSMain.cpp
CARSApp_SRCS_WIN32    += CARSWin32_registerRecordDeviceDriver.cpp     CARSMain.cpp
CARSApp_SRCS_Darwin   += CARSDarwin_registerRecordDeviceDriver.cpp    CARSMain.cpp

#The following adds support from base/src/vxWorks
CARS_OBJS_vxWorks += $(EPICS_BASE_BIN)/vxComLibrary

CARSApp_LIBS_vxWorks  += $(CARS_Common_LIBS)
CARSApp_LIBS_Linux    += $(CARS_Common_LIBS)
CARSApp_LIBS_WIN32    += $(CARS_Common_LIBS)
CARSApp_LIBS_Darwin   += $(CARS_Common_LIBS)

# Here's how to print out all gnumake variables
#$(foreach v, $(.VARIABLES), $(info $(v) = $($(v))))
# print out just one variable
#$(info SUPPORT = $(SUPPORT))

#===========================

include $(TOP)/configure/RULES
#----------------------------------------
#  ADD RULES AFTER THIS LINE

$(COMMON_DIR)/CARSWin32Include.dbd: $(COMMON_DIR)/CARS_Common.dbd
$(COMMON_DIR)/CARSWin64Include.dbd: $(COMMON_DIR)/CARS_Common.dbd
$(COMMON_DIR)/CARSVXInclude.dbd: $(COMMON_DIR)/CARS_Common.dbd
$(COMMON_DIR)/CARSLinuxInclude.dbd: $(COMMON_DIR)/CARS_Common.dbd
$(COMMON_DIR)/CARSDarwinInclude.dbd: $(COMMON_DIR)/CARS_Common.dbd

$(COMMON_DIR)/CARSWin32.dbd: $(COMMON_DIR)/CARS_Common.dbd
$(COMMON_DIR)/CARSWin64.dbd: $(COMMON_DIR)/CARS_Common.dbd
$(COMMON_DIR)/CARSVX.dbd: $(COMMON_DIR)/CARS_Common.dbd
$(COMMON_DIR)/CARSLinux.dbd: $(COMMON_DIR)/CARS_Common.dbd
$(COMMON_DIR)/CARSDarwin.dbd: $(COMMON_DIR)/CARS_Common.dbd

CARSWin32.dbd$(DEP): $(COMMON_DIR)/CARS_Common.dbd
CARSWin64.dbd$(DEP): $(COMMON_DIR)/CARS_Common.dbd
CARSVX.dbd$(DEP): $(COMMON_DIR)/CARS_Common.dbd
CARSLinux.dbd$(DEP): $(COMMON_DIR)/CARS_Common.dbd
CARSDarwin.dbd$(DEP): $(COMMON_DIR)/CARS_Common.dbd
