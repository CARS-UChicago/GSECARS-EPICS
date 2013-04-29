set Debug 0

#  Stop displacement
proc  Stop { socketID Axis}\
        {
        global Debug
        set Status 0
        set code [catch " GroupStatusGet $socketID $Axis Status"]
        if {$code != 0} {DisplayErrorAndClose  $socketID  $code  "GroupStatusGet" }
        if  {$Status==44} \
                {
                set code [catch " GroupMoveAbort $socketID $Axis"]
                if {$code != 0} {DisplayErrorAndClose  $socketID  $code  "GroupMoveAbort" }
                if { $Debug==1 }  {puts  stdout "Abort Move  $Axis"}
                after 200
                }
        if  {$Status==45} \
                {
                set code [catch " GroupMoveAbort $socketID $Axis"]
                if {$code != 0} {DisplayErrorAndClose  $socketID  $code  "GroupMoveAbort" }
                if { $Debug==1 }  {puts  stdout "Abort Trajectory  $Axis"}
                after 200
                }
        if  {$Status==46} \
                {
                set code [catch " SingleAxisSlaveModeDisable  $socketID $Axis"]
                if {$code != 0} {DisplayErrorAndClose  $socketID  $code  "SingleAxisSlaveModeDisable" }
                if { $Debug==1 }  {puts  stdout "Abort  Slave Move  $Axis"}
                after 200
                }
        if  {$Status==47} \
                {
                set Velocity 1
                set Acceleration 1
                set code [catch " GroupJogParametersGet $socketID $Axis Velocity Acceleration"]
                if {$code != 0} {DisplayErrorAndClose  $socketID  $code  "GroupJogParametersGet" }
                set Velocity 0
                set code [catch " GroupJogParametersSet $socketID $Axis $Velocity $Acceleration"]
                if {$code != 0} {DisplayErrorAndClose  $socketID  $code  "GroupJogParametersSet" }
                if { $Debug==1 }  {puts  stdout "Stop  JOG $Axis"}
                after 200
                }
        return
        }

# Display error and close procedure
proc DisplayErrorAndClose {socketID code APIName} \
        {
        if {$code != -2} {
                set code2 [catch "ErrorStringGet $socketID $code strError"]
                if {$code2 != 0} {
                        puts stdout " $APIName ErrorStringGet ERROR => $code2"
                        after 500
                        } else {
                        puts stdout "$APIName ERROR => $code : $strError"
                        }
                } else {
                puts stdout "$APIName ERROR => $code : TCP timeout"
                set code2 [catch "TCP_CloseSocket $socketID"]
                }
        return
        }

# found an actionner name in  full list

proc  ReadName { Liste IdAxis}\
        {
        set p [string first $IdAxis $Liste]
        set fin [string first ";" $Liste $p ]
        if {$fin<$p}\
                {
                set fin [string length $Liste]
                }
        set deb $p
        incr deb -1
        set c  [string index $Liste $deb]
        while { $c != ";"} \
                {
                incr deb -1
                set c  [string index $Liste $deb]
                if {$deb<0}\
                        {
                        set c ";"
                        }
                }
        incr deb
        incr fin -1
        if {$p>0 }\
                {
                set  Name_Axis [string  range $Liste $deb $fin]
                }\
        else \
                {
                set  Name_Axis ""
                }
        return $Name_Axis
        }


# Find Group name  in  full list

proc  ReadGroup { Liste IdAxis}\
        {
        set p [string first $IdAxis $Liste]
        set deb $p
        incr deb -1
        set c  [string index $Liste $deb]
        while { $c != ";"} \
                {
                incr deb -1
                set c  [string index $Liste $deb]
                if {$deb<0}\
                        {
                        set c ";"
                        }
                }
        set fin $p
        incr fin -1
        set c  [string index $Liste $fin]
        while { $c != "."} \
                {
                incr fin -1
                set c  [string index $Liste $fin]
                if {$fin<0}\
                        {
                        set c "."
                        }
                }
        incr fin -1
        incr deb
        if {$p>0 }\
                {
                set  Name_Group [string  range $Liste $deb $fin]
                }\
        else \
                {
                set  Name_Group ""
                }
        return $Name_Group
        }

#   main  program
#  Read"secur.cfg"  file

