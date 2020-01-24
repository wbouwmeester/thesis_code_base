function [element_loc, element_norm, A] = sphere_HEALPix(R, arclength, theta_max)
%SPHERE_HEALPIX Generate a spherical array with elements spaced along a
%HEALPix grid
%   [element_loc, element_norm] = sphere_HEALPix(R, arclength, theta_max)
%   generates a spherical array according to a HEALPix grid. The nSide
%   parameter of the HEALPix grid is calculated so that the resulting
%   spacing between the elements is closest to the specified arclength. The
%   sphere has a radius R. The theta_max parameter specifies the maximum 
%   angle of theta upto which the points are generated. For example, 
%   specifying pi/2 will generate a half sphere an pi will generate a full
%   sphere.
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
%   Date: 2019-07-21

% Calculate number of rings latitude rings
theta_ring_spacing = arclength./sqrt(2);
N_rings = pi*R/theta_ring_spacing;

% Find closest value of N_side
N_side = ((N_rings+1)/4);
N_side_possible = [2^(floor(log2(N_side))) 2^(ceil(log2(N_side)))];
[err, i]= min([abs(N_side-N_side_possible(1)) abs(N_side-N_side_possible(2))]);
N_side = N_side_possible(i);

% Generate element locations
[element_loc(1,:), element_loc(2,:), element_loc(3,:)] = pix2vec(N_side);
element_loc = element_loc*R;

% Remove all elements below theta_max
z_min = R*cos(theta_max);
element_loc = element_loc(:, element_loc(3,:)>=z_min);

% Setup element normals
element_norm = element_loc./vecnorm(element_loc);

% Calculate area
A = 2*pi*R^2*(1-cos(theta_max));
end

