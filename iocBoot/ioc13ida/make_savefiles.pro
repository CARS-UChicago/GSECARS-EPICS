; This is an IDL program which builds auto_positions.req and auto_settings.req

prefix = '13IDA:'
dmms   = ['DMM1','DMM2']
;tables = ['MON:t1', 'HMIR:t1', 'VMIR:t1']
; tables = ['MON:t1', 'HMIR:t1']
tables = ['HMIR:t1']
feedback = ['mono_pid1']
piezos   = ['DAC1_1','DAC1_2','DAC1_3']
mpcs            = ['ip2:', 'ip6:', 'ip7:']
mpc_tsps        = ['tsp1:']
user_transform = ['mono_pid1_incalc']

create_autosavefiles, prefix          = prefix,          $
                      nmotors         = 33,              $
                      npseudomotors   = 10,               $
                      nscans          = 4,               $
                      scalers         = scalers,         $
                      current_preamps = current_preamps, $
                      icb_amps        = icb_amps,        $
                      icb_adcs        = icb_adcs,        $
                      dmms            = dmms,            $
                      feedback        = feedback,        $
                      tables          = tables,          $
                      mcas            = mcas,            $
                      piezos          = piezos,          $
                      mpcs            = mpcs,            $
                      mpc_tsps        = mpc_tsps,        $
                      user_transform  = user_transform,  $ 
                      energy          = 'E'

end
