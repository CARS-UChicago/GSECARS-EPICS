STR7201Setup(1,0x90000000,220,6)
STR7201Config(0, 8, 2048)
dbLoadRecords("$(MCA)/mcaApp/Db/Struck8.db","P=13IDC:str:")
dbLoadTemplate("Struck8.template")
