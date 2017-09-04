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

CARS_LIBS += seq pv $(EPICS_IOC_BASE_LIBS)
# GSE_MonoSupport.cpp needs libxml2.  That is provided in ADSupport.
-include $(ADCORE)/ADApp/commonLibraryMakefile


#=============================
# build an ioc application

PROD_NAME = CARSApp
DBD_PREFIX = CARS
PROD_IOC = $(PROD_NAME)

# Note that the order in which .dbd files and libraries are added to a list
# variable is important.  For .dbd files, things must be defined before they
# are referenced by a later .dbd file.  For libraries, things must be referenced
# before they are searched for; otherwise they won't be included.

##################################################################
# First, define $(PROD_NAME)_Common_DBD and $(PROD_NAME)_Common_LIBS from the modules
# defined in RELEASE
##################################################################
DBD += $(PROD_NAME)_Common.dbd
$(PROD_NAME)_Common_DBD += base.dbd

#ifdef TDS3000
#	$(PROD_NAME)_Common_DBD += devTDS3000.dbd
#	$(PROD_NAME)_Common_LIBS := devTDS3000 $($(PROD_NAME)_Common_LIBS)
#endif

#ifdef CAPUTLOG
#	$(PROD_NAME)_Common_DBD += caPutLog.dbd
#	$(PROD_NAME)_Common_LIBS := caPutLog $($(PROD_NAME)_Common_LIBS)
#endif

ifdef CAPUTRECORDER
	$(PROD_NAME)_Common_DBD += caputRecorder.dbd
	$(PROD_NAME)_Common_LIBS := caputRecorder $($(PROD_NAME)_Common_LIBS)
endif

ifdef SNCSEQ
	ifeq (seq-2-1, $(findstring seq-2-1, $(SNCSEQ)))
		$(PROD_NAME)_Common_DBD += devSequencer.dbd
		$(PROD_NAME)_Common_LIBS := seqDev seq pv $($(PROD_NAME)_Common_LIBS)
	else ifeq (seq-2.1, $(findstring seq-2.1, $(SNCSEQ)))
		$(PROD_NAME)_Common_DBD += devSequencer.dbd
		$(PROD_NAME)_Common_LIBS := seqDev seq pv $($(PROD_NAME)_Common_LIBS)
	else
		# seq 2.2.
		$(PROD_NAME)_Common_LIBS := seq pv $($(PROD_NAME)_Common_LIBS)
	endif
endif

ifdef ASYN
	$(PROD_NAME)_Common_DBD += asyn.dbd drvAsynSerialPort.dbd
	$(PROD_NAME)_Common_DBD += drvAsynIPPort.dbd drvVxi11.dbd devGpib.dbd
	$(PROD_NAME)_Common_LIBS := asyn $($(PROD_NAME)_Common_LIBS)
endif

ifdef STD
	$(PROD_NAME)_Common_DBD += stdSupport.dbd
	$(PROD_NAME)_Common_LIBS := std $($(PROD_NAME)_Common_LIBS)
endif

ifdef CALC
	$(PROD_NAME)_Common_DBD += calcSupport.dbd
	$(PROD_NAME)_Common_LIBS := calc $($(PROD_NAME)_Common_LIBS)
endif

ifdef BUSY
	$(PROD_NAME)_Common_DBD += busySupport.dbd
	$(PROD_NAME)_Common_LIBS := busy $($(PROD_NAME)_Common_LIBS)
endif

ifdef SSCAN
	$(PROD_NAME)_Common_DBD += sscanSupport.dbd
	$(PROD_NAME)_Common_LIBS := sscan $($(PROD_NAME)_Common_LIBS)
	ifdef SNCSEQ
		$(PROD_NAME)_Common_DBD += sscanProgressSupport.dbd
		$(PROD_NAME)_Common_LIBS := scanProgress $($(PROD_NAME)_Common_LIBS)
	endif
endif

ifdef AUTOSAVE
	$(PROD_NAME)_Common_DBD += asSupport.dbd
	$(PROD_NAME)_Common_LIBS := autosave $($(PROD_NAME)_Common_LIBS)
endif

