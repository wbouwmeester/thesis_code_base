function [element_loc, element_norm, A] = sphere_spherical(R, N_theta, N_phi, theta_max)
%SPHERE_SPHERICAL Summary of this function goes here
%   [element_loc, element_norm] = SPHERE_SPHERICAL(R, N_theta, N_phi, theta_max)
%   Generates points on a sphere of radius R that are evenly spaced along 
%   theta and phi. There will be N_theta points for theta between 0 and 
%   theta_max and N_phi points between phi = 0 and phi = 2*pi.
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

% Setup meshgrid
[theta, phi] = meshgrid(0:theta_max/(N_theta-1):theta_max, 0:2*pi/N_phi:2*pi);

x = sin(theta).*cos(phi).*R;
y = sin(theta).*sin(phi).*R;
z = cos(theta).*R;

% Reshape to the correct format for element_loc 
N_elements = numel(x);
element_loc = [reshape(x, [1, N_elements]); reshape(y, [1, N_elements]); reshape(z, [1, N_elements])];

% Remove duplicates
element_loc = unique(element_loc.', 'rows').';

% Calculate element normals
element_norm = [element_loc(1,:)./R; element_loc(2,:)./R; element_loc(3,:)./R];

% Calculate area
A = 2*pi*R^2*(1-cos(theta_max));
end

