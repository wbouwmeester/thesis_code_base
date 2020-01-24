function [element_loc_proj] = project(theta, phi, element_loc)
%PROJECT Project 3D element pattern as seen from scan angle
%   [element_loc_proj] = PROJECT(theta, phi, element_loc) projects the
%   array elements on an x,y plane and rotates it such that the theta and
%   phi unit vectors correspond with respectively the y and x axis. The
%   element locations are specified by element_loc which is a 3xN matrix 
%   with the rows representing x, y and z. Theta and phi represent the scan
%   angle.
%
%   element_loc_proj is a 2xN matrix with the projected element x (phi) in
%   the first row and the projected element y (theta) in the second row.
%
%   Written by Wietse Bouwmeester
%   Date: 2019-06-04

% Setup unit vectors
theta_hat = [cos(theta).*cos(phi); cos(theta).*sin(phi); -sin(theta)];
phi_hat = [-sin(phi); cos(phi); 0];

% Expand the unit vectors
N_elements = length(element_loc(1,:));
theta_hat_exp = repmat(theta_hat, 1, N_elements);
phi_hat_exp = repmat(phi_hat, 1, N_elements);

% Perform the projections
element_loc_proj = dot(theta_hat_exp, element_loc).*theta_hat + ...
                   dot(phi_hat_exp, element_loc).*phi_hat;

% Rotate so that phi_har is along the y-axis
ROT = [cos(-phi-pi/2) -sin(-phi-pi/2) 0;
       sin(-phi-pi/2) cos(-phi-pi/2) 0;
       0 0 1];
element_loc_proj = ROT*element_loc_proj;
theta_hat = ROT*theta_hat;
phi_hat = ROT*phi_hat;
               
% Rotate so that theta_hat coincides with x
ROT = [1 0 0;
       0 cos(-theta) -sin(-theta);
       0 sin(-theta) cos(-theta)];
element_loc_proj = ROT*element_loc_proj;

% Debug plot
% theta_hat = ROT*theta_hat;
% phi_hat = ROT*phi_hat;
% 
% figure;
% hold on; axis equal; grid on;
% xlabel('x [m]'); ylabel('y [m]'); zlabel('z [m]');
% quiver3(0, 0, 0, theta_hat(1), theta_hat(2), theta_hat(3));
% quiver3(0, 0, 0, phi_hat(1), phi_hat(2), phi_hat(3));
% plot3(element_loc_proj(1,:), element_loc_proj(2,:), element_loc_proj(3,:), 'o');
% plot3(element_loc(1,:), element_loc(2,:), element_loc(3,:), '*');

end