ifdef OPTICS
	$(PROD_NAME)_Common_DBD += opticsSupport.dbd
	$(PROD_NAME)_Common_LIBS := optics $($(PROD_NAME)_Common_LIBS)
endif

ifdef MCA
	$(PROD_NAME)_Common_DBD += mcaSupport.dbd
	$(PROD_NAME)_Common_LIBS := mca $($(PROD_NAME)_Common_LIBS)
endif

ifdef IP
	$(PROD_NAME)_Common_DBD += ipSupport.dbd
	$(PROD_NAME)_Common_LIBS := ip $($(PROD_NAME)_Common_LIBS)
endif

ifdef MODBUS
	$(PROD_NAME)_Common_DBD += modbusSupport.dbd
	$(PROD_NAME)_Common_LIBS := modbus $($(PROD_NAME)_Common_LIBS)
endif

ifdef MOTOR
	$(PROD_NAME)_Common_DBD += motorSupport.dbd ACRMotorSupport.dbd devAcsMotor.dbd devAerotech.dbd
	$(PROD_NAME)_Common_DBD += devAttocube.dbd devFaulhaberMotor.dbd devImsMotor.dbd
	$(PROD_NAME)_Common_DBD += devKohzuMotor.dbd devMclennanMotor.dbd devMicos.dbd
	$(PROD_NAME)_Common_DBD += devMicroMo.dbd devNewFocus.dbd devNewport.dbd
  ifdef SNCSEQ
	$(PROD_NAME)_Common_DBD += devAerotechSeq.dbd devNewportSeq.dbd
  endif
	$(PROD_NAME)_Common_DBD += devOriel.dbd devPC6K.dbd devPIJena.dbd devPIMotor.dbd
	$(PROD_NAME)_Common_DBD += devSPiiPlus.dbd devSmartMotorMotor.dbd devSoftMotor.dbd
	$(PROD_NAME)_Common_DBD += devThorLabs.dbd motorSimSupport.dbd

	$(PROD_NAME)_Common_LIBS := motor $($(PROD_NAME)_Common_LIBS)
	$(PROD_NAME)_Common_LIBS := ACRMotor Acs acsTech80 Aerotech Attocube Faulhaber Ims KohzuMotor $($(PROD_NAME)_Common_LIBS)
	$(PROD_NAME)_Common_LIBS := Mclennan Micos MicroMo NewFocus Newport Oriel PI PIJena $($(PROD_NAME)_Common_LIBS)
	$(PROD_NAME)_Common_LIBS := Parker SmartMotor ThorLabs softMotor motorSimSupport $($(PROD_NAME)_Common_LIBS)
endif

ifdef STREAM
	$(PROD_NAME)_Common_DBD += stream.dbd streamSynApps.dbd
	$(PROD_NAME)_Common_LIBS := stream streamSynApps $($(PROD_NAME)_Common_LIBS)
endif

ifdef DEVIOCSTATS
	$(PROD_NAME)_Common_DBD += devIocStats.dbd iocAdmin.dbd
	$(PROD_NAME)_Common_LIBS := devIocStats $($(PROD_NAME)_Common_LIBS)
endif

ifdef ETHERIP
	$(PROD_NAME)_Common_DBD += ether_ip.dbd
	$(PROD_NAME)_Common_LIBS := ether_ip $($(PROD_NAME)_Common_LIBS)
endif

ifdef ALIVE
	$(PROD_NAME)_Common_DBD += aliveSupport.dbd
	$(PROD_NAME)_Common_LIBS := alive $($(PROD_NAME)_Common_LIBS)
endif

ifdef DELAYGEN
	$(PROD_NAME)_Common_DBD += delaygenSupport.dbd
	$(PROD_NAME)_Common_LIBS := delaygen $($(PROD_NAME)_Common_LIBS)
endif

ifdef VAC
	$(PROD_NAME)_Common_DBD += vacSupport.dbd
	$(PROD_NAME)_Common_LIBS := vac $($(PROD_NAME)_Common_LIBS)
endif

