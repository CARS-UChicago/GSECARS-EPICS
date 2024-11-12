
Automation1CreateController("Automation1", "10.54.160.27", 4, 100, 1000)

# traceError and traceIODriver
#!asynSetTraceMask("Automation1", 0, 0x9)
# traceIOAscii
#!asynSetTraceIOMask("Automation1", 0, 0x1)

Automation1CreateProfile("Automation1", 2000)

dbLoadTemplate "Automation1_motors.template"

dbLoadRecords("$(ASYN)/db/asynRecord.db", "P=Auto1:, R=asyn1, PORT=Automation1, ADDR=0, OMAX=256, IMAX=256")

