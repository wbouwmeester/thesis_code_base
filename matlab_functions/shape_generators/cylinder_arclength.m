function [element_loc, element_norm, A] = cylinder_arclength(R, H, arclength, d_edge)
%CYLINDER_ Generate a cylindrical array with a rectangular topology 
%   [element_loc, element_norm] = CYLINDER_ARCLENGTH(R, H, dx, dy, d_edge)
%   Generates a faced cylindrical array with a distance R on the ground to the
%   corners of the faces and a height H. arclength specifies the distance 
%   between the elements. The top of the cylinder is covered circular array
%   using arclength method distribution
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
%   Date: 2019-07-02

% Generate the cut conical array
[element_loc, element_norm] = cone_arclength(R, 1000, arclength, H-d_edge);

% Find number of circles that fit within the cylinder radius.
N_circles = floor((R-d_edge)./arclength)+1;

% Find number of points on circles
R_c = (0:N_circles-1)*arclength;
N_points_on_c = round(2*pi*R_c/arclength);

% Place an element in the dead center
cap_loc = [0; 0; H];

% Calculate cap element spacing in phi and find element coordinates
for i = 2:N_circles
    phi_step = 2*pi./N_points_on_c(i);
    phi = 0:phi_step:(2*pi-1e-6);
    
    cap_loc = [cap_loc(1,:) R_c(i).*cos(phi);
               cap_loc(2,:) R_c(i).*sin(phi);
               cap_loc(3,:) H*ones(1, length(phi))];
end

% Setup normals for the cap
[~, N_points_on_cap] = size(cap_loc);
cap_norm = [zeros(1, N_points_on_cap);
            zeros(1, N_points_on_cap);
            ones(1, N_points_on_cap)];

% Add cap points to wall points
element_loc = [element_loc cap_loc];
element_norm = [element_norm cap_norm];

% Calculate area
A = 2*pi*R*H+pi*R^2;
end

