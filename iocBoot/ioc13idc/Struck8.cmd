STR7201Setup(1,0xA0000000,220,6)
STR7201Config(0, 8, 2048)
dbLoadRecords("mcaApp/Db/Struck8.db","P=13IDC:str:", mca)
dbLoadTemplate("Struck8.template")
