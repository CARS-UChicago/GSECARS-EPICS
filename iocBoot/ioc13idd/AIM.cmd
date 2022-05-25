# Multichannel analyzer stuff
# AIMConfig(portName, ethernet_address, portNumber(1 or 2), maxChans,
#           maxSignals, maxSequences, ethernetDevice)
AIMConfig("NI3ED/1", 0x59E, 1, 4000, 1, 1,"dc0")
AIMConfig("NI3ED/2", 0x59E, 2, 4000, 1, 1,"dc0")
dbLoadRecords("$(MCA)/db/mca.db", "P=13IDD:,M=aim_adc1,DTYP=asynMCA,INP=@asyn(NI3ED/1 0),NCHAN=4096")
dbLoadRecords("$(MCA)/db/mca.db", "P=13IDD:,M=aim_mcs1,DTYP=asynMCA,INP=@asyn(NI3ED/2 0),NCHAN=4096")

#icbConfig(portName, module, ethernetAddress, icbAddress, moduleType)
#   portName to give to this asyn port
#   ethernetAddress - Ethernet address of module, low order 16 bits
#   icbAddress - rotary switch setting inside ICB module
#   moduleType
#      0 = ADC
#      1 = Amplifier
#      2 = HVPS
#      3 = TCA
#      4 = DSP
icbConfig("icbAdc1", 0x59E, 5, 0)
dbLoadRecords("$(MCA)/db/icb_adc.db", "P=13IDD:,ADC=adc1,PORT=icbAdc1")
icbConfig("icbAmp1", 0x59E, 3, 1)
dbLoadRecords("$(MCA)/db/icb_amp.db", "P=13IDD:,AMP=amp1,PORT=icbAmp1")
icbConfig("icbHvps1", 0x59E, 2, 2)
dbLoadRecords("$(MCA)/db/icb_hvps.db", "P=13IDD:,HVPS=hvps1,PORT=icbHvps1,LIMIT=1000")

