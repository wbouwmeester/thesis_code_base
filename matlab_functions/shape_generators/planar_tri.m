function [element_loc, element_norm] = planar_tri(Nx, Ny, Lx, Ly)
%PLANAR Generate planar array with a triangular topology
%   [element_loc, element_norm] = PLANAR_TRI(Nx, Ny, Lx, Ly) generates a planar
%   array of length Lx along the x-axis and Ly along the y-axis with Nx
%   elements in the x-direction and Ny in the y-direction, distributed in a
%   triangular/diamond grid.
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
%   Date: 2019-06-20 

[x, y] = meshgrid(linspace(-Lx/2, Lx/2, Nx), linspace(-Ly/2, Ly/2, Ny));

% Shift the uneven rows by halve the distance between the cells
d_shift = Lx/(2*(Nx-1));
[N_rows, ~] = size(x);

for i = 1:2:N_rows
    x(i, :) = x(i, :)+d_shift; 
end

% Reshape to element_loc format
N_elements = numel(x);
element_loc = [reshape(x, [1, N_elements]); reshape(y, [1, N_elements]); zeros(1, N_elements)];

% Element normals
element_norm = [zeros(1, N_elements); zeros(1, N_elements); ones(1, N_elements)];
end

