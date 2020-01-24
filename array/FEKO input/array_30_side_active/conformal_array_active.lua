-- Setup project
app     = cf.GetApplication()
project = app:NewProject()

-- Global variables
origin = cf.Point(0,0,0)

-- Antenna location data
N_elements = 19
rot1 = {90.000000, 90.000000, 80.405932, 90.000000, 79.966449, 90.000000, 79.966449, 90.000000, 80.405932, 69.607482, 69.094843, 69.607482, 99.594068, 100.033551, 100.033551, 99.594068, 110.392518, 110.905157, 110.392518}
rot2 = {-22.392771, -11.640723, -18.264276, 0.000000, -6.277805, 11.640723, 6.277805, 22.392771, 18.264276, -13.282526, 0.000000, 13.282526, -18.264276, -6.277805, 6.277805, 18.264276, -13.282526, 0.000000, 13.282526}
posx = {1.433121, 1.518120, 1.451325, 1.550000, 1.517142, 1.518120, 1.517142, 1.433121, 1.451325, 1.413992, 1.447967, 1.413992, 1.451325, 1.517142, 1.517142, 1.451325, 1.413992, 1.447967, 1.413992}
posy = {-0.590478, -0.312750, -0.478976, 0.000000, -0.166899, 0.312750, 0.166899, 0.590478, 0.478976, -0.333798, 0.000000, 0.333798, -0.478976, -0.166899, 0.166899, 0.478976, -0.333798, 0.000000, 0.333798}
posz = {0.000000, 0.000000, 0.258333, 0.000000, 0.270048, 0.000000, 0.270048, 0.000000, 0.258333, 0.540097, 0.553074, 0.540097, -0.258333, -0.270048, -0.270048, -0.258333, -0.540097, -0.553074, -0.540097}
beta = {{-1289.808778, -1366.307759, -1708.894715, -1395.000000, -1786.391321, -1366.307759, -1786.391321, -1289.808778, -1708.894715, -2114.520837, -2165.327855, -2114.520837, -903.491090, -944.463475, -944.463475, -903.491090, -430.665145, -441.013026, -430.665145}, {-1030.263875, -1187.639241, -1482.684043, -1310.871206, -1652.671392, -1380.179397, -1755.420555, -1393.783707, -1777.559246, -1935.024926, -2086.737061, -2140.523251, -677.280418, -810.743546, -913.492709, -972.155620, -251.169234, -362.422232, -456.667559}, {-646.453943, -865.723902, -1126.211576, -1068.631998, -1370.389364, -1227.581031, -1563.494624, -1329.647751, -1680.395679, -1623.685375, -1860.443889, -2009.895895, -320.807950, -528.461518, -721.566778, -874.992054, 60.170317, -136.129060, -326.040202}, {-1976.101695, -2093.304933, -2300.099868, -2137.263996, -2404.407015, -2093.304933, -2404.407015, -1976.101695, -2300.099868, -2574.627325, -2636.489632, -2574.627325, -1702.307391, -1779.505268, -1779.505268, -1702.307391, -1324.823831, -1356.656266, -1324.823831}, {-1578.455833, -1819.568882, -1953.525011, -2008.371206, -2199.536198, -2114.557516, -2356.957048, -2135.400528, -2405.300032, -2299.623635, -2516.081550, -2614.465335, -1355.732534, -1574.634451, -1732.055301, -1807.507555, -1049.820141, -1236.248184, -1364.661841}, {-990.424902, -1326.365970, -1407.377505, -1637.239208, -1767.055040, -1880.763254, -2062.909462, -2037.138542, -2256.436811, -1822.623769, -2169.380296, -2414.332614, -809.585028, -1142.153293, -1438.007715, -1658.644334, -572.820275, -889.546930, -1164.529120}, {-2424.047582, -2567.818638, -2613.879030, -2621.742412, -2732.415738, -2567.818638, -2732.415738, -2424.047582, -2613.879030, -2724.195760, -2789.651849, -2724.195760, -2295.800297, -2399.912464, -2399.912464, -2295.800297, -2059.189211, -2108.666739, -2059.189211}, {-1936.262722, -2232.031662, -2188.742032, -2463.631998, -2481.104477, -2593.888790, -2674.209736, -2619.456530, -2742.926135, -2386.853795, -2641.949470, -2773.064314, -1870.663298, -2148.601202, -2341.706462, -2424.847402, -1721.847245, -1960.964360, -2108.057765}, {-1214.936001, -1627.028726, -1518.792937, -2008.371206, -1950.587799, -2307.097672, -2313.506974, -2498.920360, -2560.318362, -1801.726838, -2216.657422, -2527.565188, -1200.714204, -1618.084525, -1981.003700, -2242.239629, -1136.720288, -1535.672312, -1862.558638}, {-2579.617557, -2732.615519, -2612.385805, -2790.000000, -2730.854797, -2732.615519, -2730.854797, -2579.617557, -2612.385805, -2545.185981, -2606.340882, -2545.185981, -2612.385805, -2730.854797, -2730.854797, -2612.385805, -2545.185981, -2606.340882, -2545.185981}, {-2060.527750, -2375.278482, -2159.964461, -2621.742412, -2463.414938, -2760.358794, -2668.913263, -2787.567415, -2749.714866, -2186.194160, -2449.159294, -2597.190810, -2159.964461, -2463.414938, -2668.913263, -2749.714866, -2186.194160, -2449.159294, -2597.190810}, {-1292.907887, -1731.447805, -1447.019526, -2137.263996, -1898.850882, -2455.162061, -2285.061402, -2659.295503, -2555.387733, -1563.515059, -1996.572949, -2335.936097, -1447.019526, -1898.850882, -2285.061402, -2555.387733, -1563.515059, -1996.572949, -2335.936097}}

