function [fig_geo] = plot_geometry2(element_loc, element_norm, alternative, plot_norm, plot_hat, active, theta_scan, phi_scan, angle_max, obscure, theta_view, phi_view)
%PLOT_GEOMETRY2 Plots an array geometry with more options
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
%   If obscure is specified, then all the elements that are hidden behind
%   the array are removed as seen from the scan direction.
%
%   If alternative is specified to be true, blue and red circles will be
%   used to indicate active and inactive elements.
%
%   Written by Wietse Bouwmeester
%   Date: 2019-06-08

% Check if correct number of inputs is given, if theta_scan and phi_scan
% and angle_max are given, also plot active elements
if nargin == 2
    alternative = false;
    plot_norm = false;
    plot_hat = false;
    active = false;
    obscure = false;
elseif nargin == 3
    plot_norm = false;
    plot_hat = false;
    active = false;
    obscure = false;
elseif nargin == 4
    plot_hat = false;
    active = false;
    obscure = false;
elseif nargin == 5
    active = false;
    obscure = false;
elseif nargin == 6
    if active == true
        error('Active cannot be true if scan data is not given');
    end
    obscure = false;
elseif nargin == 9
    obscure = false;
elseif nargin == 10
    theta_view = theta_scan;
    phi_view = phi_scan;
elseif nargin == 12
else
    error('Wrong number of arguments.');
end

% Create figure
fig_geo = figure; hold on;
title_str = 'Array Geometry';
cmap = get(gca, 'colororder');

% Calculate obscured elements and remove them
if obscure == true
    [~, N_elements] = size(element_loc);
    
    scan_vec = [ones(1,N_elements).*sin(theta_view)*cos(phi_view); 
                ones(1,N_elements).*sin(theta_view)*sin(phi_view); 
                ones(1,N_elements).*cos(theta_view)];
    
    % Calculate angle between these vectors for every element
    element_angle = acos(dot(element_norm, scan_vec));

    % Remove the obscured elements
    visible = element_angle < deg2rad(90);
    
    element_loc = element_loc(:, visible);
    element_norm = element_norm(:, visible);
    
    % Set view angle correctly
    view(90+rad2deg(phi_view),90-rad2deg(theta_view));
end

% Passive elements display name
if active == true
    passive_name = 'Passive Elements';
else
    passive_name = 'Elements';
end

% Plot passive element locations
if alternative == true    
    plot3(element_loc(1,:), element_loc(2,:), element_loc(3,:), 'o', 'MarkerFaceColor', cmap(1,:), 'DisplayName', passive_name);
else
    plot3(element_loc(1,:), element_loc(2,:), element_loc(3,:), '*', 'DisplayName', passive_name);
end

% Plot active elements if theta_scan and phi_scan is given
if active == true
    [active_loc] = active_elements(element_loc, element_norm, angle_max, theta_scan, phi_scan);
    if alternative == true
        plot3(active_loc(1,:), active_loc(2,:), active_loc(3,:), 'o', 'MarkerFaceColor', cmap(2,:), 'DisplayName', 'Active Elements');
    else
        plot3(active_loc(1,:), active_loc(2,:), active_loc(3,:), 'o', 'DisplayName', 'Active Elements');
    end
    
    title_str = ['Array geometry (\theta_s = ' num2str(rad2deg(theta_scan)) ' deg, \phi_s = ' ...
                 num2str(rad2deg(phi_scan)) ' deg)'];
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

