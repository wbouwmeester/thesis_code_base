function [element_loc_proj] = project_active(element_loc, element_norm, max_angle, theta_scan, phi_scan)
%PROJECT_ACTIVE Find the active elements and project them on a theta, phi
%plane
%   [element_loc_proj] = PROJECT_ACTIVE(element_loc, element_norm, max_angle, theta_scan, phi_scan)
%   Finds the active elements of an array specified by element_loc and
%   element_norm and projects it such that the x axis coincides with the 
%   phi unit vector and the y axis with the theta unit vextor. element_loc
%   and element_norm are 3xN matrices that have their x, y and z 
%   components specified in row 1, 2 and 3 respectively. Active elements
%   are the elements which normal differs less than max_angle from the scan
%   vector specified by theta_scan and phi_scan.
%
%   element_loc_proj is a 2xN matrix in which the first row represents the
%   x coordinate of the projected elements (phi) and the second row the y
%   coordinate of the projected elements (theta).
%
%   Written by Wietse Bouwmeester
%   Date: 2019-06-14

% Get active elements
[active_element_loc] = active_elements(element_loc, element_norm, max_angle, theta_scan, phi_scan);

% Do the projection
[element_loc_proj] = project(theta_scan, phi_scan, active_element_loc);

end

