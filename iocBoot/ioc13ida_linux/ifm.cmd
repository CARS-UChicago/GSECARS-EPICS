
epicsEnvSet("PREFIX1", "$(P)IFM1:")
epicsEnvSet("PREFIX2", "$(P)IFM2:")

#iocshLoad("ifm_modbus.cmd", "P=$(PREFIX1), PORT=AL1342_1, IPADDR=gse-al1342-1-mb")
#dbLoadTemplate("ifm1_inputs.substitutions", "P=$(PREFIX1)")

iocshLoad("ifm_modbus.cmd", "P=$(PREFIX2), PORT=AL1342_2, IPADDR=gse-al1342-2-mb")
dbLoadTemplate("ifm2_inputs.substitutions", "P=$(PREFIX2)")

