# AIMConfig(card, ethernet_address, port, maxChans, maxSignals, maxSequences)
AIMConfig(2, 0x8d7, 1, 4096, 4, 1)
AIMConfig(3, 0x8d7, 2, 4096, 4, 1)
AIMConfig(4, 0x3ec, 1, 4096, 4, 1)
AIMConfig(5, 0x3ec, 2, 4096, 4, 1)
dbLoadRecords("mcaApp/Db/16element.db","P=13IDC:med:", mca)
dbLoadTemplate("16element.template")

### Struck/SIS as simple scaler for ICR
STR7201Setup(1,0xA0000000,220,6)
STR7201Config(0, 16, 100)
dbLoadRecords("mcaApp/Db/STR7201scaler.db","P=13IDC:med:, S=scaler1, C=0", mca)
