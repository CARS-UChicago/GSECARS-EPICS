; This is an IDL program which builds auto_positions.req and auto_settings.req

prefix = '13IDC:'

scalers         = ['scaler1']
current_preamps = ['A1', 'A2','A3','A4']
icb_amps        = ['amp1']
icb_adcs        = ['adc1']
icb_hvps        = ['hvps1']
mcas            = ['aim_adc1', 'aim_mcs1']
mcas            = [mcas, 'mip330_1', 'mip330_2', 'mip330_3', 'mip330_4']
dmms            = ['DMM1']
tables          = ['XAS:t1', 'DIF:t1']
smart           = ['smart1']

create_autosavefiles, prefix          = prefix,          $
                      nmotors         = 64,              $
                      npseudomotors   = 6,               $
                      nscans          = 4,               $
                      scalers         = scalers,         $
                      current_preamps = current_preamps, $
                      icb_amps        = icb_amps,        $
                      icb_adcs        = icb_adcs,        $
                      tables          = tables,          $
                      smart           = smart,           $
                      dmms            = dmms,            $
                      mcas            = mcas

end
