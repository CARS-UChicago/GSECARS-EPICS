; This is an IDL program which builds auto_positions.req and auto_settings.req

prefix = '13IDC:'

scalers         = ['scaler1','scaler2']
current_preamps = ['A1', 'A2','A3','A4','A5','A6','A7']
icb_amps        = ['amp1']
icb_adcs        = ['adc1']
icb_hvps        = ['hvps1']
mcas            = ['aim_adc1', 'aim_mcs1']
mcas            = [mcas, 'mip330_1', 'mip330_2', 'mip330_3', 'mip330_4']
dmms            = ['DMM1']
tables          = ['XAS:t1', 'DIF:t1']
smart           = ['smart1']
newport_snl     = ['NewTab1:','pm10', 'pm11', 'pm12', 'pm13', 'pm14']
; note for newport snl also need to save :readback for pm's R_X, R_Y, R_Z, T_AX, T_AY


create_autosavefiles, prefix          = prefix,          $
                      nmotors         = 72,              $
                      npseudomotors   = 14,              $
                      nscans          = 4,               $
                      scalers         = scalers,         $
                      current_preamps = current_preamps, $
                      icb_amps        = icb_amps,        $
                      icb_adcs        = icb_adcs,        $
                      tables          = tables,          $
                      smart           = smart,           $
                      dmms            = dmms,            $
                      newport_snl     = newport_snl,     $
                      mcas            = mcas

end




