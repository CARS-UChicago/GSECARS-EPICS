TOP = ../..
include $(TOP)/configure/CONFIG
ARCH=windows-x64-static
# vxWorks architecture needs a cdCommands file
buildInstall: cdCommands envPaths dllPath.bat

include $(TOP)/configure/RULES.ioc
