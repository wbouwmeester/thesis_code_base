function [element_loc, element_norm, A] = cone_arclength(R, H, arclength, z_max)
%CONE_ARCLENGTH Generate a conical array with elements spaced a
%constant arclength from each other
%   [element_loc, element_norm] = CONE_ARCLENGHT(R, H, arclength, z_max)
%   generates a set of points on a cone spaced a constant arclength from
%   eachother. The height of the cone is specified by H and the bottom
%   radius by R. The top of the cone can be cut off by the parameter z_max,
%   which deletes all points above z = z_max.
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
%   Date: 2019-05-29

% Calculate the length of the diagonal and the angle with the z-axis
side_length = sqrt(R.^2+H.^2);
alpha = atan2(R, H);

% Find the number of points in z-direction
N_z = floor(side_length./arclength)+1;
z_points = 0:H/N_z:H;

% Calculate circle radii
R_c = (H-z_points)./H.*R;

% Calculate how many points will fit on each circle
N_points_on_c = floor(2*pi*R_c./arclength)+1;

% Calculate phi step for every circle
phi_step = 2*pi./N_points_on_c;

% Calculate x and y coordinates for every point on the cirle
x = []; y = []; z = [];
x_norm = []; y_norm = []; z_norm = [];
for i = 1:numel(z_points)
    phi = 0:phi_step(i):2*pi;
    
    % Calculate coordinates
    x = [x cos(phi).*R_c(i)];
    y = [y sin(phi).*R_c(i)];
    z = [z z_points(i)*ones(1, numel(phi))];
    
    % Calculate normal vector
    x_norm = [x_norm cos(phi).*cos(alpha)];
    y_norm = [y_norm sin(phi).*cos(alpha)];
    z_norm = [z_norm sin(alpha)*ones(1, numel(phi))];
end

element_loc = [x; y; z];
element_norm = [x_norm; y_norm; z_norm];

% Remove duplicates
[element_loc, i_unique, ~] = unique(element_loc.', 'rows');
element_loc = element_loc.';
element_norm = element_norm(:, i_unique);

% Set normal of the element at x = y = 0 to 1
element_norm(:, element_loc(1,:) == 0 & element_loc(2,:) == 0) = [0; 0; 1];

% Remove all elements above z_max
islower = element_loc(3,:)<=z_max;
element_loc = [element_loc(1,islower); element_loc(2,islower); element_loc(3, islower)];
element_norm = [element_norm(1,islower); element_norm(2,islower); element_norm(3, islower)];

% Calculate area
A = pi*R*sqrt(R^2+H^2);
end

