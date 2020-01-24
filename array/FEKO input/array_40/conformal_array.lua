-- Setup project
app     = cf.GetApplication()
project = app:NewProject()

-- Global variables
origin = cf.Point(0,0,0)

-- Antenna location data

-- Load the antenna element
import = project.Importer.Geometry:Import([[../cloverleaf.STEP]])
N_elements = 45
rot1 = {36.000000, 31.270210, 39.675526, 30.033431, 39.601632, 31.717474, 36.000000, 32.252442, 31.270210, 24.181414, 30.033431, 20.554443, 31.717474, 22.392771, 32.252442, 20.905157, 11.818586, 11.640723, 24.181414, 11.818586, 0.000000, 20.554443, 11.640723, 22.392771, 39.675526, 39.601632, 36.000000, 31.270210, 39.675526, 30.033431, 39.601632, 36.000000, 32.252442, 31.270210, 24.181414, 30.033431, 20.554443, 32.252442, 20.905157, 11.818586, 24.181414, 11.818586, 20.554443, 39.675526, 39.601632}
rot2 = {58.282526, 38.973447, 24.985772, 17.931933, 8.592522, -0.000000, 121.717474, 101.640723, 141.026553, 121.717474, 162.068067, 151.660033, 180.000000, -180.000000, 78.359277, 90.000000, 121.717474, 180.000000, 58.282526, 58.282526, -90.000000, 28.339967, -0.000000, -0.000000, 155.014228, 171.407478, -58.282526, -38.973447, -24.985772, -17.931933, -8.592522, -121.717474, -101.640723, -141.026553, -121.717474, -162.068067, -151.660033, -78.359277, -90.000000, -121.717474, -58.282526, -58.282526, -28.339967, -155.014228, -171.407478}
posx = {0.478976, 0.625500, 0.896968, 0.738098, 0.976951, 0.814883, -0.478976, -0.166899, -0.625500, -0.333798, -0.738098, -0.478976, -0.814883, -0.590478, 0.166899, 0.000000, -0.166899, -0.312750, 0.333798, 0.166899, 0.000000, 0.478976, 0.312750, 0.590478, -0.896968, -0.976951, 0.478976, 0.625500, 0.896968, 0.738098, 0.976951, -0.478976, -0.166899, -0.625500, -0.333798, -0.738098, -0.478976, 0.166899, 0.000000, -0.166899, 0.333798, 0.166899, 0.478976, -0.896968, -0.976951}
posy = {0.775000, 0.506040, 0.417992, 0.238853, 0.147620, -0.000000, 0.775000, 0.810145, 0.506040, 0.540097, 0.238853, 0.258333, 0.000000, -0.000000, 0.810145, 0.553074, 0.270048, 0.000000, 0.540097, 0.270048, -0.000000, 0.258333, -0.000000, -0.000000, 0.417992, 0.147620, -0.775000, -0.506040, -0.417992, -0.238853, -0.147620, -0.775000, -0.810145, -0.506040, -0.540097, -0.238853, -0.258333, -0.810145, -0.553074, -0.270048, -0.540097, -0.270048, -0.258333, -0.417992, -0.147620}
posz = {1.253976, 1.324830, 1.192992, 1.341887, 1.194267, 1.318509, 1.253976, 1.310843, 1.324830, 1.413992, 1.341887, 1.451325, 1.318509, 1.433121, 1.310843, 1.447967, 1.517142, 1.518120, 1.413992, 1.517142, 1.550000, 1.451325, 1.518120, 1.433121, 1.192992, 1.194267, 1.253976, 1.324830, 1.192992, 1.341887, 1.194267, 1.253976, 1.310843, 1.324830, 1.413992, 1.341887, 1.451325, 1.310843, 1.447967, 1.517142, 1.413992, 1.517142, 1.451325, 1.192992, 1.194267}

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

-- Set loads and sources per configuration
project.SolutionConfigurations:SetSourcesPerConfiguration()
project.SolutionConfigurations:SetLoadsPerConfiguration()

-- Define loads
for i = 1,N_elements,1 do
    project.SolutionConfigurations[1].Loads:AddComplex(port_array_theta[i], "100", "0")
    project.SolutionConfigurations[1].Loads:AddComplex(port_array_phi[i], "100", "0")
end

-- Add the far field request to the solution configuration
project.SolutionConfigurations[1].FarFields:Add3DPattern()

for i = 2,N_elements,1 do
    -- Duplicate the solution configuration for every element
    project.SolutionConfigurations[1]:Duplicate()
    
    -- Delete the load at the active element
    project.SolutionConfigurations[i].Loads[2*i-1]:Delete()
    
    -- Add the source at the active element
    project.SolutionConfigurations[i].Sources:AddVoltageSource(port_array_theta[i])
    project.SolutionConfigurations[i].Sources[1].Impedance = "100"
end

-- Finish the first configuration
project.SolutionConfigurations[1].Loads[1]:Delete()
project.SolutionConfigurations[1].Sources:AddVoltageSource(port_array_theta[1])
project.SolutionConfigurations[1].Sources[1].Impedance = "100"

-- Import the ground plane
import = project.Importer.Geometry:Import([[ground_plane.STEP]])

-- Mesh the project
wire_radius = 0.0001
project.Mesher.Settings.WireRadius = wire_radius

project.Mesher:Mesh()
