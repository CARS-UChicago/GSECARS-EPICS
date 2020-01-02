# AIMConfig(mpfServer,  ethernet_address, port, maxChans, 
#           maxSignals, maxSequences, ethernetDevice, queueSize)
AIMConfig("AIM1/1", 0x8d7, 1, 4096, 4, 1, "ei0", 100)
AIMConfig("AIM1/2", 0x8d7, 2, 4096, 4, 1, "ei0", 100)
AIMConfig("AIM2/1", 0x3ec, 1, 4096, 4, 1, "ei0", 100)
AIMConfig("AIM2/2", 0x3ec, 2, 4096, 4, 1, "ei0", 100)
dbLoadRecords("$(MCA)/db/16element.db","P=13GE1:med:")

# Configure MPF server for amplifiers
icbSetup("icb_amp/1", 16, 200)
icbConfig("icb_amp/1",  0, 0x8D7, 1)
icbConfig("icb_amp/1",  1, 0x8D7, 2)
icbConfig("icb_amp/1",  2, 0x8D7, 3)
icbConfig("icb_amp/1",  3, 0x8D7, 4)
icbConfig("icb_amp/1",  4, 0x8D7, 5)
icbConfig("icb_amp/1",  5, 0x8D7, 6)
icbConfig("icb_amp/1",  6, 0x8D7, 8)
icbConfig("icb_amp/1",  7, 0x8D7, 9)
icbConfig("icb_amp/1",  8, 0x3EC, 1)
icbConfig("icb_amp/1",  9, 0x3EC, 2)
icbConfig("icb_amp/1", 10, 0x3EC, 3)
icbConfig("icb_amp/1", 11, 0x3EC, 4)
icbConfig("icb_amp/1", 12, 0x3EC, 5)
icbConfig("icb_amp/1", 13, 0x3EC, 6)
icbConfig("icb_amp/1", 14, 0x3EC, 8)
icbConfig("icb_amp/1", 15, 0x3EC, 9)

# Configure MPF server for ADCs
icbSetup("icb_adc/1", 4, 100)
icbConfig("icb_adc/1",  0, 0x8D7, 0xB)
icbConfig("icb_adc/1",  1, 0x8D7, 0)
icbConfig("icb_adc/1",  2, 0x3EC, 0xB)
icbConfig("icb_adc/1",  3, 0x3EC, 0x7)

# Configure MPF server for HVPS
icbSetup("icb_hvps/1", 1, 100)
icbConfig("icb_hvps/1", 0, 0x3EC, 0xA)

# Load all of the records for the MCAs and ICB devices
dbLoadTemplate("16element.template")

### Struck/SIS as simple scaler for ICR
STR7201Setup(1,0xA0000000,220,6)
STR7201Config(0, 16, 100, 0)
dbLoadRecords("$(MCA)/db/STR7201scaler.db","P=13GE1:med:, S=scaler1, C=0")
