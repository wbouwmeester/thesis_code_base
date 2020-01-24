-- Initialise project
app = pf.GetApplication()
app:NewProject()
--app:OpenFile([[array_30_global\feko\array_30_global.fek]])
app:OpenFile([[H:\My Documents\thesis\array\FEKO output\array_30_side_all\1G3\feko\array_30_side_2_1G3.fek]])

-- Number of elements
N_elements = 39

for i = 1,N_elements,1 do
    -- Select data object
    data = app.Models[1].Configurations[i].FarFields[1]:GetDataSet()
    
    -- Export the data object
    export_data = data:StoreData(pf.Enums.StoredDataTypeEnum.FarField)    
    export_data:ExportData([[H:\My Documents\thesis\array\FEKO output\array_30_side_all\1G3\]]..i..[[.ffe]], pf.Enums.FarFieldsExportTypeEnum.Directivity, 2)
end
