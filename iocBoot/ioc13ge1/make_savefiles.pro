; This is an IDL program which builds auto_positions.req and auto_settings.req

prefix = '13GE1:'

icb_amps        = strarr(16)
for i=1, 16 do icb_amps[i-1] = 'med:amp'+strtrim(i,2)
icb_adcs        = strarr(4)
for i=1, 4  do icb_adcs[i-1] = 'med:adc'+strtrim(i,2)
icb_hvps        = 'med:hvps1'
simple_mcas = strarr(16)
for i=1, 16 do simple_mcas[i-1] = 'med:mca'+strtrim(i,2)

create_autosavefiles, prefix          = prefix,          $
                      icb_amps        = icb_amps,        $
                      icb_adcs        = icb_adcs,        $
                      icb_hvps        = icb_hvps,        $
                      simple_mcas     = simple_mcas
end
