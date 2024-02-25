# Initialize Systran DAC
# initDAC128V(char *portName, int carrier, int slot)
# portName  = name to give this asyn port
# carrier     = IPAC carrier number (0, 1, etc.)
# slot        = IPAC slot (0,1,2,3, etc.)
initDAC128V("DAC1",0,0)
dbLoadTemplate "DAC.substitutions"
#asynSetTraceMask DAC1 -1 9
