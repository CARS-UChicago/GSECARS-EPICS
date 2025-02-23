# scan communication and meta data
# dbLoadRecords("$(CARS)/db/scanner.db","P=13XRM:, Q=edb")


# XRM Analyzer control
dbLoadRecords("$(CARS)/db/XRMAnalyzer.db","P=13XRM:,ANA=ANA")

# fast mapping
dbLoadRecords("$(CARS)/db/XRM_fastmap.db","P=13XRM:,Q=map")

# fast XAFS 
dbLoadRecords("qxafs.db","P=13XRM:,Q=QXAFS")

# simple Image (to push Point Grey image)
dbLoadRecords("simple_image.db","P=13XRM:,R=image1")

# status of Eiger copying
# dbLoadRecords("eigercopy.db","P=13XRM:,Q=EIGER")

# scan server
dbLoadRecords("epicsscan.db","P=13XRM:,Q=SCANDB")

# temporary data arrays for escan
dbLoadRecords("escandata.db","P=13XRM:,Q=ScanData")

dbLoadRecords("esensor.db","P=13IDE:,Q=Esensor")
dbLoadRecords("esensor.db","P=13BMD:,Q=Esensor")
dbLoadRecords("esensor.db","P=13IDC:,Q=Esensor")
dbLoadRecords("esensor.db","P=13IDD:,Q=Esensor")


dbLoadRecords("apsbss.db","P=13IDE:bss:")
dbLoadRecords("apsbss.db","P=13IDCD:bss:")
dbLoadRecords("apsbss.db","P=13BMD:bss:")
dbLoadRecords("apsbss.db","P=13BMC:bss:")


# Epics PyInstrument
dbLoadRecords("$(CARS)/db/PyInstrument.db","P=13XRM:,Q=Inst")
dbLoadRecords("$(CARS)/db/PyInstrument.db","P=13IDE:,Q=Inst")
dbLoadRecords("$(CARS)/db/PyInstrument.db","P=13IDD:,Q=Inst")
dbLoadRecords("$(CARS)/db/PyInstrument.db","P=13IDC:,Q=Inst")
dbLoadRecords("$(CARS)/db/PyInstrument.db","P=13IDA:,Q=Inst")
dbLoadRecords("$(CARS)/db/PyInstrument.db","P=13BMA:,Q=Inst")
dbLoadRecords("$(CARS)/db/PyInstrument.db","P=13BMC:,Q=Inst")
dbLoadRecords("$(CARS)/db/PyInstrument.db","P=13BMD:,Q=Inst")

# ion chamber calculations
dbLoadRecords("$(CARS)/db/IonChamber.db","P=13XRM:,Q=IC0")
dbLoadRecords("$(CARS)/db/IonChamber.db","P=13XRM:,Q=IC")

dbLoadRecords("pydebug.db", "P=PyTest:")

dbLoadRecords("py_exapp.db", "P=Py:,Q=EXT")
