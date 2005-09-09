#FILENAME:	Makefile
#USAGE:		Top Makefile
#Version:	$Revision$
#Modified By:	$Author$
#Last Modified:	$Date$
#NOTES- The "DIRS" order is based on compile time dependencies.
#     - The user must modify SUPPORT and EPICS_BASE for local configuration.
#     - To support multiple configurations, use multiple config* directories
#     - Support modules can be shared between configurations only if
#	dependencies are not violated.  Only the "DIRS" are the target of
#	gnumake.  If this configuration is using a support module built by
#	another configuration, then the	DIRS line for that support module
#       must be commented out (i.e, must begin with a '#').

include MASTER_RELEASE
MASTER_FILES = MASTER_RELEASE

include CONFIG
include $(EPICS_BASE)/config/CONFIG_COMMON

DIRS += $(VXSTATS)
RELEASE_FILES += $(VXSTATS)/configure/RELEASE

DIRS += $(SNCSEQ)
RELEASE_FILES += $(SNCSEQ)/configure/RELEASE

DIRS += $(ALLEN_BRADLEY)
RELEASE_FILES += $(ALLEN_BRADLEY)/configure/RELEASE

DIRS += $(IPAC)
RELEASE_FILES += $(IPAC)/configure/RELEASE

DIRS += $(ASYN)
RELEASE_FILES += $(ASYN)/configure/RELEASE

DIRS += $(MOTOR)
RELEASE_FILES += $(MOTOR)/configure/RELEASE

DIRS += $(STD)
RELEASE_FILES += $(STD)/configure/RELEASE

DIRS += $(SSCAN)
RELEASE_FILES += $(SSCAN)/configure/RELEASE

DIRS += $(GENSUB)
RELEASE_FILES += $(GENSUB)/configure/RELEASE

DIRS += $(CALC)
RELEASE_FILES += $(CALC)/configure/RELEASE

DIRS += $(VME)
RELEASE_FILES += $(VME)/configure/RELEASE

DIRS += $(OPTICS)
RELEASE_FILES += $(OPTICS)/configure/RELEASE

DIRS += $(AUTOSAVE)
RELEASE_FILES += $(AUTOSAVE)/configure/RELEASE

DIRS += $(DAC128V)
RELEASE_FILES += $(DAC128V)/configure/RELEASE

DIRS += $(IPUNIDIG)
RELEASE_FILES += $(IPUNIDIG)/configure/RELEASE

DIRS += $(LOVE)
RELEASE_FILES += $(LOVE)/configure/RELEASE

DIRS += $(MCA)
RELEASE_FILES += $(MCA)/configure/RELEASE

DIRS += $(CAMAC)
RELEASE_FILES += $(CAMAC)/configure/RELEASE

DIRS += $(IP330)
RELEASE_FILES += $(IP330)/configure/RELEASE

DIRS += $(IP)
RELEASE_FILES += $(IP)/configure/RELEASE

DIRS += $(DXP)
RELEASE_FILES += $(DXP)/configure/RELEASE

DIRS += $(CCD)
RELEASE_FILES += $(CCD)/configure/RELEASE

DIRS += $(QUADEM)
RELEASE_FILES += $(QUADEM)/configure/RELEASE

DIRS += $(XXX)
RELEASE_FILES += $(XXX)/configure/RELEASE

DIRS += $(CARS)
RELEASE_FILES += $(CARS)/configure/RELEASE

all install clean rebuild inc depends build uninstall release:
	echo SUPPORT=$(SUPPORT)
	echo ' '
	echo EPICS_BASE=$(EPICS_BASE)
	echo ' '
	echo MASTER_FILES=$(MASTER_FILES)
	echo ' '
	echo RELEASE_FILES=$(RELEASE_FILES)
	echo ' '
	$(PERL) makeReleaseConsistent.pl $(SUPPORT) $(EPICS_BASE) $(MASTER_FILES) $(RELEASE_FILES)

# per jba, to support actions normally defined in RULES_TOP 
ACTIONS += uninstall distclean cvsclean realuninstall

include $(SUPPORT)/config/RULES_DIRS
