function [element_loc, element_norm, A] = sphere_arclength(R, arclength, theta_max)
%SPHERE_ARCLENGTH Generate a spherical array with elements spaced a
%constant arclength from each other
%   [element_loc, element_norm] = SPHERE_ARCLENGTH(R, arclength, theta_max) 
%   Generates a spherical array of radius R with the elements spaced a 
%   constant arclength, specified by the arclength parameter, from each 
%   other along theta and phi. The theta_max parameter specifies the 
%   maximum angle of theta upto which the points are generated. For 
%   example, specifying pi/2 will generate a half sphere an pi will 
%   generate a full sphere.
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
%   Date: 2019-05-27

% Calculate number of circles
arclength_theta = pi.*R.*theta_max./pi;
N_c = round(arclength_theta./arclength)+1;

theta = 0:theta_max/(N_c-1):theta_max;

% Calculate circle radius for every theta
R_c = R*sin(theta);

% Calculate how many points will fit on each circle
N_points_on_c = round(2*pi*R_c./arclength);

% Also place point on the top of the sphere
N_points_on_c(1) = 1;

% Calculate phi step for every circle
phi_step = 2*pi./N_points_on_c;

% Generate points phi and theta
theta_s = []; phi_s = [];
for i = 1:numel(theta)
    theta_s = [theta_s theta(i).*ones(1,N_points_on_c(i))];
    phi_s = [phi_s (0:N_points_on_c(i)-1).*phi_step(i)]; 
end

x = R.*sin(theta_s).*cos(phi_s);
y = R.*sin(theta_s).*sin(phi_s);
z = R.*cos(theta_s);

x_norm = x./R; 
y_norm = y./R; 
z_norm = z./R;

element_loc = [x; y; z];
element_norm = [x_norm; y_norm; z_norm];

% Calculate area
A = 2*pi*R^2*(1-cos(theta_max));
end

