function [element_loc, element_norm, N_active] = active_elements(element_loc, element_norm, max_angle, theta_scan, phi_scan)
%ACTIVE_ELEMENTS Find the active elements of an array
%   [element_loc, element_norm, N_active] = ACTIVE_ELEMENTS(element_loc, element_norm, max_angle, theta_scan, phi_scan)
%   Finds the active elements of an array. Active elements are defined as
%   elements that differ less than max_angle with the scan angle, defined
%   by theta_scan and phi_scan, with the normal vector of the element.
%   Normal vectors of the array are specified by element_norm and the
%   locations of the elements in the array are specified by element_loc.
%   Both are 3xN matrices that have their x,y and z components in row 1, 2
%   and 3 respectively.
%
%   ACTIVE_ELEMENTS returns element_loc which has the same format as the
%   input element_loc, but only contains the active element locations.
%   Similary, the output element_norm contains only the active element
%   normals. N_active is the number of active elements.
%
%   Written by Wietse Bouwmeester
%   Date: 2019-06-14

[~, N_elements] = size(element_loc);
isactive = ones(1, N_elements);

% Calculate scan direction unit vactor
x_scan = ones(1,N_elements).*sin(theta_scan).*cos(phi_scan);
y_scan = ones(1,N_elements).*sin(theta_scan).*sin(phi_scan);
z_scan = ones(1,N_elements).*cos(theta_scan);

% Calculate angle between these vectors for every element
element_angle = acos(dot(element_norm, ...
                         [x_scan; y_scan; z_scan]));

% Disable all elements beyond a certain angle
isactive(element_angle > max_angle) = 0;

% Get active element info
element_loc = element_loc(:, isactive == 1);
element_norm = element_norm(:, isactive == 1);
N_active = sum(isactive == 1);
end

