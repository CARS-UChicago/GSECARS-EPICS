# vxWorks startup file for 13BMD IOC
< cdCommands

< ../nfsCommandsGSE
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

# Initialize MPF 
routerInit

# Initialize local MPF connection
localMessageRouterStart(0)

# Set debugging flags
#reboot_restoreDebug = 5
#save_restore_debug =10
devMcaMpfDebug=0
mcaAIMServerDebug=0
aimDebug=0

# override address, interrupt vector, etc. information in module_types.h
module_types()

# need more entries in Wait-record channel-access queue (?)
recDynLinkQsize = 1024

# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in this build.
dbLoadDatabase("../../dbd/CARSApp.dbd")

# Load database
dbLoadRecords  "stdApp/Db/Jscaler.db","P=13BMD:,S=scaler1,C=0", std
dbLoadRecords  "ipApp/Db/SR570.db", "P=13BMD:,A=A1,C=0,IPSLOT=a,CHAN=0", ip
dbLoadRecords  "ipApp/Db/SR570.db", "P=13BMD:,A=A2,C=0,IPSLOT=a,CHAN=2", ip
dbLoadRecords  "ipApp/Db/SR570.db", "P=13BMD:,A=A3,C=0,IPSLOT=a,CHAN=3", ip
# LVP Omega controller
#dbLoadRecords "CARSApp/Db/BM_LVP_Omega.db","P=13BMD:,R=Omega1_,C=0,IPSLOT=a,CHAN=4,BAUD=9600,PRTY=None,DBIT=7,SBIT=2", top
dbLoadRecords  "CARSApp/Db/generic_serial.db","P=13BMD:,R=ser2,C=0,IPSLOT=a,CHAN=5,BAUD=9600,PRTY=None,DBIT=8,SBIT=1", top
#dbLoadRecords  "CARSApp/Db/generic_gpib.db", "P=13BMD:,R=gpib1,SIZE=2048", top
dbLoadRecords  "ipApp/Db/Keithley2kDMM_mf.db", "P=13BMD:,Dmm=DMM2,C=0,IPSLOT=a,CHAN=6", ip
dbLoadRecords  "CARSApp/Db/lvp_dmm.db", "P=13BMD:,Dmm=DMM2,DLY=0.1", top
dbLoadRecords  "ipApp/Db/Keithley2kDMM_mf.db", "P=13BMD:,Dmm=DMM1,C=0,IPSLOT=a,CHAN=7", ip
dbLoadRecords  "CARSApp/Db/lvp_dmm.db", "P=13BMD:,Dmm=DMM1,DLY=0.1", top
dbLoadTemplate "DAC.template"
dbLoadTemplate "LVP_furnace_control.template"
dbLoadTemplate "LVP_pressure_control.template"
dbLoadTemplate "motors.template"

# Acromag Ip330 ADC
dbLoadTemplate "Ip330_ADC.template"

# IP-Unidig binary I/O
dbLoadTemplate "IpUnidig.template"

# SMART detector database
str=malloc(256)
strcpy(str,"P=13BMD:,R=smart1,C=0,IPSLOT=a,CHAN=5,BAUD=9600,")
strcat(str,"FSHUT=UnidigBo0,TRIG=UnidigBo1,SSHUT=UnidigBo2")
dbLoadRecords("CARSApp/Db/smartControl.db",str,top)


# CCD synchronization record
dbLoadRecords  "CARSApp/Db/CCD.db", "P=13BMD:,C=CCD1", top

# Multichannel analyzer stuff
# AIMConfig(mpfServer, card, ethernet_address, port, maxChans, 
#           maxSignals, maxSequences, ethernetDevice, queueSize)
AIMConfig("NI9CE/1", 0x9CE, 1, 2048, 1, 1,"dc0", 40)
AIMConfig("NI9CE/2", 0x9CE, 2, 2048, 4, 1,"dc0", 40)
dbLoadRecords("mcaApp/Db/mca.db", "P=13BMD:,M=aim_adc1,DTYPE=MPF MCA,INP=#C0 S0 @NI9CE/1,NCHAN=2048", mca)
dbLoadRecords("mcaApp/Db/mca.db", "P=13BMD:,M=aim_mcs1,DTYPE=MPF MCA,INP=#C0 S0 @NI9CE/2,NCHAN=2048", mca)
picbServer = icbConfig("icb/1", 10, "NI9CE:5", 100)
dbLoadRecords "mcaApp/Db/icb_adc.db", "P=13BMD:,ADC=adc1,CARD=0,SERVER=icb/1,ADDR=0", mca
icbAddModule(picbServer, 1, "NI9CE:3")
dbLoadRecords "mcaApp/Db/icb_amp.db", "P=13BMD:,AMP=amp1,CARD=0,SERVER=icb/1,ADDR=1", mca