ifdef ADCORE
  # areaDetector provides a Makefile for things it needs and supplies
	-include $(ADCORE)/ADApp/commonDriverMakefile
	$(PROD_NAME)_Common_DBD += ADSupport.dbd NDPluginSupport.dbd
endif

ifdef QUADEM
  $(PROD_NAME)_Common_DBD += drvAHxxx.dbd drvTetrAMM.dbd
	$(PROD_NAME)_Common_LIBS += quadEM
endif

ifdef TPMAC
  $(PROD_NAME)_Common_DBD += pmacAsynMotor.dbd
	$(PROD_NAME)_Common_LIBS += pmacAsynMotor pmacAsynIPPort
endif

#ifdef FLY
#	$(PROD_NAME)_Common_DBD += flySupport.dbd
#	$(PROD_NAME)_Common_LIBS := fly $($(PROD_NAME)_Common_LIBS)
#endif


ifdef CARS
  $(PROD_NAME)_Common_DBD += CARSSupport.dbd
	$(PROD_NAME)_Common_LIBS += CARS
endif

$(PROD_NAME)_Common_LIBS := $($(PROD_NAME)_Common_LIBS) $(EPICS_BASE_IOC_LIBS)

##################################################################
# Windows
WINDOWS_TARGET =
ifeq (win32-x86, $(findstring win32-x86, $(T_A)))
  WINDOWS_TARGET = YES
endif
ifeq (windows-x64, $(findstring windows-x64, $(T_A)))
  WINDOWS_TARGET = YES
endif
ifdef WINDOWS_TARGET
  DBD  += $(DBD_PREFIX)Win32.dbd
  $(DBD_PREFIX)Win32_DBD += $(PROD_NAME)_Common.dbd

  ifdef MEASCOMP
    $(DBD_PREFIX)Win32_DBD += measCompSupport.dbd
	  $(PROD_NAME)_LIBS_WIN32 += measComp
    ifeq (win32-x86, $(findstring win32-x86, $(T_A)))
      $(PROD_NAME)_LIBS_WIN32 += cbw32
    else ifeq (windows-x64, $(findstring windows-x64, $(T_A)))
      $(PROD_NAME)_LIBS_WIN32 += cbw64
    endif
  endif

	ifdef MCA
		# If your host supports libpcap and libnet and you want to build
		# Canberra network support uncomment the following lines
		$(DBD_PREFIX)Win32_DBD += mcaCanberraSupport.dbd
		$(PROD_NAME)_LIBS_WIN32 += mcaCanberra
		$(PROD_NAME)_LIBS_WIN32 += wpcap Packet
		
		$(DBD_PREFIX)Win32_DBD += mcaAmptekSupport.dbd
    $(PROD_NAME)_LIBS_WIN32 += mcaAmptek
    $(PROD_NAME)_LIBS_WIN32 += libusb-1.0

	endif
endif

