#  "Flag "  to set to 1  in debug mode
set Debug 1
puts  stdout "BaseSecurity071205.tcl ver 1.0"

#  "Bliinking output parameters
set Loop 1000
set Loop2 [expr $Loop/2]


# "Flag" to set to 1 to inverse input
set Inverse 1

#  Overcrossing value
set Delta 0.05

# Axes used :
# Names des actionneurs
set Axis_Y1 "Y1"
set Axis_Y2 "Y2"
set Axis_Y3 "Y3"

set TimeOut 120

#  Name "system"
set Name_Axis_Y1 ""
set Name_Axis_Y2 ""
set Name_Axis_Y3 ""

#  Inputs  and  Outputs used
set Input "GPIO1.DI"
set Output "GPIO1.DO"

#    old  Inputs  values initialisations
set Old_Input_S1U 0
set Old_Input_S1D 0
set Old_Input_S3U 0
set Old_Input_S3D 0

# I Inputs  values  iitialisation
set AdS1U 1
set AdS1D 2
set AdS3U 4
set AdS3D 8

set UserMinimumTargetY1 0.000
set UserMaximumTargetY1 0.000
set UserMinimumTargetY2 0.000
set UserMaximumTargetY2 0.000
set UserMinimumTargetY3 0.000
set UserMaximumTargetY3 0.000

set CurrentPosition 0.1234

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

#   Find  Positionner names  in  full list
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

