; This is an IDL program which builds auto_positions.req and auto_settings.req

prefix = '13LAB2:'

;scalers         = ['scaler1']
;current_preamps = ['A1']
;icb_amps        = ['amp1']
;icb_dsps        = ['dsp1']
;icb_adcs        = ['adc1']
;icb_hvps        = ['hvps1']
;icb_tcas        = ['tca1']
dmms            = ['DMM1']
;mpcs            = ['ip1:', 'ip2:']
;mpc_tsps        = ['tsp1:']
;mcas            = ['aim_adc1', 'aim_adc2']
;tables          = ['MON:t1']
;smart           = ['smart1']

create_autosavefiles, prefix          = prefix,          $
                      nmotors         = 8,               $
;                     npseudomotors   = 4,               $
                      nscans          = 4,               $
                      scalers         = scalers,         $
                      current_preamps = current_preamps, $
                      dmms            = dmms,            $
                      icb_amps        = icb_amps,        $
                      icb_dsps        = icb_dsps,        $
                      icb_adcs        = icb_adcs,        $
                      icb_hvps        = icb_hvps,        $
                      icb_tcas        = icb_tcas,        $
                      mcas            = mcas,            $
                      mpcs            = mpcs,            $
                      mpc_tsps        = mpc_tsps,        $
                      smart           = smart,           $
                      tables          = tables

end
