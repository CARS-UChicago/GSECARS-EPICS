; This is an IDL program which builds auto_positions.req and auto_settings.req

prefix = '13BMD:'
tables          = ['LVP:t1', 'XAS:t1']
scalers         = ['scaler1']
current_preamps = ['A1', 'A2', 'A3']
icb_amps        = ['amp1']
icb_adcs        = ['adc1']
dmms            = ['DMM1','DMM2']
mcas            = ['aim_adc1', 'aim_mcs1']
smart           = ['smart1']

create_autosavefiles, prefix          = prefix,          $
                      nmotors         = 56,              $
                      npseudomotors   = 8,               $
                      nscans          = 4,               $
                      tables          = tables,          $
                      scalers         = scalers,         $
                      current_preamps = current_preamps, $
                      icb_amps        = icb_amps,        $
                      icb_adcs        = icb_adcs,        $
                      dmms            = dmms,            $
                      smart           = smart,           $
                      mcas            = mcas

end
