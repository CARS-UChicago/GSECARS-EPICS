; This is an IDL program which builds auto_positions.req and auto_settings.req

prefix = '13GE2:'
scalers = ['scaler1']
;dxps = ['dxp1']

create_autosavefiles, prefix          = prefix,          $
                      nscans          = 4,               $
                      nmotors         = 16,              $
                      scalers         = scalers,         $
                      current_preamps = current_preamps, $
                      dmms            = dmms,            $
                      icb_amps        = icb_amps,        $
                      icb_adcs        = icb_adcs,        $
                      icb_hvps        = icb_hvps,        $
                      mcas            = mcas,            $
                      dxps            = dxps,            $
                      tables          = tables

end
