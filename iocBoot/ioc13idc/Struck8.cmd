# STR7201Setup(int numCards, int baseAddress, int interruptVector, int interruptLevel)
STR7201Setup(1,0x90000000,220,6)
# STR7201Config(int card, int maxSignals, int maxChans,
#               int 1=enable internal 25MHZ clock,
#               int 0=disable initial software channel advance in MCS external advance mode)
# NOTE: We are not using the 25MHz internal clock because it was overflowing on really long
# count times.  Instead we use the 1MHz clock from the Nova V/F converter.
STR7201Config(0, 8, 2048, 0, 0)
dbLoadRecords("$(MCA)/mcaApp/Db/Struck8.db","P=13IDC:str:")
dbLoadTemplate("Struck8.template")


### Scalers: Struck/SIS as simple scaler 
dbLoadRecords("$(MCA)/mcaApp/Db/STR7201scaler.db","P=13IDC:,S=scaler2,C=0")
