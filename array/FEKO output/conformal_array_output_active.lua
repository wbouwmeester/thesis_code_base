-- Initialise project
app = pf.GetApplication()
app:NewProject()
app:OpenFile([[H:\My Documents\thesis\array\FEKO output\array_30_side_active_3GHz\feko\array_30_side_active_3GHz.fek]])

-- Number of elements
N_elements = 19

for i_config, v_config in ipairs(app.Models[1].Configurations) do
    for i_element, v_element in ipairs(v_config.Excitations) do
        v_element:ExportData([[H:\My Documents\thesis\array\FEKO output\array_30_side_active_3GHz\]]..i_config..[[_]]..i_element, pf.Enums.FrequencyUnitEnum.Hz, pf.Enums.NetworkParameterTypeEnum.Scattering, pf.Enums.NetworkParameterFormatEnum.MA, 100, 2) 
    end   
end
