%% Conformal Array Factor
%  This scrip calculates the array factor for a certain array geometry in
%  3D so that also conformal array shapes can be included. 
%
%  Written by Wietse Bouwmeester
%  Date: 2019-05-20
clear;
close all;

% Constants
c = 3e8;

% Inputs
N_Fc                = 2;
Fc                  = linspace(1.5e9, 1.5e9, N_Fc);

theta_scan          = deg2rad(45);
phi_scan            = deg2rad(45);
element_max_angle   = deg2rad(60);

theta               = 0:deg2rad(1):deg2rad(180);
phi                 = 0:deg2rad(1):deg2rad(360);
[theta, phi]        = meshgrid(theta,phi);

isotropic           = true;

mem_ratio_min       = 3;

% Derived values
k = 2*pi*Fc./c;

%% Array geometry
% Setup array element locations, specified as x,y,z per point in a column 
% vector
R = 5; H = 5;
% [element_loc, element_norm] = cone_arclength(R,H,0.3,H);
% [element_loc, element_norm] = sphere_arclength(R,0.3,pi/2);
% [element_loc, element_norm] = sphere_distance(1000, R, 1000, deg2rad(225));
% [element_loc, element_norm] = sphere_spherical(R, 30,30,pi/2);
% [element_loc, element_norm] = sphere_cartesian(R, 30, 30);
% [element_loc, element_norm] = planar(30, 30, 2*R, 2*R);
[element_loc, element_norm] = cone_faces(4, 3.6, 6, 0.3, 0.3, 0.15, 10);
%[element_loc, element_norm] = cylinder_faces(2.3, 2.95, 6, 0.3, 0.3, 0.15); 

[~, N_elements] = size(element_loc);

% Plot the array
fig_geo = figure;
plot3(element_loc(1,:), element_loc(2,:), element_loc(3,:), '*', 'DisplayName', 'Elements');

grid on; axis equal;
xlabel('x [m]'); ylabel('y [m]'); zlabel('z [m]');
title('Array Geometry');

%% Element exitations
% Calculate the exitations for the seperate elements to improve side lobe
% behaviour

% Find active elements
[element_active, element_active_norm, N_active_elements] = ...
    active_elements(element_loc, element_norm, element_max_angle, ...
                    theta_scan, phi_scan);

% Assign weights to all elements
A_active = ones(1, N_active_elements);

% Plot active elements
figure(fig_geo); hold on;
plot3(element_active(1,:), element_active(2,:), element_active(3,:), 'o', 'DisplayName', 'Active');
legend;
quiver3(element_loc(1,:), element_loc(2,:), element_loc(3,:), ...
        element_norm(1,:), element_norm(2,:), element_norm(3,:), 'DisplayName', 'Element Normals');

%% Element Phase Shifts
% Calculate the phase shift of the elements to steer the main beam in the
% phi_scan and theta_scan directions (only for active elements to speed up
% calculations)
beta = -k.'*(sin(theta_scan).*cos(phi_scan).*element_active(1,:) + ...
             sin(theta_scan).*sin(phi_scan).*element_active(2,:) + ...
             cos(theta_scan).*element_active(3,:));
    
%% Element radiation patterns
% Setup the element radiation patterns

