# AIMConfig(mpfServer,  ethernet_address, port, maxChans, 
#           maxSignals, maxSequences, ethernetDevice, queueSize)
AIMConfig("AIM1/1", 0x8d7, 1, 4096, 4, 1, "ei0", 100)
AIMConfig("AIM1/2", 0x8d7, 2, 4096, 4, 1, "ei0", 100)
AIMConfig("AIM2/1", 0x3ec, 1, 4096, 4, 1, "ei0", 100)
AIMConfig("AIM2/2", 0x3ec, 2, 4096, 4, 1, "ei0", 100)
dbLoadRecords("mcaApp/Db/16element.db","P=13GE1:med:", mca)

# Configure MPF server for amplifiers
picbServer = icbConfig("icb_amp/1", 16, "NI8D7:1", 1000)
icbAddModule(picbServer,  1, "NI8D7:2")
icbAddModule(picbServer,  2, "NI8D7:3")
icbAddModule(picbServer,  3, "NI8D7:4")
icbAddModule(picbServer,  4, "NI8D7:5")
icbAddModule(picbServer,  5, "NI8D7:6")
icbAddModule(picbServer,  6, "NI8D7:8")
icbAddModule(picbServer,  7, "NI8D7:9")
icbAddModule(picbServer,  8, "NI3EC:1")
icbAddModule(picbServer,  9, "NI3EC:2")
icbAddModule(picbServer, 10, "NI3EC:3")
icbAddModule(picbServer, 11, "NI3EC:4")
icbAddModule(picbServer, 12, "NI3EC:5")
icbAddModule(picbServer, 13, "NI3EC:6")
icbAddModule(picbServer, 14, "NI3EC:8")
icbAddModule(picbServer, 15, "NI3EC:9")

# Configure MPF server for ADCs
picbServer = icbConfig("icb_adc/1", 4, "NI8D7:B", 100)
icbAddModule(picbServer,  1, "NI8D7:0")
icbAddModule(picbServer,  2, "NI3EC:B")
icbAddModule(picbServer,  3, "NI3EC:7")

# Configure MPF server for HVPS
picbServer = icbConfig("icb_hvps/1", 1, "NI3EC:A", 100)

# Load all of the records for the MCAs and ICB devices
dbLoadTemplate("16element.template")

### Struck/SIS as simple scaler for ICR
STR7201Setup(1,0xA0000000,220,6)
STR7201Config(0, 16, 100)
dbLoadRecords("mcaApp/Db/STR7201scaler.db","P=13GE1:med:, S=scaler1, C=0", mca)