cd "/ata0/Admin/Public/Scripts"
set CurrentPath [ pwd ]
set Path "$CurrentPath/secur.cfg"
set f [open $Path "r"]
set config [ fconfigure $f ]

set mode 0
set Axe 0
set La "   "

set Axe_security_in_use 0
set Input ""
set adr 0
set val 0
set equ "="
set index 0
set axe_parm_jog 0
set strListe "  "
for {set i 0 } { $i<17  } {incr i}\
        {
        set nom($i)  " "
        set Name_Axis($i) " "
        set Nb_axe_in_security($i) 0
        set  JogX_security($i) 0
        set  JogY_security($i) 0
        set UserMinimumTarget($i)  -10000.00
        set UserMaximumTarget($i) 100000.00
        set Analog_Input($i) " "
        set Offset($i) 0.00
        set Scale($i) 1.00
        set Dbt($i) 0.00
        set Order($i) 1
        set Jog_Speed($i) 1.00
        set Jog_Acceleration($i) 1.00
        set Axe_condition_un($i) ""
        set Axe_condition_deux($i) ""
        set Position_un($i) 0.0
        set Position_deux($i) 0.0
        set Sens_plus_un($i) 1
        set Sens_plus_deux($i) 1
        }

# Read parametrs in configuration file

while {[eof $f] !=1} \
        {
        set Ligne  [gets $f]
        
        #  remove comments
        
        set Debut_comment [string first ";" $Ligne]
        if {$Debut_comment>=0} \
                {
                set Ligne [string range $Ligne 0 [expr $Debut_comment-1]]
                }
        
        #  "="   char must be beetween  two spaces. Add space character if not
        set debut 0
        set Arg1 "Empty"
        set Arg2 0
        set Arg3 0.00
        set Ya_egal 0
        while { $Ya_egal >= 0 }\
                {
                set Ya_egal [string first "=" $Ligne $debut]
                if {$Ya_egal >=0}\
                        {
                        set Car_avant [string index $Ligne  [expr  $Ya_egal-1 ]]
                        if {$Car_avant !=" "}\
                                {
                                set Ligne [string replace $Ligne  $Ya_egal  $Ya_egal   " ="]
                                incr Ya_egal 1
                                }
                        set Car_apres [string index $Ligne  [expr  $Ya_egal+1 ]]
                        if {$Car_apres !=" "}\
                                {
                                set Ligne [string replace $Ligne  $Ya_egal  $Ya_egal   "= "]
                                }
                        }
                set debut [expr $Ya_egal+1]
                }
        
        #  Lok for key words
        
        set Found [string first "AXIS LIST" $Ligne]
        if {$Found>=0}\
                {
                set Mode 1
                }\
        else\
                {
                #  "AXIS LIST"  not found
                set Found [string first "ENABLE JOG" $Ligne]
                if { $Found >= 0 }\
                        {
                        set Mode 2
                        }\
                else\
                        {
                        # "ENABLE JOG" not found
                        set Found [string first "SECURITY" $Ligne]
                        if {$Found>=0}\
                                {
                                set Mode 3
                                scan $Ligne "%s %d"  L2  Axe_security_in_use
                                set Nb_axe_in_security(Axe_security_in_use) 0
                                }\
                        else\
                                {
                                set Found [string first "ACTIVITY" $Ligne]
                                if {$Found>=0}\
                                        {
                                        set Mode 4
                                        }\
                                else\
                                        {
                                        set Found [string first "DETECTED" $Ligne]
                                        if {$Found>=0}\
                                                {
                                                set Mode 5
                                                }\
                                        else\
                                                {
                                                set Found [string first "JOG PARAMETERS AXIS" $Ligne]
                                                if {$Found>=0}\
                                                        {
                                                        set Mode 6
                                                        set  La  [string range $Ligne 19 35]
                                                        scan $La "%d"  axe_parm_jog
                                                        }\
                                                else\
                                                        {
                                                        if {$Mode==1}\
                                                                {
                                                                set  La  [string range $Ligne 0 1]
                                                                scan $La "%d " Axe
                                                                set La [string range $Ligne  4 100]
                                                                set nom($Axe) $La
                                                                set Axe 0
                                                                }\
                                                        else\
                                                                {
                                                                set Found [string first "INPUT" $Ligne]
                                                                if {$Found>=0}\
                                                                        {
                                                                        if {$Mode==2 }\
                                                                                {
                                                                                scan $Ligne "%s %s %d %s %d" L2 Input adr equ val
                                                                                set Input_Jog  $Input
                                                                                set Adr_Jog $adr
                                                                                set Val_Jog $val
                                                                                }
                                                                        if {$Mode==3 }\
                                                                                {
                                                                                scan $Ligne "%s %s %d %s %d" L2 Input adr equ val
                                                                                set Input_Security($Axe_security_in_use)  $Input
                                                                                set Adr_Security($Axe_security_in_use)  $adr
                                                                                set Val_Security($Axe_security_in_use)  $val
                                                                                }
                                                                        if {$Mode==6}\
                                                                                {
                                                                                scan $Ligne "%s %s %s" L2 equ  Analog_Input($axe_parm_jog)
                                                                                set Found [string first "OFFSET" $Ligne]
                                                                                if {$Found>=0}\
                                                                                        {
                                                                                        set L2  [string range $Ligne [expr $Found+6] 100]
                                                                                        scan $L2 " %s %f" equ  Offset($axe_parm_jog)
                                                                                        }
                                                                                set Found [string first "SCALE" $Ligne]
                                                                                if {$Found>=0}\
                                                                                        {
                                                                                        set L2  [string range $Ligne [expr $Found+5] 100]
                                                                                        scan $L2 " %s %f" equ  Scale($axe_parm_jog)
                                                                                        }
                                                                                set Found [string first "DBT" $Ligne]
                                                                                if {$Found>=0}\
                                                                                        {
                                                                                        set L2  [string range $Ligne [expr $Found+3] 100]
                                                                                        scan $L2 " %s %f" equ  Dbt($axe_parm_jog)
                                                                                        }
                                                                                set Found [string first "ORDER" $Ligne]
                                                                                if {$Found>=0}\
                                                                                        {
                                                                                        set L2  [string range $Ligne [expr $Found+5] 100]
                                                                                        scan $L2 " %s %d" equ  Order($axe_parm_jog)
                                                                                        }
                                                                                set Found [string first "SPEED" $Ligne]
                                                                                if {$Found>=0}\
                                                                                        {
                                                                                        set L2  [string range $Ligne [expr $Found+5] 100]
                                                                                        scan $L2 " %s %f" equ  Jog_Speed($axe_parm_jog)
                                                                                        }
                                                                                set Found [string first "ACCELERATION" $Ligne]
                                                                                if {$Found>=0}\
                                                                                        {
                                                                                        set L2  [string range $Ligne [expr $Found+12] 100]
                                                                                        scan $L2 " %s %f" equ  Jog_Acceleration($axe_parm_jog)
                                                                                        
                                                                                        }
                                                                                }
                                                                        }
                                                                set Found [string first "POSITION1" $Ligne]
                                                                if {$Found>=0}\
                                                                        {
                                                                        set Ligne [string range $Ligne 9 255]
                                                                        scan $Ligne %s%s%e  Arg1 Arg2  Arg3
                                                                        set Axe_condition_un($Axe_security_in_use)  $Arg1
                                                                        if {$Arg2==">" }\
                                                                                {
                                                                                set Sens_plus_un($Axe_security_in_use) 1
                                                                                }\
                                                                        else\
                                                                                {
                                                                                if {$Arg2=="<"}\
                                                                                        {
                                                                                        set Sens_plus_un($Axe_security_in_use) 0
                                                                                        }\
                                                                                else\
                                                                                        {
                                                                                        puts "Erreur dans le fichier de configuration"
                                                                                        }
                                                                                }
                                                                        set Position_un($Axe_security_in_use) $Arg3
                                                                        }
                                                                set Found [string first "POSITION2" $Ligne]
                                                                if {$Found>=0}\
                                                                        {
                                                                        set Ligne [string range $Ligne 9 255]
                                                                        scan $Ligne %s%s%e  Arg1 Arg2  Arg3
                                                                        set Axe_condition_deux($Axe_security_in_use)  $Arg1
                                                                        if {$Arg2==">" }\
                                                                                {
                                                                                set Sens_plus_deux($Axe_security_in_use) 1
                                                                                }\
                                                                        else\
                                                                                {
                                                                                if {$Arg2=="<"}\
                                                                                        {
                                                                                        set Sens_plus_deux($Axe_security_in_use) 0
                                                                                        }\
                                                                                else\
                                                                                        {
                                                                                        puts "Erreur dans le fichier de configuration"
                                                                                        }
                                                                                }
                                                                        set Position_deux($Axe_security_in_use) $Arg3
                                                                        }
                                                                set Found [string first "OUTPUT" $Ligne]
                                                                if {$Found>=0}\
                                                                        {
                                                                        if {$Mode==4 }\
                                                                                {
                                                                                scan $Ligne "%s %s %d " L2  Output_Activity Adr_activity
                                                                                }
                                                                        if {$Mode==5 }\
                                                                                {
                                                                                scan $Ligne "%s %s%d " L2 Output_Detected  Adr_Detected
                                                                                }
                                                                        }
                                                                if {$Mode==3 }\
                                                                        {
                                                                        set Found [string first "AXIS" $Ligne]
                                                                        if {$Found>=0}\
                                                                                {
                                                                                set L2  [string range $Ligne [expr $Found+4] 100]
                                                                                set No 0
                                                                                scan $L2 " %s %d" equ  No
                                                                                incr Nb_axe_in_security($Axe_security_in_use)
                                                                                set index [expr [expr ($Nb_axe_in_security($Axe_security_in_use)*8) ]+ $Axe_security_in_use]
                                                                                set Axis_security($index) $No
                                                                                }
                                                                        set Found [string first "SENSE" $Ligne]
                                                                        if {$Found>=0}\
                                                                                {
                                                                                set L2  [string range $Ligne [expr $Found+5] 100]
                                                                                set s "+"
                                                                                scan $L2 " %s %s" equ  s
                                                                                set Sense_security($index) $s
                                                                                }
                                                                        set Found [string first "DELTA" $Ligne]
                                                                        if {$Found>=0}\
                                                                                {
                                                                                set L2  [string range $Ligne [expr $Found+5] 100]
                                                                                set d 0.0
                                                                                scan $L2 " %s %f" equ  d
                                                                                set Delta_security($index) $d
                                                                                }
                                                                        set Found [string first "JOGX" $Ligne]
                                                                        if {$Found>=0}\
                                                                                {
                                                                                set L2  [string range $Ligne [expr $Found+4] 100]
                                                                                set No 0
                                                                                scan $L2 " %s %d" equ  No
                                                                                if {$No != 0 }\
                                                                                        {
                                                                                        set JogX_security($Axe_security_in_use) $No
                                                                                        }
                                                                                }
                                                                        set Found [string first "JOGY" $Ligne]
                                                                        if {$Found>=0}\
                                                                                {
                                                                                set L2  [string range $Ligne [expr $Found+4] 100]
                                                                                set No 0
                                                                                scan $L2 " %s %d" equ  No
                                                                                if {$No != 0 }\
                                                                                        {
                                                                                        set JogY_security($Axe_security_in_use) $No
                                                                                        }
                                                                                }
                                                                        }
                                                                }
                                                        }
                                                }
                                        }
                                }
                        }
                }
        }
