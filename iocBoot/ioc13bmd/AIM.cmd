# Multichannel analyzer stuff
# AIMConfig(portName, card, ethernet_address, port, maxChans,
#           maxSignals, maxSequences, ethernetDevice)
AIMConfig("NI9CE/1", 0x9CE, 1, 2048, 1, 1,"dc0")
AIMConfig("NI9CE/2", 0x9CE, 2, 2048, 4, 1,"dc0")
dbLoadRecords("$(MCA)/db/mca.db", "P=13BMD:,M=aim_adc1,DTYP=asynMCA,INP=@asyn(NI9CE/1 0),NCHAN=4096")
dbLoadRecords("$(MCA)/db/mca.db", "P=13BMD:,M=aim_mcs1,DTYP=asynMCA,INP=@asyn(NI9CE/2 0),NCHAN=4096")
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
icbConfig("icbAdc1", 0x9ce, 5, 0)
dbLoadRecords("$(MCA)/db/icb_adc.db", "P=13BMD:,ADC=adc1,PORT=icbAdc1")
icbConfig("icbAmp1", 0x9ce, 3, 1)
dbLoadRecords("$(MCA)/db/icb_amp.db", "P=13BMD:,AMP=amp1,PORT=icbAmp1")
icbConfig("icbHvps1", 0x9ce, 2, 2)
dbLoadRecords("$(MCA)/db/icb_hvps.db", "P=13BMD:,HVPS=hvps1,PORT=icbHvps1,LIMIT=1000")
