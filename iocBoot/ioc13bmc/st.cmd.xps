< envPaths
# Start errlog Task before any possible error messsage to prevent
# erroneous "Interrupted system call" message on Linux OS.
errlogInit(0)
#
dbLoadDatabase("../../dbd/CARSLinux.dbd")
CARSLinux_registerRecordDeviceDriver(pdbbase)

################################################################################
# XPS trajectoryScan records

# Database for trajectory scanning with the XPS

dbLoadRecords("$(MOTOR)/motorApp/Db/trajectoryScan.db", "P=13BMC:,R=traj1,NAXES=6,NELM=2000,NPULSE=2000,PORT=5001,DONPV=13BMC:str:EraseStart,DONV=1,DOFFPV=13BMC:str:StopAll,DOFFV=1")

# asyn record for debugging
drvAsynIPPortConfigure("xps", "164.54.160.124:5001", 0, 0, 0)
asynSetTraceIOMask("xps",0,2)
asynSetTraceMask("xps",0,9)
dbLoadRecords("$(ASYN)/db/asynRecord.db", "P=13BMC:, R=trajAsyn1, PORT=xps, ADDR=0, OMAX=300, IMAX=32000")

iocInit

### Start up the autosave task and tell it what to do.
# The task is actually named "save_restore".
# (See also, 'initHooks' above, which is the means by which the values that
# will be saved by the task we're starting here are going to be restored.
#
< ../requestFileCommands
# save positions every five seconds
#create_monitor_set("auto_positions_xps.req",5,"P=13BMC:")
# save other things every thirty seconds
#create_monitor_set("auto_settings_xps.req",30,"P=13BMC:")

dbpf("13BMC:traj1DebugLevel","1")

# Trajectory scanning with XPS
seq(XPS_trajectoryScan, "P=13BMC:,R=traj1,M1=m33,M2=m34,M3=m35,M4=m36,M5=m37,M6=m38,IPADDR=164.54.160.124,PORT=5001,GROUP=GROUP1,P1=PHI,P2=KAPPA,P3=OMEGA,P4=PSI,P5=2THETA,P6=NU")

dbpf("13BMC:trajAsyn1.IFMT","Binary")
dbpf("13BMC:trajAsyn1.OFMT","Binary")

epicsThreadSleep(2)
asynSetTraceIOMask(164.54.160.124:5001:0,0,2)
asynSetTraceIOMask(164.54.160.124:5001:1,0,2)
asynSetTraceIOMask(164.54.160.124:5001:2,0,2)
#asynSetTraceMask(164.54.160.124:5001:0,0,9)
#asynSetTraceMask(164.54.160.124:5001:1,0,9)
#asynSetTraceMask(164.54.160.124:5001:2,0,9)
