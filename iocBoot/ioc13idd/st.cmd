# vxWorks startup file for 13BMD IOC
< cdCommands
< ../nfsCommandsGSE
###MATT May-28-2002 
loginUserAdd "epics","SzeSebbzRR"

cd topbin
ld < iocCore
ld < seq
ld < CARSLib

# This IOC loads the MPF server code locally
cd startup
< st_mpfserver.cmd

cd topbin
# This IOC talks to a local GPIB server
ld < GpibHideosLocal.o

# Currently, the only thing we do in initHooks is call reboot_restore(), which
# restores positions and settings saved ~continuously while EPICS is alive.
# See calls to "create_monitor_set()" at the end of this file.  To disable
# autorestore, comment out the following line.
ld < initHooks.o

cd startup

# Initialize MPF stuff
routerInit

# Initialize local MPF connection
localMessageRouterStart(0)

# Set debugging flags
#reboot_restoreDebug = 5
#save_restore_debug =10
mcaRecordDebug=0

# override address, interrupt vector, etc. information in module_types.h
module_types()

# need more entries in Wait-record channel-access queue (?)
recDynLinkQsize = 1024

# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in this build.
dbLoadDatabase("../../dbd/CARSApp.dbd")

# Load database
dbLoadRecords  "stdApp/Db/Jscaler.db","P=13IDD:,S=scaler1,C=0", std

dbLoadRecords  "ipApp/Db/SR570.db", "P=13IDD:,A=A1,C=0,IPSLOT=a,CHAN=0", ip
dbLoadRecords  "ipApp/Db/SR570.db", "P=13IDD:,A=A2,C=0,IPSLOT=a,CHAN=1", ip
dbLoadRecords  "CARSApp/Db/Keithley2kDMM_mf.db", "P=13IDD:,Dmm=DMM1,C=0,IPSLOT=a,CHAN=2", top
dbLoadRecords  "CARSApp/Db/generic_serial.db","P=13IDD:,R=ser1,C=0,IPSLOT=a,CHAN=3,BAUD=4800,PRTY=None,DBIT=8,SBIT=1", top
dbLoadRecords  "CARSApp/Db/Keithley2kDMM_mf.db", "P=13IDD:,Dmm=DMM3,C=0,IPSLOT=a,CHAN=4", top
dbLoadRecords  "CARSApp/Db/Keithley2kDMM_mf.db", "P=13IDD:,Dmm=DMM4,C=0,IPSLOT=a,CHAN=5", top
dbLoadRecords  "ipApp/Db/SR570.db", "P=13IDD:,A=A3,C=0,IPSLOT=a,CHAN=6", ip
dbLoadRecords  "CARSApp/Db/LAE500.db","P=13IDD:,R=LAE500,C=0,IPSLOT=a,CHAN=7,BAUD=9600,PRTY=None,DBIT=8,SBIT=1", top
dbLoadRecords  "CARSApp/Db/generic_serial.db","P=13IDD:,R=ser2,C=0,IPSLOT=a,CHAN=7,BAUD=9600,PRTY=None,DBIT=8,SBIT=1", top

# IP-Unidig binary I/O
dbLoadTemplate "IpUnidig.template"

# SMART detector database
str=malloc(256)
strcpy(str,"P=13IDD:,R=smart1,C=0,IPSLOT=a,CHAN=7,BAUD=9600,")
# Use Bo0 for Bruker shutter, Bo11 for XIA
#strcat(str,"FSHUT=UnidigBo0,TRIG=UnidigBo1,SSHUT=UnidigBo2")
strcat(str,"FSHUT=UnidigBo11,TRIG=UnidigBo1,SSHUT=UnidigBo2")
dbLoadRecords("CARSApp/Db/smartControl.db", str, top)

dbLoadTemplate  "motors.template"

#dbLoadRecords  "CARSApp/Db/generic_gpib.db", "P=13IDD:,R=gpib1,SIZE=4098", top

# Multichannel analyzer stuff
# AIMConfig(mpfServer, ethernet_address, port, maxChans, 
#           maxSignals, maxSequences, ethernetDevice, queueSize)
AIMConfig("NI3ED/1", 0x3ED, 1, 4000, 1, 1,"dc0", 40)
AIMConfig("NI3ED/2", 0x3ED, 2, 4000, 1, 1,"dc0", 40)
dbLoadRecords("mcaApp/Db/mca.db", "P=13IDD:,M=aim_adc1,DTYPE=MPF MCA,INP=#C0 S0 @NI3ED/1,NCHAN=4000", mca)
dbLoadRecords("mcaApp/Db/mca.db", "P=13IDD:,M=aim_mcs1,DTYPE=MPF MCA,INP=#C0 S0 @NI3ED/2,NCHAN=4000", mca)
picbServer = icbConfig("icb/1", 10, "NI3ED:5", 100)
dbLoadRecords "mcaApp/Db/icb_adc.db", "P=13IDD:,ADC=adc1,CARD=0,SERVER=icb/1,ADDR=0", mca
icbAddModule(picbServer, 1, "NI3ED:3")
dbLoadRecords "mcaApp/Db/icb_amp.db", "P=13IDD:,AMP=amp1,CARD=0,SERVER=icb/1,ADDR=1", mca
icbAddModule(picbServer, 2, "NI3ED:2")
dbLoadRecords "mcaApp/Db/icb_hvps.db", "P=13IDD:,HVPS=hvps1,CARD=0,SERVER=icb/1,ADDR=2,LIMIT=1000", mca