ifeq (vxWorks,$(findstring vxWorks, $(T_A)))
	DBD  += $(DBD_PREFIX)VX.dbd
	$(DBD_PREFIX)VX_DBD += $(PROD_NAME)_Common.dbd

	ifdef ALLEN_BRADLEY
		$(DBD_PREFIX)VX_DBD += allenBradley.dbd
		$(PROD_NAME)_LIBS_vxWorks += allenBradley
	endif

	ifdef VME
		$(DBD_PREFIX)VX_DBD += vmeVXSupport.dbd
		$(PROD_NAME)_LIBS_vxWorks += vme
	endif

	ifdef STD
		$(DBD_PREFIX)VX_DBD += stdVXSupport.dbd
	endif

	ifdef IP
		$(DBD_PREFIX)VX_DBD += ipVXSupport.dbd
	endif

	ifdef MCA
		$(DBD_PREFIX)VX_DBD += SIS38XXSupport.dbd
		$(DBD_PREFIX)VX_DBD += mcaCanberraSupport.dbd
		$(PROD_NAME)_LIBS_vxWorks += SIS38XX
		$(PROD_NAME)_LIBS_vxWorks += mcaCanberra
	endif

	ifdef IPUNIDIG
		$(DBD_PREFIX)VX_DBD += ipUnidigSupport.dbd
		$(PROD_NAME)_LIBS_vxWorks += ipUnidig
	endif

	ifdef DAC128V
		$(DBD_PREFIX)VX_DBD += dac128VSupport.dbd
		$(PROD_NAME)_LIBS_vxWorks += dac128V
	endif

	ifdef IP330
		$(DBD_PREFIX)VX_DBD += ip330Support.dbd
		$(PROD_NAME)_LIBS_vxWorks += ip330
	endif

	ifdef CAMAC
		$(DBD_PREFIX)VX_DBD += camacSupport.dbd
		$(DBD_PREFIX)VX_DBD += devCamacSupport.dbd
		$(PROD_NAME)_LIBS_vxWorks += camac devCamac
	endif

	ifdef LOVE
		$(DBD_PREFIX)VX_DBD += devLove.dbd
		$(PROD_NAME)_LIBS_vxWorks += love
	endif

	ifdef IPAC
		$(DBD_PREFIX)VX_DBD += tyGSOctal.dbd
		$(DBD_PREFIX)VX_DBD += drvIpac.dbd
		$(PROD_NAME)_LIBS_vxWorks += TyGSOctal Ipac
		$(DBD_PREFIX)VX_DBD += IP520.dbd
		$(PROD_NAME)_LIBS_vxWorks += IP520
	endif

	ifdef ASYN
		$(DBD_PREFIX)VX_DBD += drvGsIP488.dbd
	endif

	ifdef SOFTGLUE
		$(DBD_PREFIX)VX_DBD += softGlueSupport.dbd
		$(PROD_NAME)_LIBS_vxWorks += softGlue
	endif

	ifdef MOTOR
		$(DBD_PREFIX)VX_DBD += devDeltaTau.dbd
		$(DBD_PREFIX)VX_DBD += devOms.dbd
		$(PROD_NAME)_LIBS_vxWorks += oms DeltaTau
	endif

#	ifdef FLY
#		$(DBD_PREFIX)VX_DBD += flyVXSupport.dbd
#		$(PROD_NAME)_LIBS_vxWorks += fly
#	endif

endif

ifeq (linux,$(findstring linux, $(T_A)))
	DBD  += $(DBD_PREFIX)Linux.dbd
	$(DBD_PREFIX)Linux_DBD += $(PROD_NAME)_Common.dbd


	ifdef MCA
		# If your host supports libpcap and libnet and you want to build Canberra network
		# support, set LINUX_NET_INSTALLED to YES in <synApps>/configure/CONFIG_SITE.
		ifeq ($(LINUX_NET_INSTALLED), YES)
			$(DBD_PREFIX)Linux_DBD += mcaCanberraSupport.dbd
			$(PROD_NAME)_LIBS_Linux += mcaCanberra
			$(PROD_NAME)_SYS_LIBS_Linux += net pcap
		endif
		
		ifeq ($(LINUX_USB1.0_INSTALLED), YES)
	    $(DBD_PREFIX)Linux_DBD += mcaAmptekSupport.dbd
      $(PROD_NAME)_LIBS_Linux += mcaAmptek
      $(PROD_NAME)_SYS_LIBS_Linux += libusb-1.0
    endif
	endif

	ifdef IPAC
		$(DBD_PREFIX)Linux_DBD += drvIpac.dbd
		$(PROD_NAME)_LIBS_Linux += Ipac
	endif

	ifdef IPUNIDIG
		$(DBD_PREFIX)Linux_DBD += ipUnidigSupport.dbd
		$(PROD_NAME)_LIBS_Linux += ipUnidig
	endif

	ifdef DAC128V
		$(DBD_PREFIX)Linux_DBD += dac128VSupport.dbd
		$(PROD_NAME)_LIBS_Linux += dac128V
	endif

	ifdef IP330
		$(DBD_PREFIX)Linux_DBD += ip330Support.dbd
		$(PROD_NAME)_LIBS_Linux += ip330
	endif

	ifdef SOFTGLUE
		$(DBD_PREFIX)Linux_DBD += softGlueSupport.dbd
		$(PROD_NAME)_LIBS_Linux += softGlue
	endif
endif

