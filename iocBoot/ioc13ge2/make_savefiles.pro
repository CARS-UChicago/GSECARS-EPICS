; This is an IDL program which builds auto_positions.req and auto_settings.req

prefix = '13GE2:'
scalers = ['scaler1']
dxps = ['med:dxp1']
nelems = 16
for i=2,nelems do dxps = [dxps, 'med:dxp'+strtrim(i,2)]
for i=2,nelems do dxps = [dxps, 'med:dxp'+strtrim(i,2)]
;simple_mcas = ['med:mca1']
;for i=2,16 do simple_mcas = [simple_mcas, 'med:mca'+strtrim(i,2)]
;mcas = ['aim_adc1']

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
                      simple_mcas     = simple_mcas,     $
                      dxps            = dxps,            $
                      tables          = tables

end
