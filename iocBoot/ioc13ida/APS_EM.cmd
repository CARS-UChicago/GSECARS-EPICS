epicsEnvSet("PREFIX", "13IDA:")
epicsEnvSet("PORT", "QE1")
epicsEnvSet("MODEL","APS_EM")
epicsEnvSet("QSIZE", "20")
epicsEnvSet("RING_SIZE", "8000")
epicsEnvSet("TSPOINTS", "1000")
epicsEnvSet("IP", "164.54.160.11:10001")

# drvAPS_EMConfigure(const char *portName, unsigned short *baseAddr, int fiberChannel,
#                    const char *unidigName, int unidigChan, char *unidigDrvInfo)
#  portName     = name of APS_EM asyn port driver created 
#  baseAddress = base address of VME card
#  channel     = 0-3, fiber channel number
#  unidigName  = name of ipInidig server if it is used for interrupts.
#                Set to 0 if there is no IP-Unidig being used, in which
#                case the quadEM will be read at 60Hz.
#  unidigChan  = IP-Unidig channel connected to quadEM pulse output
#  unidigDrvInfo = drvInfo string for digital input parameter
# The Quad-EM input is on IP-Unidig input 0
drvAPS_EMConfigure("$(PORT)", 0xf000, 0, "Unidig1", 0, "DIGITAL_INPUT")
dbLoadRecords("$(QUADEM)/quadEMApp/Db/quadEM.template", "P=$(PREFIX), R=$(PORT):, PORT=$(PORT)")
dbLoadRecords("$(QUADEM)/quadEMApp/Db/$(MODEL).template", "P=$(PREFIX), R=$(PORT):, PORT=$(PORT)")

# initFastSweep(portName, inputName, maxSignals, maxPoints)
#  portName = asyn port name for this new port (string)
#  inputName = name of asynPort providing data
#  maxSignals  = maximum number of signals (spectra)
#  maxPoints  = maximum number of channels per spectrum
#  dataString  = drvInfo string for current and position data
#  intervalString  = drvInfo string for time interval per point
initFastSweep("$(PORT)TS", "$(PORT)", 11, 2048, "QE_INT_ARRAY_DATA", "QE_SAMPLE_TIME")
dbLoadRecords("$(QUADEM)/quadEMApp/Db/quadEM_TimeSeries.template", "P=$(PREFIX),R=$(PORT)_TS:,NUM_TS=2048,NUM_FREQ=1024,PORT=$(PORT)TS")

# Fast feedback using EPID record
#dbLoadTemplate("quadEM_pid.substitutions")

< commonPlugins.cmd
