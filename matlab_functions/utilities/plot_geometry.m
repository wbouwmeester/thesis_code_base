function [fig_geo] = plot_geometry(element_loc, element_norm,  plot_norm, plot_hat, theta_scan, phi_scan, angle_max)
%PLOT_GEOMETRY Plots an array geometry
%   [fig_geo] = plot_geometry(element_loc, element_norm,  plot_hat, theta_scan, phi_scan, angle_max)
%   Plots the geometry of an array specified by element_loc and
%   element_norm. element_loc and element_norm are both 3xN vectors with
%   the first row representing x, second y and third z. element_loc
%   describes the x, y and z coordinates of the elements and element_norm
%   the normal vectors/pointing direction of the elements.
%   
%   If plot_hat is specified to true, also the local grid vectors are
%   plotted. If also a scan angle is specified in radians by theta_scan and
%   phi_scan plus a maximum element angle, also the active elements in the
%   array are plotted.
%
%   Written by Wietse Bouwmeester
%   Date: 2019-06-08

% Check if correct number of inputs is given, if theta_scan and phi_scan
% and angle_max are given, also plot active elements
if nargin == 7
    active = true;
elseif nargin == 2
    active = false;
    plot_hat = false;
    plot_norm = false;
    
elseif nargin == 3
    plot_hat = false;
    active = false;
elseif nargin == 4
    active = false;
else
    error('Wrong number of arguments.');
end

% Create figure
fig_geo = figure; hold on;
title_str = 'Array Geometry';

% Plot element locations
plot3(element_loc(1,:), element_loc(2,:), element_loc(3,:), '*', 'DisplayName', 'Elements');

% Plot active elements if theta_scan and phi_scan is given
if active == true
    [active_loc] = active_elements(element_loc, element_norm, angle_max, theta_scan, phi_scan);
    plot3(active_loc(1,:), active_loc(2,:), active_loc(3,:), 'o', 'DisplayName', 'Active Elements');
    title_str = ['Array geometry (\theta_s = ' num2str(rad2deg(theta_scan)) ' deg, \phi_s = ' ...
                 num2str(rad2deg(phi_scan)) ' deg)'];
    view(90+rad2deg(phi_scan),90-rad2deg(theta_scan));
end

% Plot element normal vectors
if plot_norm == true
    quiver3(element_loc(1,:), element_loc(2,:), element_loc(3,:), ...
            element_norm(1,:), element_norm(2,:), element_norm(3,:), 'DisplayName', 'Element Normals');
end

if plot_hat == true
    % Find element orientation by first finding angle between z-axis and normal
    % vector
    theta_rot = acos(element_norm(3,:));
    phi_rot = atan2(element_norm(2,:), element_norm(1,:));

    theta_hat = [cos(theta_rot).*cos(phi_rot); 
                 cos(theta_rot).*sin(phi_rot);
                 -sin(theta_rot)];
    phi_hat = [-sin(phi_rot);
               cos(phi_rot);
               zeros(1, length(theta_rot))];

    % Plot these orientation vectors
    quiver3(element_loc(1,:), element_loc(2,:), element_loc(3,:), ...
        theta_hat(1,:), theta_hat(2,:), theta_hat(3,:), 'DisplayName', 'Element \theta_{hat}');
    quiver3(element_loc(1,:), element_loc(2,:), element_loc(3,:), ...
        phi_hat(1,:), phi_hat(2,:), phi_hat(3,:), 'DisplayName', 'Element \phi_{hat}');    
end

% Annotate plot
grid on; axis equal;
xlabel('x [m]'); ylabel('y [m]'); zlabel('z [m]'); legend;
title(title_str);
end

