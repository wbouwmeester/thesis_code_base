function [element_loc, element_norm] = sphere_cartesian(R, Nx, Ny)
%SPHERE_CARTESIAN Generates a sphere with cartesian x and y points
%   [element_loc, element_norm] = SPHERICAL_CARTESIAN(R, Nx, Ny) generates 
%   points on a sphere with radius R that have cartesian x and y 
%   coordinates that are projected on a sphere. The cartesian grid is made 
%   up out of Nx points between x = -R and x = R and Ny points between y = 
%   -R and y = R.
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

% Setup grid
[x, y] = meshgrid(linspace(-R, R, Nx), linspace(-R, R, Ny));

% Calculate corresponding z coordinates
z = sqrt(R^2-x.^2-y.^2);

% Reformat to element_loc format
N_elements = numel(x);
element_loc = [reshape(x, [1, N_elements]); reshape(y, [1, N_elements]); reshape(z, [1, N_elements])];

% Remove complex entries
real_list = imag(element_loc(3,:))==0;
element_loc = [element_loc(1,real_list); element_loc(2,real_list); element_loc(3, real_list)];

% Calculate normal vectors
element_norm = [element_loc(1,:)./R; element_loc(2,:)./R; element_loc(3,:)./R];

end

