; This is an IDL program which builds auto_positions.req and auto_settings.req

prefix = '13BMA:'
dmms   = ['DMM1','DMM2']
;tables = ['MON:t1','VMIR:t1']
tables = ['MON:t1']
feedback = ['mono_pid1']
dacs = ['DAC1']
mpcs       = ['ip8:', 'ip9:']
mpc_tsps   = ['tsp1:']

create_autosavefiles, prefix          = prefix,          $
                      nmotors         = 25,              $
                      npseudomotors   = 6,               $
                      nscans          = 4,               $
                      scalers         = scalers,         $
                      current_preamps = current_preamps, $
                      icb_amps        = icb_amps,        $
                      icb_adcs        = icb_adcs,        $
                      dmms            = dmms,            $
                      feedback        = feedback,        $
                      tables          = tables,          $
                      mcas            = mcas,            $
                      dacs            = dacs,            $
                      mpcs            = mpcs,            $
                      mpc_tsps        = mpc_tsps,        $
                      energy          = 'E'

end