set TimeOut 10
set code [catch "OpenConnection $TimeOut socketID"]
if {$code == 0}  \
        {
        # Read the full list : all objetcts  knowed by  XPS
        set code [catch "ObjectsListGet  $socketID strListe"]
        if {$code != 0} \
                {
                DisplayErrorAndClose  $socketID  $code  "ObjectsListGet"
                }
        for {set i 0 } { $i<9  } {incr i}\
                {
                set  Name_Axis($i)  [ReadName  $strListe $nom($i)]
                set  Group($i)  [ReadGroup  $strListe $nom($i)]
                if {$Name_Axis($i) !="" }\
                        {
                        set code [catch " PositionerUserTravelLimitsGet $socketID $Name_Axis($i) UserMinimumTarget($i)  UserMaximumTarget($i)"]
                        if {$code != 0} { DisplayErrorAndClose  $socketID  $code  "PositionerUserTravelLimitsGet" }
                        }
                }
        
        if {$Debug==1 }\
                {
                puts  " "
                puts " AXIS LIST"
                for {set i 0 } { $i<9  } {incr i}\
                        {
                        if {$Name_Axis($i) !="" }\
                                {
                                puts "$Name_Axis($i)  in  $Group($i) Group"
                                }
                        }
                puts " "
                puts "ENABLE JOG  with  $Input_Jog Address =  $Adr_Jog Value =  $Val_Jog "
                for {set i 1  } {$i < 9  } {incr i }\
                        {
                        if {$Analog_Input($i) != " "  }\
                                {
                                puts "Jog for axis $i driven by $Analog_Input($i) . Offset : $Offset($i) . Scale : $Scale($i)  . DBT : $Dbt($i)  . Order : $Order($i)  Speed : $Jog_Speed($i). Acc : $Jog_Acceleration($i)"
                                }
                        }
                puts " "
                puts "ACTIVITY BLINK on $Output_Activity  Address = $Adr_activity"
                puts "SECURITY DETECTED on $Output_Detected  Address = $Adr_Detected "
                for {set  i 1  } {$i<9   } {incr i}\
                        {
                        if {$Nb_axe_in_security($i) != 0   }\
                                {
                                puts " "
                                puts "Security number $i drive  $Nb_axe_in_security($i)  axe(s)"
                                puts "It is driven by $Input_Security($i) port, if the $Adr_Security($i) address go to $Val_Security($i) state"
                                if {$Axe_condition_un($i) !=""}\
                                        {
                                        puts "Condition 1 : $Axe_condition_un($i)  sens plus = $Sens_plus_un($i)  Position=$Position_un($i)"
                                        }
                                if {$Axe_condition_deux($i) !=""}\
                                        {
                                        puts "Condition 2 : $Axe_condition_deux($i)  sens plus = $Sens_plus_deux($i)  Position=$Position_deux($i)"
                                        }
                                
                                if {$JogX_security($i) != 0  }\
                                        {
                                        puts  "X axis Joystick is usable to drive Axis $JogX_security($i)"
                                        }
                                if {$JogY_security($i) != 0  }\
                                        {
                                        puts  "Y axis Joystick is usable to drive Axis $JogY_security($i)"
                                        }
                                }
                        for {set j 1  } {$j<=$Nb_axe_in_security($i) } {incr j}\
                                {
                                set index [expr [expr ($j*8) ]+ $i]
                                puts "This security drive axis $Axis_security($index)  in $Sense_security($index)  sens with a $Delta_security($index) diplacement allowed for this sense"
                                }
                        }
                }
        }\
