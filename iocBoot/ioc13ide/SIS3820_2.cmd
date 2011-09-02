#mcaSIS3820Setup(int baseAddress, int intVector, int intLevel)
mcaSIS3820Setup(0xA8000000, 224, 6)
#mcaSIS3820Config("Port name",
#                  card,
#                  channels,
#                  signals,
#                  input mode,
#                  output mode,
#                  lne prescale
#                  ch1 ref enable)
mcaSIS3820Config("mcaSIS3820/1", 0, 2000000, 2, 2, 0, 1000000, 1)
dbLoadTemplate("SIS3820_2.substitutions")

#asynSetTraceIOMask("mcaSIS3820/1",0,2)
#asynSetTraceMask  ("mcaSIS3820/1",0,0x11)