# Set up Struck multichannel scaler
#STR7201Setup(1,0xA0000000,220,6)
#STR7201Config(0, 4, 2048)
#dbLoadRecords("mcaApp/Db/mca.db", "P=13BMD:,M=mca_str1,DTYPE=Struck STR7201 MCS,NCHAN=1024,INP=#C0 S0", mca)

# IP-330 ADC with MCA record as transient recorder
dbLoadRecords("mcaApp/Db/mca.db", "P=13BMD:,M=mip330_1,DTYPE=MPF MCA,NCHAN=2048,INP=#C0 S0 @b-Ip330Sweep", mca)
dbLoadRecords("mcaApp/Db/mca.db", "P=13BMD:,M=mip330_2,DTYPE=MPF MCA,NCHAN=2048,INP=#C0 S1 @b-Ip330Sweep", mca)
dbLoadRecords("mcaApp/Db/mca.db", "P=13BMD:,M=mip330_3,DTYPE=MPF MCA,NCHAN=2048,INP=#C0 S2 @b-Ip330Sweep", mca)
dbLoadRecords("mcaApp/Db/mca.db", "P=13BMD:,M=mip330_4,DTYPE=MPF MCA,NCHAN=2048,INP=#C0 S3 @b-Ip330Sweep", mca)

### Allstop, alldone
# This database must agree with the motors you've actually loaded.
# Several versions (e.g., all_com_40.db) are in std/stdApp/Db
dbLoadRecords("stdApp/Db/all_com_56.db","P=13BMD:", std)

### Scan-support software
# crate-resident scan.  This executes 1D, 2D, 3D, and 4D scans, and caches
# 1D data, but it doesn't store anything to disk.  (You need the data catcher
# or the equivalent for that.)  This database is configured to use the
# "alldone" database (above) to figure out when motors have stopped moving
# and it's time to trigger detectors.
dbLoadRecords("stdApp/Db/scan.db","P=13BMD:,MAXPTS1=1000,MAXPTS2=200,MAXPTS3=20,MAXPTS4=10,MAXPTSH=10", std)

# A set of scan parameters for each positioner.  This is a convenience
# for the user.  It can contain an entry for each scannable thing in the
# crate.
dbLoadTemplate "scanParms.template"

# Miscellaneous PV's, such as burtResult
dbLoadRecords("stdApp/Db/misc.db","P=13BMD:", std)
dbLoadRecords("stdApp/Db/userTransform.db", "P=13BMD:, N=1", std)
dbLoadRecords("stdApp/Db/userTransform.db", "P=13BMD:, N=2", std)

# Experiment description
dbLoadRecords("CARSApp/Db/experiment_info.db","P=13BMD:", top)

# vxWorks statistics
dbLoadRecords("stdApp/Db/VXstats.db","P=13BMD:", std)

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
 
# dbrestore setup
sr_restore_incomplete_sets_ok = 1
#reboot_restoreDebug=5

# Link to GPIB server.  Do this just before iocInit, since it waits for MPF
# server to connect
#HiDEOSGpibLinkConfig(10,1,"GPIB0")

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

seq &Keithley2kDMM, "P=13BMD:, Dmm=DMM1, stack=10000"
#ybW 1/19/99
seq &Keithley2kDMM, "P=13BMD:, Dmm=DMM2, stack=15000"
seq &BMD_LVP_Detector, "P=13BMD:,PMT=pm4,PMR=pm3,X=m9,Y=m16,Z=m10,TV=m12,TH=m13"

# Force the DAC to be 0 volts.  The hardware does this automatically on VME 
# reset but the the software display is not correct
dbpf "13BMD:DAC1_1", "0."

# Need to wait 15 seconds before starting this task or CPU use is 100% - TRACK DOWN WHY !!!
taskDelay(900)
seq &smartControl, "P=13BMD:,R=smart1,TTH=m38,OMEGA=m38,PHI=m38,KAPPA=m38,SCALER=scaler1,I0=2,stack=10000"