-- Load the antenna element
import = project.Importer.Geometry:Import([[../cloverleaf.STEP]])

-- Create feed wire
gap = 0.001
feed = project.Geometry:AddLine(cf.Point(-math.sqrt(2)*gap/2,0,0), cf.Point(math.sqrt(2)*gap/2,0,0))

-- Union the feed and the antenna
antenna_theta = project.Geometry:Union({import[1], import[2], feed})
antenna_phi = antenna_theta:CopyAndRotate(origin, cf.Point(0,0,1), 90, 1)

-- -- Create the dummy antenna element geometry a.k.a. a planar dipole
-- length = 0.1
-- gap = 0.001
-- width = 0.01
-- 
-- antenna_upper = project.Geometry:AddRectangle(cf.Point(-length/2, -width/2, 0), length/2-gap/2, width)
-- antenna_lower = project.Geometry:AddRectangle(cf.Point(gap/2, -width/2, 0), length/2-gap/2, width)
-- antenna_feed_theta = project.Geometry:AddLine(cf.Point(-gap/2, 0, 0), cf.Point(gap/2, 0, 0))
-- 
-- antenna = project.Geometry:Union({antenna_upper, antenna_lower, antenna_feed_theta})

-- Create all antenna elements
antenna_array_theta = {}
antenna_array_phi = {}
for i = 1,N_elements,1 do
    -- Rotate the antenna and move it into place
    -- First rotation
    antenna_array_theta[i] = antenna_theta:CopyAndRotate(origin, cf.Point(0,1,0), rot1[i], 1)
    antenna_array_phi[i] = antenna_phi[1]:CopyAndRotate(origin, cf.Point(0,1,0), rot1[i], 1)
    
    -- Second rotation
    antenna_array_theta[i][1].Transforms:AddRotate(origin, cf.Point(0,0,1), rot2[i])
    antenna_array_phi[i][1].Transforms:AddRotate(origin, cf.Point(0,0,1), rot2[i])
    
    -- Translate antenna to position        
    antenna_array_theta[i][1].Transforms:AddTranslate(origin, cf.Point(posx[i],posy[i],posz[i]))
    antenna_array_phi[i][1].Transforms:AddTranslate(origin, cf.Point(posx[i],posy[i],posz[i]))
end

-- Delete imported antenna element
antenna_theta:Delete()
antenna_phi[1]:Delete()

-- Define all the ports
port_array_theta = {}
port_array_phi = {}
for i = 1,N_elements,1 do
    port_array_theta[i] = project.Ports:AddWirePort(antenna_array_theta[i][1].Wires[1])
    port_array_theta[i].Location = "Middle"
    
    port_array_phi[i] = project.Ports:AddWirePort(antenna_array_phi[i][1].Wires[1])
    port_array_phi[i].Location = "Middle"    
end

-- Setup configurations
-- Setup global frequency
frequency = 1.5e9
project.SolutionConfigurations[1].Frequency.Start = frequency

-- Set loads global and sources per configuration
project.SolutionConfigurations:SetSourcesPerConfiguration()
project.SolutionConfigurations:SetLoadsGlobal(project.SolutionConfigurations[1])

-- Define loads
for i = 1,N_elements,1 do
    project.SolutionConfigurations[1].Loads:AddComplex(port_array_theta[i], "100", "0")
    project.SolutionConfigurations[1].Loads:AddComplex(port_array_phi[i], "100", "0")
end

-- Add the far field request to the solution configuration
project.SolutionConfigurations[1].FarFields:Add(0, 0, 180, 360, 0.5, 1)

-- Add configuration with all elements active for every scan angle
for i_angle, v_angle in ipairs(beta) do
    full_config = project.SolutionConfigurations[1]:Duplicate()
    
    for i_element, v_element in ipairs(beta[i_angle]) do   
        full_config.Sources:AddVoltageSource(port_array_theta[i_element])
        full_config.Sources[i_element].Impedance = "100"
        full_config.Sources[i_element].Phase = beta[i_angle][i_element]
    end
end

-- Delete first configuration
project.SolutionConfigurations[1]:Delete()

-- Import the ground plane
import = project.Importer.Geometry:Import([[ground_plane.STEP]])

-- Mesh the project
--wire_radius = 0.0001
--project.Mesher.Settings.WireRadius = wire_radius
--
--project.Mesher:Mesh()