ifeq ($(OS_CLASS), Darwin)
	DBD  += $(DBD_PREFIX)Darwin.dbd
	$(DBD_PREFIX)Darwin_DBD += $(PROD_NAME)_Common.dbd
endif

# <name>_registerRecordDeviceDriver.cpp will be created from <name>.dbd
$(PROD_NAME)_SRCS_vxWorks  += $(DBD_PREFIX)VX_registerRecordDeviceDriver.cpp
$(PROD_NAME)_SRCS_Linux    += $(DBD_PREFIX)Linux_registerRecordDeviceDriver.cpp     $(PROD_NAME)Main.cpp
$(PROD_NAME)_SRCS_WIN32    += $(DBD_PREFIX)Win32_registerRecordDeviceDriver.cpp     $(PROD_NAME)Main.cpp
$(PROD_NAME)_SRCS_Darwin   += $(DBD_PREFIX)Darwin_registerRecordDeviceDriver.cpp    $(PROD_NAME)Main.cpp

#The following adds support from base/src/vxWorks
$(PROD_NAME)_OBJS_vxWorks += $(EPICS_BASE_BIN)/vxComLibrary

$(PROD_NAME)_LIBS_vxWorks  += $($(PROD_NAME)_Common_LIBS)
$(PROD_NAME)_LIBS_Linux    += $($(PROD_NAME)_Common_LIBS)
$(PROD_NAME)_LIBS_WIN32    += $($(PROD_NAME)_Common_LIBS)
$(PROD_NAME)_LIBS_Darwin   += $($(PROD_NAME)_Common_LIBS)

# Here's how to print out all gnumake variables
#$(foreach v, $(.VARIABLES), $(info $(v) = $($(v))))
# print out just one variable
#$(info SUPPORT = $(SUPPORT))

#===========================

include $(TOP)/configure/RULES
#----------------------------------------
#  ADD RULES AFTER THIS LINE

$(COMMON_DIR)/$(DBD_PREFIX)Win32Include.dbd: $(COMMON_DIR)/$(PROD_NAME)_Common.dbd
$(COMMON_DIR)/$(DBD_PREFIX)Win64Include.dbd: $(COMMON_DIR)/$(PROD_NAME)_Common.dbd
$(COMMON_DIR)/$(DBD_PREFIX)VXInclude.dbd: $(COMMON_DIR)/$(PROD_NAME)_Common.dbd
$(COMMON_DIR)/$(DBD_PREFIX)LinuxInclude.dbd: $(COMMON_DIR)/$(PROD_NAME)_Common.dbd
$(COMMON_DIR)/$(DBD_PREFIX)DarwinInclude.dbd: $(COMMON_DIR)/$(PROD_NAME)_Common.dbd

$(COMMON_DIR)/$(DBD_PREFIX)Win32.dbd: $(COMMON_DIR)/$(PROD_NAME)_Common.dbd
$(COMMON_DIR)/$(DBD_PREFIX)Win64.dbd: $(COMMON_DIR)/$(PROD_NAME)_Common.dbd
$(COMMON_DIR)/$(DBD_PREFIX)VX.dbd: $(COMMON_DIR)/$(PROD_NAME)_Common.dbd
$(COMMON_DIR)/$(DBD_PREFIX)Linux.dbd: $(COMMON_DIR)/$(PROD_NAME)_Common.dbd
$(COMMON_DIR)/$(DBD_PREFIX)Darwin.dbd: $(COMMON_DIR)/$(PROD_NAME)_Common.dbd

$(DBD_PREFIX)Win32.dbd$(DEP): $(COMMON_DIR)/$(PROD_NAME)_Common.dbd
$(DBD_PREFIX)Win64.dbd$(DEP): $(COMMON_DIR)/$(PROD_NAME)_Common.dbd
$(DBD_PREFIX)VX.dbd$(DEP): $(COMMON_DIR)/$(PROD_NAME)_Common.dbd
$(DBD_PREFIX)Linux.dbd$(DEP): $(COMMON_DIR)/$(PROD_NAME)_Common.dbd
$(DBD_PREFIX)Darwin.dbd$(DEP): $(COMMON_DIR)/$(PROD_NAME)_Common.dbd
