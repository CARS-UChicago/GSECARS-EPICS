< envPaths

dbLoadDatabase "$(SYMETRIE)/iocs/hexapod-demo/dbd/hexapodDemo.dbd"
hexapodDemo_registerRecordDeviceDriver(pdbbase)

# Create SSH Port (PortName, IPAddress, Username, Password, Priority, DisableAutoConnect, noProcessEos)
drvAsynPowerPMACPortConfigure("PPMAC_SSH", "10.54.160.42", "root", "deltatau", "0", "0", "0")

# Configure Symetrie Hexapod Controller Driver (ControllerPort, LowLevelDriverPort, Address, movingPollPeriod, idlePollPeriod)
symetrieHexapod("HEXAPOD", "PPMAC_SSH", 0, .05, 1)

dbLoadTemplate "$(SYMETRIE)/db/SymetriePmac.substitutions", "P=13IDC:,R=BORA1:,PORT=HEXAPOD"
dbLoadTemplate motors.template
iocInit