#  Stop displacement
proc  Stop { socketID Axis}\
      {
      global Debug
      set Status 0
      set code [catch " GroupStatusGet $socketID $Axis Status"]
      if {$code != 0} {DisplayErrorAndClose  $socketID  $code  "GroupStatusGet" }
      if  {$Status==44} \
            {     # Displacement  -> stop
            set code [catch " GroupMoveAbort $socketID $Axis"]
            if {$code != 0} {DisplayErrorAndClose  $socketID  $code  "GroupMoveAbort" }
            if { $Debug==1 }  {puts  stdout "Abort Move  $Axis"}
            after 200
            }
      if  {$Status==45} \
            {     #  Trajectory -> stop
            set code [catch " GroupMoveAbort $socketID $Axis"]
            if {$code != 0} {DisplayErrorAndClose  $socketID  $code  "GroupMoveAbort" }
            if { $Debug==1 }  {puts  stdout "Abort Trajectory  $Axis"}
            after 200
            }
      if  {$Status==46} \
            {     # Slave  -> slave disable
            set code [catch " SingleAxisSlaveModeDisable  $socketID $Axis"]
            if {$code != 0} {DisplayErrorAndClose  $socketID  $code  "SingleAxisSlaveModeDisable" }
            if { $Debug==1 }  {puts  stdout "Abort  Slave Move  $Axis"}
            after 200
            }
      if  {$Status==47} \
            {     #Jog Mode
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
      if  {$Status==48} \
            {     #  Analog Tracking Mode  Mode
            set code [catch " GroupAnalogTrackingModeDisable  $socketID $Axis"]
            if {$code != 0} {DisplayErrorAndClose  $socketID  $code  "GroupAnalogTrackingModeDisable" }
            if { $Debug==1 }  {puts  stdout "Abort Tracking  Mode  $Axis"}
            after 200
            }
      return
      }


# open TCP socket
set code  [catch "OpenConnection $TimeOut socketID"]
if {$code == 0}  \
      {
      # Read the full list : alla objetcts  knowed by  XPS
      set code [catch "ObjectsListGet  $socketID strListe"]
      if {$code != 0} \
            {
            DisplayErrorAndClose  $socketID  $code  "ObjectsListGet"
            }
      #   strlListe  = full list
      #    find and extract  positionner names
      set  Name_Axis_Y1  [ReadName  $strListe $Axis_Y1 ]
      set  Name_Axis_Y2  [ReadName  $strListe $Axis_Y2 ]
      set  Name_Axis_Y3  [ReadName  $strListe $Axis_Y3]
      
      #  Find and extract group names
      set  Group_Y1  [ReadGroup  $strListe $Axis_Y1 ]
      set  Group_Y2  [ReadGroup  $strListe $Axis_Y2 ]
      set  Group_Y3  [ReadGroup  $strListe $Axis_Y3]
      
      if { $Debug==1 }\
            {
            puts  stdout " $Axis_Y1  name  =  $Name_Axis_Y1 in $Group_Y1"
            puts  stdout " $Axis_Y2  name  =  $Name_Axis_Y2 in $Group_Y2"
            puts  stdout " $Axis_Y3  name  =  $Name_Axis_Y3 in $Group_Y3"
            }
      
      set Ledloop [expr $Loop]
      set code [catch " GPIODigitalSet $socketID $Output 1 1"]
      while {1==1} \
            {                                                                                                                                  
            after 100                                                                                           
            # puts  stdout "in while"
            set Ledloop [expr $Ledloop-1]
 
            # puts stdout "N0= $Outputloop"
            
		if {$Ledloop==$Loop2 } {set code [catch " GPIODigitalSet $socketID $Output 1 0"]}
            if {$Ledloop==0 } \
			{
                  set code [catch " GPIODigitalSet $socketID $Output 1 1"]
                  set Ledloop [expr $Loop]
                  }
            set code [catch " GPIODigitalGet $socketID $Input Etat_Inputs"]
            
            if {$Inverse!=0   }\
                  {
                  set Etat_Inputs  [expr 255 - $Etat_Inputs]
                  }
            #   Read all inputs
            if {$code != 0} { DisplayErrorAndClose  $socketID  $code  "GPIODigitalGet" }
            
		set Input_S1U [expr $Etat_Inputs  &  $AdS1U]
            #   Extract   Y1 "plus" input
            set Input_S1D [expr $Etat_Inputs  &  $AdS1D]
            #   Extract   Y2 "plus" input
            set Input_S3U [expr $Etat_Inputs  &  $AdS3U]
            #   Extract   Y3 "plus" input
            set Input_S3D [expr $Etat_Inputs  &  $AdS3D]
            #   Extract   Y3 "minus" input
            
            if {$Input_S1U !=$Old_Input_S1U   }\
                  {                                                                                                                             
                  if   { $Debug == 1}  { puts "  S1U  $Input_S1U" }
                  if {[string  first  $Axis_Y1 $Name_Axis_Y1] >0  }\
                        {        # Y1 axis is defined, his nam  has been found
                        set  Old_Input_S1U $Input_S1U
                        if {$Input_S1U != 0 }\
                              {        # Y1 "plus " switch has moved to 1
                              Stop $socketID $Group_Y1
                              Stop $socketID $Group_Y2
                              Stop $socketID $Group_Y3
                              set code [catch " PositionerUserTravelLimitsGet $socketID $Name_Axis_Y1 UserMinimumTargetY1 UserMaximumTargetY1"]
                              # Read current soft limits for axis Y1
                              if {$code != 0} { DisplayErrorAndClose  $socketID  $code  "PositionerUserTravelLimitsGet" }
                              set code [catch " GroupPositionCurrentGet $socketID $Name_Axis_Y1 CurrentPosition"]
                              # Read current position for axis Y1
                              if {$code != 0} { DisplayErrorAndClose  $socketID  $code  "GroupPositionCurrentGet" }
                              set CurrentPosition [expr $CurrentPosition+$Delta]
                              set code [catch " PositionerUserTravelLimitsSet $socketID $Name_Axis_Y1 $UserMinimumTargetY1 $CurrentPosition"]
                              # Set new value (current position) to  maximum target position  on axis Y1
                              if {$code != 0} { DisplayErrorAndClose  $socketID  $code  "PositionerUserTravelLimitsSet" }
                              if { $Debug==1 }  {puts " Y1 Software limits :  Min $UserMinimumTargetY1  ,  Max  $UserMaximumTargetY1   Current Position : $CurrentPosition  Current -> Max  "}
                              
                              set code [catch " PositionerUserTravelLimitsGet $socketID $Name_Axis_Y2 UserMinimumTargetY2 UserMaximumTargetY2"]
                              # ditto for Y2 axis but  with  minimum target position
                              if {$code != 0} { DisplayErrorAndClose  $socketID  $code  "PositionerUserTravelLimitsGet" }
                              set code [catch " GroupPositionCurrentGet $socketID $Name_Axis_Y2 CurrentPosition"]
                              if {$code != 0} { DisplayErrorAndClose  $socketID  $code  "GroupPositionCurrentGet" }
                              set CurrentPosition [expr $CurrentPosition-$Delta]
                              set code [catch " PositionerUserTravelLimitsSet $socketID $Name_Axis_Y2 $CurrentPosition  $UserMaximumTargetY2 "]
                              if {$code != 0} { DisplayErrorAndClose  $socketID  $code  "PositionerUserTravelLimitsSet" }
                              if { $Debug==1 }  {puts " Y2  Software limits :  Min $UserMinimumTargetY2  ,  Max  $UserMaximumTargetY2   Current Position : $CurrentPosition  Current -> Min"}
                              
                              set code [catch " PositionerUserTravelLimitsGet $socketID $Name_Axis_Y3 UserMinimumTargetY3 UserMaximumTargetY3"]
                              # ditto for Y3 axis  with miaximum target position
                              if {$code != 0} { DisplayErrorAndClose  $socketID  $code  "PositionerUserTravelLimitsGet" }
                              set code [catch " GroupPositionCurrentGet $socketID $Name_Axis_Y3 CurrentPosition"]
                              if {$code != 0} { DisplayErrorAndClose  $socketID  $code  "GroupPositionCurrentGet" }
                              set CurrentPositionP [expr $CurrentPosition+$Delta]
                              
                              set CurrentPositionM [expr $CurrentPosition-$Delta]
                              
                              set code [catch " PositionerUserTravelLimitsSet $socketID $Name_Axis_Y3 $CurrentPositionM $CurrentPositionP"]
                              if {$code != 0} { DisplayErrorAndClose  $socketID  $code  "PositionerUserTravelLimitsSet" }
                              if { $Debug==1 }  {puts " Y3  Software limits :  Min $UserMinimumTargetY3  ,  Max  $UserMaximumTargetY3   Current Position : $CurrentPosition  $CurrentPositionM-> Min $CurrentPositionP->Max"}
                              }  \
                        else \
                              { #  S1Uswitch has moved to 0
                              set code [catch " PositionerUserTravelLimitsSet $socketID $Name_Axis_Y1 $UserMinimumTargetY1 $UserMaximumTargetY1"]
                              if {$code != 0} { DisplayErrorAndClose  $socketID  $code  "PositionerUserTravelLimitsSet" }
                              if { $Debug==1 }  {puts " Y1 Software limits :  Min $UserMinimumTargetY1  ,  Max  $UserMaximumTargetY1 "}
                              
                              set code [catch " PositionerUserTravelLimitsSet $socketID $Name_Axis_Y2 $UserMinimumTargetY2 $UserMaximumTargetY2"]
                              if {$code != 0} { DisplayErrorAndClose  $socketID  $code  "PositionerUserTravelLimitsSet" }
                              if { $Debug==1 }  {puts " Y2 Software limits :  Min $UserMinimumTargetY2  ,  Max  $UserMaximumTargetY2 "}
                              
                              set code [catch " PositionerUserTravelLimitsSet $socketID $Name_Axis_Y3 $UserMinimumTargetY3 $UserMaximumTargetY3"]
                              if {$code != 0} { DisplayErrorAndClose  $socketID  $code  "PositionerUserTravelLimitsSet" }
                              if { $Debug==1 }  {puts " Y3 Software limits :  Min $UserMinimumTargetY3  ,  Max  $UserMaximumTargetY3 "}
                              }
                        }
                  }
            if {$Input_S1D !=$Old_Input_S1D   }\
                  { # S11DU "plus " input is changed
                  if   { $Debug == 1}  { puts "  S1D  $Input_S1D" }
                  set  Old_Input_S1D $Input_S1D
                  if {[string  first  $Axis_Y2 $Name_Axis_Y2] >0  }\
                        {
                        if {$Input_S1D != 0 }\
                              {
                              Stop $socketID $Group_Y1
                              Stop $socketID $Group_Y2
                              Stop $socketID $Group_Y3
                              set code [catch " PositionerUserTravelLimitsGet $socketID $Name_Axis_Y2 UserMinimumTargetY2 UserMaximumTargetY2"]
                              if {$code != 0} { DisplayErrorAndClose  $socketID  $code  "PositionerUserTravelLimitsGet" }
                              set code [catch " GroupPositionCurrentGet $socketID $Name_Axis_Y2 CurrentPosition"]
                              if {$code != 0} { DisplayErrorAndClose  $socketID  $code  "GroupPositionCurrentGet" }
                              set CurrentPosition [expr $CurrentPosition+$Delta]
                              set code [catch " PositionerUserTravelLimitsSet $socketID $Name_Axis_Y2 $UserMinimumTargetY2 $CurrentPosition"]
                              if {$code != 0} { DisplayErrorAndClose  $socketID  $code  "PositionerUserTravelLimitsSet" }
                              if { $Debug==1 }  {puts " Y2 Software limits :  Min $UserMinimumTargetY2  ,  Max  $UserMaximumTargetY2   Current Position : $CurrentPosition  Current -> Max  "}
                              
                              set code [catch " PositionerUserTravelLimitsGet $socketID $Name_Axis_Y1 UserMinimumTargetY1 UserMaximumTargetY1"]
                              if {$code != 0} { DisplayErrorAndClose  $socketID  $code  "PositionerUserTravelLimitsGet" }
                              set code [catch " GroupPositionCurrentGet $socketID $Name_Axis_Y1 CurrentPosition"]
                              if {$code != 0} { DisplayErrorAndClose  $socketID  $code  "GroupPositionCurrentGet" }
                              set CurrentPosition [expr $CurrentPosition-$Delta]
                              set code [catch " PositionerUserTravelLimitsSet $socketID $Name_Axis_Y1 $CurrentPosition  $UserMaximumTargetY1 "]
                              if {$code != 0} { DisplayErrorAndClose  $socketID  $code  "PositionerUserTravelLimitsSet" }
                              if { $Debug==1 }  {puts " Y1  Software limits :  Min $UserMinimumTargetY1  ,  Max  $UserMaximumTargetY1   Current Position : $CurrentPosition  Current -> Min"}
                              
                              set code [catch " PositionerUserTravelLimitsGet $socketID $Name_Axis_Y3 UserMinimumTargetY3 UserMaximumTargetY3"]
                              if {$code != 0} { DisplayErrorAndClose  $socketID  $code  "PositionerUserTravelLimitsGet" }
                              set code [catch " GroupPositionCurrentGet $socketID $Name_Axis_Y3 CurrentPosition"]
                              if {$code != 0} { DisplayErrorAndClose  $socketID  $code  "GroupPositionCurrentGet" }
                              set CurrentPositionP [expr $CurrentPosition+$Delta]
                              
                              set CurrentPositionM [expr $CurrentPosition-$Delta]
                              
                              set code [catch " PositionerUserTravelLimitsSet $socketID $Name_Axis_Y3 $CurrentPositionM $CurrentPositionP"]
                              if {$code != 0} { DisplayErrorAndClose  $socketID  $code  "PositionerUserTravelLimitsSet" }
                              if { $Debug==1 }  {puts " Y3  Software limits :  Min $UserMinimumTargetY3  ,  Max  $UserMaximumTargetY3   Current Position : $CurrentPosition  $CurrentPositionM-> Min $CurrentPositionP->Max"}
                              
                              }  \
                        else \
                              {
                              set code [catch " PositionerUserTravelLimitsSet $socketID $Name_Axis_Y1 $UserMinimumTargetY1 $UserMaximumTargetY1"]
                              if {$code != 0} { DisplayErrorAndClose  $socketID  $code  "PositionerUserTravelLimitsSet" }
                              if { $Debug==1 }  {puts " Y1 Software limits :  Min $UserMinimumTargetY1  ,  Max  $UserMaximumTargetY1 "}
                              
                              set code [catch " PositionerUserTravelLimitsSet $socketID $Name_Axis_Y2 $UserMinimumTargetY2 $UserMaximumTargetY2"]
                              if {$code != 0} { DisplayErrorAndClose  $socketID  $code  "PositionerUserTravelLimitsSet" }
                              if { $Debug==1 }  {puts " Y2 Software limits :  Min $UserMinimumTargetY2  ,  Max  $UserMaximumTargetY2 "}
                              
                              set code [catch " PositionerUserTravelLimitsSet $socketID $Name_Axis_Y3 $UserMinimumTargetY3 $UserMaximumTargetY3"]
                              if {$code != 0} { DisplayErrorAndClose  $socketID  $code  "PositionerUserTravelLimitsSet" }
                              if { $Debug==1 }  {puts " Y3 Software limits :  Min $UserMinimumTargetY3  ,  Max  $UserMaximumTargetY3 "}
                              }
                        }
                  }
            if {$Input_S3U !=$Old_Input_S3U   }\
                  {
                  if   { $Debug == 1}  { puts "  S3U  $Input_S3U" }
                  set  Old_Input_S3U $Input_S3U
                  if {[string  first  $Axis_Y3 $Name_Axis_Y3] >0  }\
                        {
                        if {$Input_S3U != 0 }\
                              {
                              Stop $socketID $Group_Y1
                              Stop $socketID $Group_Y2
                              Stop $socketID $Group_Y3
                              set code [catch " PositionerUserTravelLimitsGet $socketID $Name_Axis_Y3 UserMinimumTargetY3 UserMaximumTargetY3"]
                              if {$code != 0} { DisplayErrorAndClose  $socketID  $code  "PositionerUserTravelLimitsGet" }
                              set code [catch " GroupPositionCurrentGet $socketID $Name_Axis_Y3 CurrentPosition"]
                              if {$code != 0} { DisplayErrorAndClose  $socketID  $code  "GroupPositionCurrentGet" }
                              set CurrentPosition [expr $CurrentPosition+$Delta]
                              set code [catch " PositionerUserTravelLimitsSet $socketID $Name_Axis_Y3 $UserMinimumTargetY3 $CurrentPosition"]
                              if {$code != 0} { DisplayErrorAndClose  $socketID  $code  "PositionerUserTravelLimitsSet" }
                              if { $Debug==1 }  {puts " Y3 Software limits :  Min $UserMinimumTargetY3  ,  Max  $UserMaximumTargetY3   Current Position : $CurrentPosition  Current -> Max  "}
                              
                              set code [catch " PositionerUserTravelLimitsGet $socketID $Name_Axis_Y1 UserMinimumTargetY1 UserMaximumTargetY1"]
                              if {$code != 0} { DisplayErrorAndClose  $socketID  $code  "PositionerUserTravelLimitsGet" }
                              set code [catch " GroupPositionCurrentGet $socketID $Name_Axis_Y1 CurrentPosition"]
                              if {$code != 0} { DisplayErrorAndClose  $socketID  $code  "GroupPositionCurrentGet" }
                              set CurrentPosition [expr $CurrentPosition-$Delta]
                              set code [catch " PositionerUserTravelLimitsSet $socketID $Name_Axis_Y1 $CurrentPosition  $UserMaximumTargetY1 "]
                              if {$code != 0} { DisplayErrorAndClose  $socketID  $code  "PositionerUserTravelLimitsSet" }
                              if { $Debug==1 }  {puts " Y1  Software limits :  Min $UserMinimumTargetY1  ,  Max  $UserMaximumTargetY1   Current Position : $CurrentPosition  Current -> Min"}
                              
                              set code [catch " PositionerUserTravelLimitsGet $socketID $Name_Axis_Y2 UserMinimumTargetY2 UserMaximumTargetY2"]
                              if {$code != 0} { DisplayErrorAndClose  $socketID  $code  "PositionerUserTravelLimitsGet" }
                              set code [catch " GroupPositionCurrentGet $socketID $Name_Axis_Y2 CurrentPosition"]
                              if {$code != 0} { DisplayErrorAndClose  $socketID  $code  "GroupPositionCurrentGet" }
                              set CurrentPosition [expr $CurrentPosition-$Delta]
                              set code [catch " PositionerUserTravelLimitsSet $socketID $Name_Axis_Y2 $CurrentPosition  $UserMaximumTargetY2 "]
                              if {$code != 0} { DisplayErrorAndClose  $socketID  $code  "PositionerUserTravelLimitsSet" }
                              if { $Debug==1 }  {puts " Y2  Software limits :  Min $UserMinimumTargetY2  ,  Max  $UserMaximumTargetY2   Current Position : $CurrentPosition  Current -> Min"}
                              }  \
                        else \
                              {
                              set code [catch " PositionerUserTravelLimitsSet $socketID $Name_Axis_Y1 $UserMinimumTargetY1 $UserMaximumTargetY1"]
                              if {$code != 0} { DisplayErrorAndClose  $socketID  $code  "PositionerUserTravelLimitsSet" }
                              if { $Debug==1 }  {puts " Y1 Software limits :  Min $UserMinimumTargetY1  ,  Max  $UserMaximumTargetY1 "}
                              
                              set code [catch " PositionerUserTravelLimitsSet $socketID $Name_Axis_Y2 $UserMinimumTargetY2 $UserMaximumTargetY2"]
                              if {$code != 0} { DisplayErrorAndClose  $socketID  $code  "PositionerUserTravelLimitsSet" }
                              if { $Debug==1 }  {puts " Y2 Software limits :  Min $UserMinimumTargetY2  ,  Max  $UserMaximumTargetY2 "}
                              
                              set code [catch " PositionerUserTravelLimitsSet $socketID $Name_Axis_Y3 $UserMinimumTargetY3 $UserMaximumTargetY3"]
                              if {$code != 0} { DisplayErrorAndClose  $socketID  $code  "PositionerUserTravelLimitsSet" }
                              if { $Debug==1 }  {puts " Y3 Software limits :  Min $UserMinimumTargetY3  ,  Max  $UserMaximumTargetY3 "}
                              }
                        }
                  }
            if {$Input_S3D !=$Old_Input_S3D   }\
                  {
                  if   { $Debug == 1}  { puts "  S3D  $Input_S3D" }
                  set  Old_Input_S3D $Input_S3D
                  if {[string  first  $Axis_Y3 $Name_Axis_Y3] >0  }\
                        {
                        if {$Input_S3D != 0 }\
                              {
                              Stop $socketID $Group_Y1
                              Stop $socketID $Group_Y2
                              Stop $socketID $Group_Y3
                              set code [catch " PositionerUserTravelLimitsGet $socketID $Name_Axis_Y3  UserMinimumTargetY3  UserMaximumTargetY3"]
                              if {$code != 0} { DisplayErrorAndClose  $socketID  $code  "PositionerUserTravelLimitsGet" }
                              set code [catch " GroupPositionCurrentGet $socketID $Name_Axis_Y3 CurrentPosition"]
                              if {$code != 0} { DisplayErrorAndClose  $socketID  $code  "GroupPositionCurrentGet" }
                              set CurrentPosition [expr $CurrentPosition-$Delta]
                              set code [catch " PositionerUserTravelLimitsSet $socketID $Name_Axis_Y3 $CurrentPosition  $UserMaximumTargetY3"]
                              if {$code != 0} { DisplayErrorAndClose  $socketID  $code  "PositionerUserTravelLimitsSet" }
                              if { $Debug==1 }  {puts " Y3 Software limits :  Min $UserMinimumTargetY3  ,  Max  $UserMaximumTargetY3   Current Position : $CurrentPosition  Current -> Min  "}
                              
                              set code [catch " PositionerUserTravelLimitsGet $socketID $Name_Axis_Y1 UserMinimumTargetY1 UserMaximumTargetY1"]
                              if {$code != 0} { DisplayErrorAndClose  $socketID  $code  "PositionerUserTravelLimitsGet" }
                              set code [catch " GroupPositionCurrentGet $socketID $Name_Axis_Y1 CurrentPosition"]
                              if {$code != 0} { DisplayErrorAndClose  $socketID  $code  "GroupPositionCurrentGet" }
                              set CurrentPosition [expr $CurrentPosition+$Delta]
                              set code [catch " PositionerUserTravelLimitsSet $socketID $Name_Axis_Y1 $UserMinimumTargetY1 $CurrentPosition "]
                              if {$code != 0} { DisplayErrorAndClose  $socketID  $code  "PositionerUserTravelLimitsSet" }
                              if { $Debug==1 }  {puts " Y1  Software limits :  Min $UserMinimumTargetY1  ,  Max  $UserMaximumTargetY1   Current Position : $CurrentPosition  Current -> Max"}
                              
                              set code [catch " PositionerUserTravelLimitsGet $socketID $Name_Axis_Y2 UserMinimumTargetY2 UserMaximumTargetY2"]
                              if {$code != 0} { DisplayErrorAndClose  $socketID  $code  "PositionerUserTravelLimitsGet" }
                              set code [catch " GroupPositionCurrentGet $socketID $Name_Axis_Y2 CurrentPosition"]
                              if {$code != 0} { DisplayErrorAndClose  $socketID  $code  "GroupPositionCurrentGet" }
                              set CurrentPosition [expr $CurrentPosition+$Delta]
                              set code [catch " PositionerUserTravelLimitsSet $socketID $Name_Axis_Y2  $UserMinimumTargetY2 $CurrentPosition "]
                              if {$code != 0} { DisplayErrorAndClose  $socketID  $code  "PositionerUserTravelLimitsSet" }
                              if { $Debug==1 }  {puts " Y2  Software limits :  Min $UserMinimumTargetY2  ,  Max  $UserMaximumTargetY2   Current Position : $CurrentPosition  Current -> Max"}
                              }  \
                        else \
                              {
                              set code [catch " PositionerUserTravelLimitsSet $socketID $Name_Axis_Y1 $UserMinimumTargetY1 $UserMaximumTargetY1"]
                              if {$code != 0} { DisplayErrorAndClose  $socketID  $code  "PositionerUserTravelLimitsSet" }
                              if { $Debug==1 }  {puts " Y1 Software limits :  Min $UserMinimumTargetY1  ,  Max  $UserMaximumTargetY1 "}
                              
                              set code [catch " PositionerUserTravelLimitsSet $socketID $Name_Axis_Y2 $UserMinimumTargetY2 $UserMaximumTargetY2"]
                              if {$code != 0} { DisplayErrorAndClose  $socketID  $code  "PositionerUserTravelLimitsSet" }
                              if { $Debug==1 }  {puts " Y2 Software limits :  Min $UserMinimumTargetY2  ,  Max  $UserMaximumTargetY2 "}
                              
                              set code [catch " PositionerUserTravelLimitsSet $socketID $Name_Axis_Y3 $UserMinimumTargetY3 $UserMaximumTargetY3"]
                              if {$code != 0} { DisplayErrorAndClose  $socketID  $code  "PositionerUserTravelLimitsSet" }
                              if { $Debug==1 }  {puts " Y3 Software limits :  Min $UserMinimumTargetY3  ,  Max  $UserMaximumTargetY3 "}
                              }
                        }
                  }
            }
      TCP_CloseSocket $socketID
      }

