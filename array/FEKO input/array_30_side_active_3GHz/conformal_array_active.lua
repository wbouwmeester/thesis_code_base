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
beta = {{-2579.617557, -2732.615519, -3417.789430, -2790.000000, -3572.782643, -2732.615519, -3572.782643, -2579.617557, -3417.789430, -4229.041674, -4330.655710, -4229.041674, -1806.982179, -1888.926950, -1888.926950, -1806.982179, -861.330289, -882.026053, -861.330289}, {-2060.527750, -2375.278482, -2965.368086, -2621.742412, -3305.342784, -2760.358794, -3510.841109, -2787.567415, -3555.118491, -3870.049853, -4173.474122, -4281.046503, -1354.560835, -1621.487092, -1826.985417, -1944.311240, -502.338468, -724.844465, -913.335118}, {-1292.907887, -1731.447805, -2252.423151, -2137.263996, -2740.778728, -2455.162061, -3126.989248, -2659.295503, -3360.791358, -3247.370751, -3720.887778, -4019.791789, -641.615900, -1056.923036, -1443.133555, -1749.984107, 120.340634, -272.258121, -652.080405}, {-3952.203389, -4186.609866, -4600.199735, -4274.527993, -4808.814031, -4186.609866, -4808.814031, -3952.203389, -4600.199735, -5149.254650, -5272.979264, -5149.254650, -3404.614781, -3559.010537, -3559.010537, -3404.614781, -2649.647662, -2713.312533, -2649.647662}, {-3156.911666, -3639.137764, -3907.050022, -4016.742412, -4399.072396, -4229.115031, -4713.914096, -4270.801056, -4810.600063, -4599.247270, -5032.163100, -5228.930670, -2711.465068, -3149.268902, -3464.110602, -3615.015109, -2099.640282, -2472.496369, -2729.323682}, {-1980.849804, -2652.731939, -2814.755010, -3274.478416, -3534.110080, -3761.526508, -4125.818925, -4074.277085, -4512.873622, -3645.247539, -4338.760591, -4828.665227, -1619.170056, -2284.306586, -2876.015431, -3317.288668, -1145.640551, -1779.093861, -2329.058239}, {-4848.095165, -5135.637276, -5227.758060, -5243.484824, -5464.831476, -5135.637276, -5464.831476, -4848.095165, -5227.758060, -5448.391520, -5579.303697, -5448.391520, -4591.600593, -4799.824927, -4799.824927, -4591.600593, -4118.378422, -4217.333477, -4118.378422}, {-3872.525443, -4464.063323, -4377.484064, -4927.263996, -4962.208953, -5187.777580, -5348.419473, -5238.913059, -5485.852271, -4773.707589, -5283.898941, -5546.128628, -3741.326597, -4297.202404, -4683.412924, -4849.694804, -3443.694491, -3921.928721, -4216.115529}, {-2429.872001, -3254.057451, -3037.585874, -4016.742412, -3901.175599, -4614.195344, -4627.013949, -4997.840720, -5120.636724, -3603.453675, -4433.314844, -5055.130375, -2401.428407, -3236.169050, -3962.007400, -4484.479258, -2273.440577, -3071.344624, -3725.117277}, {-5159.235113, -5465.231037, -5224.771610, -5580.000000, -5461.709593, -5465.231037, -5461.709593, -5159.235113, -5224.771610, -5090.371963, -5212.681763, -5090.371963, -5224.771610, -5461.709593, -5461.709593, -5224.771610, -5090.371963, -5212.681763, -5090.371963}, {-4121.055500, -4750.556964, -4319.928922, -5243.484824, -4926.829877, -5520.717589, -5337.826527, -5575.134829, -5499.429732, -4372.388321, -4898.318587, -5194.381621, -4319.928922, -4926.829877, -5337.826527, -5499.429732, -4372.388321, -4898.318587, -5194.381621}, {-2585.815773, -3462.895610, -2894.039051, -4274.527993, -3797.701765, -4910.324123, -4570.122803, -5318.591005, -5110.775465, -3127.030117, -3993.145898, -4671.872194, -2894.039051, -3797.701765, -4570.122803, -5110.775465, -3127.030117, -3993.145898, -4671.872194}}

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
frequency = 3e9
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
