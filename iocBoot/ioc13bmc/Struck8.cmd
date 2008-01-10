# STR7201Setup(int maxCards, int baseAddress, int intVector, int intLevel);
STR7201Setup(1,0x90000000,220,6)
# STR7201Config(int card, int maxSignals, int maxChans, int ch1RefEnable, int softAdvance);
#STR7201Config(0, 8, 2048, 1, 0)
# Change to use the 1MHz clock in channel 1
STR7201Config(0, 8, 2048, 0, 0)
dbLoadRecords("$(MCA)/mcaApp/Db/Struck8.db","P=13BMC:str:")
dbLoadTemplate("Struck8.template")