dbLoadRecords("mcaApp/Db/mca.db", "P=13IDD:,M=mip330_1,DTYPE=MPF MCA,NCHAN=2048,INP=#C0 S0 @b-Ip330Sweep", mca)
dbLoadRecords("mcaApp/Db/mca.db", "P=13IDD:,M=mip330_2,DTYPE=MPF MCA,NCHAN=2048,INP=#C0 S1 @b-Ip330Sweep", mca)
dbLoadRecords("mcaApp/Db/mca.db", "P=13IDD:,M=mip330_3,DTYPE=MPF MCA,NCHAN=2048,INP=#C0 S2 @b-Ip330Sweep", mca)
dbLoadRecords("mcaApp/Db/mca.db", "P=13IDD:,M=mip330_4,DTYPE=MPF MCA,NCHAN=2048,INP=#C0 S3 @b-Ip330Sweep", mca)

### Allstop, alldone
# This database must agree with the motors you've actually loaded.
# Several versions (e.g., all_com_32.db) are in share/stdApp/Db
dbLoadRecords("stdApp/Db/all_com_56.db","P=13IDD:", std)

# Digital to analog converter
dbLoadTemplate("DigitalToAnalog.template")

# Acromag Ip330 ADC
dbLoadTemplate "Ip330_ADC.template"

# Laser PID control
dbLoadTemplate("laser_pid.template")

# Simple laser heating database
dbLoadRecords "CARSApp/Db/laser_heating.db", "P=13IDD:", top

# Laser power controller
dbLoadRecords "CARSApp/Db/lpc.db", "P=13IDD:,L=LPC1_,DAC=DAC1_2,C=0,IPSLOT=a,CHAN=3,BAUD=4800,PRTY=None,DBIT=8,SBIT=1", top


# LVP furnace controls
dbLoadTemplate "LVP_furnace_control.template"

# LVP Omega controller
dbLoadRecords "CARSApp/Db/LVP_Omega.db","P=13IDD:,R=Omega1_,C=0,IPSLOT=b,CHAN=0,BAUD=9600,PRTY=None,DBIT=7,SBIT=2", top

#MN May-29-2002
# LVP Theta (temperature ramping) controller
dbLoadRecords("CARSApp/Db/RampScan.db","P=13IDD:,R=Theta1_,DRV=LVP:PID1.VAL,RBV=LVP_furnace_calcs.E", top)

# Experiment description
dbLoadRecords("CARSApp/Db/experiment_info.db","P=13IDD:", top)

### Scan-support software
# crate-resident scan.  This executes 1D, 2D, 3D, and 4D scans, and caches
# 1D data, but it doesn't store anything to disk.  (You need the data catcher
# or the equivalent for that.)  This database is configured to use the
# "alldone" database (above) to figure out when motors have stopped moving
# and it's time to trigger detectors.
dbLoadRecords("stdApp/Db/scan.db","P=13IDD:,MAXPTS1=2000,MAXPTS2=200,MAXPTS3=20,MAXPTS4=10,MAXPTSH=10", std)

# A set of scan parameters for each positioner.  This is a convenience
# for the user.  It can contain an entry for each scannable thing in the
# crate.
dbLoadTemplate "scanParms.template"

# Miscellaneous PV's, such as burtResult
dbLoadRecords("stdApp/Db/misc.db","P=13IDD:", std)
dbLoadRecords("stdApp/Db/userTransforms10.db", "P=13IDD:", std)

# vxWorks statistics
dbLoadRecords("stdApp/Db/VXstats.db","P=13IDD:", std)

################################################################################
# Setup device/driver support addresses, interrupt vectors, etc.

# OMS VME58 driver setup parameters: 
#     (1)cards, (2)axis per card, (3)base address(short, 4k boundary), 
#     (4)interrupt vector (0=disable or  64 - 255), (5)interrupt level (1 - 6),
#     (6)motor task polling rate (min=1Hz,max=60Hz)
oms58Setup(8, 8, 0x4000, 190, 5, 10)

# Joerger VSC setup parameters: 
#     (1)cards, (2)base address(ext, 256-byte boundary), 
#     (3)interrupt vector (0=disable or  64 - 255)
VSCSetup(1, 0xB0000000, 200)
 
#HiDEOSGpibLinkConfig(10,1,"GPIB0")

# dbrestore setup
sr_restore_incomplete_sets_ok = 1

iocInit

### Start up the autosave task and tell it what to do.
# The task is actually named "save_restore".
# (See also, 'initHooks' above, which is the means by which the values that
# will be saved by the task we're starting here are going to be restored.
#
# save positions every five seconds
create_monitor_set("auto_positions.req",5.0)
# save other things every thirty seconds
create_monitor_set("auto_settings.req",30.0)

seq &Keithley2kDMM, "P=13IDD:, Dmm=DMM1, stack=10000"
seq &Keithley2kDMM, "P=13IDD:, Dmm=DMM3, stack=10000"
seq &Keithley2kDMM, "P=13IDD:, Dmm=DMM4, stack=10000"

seq &IDD_LVP_Detector, "P=13IDD:,PMR=pm9,PMT=pm10,PMC=pm11,X=m33,Y=m34,Z=m35,TX=m38,TZ=m39"

# Need to wait 10 seconds before starting smartControl - THIS NEEDS TO BE FIXED
taskDelay(600)
seq &smartControl, "P=13IDD:,R=smart1,TTH=m21,OMEGA=m21,PHI=m21,KAPPA=m21,SCALER=scaler1,I0=6,stack=10000"

# There is a bug in dbLoadRecords, it does not correctly remove \ from \"
dbpf "13IDD:LPC1_power_decode.CALC","AA[-3,-2]==\"mW\"?DBL(AA)/1e3:DBL(AA)"
# The scale factor from LPC power reading to actual laser watts
dbpf "13IDD:LPC1_power_scale.B","1.0"
