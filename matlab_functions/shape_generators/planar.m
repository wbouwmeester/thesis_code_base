function [element_loc, element_norm, A] = planar(Nx, Ny, Lx, Ly)
%PLANAR Generate planar array
%   [element_loc, element_norm] = PLANAR(Nx, Ny, Lx, Ly) generates a planar
%   array of length Lx along the x-axis and Ly along the y-axis with Nx
%   elements in the x-direction and Ny in the y-direction.
%
%   element_loc is a 3xN array where N is the number of
%   points and the first, second and third row represent the x, y and z
%   coordinates respectively.
%  
%   element_norm is the same format as element_loc, except for the fact
%   that it contains the normal vector for each element corresponding to 
%   the element in element_loc.
%
%   Written by Wietse Bouwmeester
%   Date: 2019-05-28 

[x, y] = meshgrid(linspace(-Lx/2, Lx/2, Nx), linspace(-Ly/2, Ly/2, Ny));

% Reshape to element_loc format
N_elements = numel(x);
element_loc = [reshape(x, [1, N_elements]); reshape(y, [1, N_elements]); zeros(1, N_elements)];

% Element normals
element_norm = [zeros(1, N_elements); zeros(1, N_elements); ones(1, N_elements)];

% Area
A = Lx*Ly;
end

