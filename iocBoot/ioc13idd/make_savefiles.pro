; This is an IDL program which builds auto_positions.req and auto_settings.req

prefix = '13IDD:'
tables          = ['DAC:t1']
scalers         = ['scaler1']
current_preamps = ['A1', 'A2','A3']
icb_amps        = ['amp1']
icb_adcs        = ['adc1']
icb_hvps        = ['hvps1']
mcas            = ['aim_adc1', 'aim_mcs1', 'mip330_1', 'mip330_2']
dmms            = ['DMM1','DMM3','DMM4']
feedback        = ['PID1','PID2']
smart           = ['smart1']

create_autosavefiles, prefix          = prefix,          $
                      nmotors         = 64,              $
                      npseudomotors   = 11,              $
                      nscans          = 4,               $
                      tables          = tables,          $
                      scalers         = scalers,         $
                      current_preamps = current_preamps, $
                      icb_amps        = icb_amps,        $
                      icb_adcs        = icb_adcs,        $
                      icb_hvps        = icb_hvps,        $
                      dmms            = dmms,            $
                      mcas            = mcas,            $
                      smart           = smart,           $
                      feedback        = feedback

end
