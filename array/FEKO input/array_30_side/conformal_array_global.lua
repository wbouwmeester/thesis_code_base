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

for i = 2,N_elements,1 do
    -- Create new solution configuration
    project.SolutionConfigurations[1]:Duplicate()
    
    -- Add the source at the active element
    project.SolutionConfigurations[i].Sources:AddVoltageSource(port_array_theta[i])
    project.SolutionConfigurations[i].Sources[1].Impedance = "100"
end

-- Add configuration with all elements active
full_config = project.SolutionConfigurations[1]:Duplicate()
for i = 1,N_elements,1 do
    full_config.Sources:AddVoltageSource(port_array_theta[i])
    full_config.Sources[i].Impedance = "100"
end

-- Finish the first configuration
project.SolutionConfigurations[1].Sources:AddVoltageSource(port_array_theta[1])
project.SolutionConfigurations[1].Sources[1].Impedance = "100"

-- Add S-parameter configurations
s_parameter_config = project.SolutionConfigurations:AddMultiportSParameter({port_array_theta[1].Terminal})
port_properties = s_parameter_config.SParameter.PortProperties

-- Set impedance of the first port correctly and add the phi port
port_properties[1].Impedance = 100
port_properties:Add(port_array_phi[1].Terminal, 100, true)

for i = 2,N_elements,1 do
    port_properties:Add(port_array_theta[i].Terminal, 100, true)
    port_properties:Add(port_array_phi[i].Terminal, 100, true)
end

-- Import the ground plane
import = project.Importer.Geometry:Import([[ground_plane.STEP]])

-- Mesh the project
--wire_radius = 0.0001
--project.Mesher.Settings.WireRadius = wire_radius
--
--project.Mesher:Mesh()