% Isotropic pattern
if isotropic == false
    % Find angle between z-axis and normal vector and setup theta_hat and
    % phi_hat
    theta_rot = acos(element_active_norm(3,:));
    phi_rot = atan2(element_active_norm(2,:), element_active_norm(1,:));
    
    theta_hat = [cos(theta_rot).*cos(phi_rot); 
                 cos(theta_rot).*sin(phi_rot);
                 -sin(theta_rot)];
    phi_hat = [-sin(phi_rot);
               cos(phi_rot);
               zeros(1, N_active_elements)];
    
    % Plot these vectors for debugging purposes
    quiver3(element_active(1,:), element_active(2,:), element_active(3,:), ...
        theta_hat(1,:), theta_hat(2,:), theta_hat(3,:), 'DisplayName', 'Element x');
    quiver3(element_active(1,:), element_active(2,:), element_active(3,:), ...
        phi_hat(1,:), phi_hat(2,:), phi_hat(3,:), 'DisplayName', 'Element y');
    
    % Save original size and vectorize observation angles
    oSize = size(theta);
    N_angles = numel(theta);

    theta_lin = reshape(theta, [1, N_angles]);
    phi_lin = reshape(phi, [1, N_angles]);
    
    % Find x, y and z components for all observation angles
    x_obs = sin(theta_lin).*cos(phi_lin);
    y_obs = sin(theta_lin).*sin(phi_lin);
    z_obs = cos(theta_lin);
    
    % Setup single element pattern
    single_element_FF = FF_cos(theta_lin);
    
    % Create fit of radiation pattern
    % single_element_FF = fit([theta_lin.', phi_lin.'], single_element_FF.', 'linearinterp');
    
    % Setup element_FF
    element_FFs = zeros([size(theta), N_active_elements]); 
    element_FFs_lin = zeros(N_active_elements, N_angles);
    
    for i = 1:N_active_elements
        % Calculate projections of observation vectors on local grids to
        % find the apparent observation vectors
        x_apparent = theta_hat(:,i)'*[x_obs; y_obs; z_obs];
        y_apparent = phi_hat(:,i)'*[x_obs; y_obs; z_obs];
        z_apparent = element_active_norm(:,i)'*[x_obs; y_obs; z_obs];
        
        % Transform these observation vectors to theta and phi
        theta_apparent = acos(z_apparent);
        phi_apparent = atan2(y_apparent, x_apparent);
        
        % Throw away imagnary part that occurs due to numerical errors
        theta_apparent = real(theta_apparent);
        
        % Resample at original theta and phi
        % element_FFs_lin = single_element_FF(mod(theta_apparent,pi), mod(phi_apparent,2*pi));
        % element_FFs_lin(i,:) = FF_cos(mod(theta_apparent,pi));
        element_FFs_lin(i,:) = FF_ideal(mod(theta_apparent,pi), element_max_angle);
        
        % Reformat to theta and phi grids
        element_FFs(:,:,i) = reshape(element_FFs_lin(i,:), oSize);        
    end
    
    % Make a 3D radiation plot of an element pattern
    C = 20.*log10(abs(squeeze(element_FFs(:, :, i))));
    C(C<-40) = -40;
    R = C-min(min(C));

    figure;
    surf(R.*sin(theta).*cos(phi), R.*sin(theta).*sin(phi), R.*cos(theta), C)

    grid on; colorbar; caxis([-40 0]); shading interp;
    title('3D Normalized Element Far Field [dB]'); axis equal;
    xlabel('x'); ylabel('y');
end

%% Array Far Field
% Calculate the array far field using one of two methods for array far
% field computation. The first one relies on matrix math, the second one on 
% a loop per element. Matrix method is quicker if enough free memory is
% available, the element method is quicker when memory is limited.

% Allocate memory for FF
array_FF = zeros([size(theta) N_Fc]);

% Estimate needed memory for matrix method
N_angles = numel(theta);
mem_req = N_angles*N_active_elements*16;
[~, mem_free] = memory; mem_free = mem_free.PhysicalMemory.Available;
mem_ratio = mem_free/mem_req;

% Choose between fast memory intesive method or slow non-intensive memory 
% method 
if mem_ratio > mem_ratio_min
    fprintf("Matrix method\n");
    tic;
    % Save original size and vectorize observation angles
    oSize = size(theta);
    N_angles = numel(theta);

    theta_lin = reshape(theta, [1, N_angles]);
    phi_lin = reshape(phi, [1, N_angles]);

    % Setup position matrix
    POS = [element_active(1,:).', element_active(2,:).', element_active(3,:).'];

    for i = 1:N_Fc
        % Calculate wave vector matrix with -1's for beta subtraction
        K =      [k(i)*sin(theta_lin).*cos(phi_lin); ...
                  k(i)*sin(theta_lin).*sin(phi_lin); ...
                  k(i)*cos(theta_lin); ...
                  ones(1, N_angles)];

        % Add beta to position matrix 
        POS_beta = [POS, beta(i,:).'];

        % Calculate AF contributions
        FF_lin = 1j*POS_beta*K;
        FF_lin = exp(FF_lin);
        
        if isotropic == true
            FF_lin = A_active.'.*FF_lin;
        else
            FF_lin = A_active.'.*FF_lin.*element_FFs_lin;
        end
        
        % Sum AF contributions
        FF_lin = sum(FF_lin,1);

        % Reshape and write back to original format
        array_FF(:,:,i) = reshape(FF_lin, oSize);
    end
    toc;
else
    fprintf("Element method\n");
    tic;
    % Setup wave vectors
    kx = zeros(size(array_FF)); ky = kx; kz = kx;
    for i = 1:N_Fc
        kx(:,:,i) = k(i).*sin(theta).*cos(phi);
        ky(:,:,i) = k(i).*sin(theta).*sin(phi);
        kz(:,:,i) = k(i).*cos(theta);
    end

    % Calculate the final array factor (only active elements)
    FF_int = zeros(size(theta));
    for i = 1:N_Fc
        for j = 1:N_active_elements
            if isotropic == true
                FF = 1;
            else
                FF = element_FFs(:,:,j);
            end
            AF_int = AF_int + FF .* A_active(j) .* ...
                     exp(1j .* (kx(:,:,i).*element_active(1,j) + ...
                                ky(:,:,i).*element_active(2,j) + ...
                                kz(:,:,i).*element_active(3,j) + ...
                                beta(i,j)));
        end
        array_FF(:,:,i) = AF_int;
    end
    toc;
end 


%% Radiation patterns
% Normalize the radiation patterns of the array

for i = 1:N_Fc
    array_FF(:,:,i) = array_FF(:,:,i)./max(max(abs(array_FF(:,:,i))));    
end

% Plot the radiation patterns
figure; hold on;
for i = 1:N_Fc
    plot(theta(1,:)./pi*180, 20*log10(abs(squeeze(array_FF(31,:,i)))), ...
         'DisplayName', ['f = ' num2str(Fc(i)./1e6) 'MHz']);
end

grid on; legend; ylim([-40 0]);
xlabel('\theta [deg]'); ylabel('FF [dB]'); title('Array Far Field');

% Make surface plot
figure;
surf(theta./pi*180, phi./pi*180, 20*log10(abs(squeeze(array_FF(:,:,1)))))

view([0 0 1]);
grid on; shading interp; colorbar; caxis([-40 0]); axis equal;
xlabel('\theta [deg]'); ylabel('\phi [deg]'); title('Array Far Field');

% Make uv surface plot
figure;
surf(sin(theta).*cos(phi), sin(theta).*sin(phi), 20.*log10(abs(squeeze(array_FF(:,:,1)))))

view([0 0 1]);
grid on; shading interp; colorbar; caxis([-40 0]); axis equal;
xlabel('u [m]'); ylabel('v [m]'); title('Array Far Field');

% Make a 3D radiation plot
C = 20.*log10(abs(squeeze(array_FF(:,:,1))));
C(C<-40) = -40;
R = C-min(min(C));

figure;
surf(R.*sin(theta).*cos(phi), R.*sin(theta).*sin(phi), R.*cos(theta), C)

grid on; shading interp; colorbar; caxis([-40 0]);
title('3D Normalized Array Far Field [dB]'); axis equal;
xlabel('x'); ylabel('y');
