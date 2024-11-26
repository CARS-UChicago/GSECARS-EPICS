#------------------------------------------------------------------------------
# Define environment variables
< envPaths

epicsEnvSet PORT LJT7PRO_1
epicsEnvSet PREFIX 13LJT7Pro_1:
epicsEnvSet WDIG_POINTS 4096
epicsEnvSet WGEN_POINTS 4096

#------------------------------------------------------------------------------
# Register all support components
dbLoadDatabase("$(CARS)/dbd/CARSLinux.dbd")
CARSLinux_registerRecordDeviceDriver(pdbbase)

#------------------------------------------------------------------------------
# Create driver
#LabJackShowDevices
# If identifying the device by IP name it must be fully qualified, i.e. include periods.
LabJackConfig("$(PORT)", "gse-labjack2.cars.aps.anl.gov", $(WDIG_POINTS), $(WGEN_POINTS))
#LabJackConfig("$(PORT)", "10.54.160.73",                  $(WDIG_POINTS), $(WGEN_POINTS))

#------------------------------------------------------------------------------
###  LabJack support  ###
# If running multiple LabJack devices in the same IOC must set P and PORT differently for each one.
dbLoadTemplate("$(LABJACK)/db/LabJack_T7.substitutions", "P=$(PREFIX), PORT=$(PORT), WDIG_POINTS=$(WDIG_POINTS), WGEN_POINTS=$(WGEN_POINTS)")

< ../calc_GSECARS.iocsh

# PID control 
dbLoadRecords("$(STD)/db/pid_control.db","P=$(PREFIX),PID=PID1,INP=$(PREFIX)Ai0,OUT=$(PREFIX)Ao0")

### Scan-support software
dbLoadRecords("$(SSCAN)/db/scan.db", "P=$(PREFIX),MAXPTS1=2000,MAXPTS2=200,MAXPTS3=20,MAXPTS4=10,MAXPTSH=10")

< ../save_restore_IOCSH.cmd

# devIocStats
epicsEnvSet("ENGINEER", "Mark Rivers")
epicsEnvSet("LOCATION","Sector 13 portable")
epicsEnvSet("GROUP","GSECARS")
dbLoadRecords("$(DEVIOCSTATS)/db/iocAdminSoft.db","IOC=13LabJackT7Pro_1:")

#------------------------------------------------------------------------------
# Start IOC
iocInit()

#------------------------------------------------------------------------------
# Start autosave

# Monitor every ten seconds
create_monitor_set("auto_settings.req", 10, "P=$(PREFIX)")