else \
        {
        puts $code
        }
for {set i 1  } {$i<17   } {incr i}\
        {
        if {$Nb_axe_in_security($i) != 0   }\
                {
                if {$Val_Security($i)==0 }\
                        {
                        set Old_value($i) $Adr_Security($i)
                        }\
                else\
                        {
                        set Old_value($i) 0
                        }
                set OK_value($i) $Old_value($i)
                }
        }
set Input_state 0
set CurrentPosition 0
set NewLimit 0
set JogX_in_use 0
set JogY_in_use 0


#  main loop  programm    ( infinite)
set Begin [clock clicks]
while {1==1 }\
        {
        set End [clock clicks]
        if {$End > $Begin +250000 }\
                {
                set code [catch " GPIODigitalSet $socketID $Output_Activity  $Adr_activity $Adr_activity"]
                if {$code != 0} { DisplayErrorAndClose  $socketID  $code  "GPIODigitalSet" }
                }
        if {$End > $Begin + 500000 }\
                {
                set code [catch " GPIODigitalSet $socketID $Output_Activity  $Adr_activity 0"]
                if {$code != 0} { DisplayErrorAndClose  $socketID  $code  "GPIODigitalSet" }
                set Begin $End
                }
        set security 0
        set JogX 0
        set JogY 0
        set Pos_courante 0
        for {set security_in_use 1  } { $security_in_use<17  } {incr security_in_use}\
                {
                if {$Nb_axe_in_security($security_in_use) != 0   }\
                        {
                        set ok 1
        	            set code [catch " GPIODigitalGet $socketID $Input_Security($security_in_use) Input_state"]
                        if {$code != 0} { DisplayErrorAndClose  $socketID  $code  "GPIODigitalGet" }
                        if {$Axe_condition_un($security_in_use) !=""}\
                                {
                                set code [catch "GroupPositionCurrentGet $socketID $Axe_condition_un($security_in_use)  Pos_courante"]
                                if {$code != 0} { DisplayErrorAndClose  $socketID  $code  "GroupPositionCurrentGet" }
                                if {$Sens_plus_un($security_in_use)==1}\
                                        {
                                        if {$Pos_courante < $Position_un($security_in_use)}\
                                                {
                                                set ok 0
                                                }
                                        }\
                                else\
                                        {
                                        if {$Pos_courante > $Position_un($security_in_use)}\
                                                {
                                                set ok 0
                                                }
                                        }
                                }
                        if {$Axe_condition_deux($security_in_use) !=""}\
                                {
                                set code [catch "GroupPositionCurrentGet $socketID $Axe_condition_deux($security_in_use)  Pos_courante"]
                                if {$code != 0} { DisplayErrorAndClose  $socketID  $code  "GroupPositionCurrentGet" }
                                if {$Sens_plus_deux($security_in_use)==1}\
                                        {
                                        if {$Pos_courante < $Position_deux($security_in_use)} \
                                                {
                                                set ok 0
                                                }
                                        }\
                                else\
                                        {
                                        if {$Pos_courante > $Position_deux($security_in_use)}\
                                                {
                                                set ok 0
                                                }
                                        }
                                }
                        set Input_read [expr $Input_state  &  $Adr_Security($security_in_use) ]
                        if {($Input_read  != $OK_value($security_in_use) &&($ok==1))    }\
                                {
                                set s 1
                                for {set a 1} {$a!=$security_in_use} {incr a}\
                                        {
                                        set s $s*2
                                        }
                                set security [ expr $security + $s ]
                                if {$JogX_security($security_in_use) !=0   }\
                                        {
                                        set JogX $JogX_security($security_in_use)
                                        }
                                if {$JogY_security($security_in_use) !=0   }\
                                        {
                                        set JogY $JogY_security($security_in_use)
                                        }
                                if {$Input_read != $Old_value($security_in_use)  }\
                                        {
                                        set  Old_value($security_in_use)  $Input_read
                                        if {$Debug==1 }  { puts "security $security_in_use  "  }
                                        for {set j 1  } {$j<=$Nb_axe_in_security($security_in_use) } {incr j}\
                                                {
                                                set index [expr [expr ($j*8) ]+ $security_in_use]
                                                set Axis $Axis_security($index)
                                                Stop $socketID $Group($Axis)
                                                set code [catch " PositionerUserTravelLimitsGet $socketID $Name_Axis($Axis) UserMinimumTarget($Axis)  UserMaximumTarget($Axis)"]
                                                if {$code != 0} { DisplayErrorAndClose  $socketID  $code  "PositionerUserTravelLimitsGet" }
                                                set code [catch " GroupPositionCurrentGet $socketID $Name_Axis($Axis) CurrentPosition"]
                                                if {$code != 0} { DisplayErrorAndClose  $socketID  $code  "GroupPositionCurrentGet" }
                                                if {$Sense_security($index) == "+" }\
                                                        {
                                                        set NewLimit [expr $CurrentPosition+$Delta_security($index) ]
                                                        set code [catch " PositionerUserTravelLimitsSet $socketID $Name_Axis($Axis)  $UserMinimumTarget($Axis) $NewLimit"]
                                                        if {$code != 0} { DisplayErrorAndClose  $socketID  $code  "PositionerUserTravelLimitsSet" }
                                                        if { $Debug==1 }  {puts " $Name_Axis($Axis) Software limits :  Min $UserMinimumTarget($Axis)  ,  Max  $UserMaximumTarget($Axis)   Current Position : $CurrentPosition   $NewLimit -> Max  "}
                                                        }\
                                                else \
                                                        {
                                                        set NewLimit [expr $CurrentPosition - $Delta_security($index) ]
                                                        set code [catch " PositionerUserTravelLimitsSet $socketID $Name_Axis($Axis)   $NewLimit  $UserMaximumTarget($Axis)"]
                                                        if {$code != 0} { DisplayErrorAndClose  $socketID  $code  "PositionerUserTravelLimitsSet" }
                                                        if { $Debug==1 }  {puts " $Name_Axis($Axis) Software limits :  Min $UserMinimumTarget($Axis)  ,  Max  $UserMaximumTarget($Axis)   Current Position : $CurrentPosition  $NewLimit -> Min  "}
                                                        }
                                                }
                                        }
                                }\
                        else \
                                {
                                if {($Input_read != $Old_value($security_in_use))&&($ok==1)}\
                                        {
                                        set  Old_value($security_in_use)  $Input_read
                                        for {set j 1  } {$j<=$Nb_axe_in_security($security_in_use) } {incr j}\
                                                {
                                                set index [expr [expr ($j*8) ]+ $security_in_use]
                                                set Axis $Axis_security($index)
                                                set code [catch " PositionerUserTravelLimitsSet $socketID $Name_Axis($Axis)  $UserMinimumTarget($Axis) $UserMaximumTarget($Axis)"]
                                                if {$code != 0} { DisplayErrorAndClose  $socketID  $code  "PositionerUserTravelLimitsSet" }
                                                if { $Debug==1 }  {puts " $Name_Axis($Axis) Software limits :  Min $UserMinimumTarget($Axis)  ,  Max  $UserMaximumTarget($Axis)  "}
                                                }
                                        }
                                }
                        }
                }
        if {$security != 0 }\
                {
                set code [catch " GPIODigitalSet $socketID GPIO1.DO 255 $security"]
                if {$code != 0} { DisplayErrorAndClose  $socketID  $code  "GPIODigitalSet" }
                }\
        else \
                {
                set code [catch " GPIODigitalSet $socketID GPIO1.DO 255 0"]
                if {$code != 0} { DisplayErrorAndClose  $socketID  $code  "GPIODigitalSet" }
                }
        set code [catch " GPIODigitalGet $socketID  $Input_Jog Input_state"]
        if {$code != 0} { DisplayErrorAndClose  $socketID  $code  "GPIODigitalGet" }
        set Input_read [expr $Input_state  &   $Adr_Jog]
        if {$Input_read ==[expr $Val_Jog * $Adr_Jog]   }\
                {
                if {$JogX!=0 }\
                        {
                        if {$JogX_in_use==0 }\
                                {
                                if {$Debug==1 } { puts "Validation Jog X pour $Name_Axis($JogX)"   }
                                set code [catch "PositionerAnalogTrackingVelocityParametersSet $socketID $Name_Axis($JogX) $Analog_Input($JogX)  $Offset($JogX)  $Scale($JogX)  $Dbt($JogX) $Order($JogX)  $Jog_Speed($JogX) $Jog_Acceleration($JogX)"]
                                if {$code != 0} { DisplayErrorAndClose  $socketID  $code  "PositionerAnalogTrackingVelocityParametersSet" }
                                set code [catch "GroupAnalogTrackingModeEnable $socketID $Group($JogX)  Velocity"]
                                if {$code != 0} { DisplayErrorAndClose  $socketID  $code  "GroupAnalogTrackingModeEnablet" }
                                set JogX_in_use  $JogX
                                }
                        }
                if {$JogY!=0 }\
                        {
                        if {$JogY_in_use==0 }\
                                {
                                if {$Debug==1 }  { puts "Validation Jog Y pour $Name_Axis($JogY) "  }
                                set code [catch "PositionerAnalogTrackingVelocityParametersSet $socketID $Name_Axis($JogY) $Analog_Input($JogY)  $Offset($JogY)  $Scale($JogY)  $Dbt($JogY) $Order($JogY)  $Jog_Speed($JogY) $Jog_Acceleration($JogY)"]
                                if {$code != 0} { DisplayErrorAndClose  $socketID  $code  "PositionerAnalogTrackingVelocityParametersSet" }
                                set code [catch "GroupAnalogTrackingModeEnable $socketID $Group($JogY)  Velocity"]
                                if {$code != 0} { DisplayErrorAndClose  $socketID  $code  "GroupAnalogTrackingModeEnablet" }
                                set JogY_in_use  $JogY
                                }
                        }
                }\
        else \
                {
                if {$JogX_in_use != 0    }\
                        {
                        if {$Debug==1 } { puts "End  Jog X " }
                        set code [catch "GroupAnalogTrackingModeDisable $socketID $Group($JogX_in_use) "]
                        if {$code != 0} { DisplayErrorAndClose  $socketID  $code  "GroupAnalogTrackingModeDisable" }
                        set JogX_in_use 0
                        }
                if {$JogY_in_use != 0    }\
                        {
                        if {$Debug==1 } { puts "End  Jog Y " }
                        set code [catch "GroupAnalogTrackingModeDisable $socketID $Group($JogY_in_use) "]
                        if {$code != 0} { DisplayErrorAndClose  $socketID  $code  "GroupAnalogTrackingModeDisable" }
                        set JogY_in_use 0
                        }
                }
        }