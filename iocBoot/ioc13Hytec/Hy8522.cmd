#int Hy8522AsynInit(
#  char *portName,  /* "SCALER8522" */
#  int carrierNum, 	/* 0 */
#  int ipSlotNum,   /* 0 ~ 5 for slot 'A' to 'F' */
#  int vectorNum,   /* 88 */
#  int freq,		/* internal clock. 0: 25MHz, 1:50MHz, 2:100MHz, 3:200MHz */
#  int sourceMask,	/* bi mask for clock source. 0: external. 1: internal defined by freq *////
#  int hwtrigger,   /* 0: no hardware trigger, 1: allow hardware trigger */
#  int hwreset)   	/* 0: no hardware reset, 1: allow hardware reset */
Hy8522AsynInit("SCALER8522", 0, 1, 88, 0, 0x1, 0, 0 )

#int Hy8522HistogramMode(
#  char *portName, 	/* asyn port name
#  int gateIntv,	/* When extadvance setting is 0 , this is the gate interval as below: 
#     						If timeunit = 0, i.e. 1ms, this defines the interval in mini-second 
#     			  			If timeunit = 1, i.e. 100us, this defines the interval in 100us steps. 
#     			  	/* When extadvance = 1, it is number of pulses to advance the memory location
#  int timeunit, 	/* Define interval time unit. 0 = 1ms, 1 = 100us
#  int nocycles,	/* Define the number of cycles. If it is set to 0, the scaler doesn't do anything.
#  int nogates, 	/* Define the number of gates (bins), i.e. How many gates in a cycle. Each gate 
#      					stores counting of pulses in one memory location. Next cycle adds up to 
#      					the same locatoin to form histogram.
#  int mask, 		/* bit mask to enable/disable channels. 0 = enable, 1 = disable.
#  int extadvance, 	/* Memory advance control. 0 = advanced by interval timer, 1 = advanced by external hardware pulses 
#  int accumulate) 	/* Define the return waveform of the histogram. =0 return normal histogram. = 1 return accumulated 
#				  		waveform -- each bin also accumulates all previous bins.
#uncomment this for normal histogram mode
#Hy8522HistogramMode("SCALER8522", 1000, 0, 1, 10, 0x0000, 0, 1)	


#int Hy8522CoincidenceMode(
#  char *portName, 	/* asyn port name
#  int gateIntv,	/* When extadvance setting is 0 , this is the gate interval as below: 
#     						If timeunit = 0, i.e. 1ms, this defines the interval in mini-second 
#     			  			If timeunit = 1, i.e. 100us, this defines the interval in 100us steps. 
#     			  	/* When extadvance = 1, it is number of pulses to advance the memory location
#  int timeunit, 	/* Define interval time unit. 0 = 1ms, 1 = 100us
#  int nocycles,	/* Define the number of cycles. If it is set to 0, the scaler doesn't do anything.
#  int nogates, 	/* Define the number of gates (bins), i.e. How many gates in a cycle. Each gate 
#      					stores counting of pulses in one memory location. Next cycle adds up to 
#      					the same locatoin to form histogram.
#  int mask, 		/* bit mask to enable/disable channels. 0 = enable, 1 = disable.
#  int extadvance, 	/* Memory advance control. 0 = advanced by interval timer, 1 = advanced by external hardware pulses 
#  int accumulate) 	/* Define the return waveform of the histogram. =0 return normal histogram. = 1 return accumulated 
#				  		waveform -- each bin also accumulates all previous bins.
#Hy8522CoincidenceMode("SCALER8522", 100, 0, 4, 6, 0x0000, 0)	
#uncomment this and the next two lines for coincidence histogram mode
#Hy8522AsynInitCoin1("SCALER8522", 0x1111, 0x2222, 0x3333, 0x4444, 0x5555, 0x6666, 0x7777, 0x8888 )
#Hy8522AsynInitCoin2("SCALER8522", 0x9999, 0xAAAA, 0xBBBB, 0xCCCC, 0xDDDD, 0xEEEE, 0xFFFF, 0x0000 )

#int Hy8522StraightMode(
#  char *portName, 	/* asyn port name
#  int gateIntv, 	/* Define gate interval as below:
#						If timeunit = 0, i.e. 1ms, this defines the interval in mini-second
#						If timeunit = 1, i.e. 100us, this defines the interval in 100us steps.
#  int timeunit, 	/* Define interval time unit. 0 = 1ms, 1 = 100us
#  int nocycles, 	/* Define the number of trigger cycles. Up to 32K
#  int mask)		/* bit mask to enable/disable channels. 0 = enable, 1 = disable
#Hy8522StraightMode("SCALER8522", 100, 0, 5, 0x0000)		
#uncomment this for straight scaler mode


#int Hy8522PresetMode(
#  char *portName, 	/* asyn port name
#  int armMask)		/* Define ARM bit. Set to 1 to ARM the correspondent channel
Hy8522PresetMode("SCALER8522", 0xffff);

#8522.db is for other modes, 8522_preset.db is for preset scaler mode. Use only one of them.
#dbLoadRecords("$(HY8522)/db/8522.db","P=CARD1,PORT=SCALER8522")
dbLoadRecords("$(HY8522)/db/8522_preset.db","P=13Hytec,S=scaler1,PORT=SCALER8522,DTYP=Asyn Scaler,OUT=@asyn(SCALER8522),FREQ=25000000")	

# set trace output level for asyn port "SCALER8522"
# Level: 0x01 = Errors only
# asynSetTraceMask arguments:
#  * asyn port
#  * address of that asynport (i.e. channel number)
#  * verbosity level: 
#                     0x01: error, 
#                     0x11: errors, warnings and debug
#                     0x00: silent
asynSetTraceMask( "SCALER8522", 0, 0x01)  
