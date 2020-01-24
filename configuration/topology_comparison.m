%% Topology Comparison
%  This script performs comparison of a number of array topologies.
%
%  Written by Wietse Bouwmeester
%  Date: 2019-09-18
clear;
close all;

%% Setup geometries
[element_loc1, element_norm1] = sphere_arclength(2, 0.3, pi/2);
[element_loc2, element_norm2] = sphere_geodesic(2, 0.3, pi/2);
[element_loc3, element_norm3] = sphere_HEALPix(2, 0.3, pi/2);

plot_geometry(element_loc1, element_norm1, false, false, deg2rad(40), 0, deg2rad(60.01));
title('Arclength Topology');
plot_geometry(element_loc2, element_norm2, false, false, deg2rad(40), 0, deg2rad(60.01));
title('Geodesic Topology');
plot_geometry(element_loc3, element_norm3, false, false, deg2rad(40), 0, deg2rad(60.01));
title('HEALPix Topology');

%% Scan angle settings
theta_scan_step     = deg2rad(1);
phi_scan_step       = deg2rad(15);

theta_scan          = deg2rad(0):theta_scan_step:deg2rad(90);
phi_scan            = deg2rad(0):phi_scan_step:deg2rad(90);
element_max_angle   = deg2rad(60.01);

phi_scan = deg2rad(0);
%theta_scan = 0;

% Frequency settings
Fc                  = 3e9;
N_Fc                = 1;

%% Beamwidth calculations
% Setup observation grid
theta_step      = deg2rad(0.1);
theta_max       = deg2rad(90);
phi_step        = deg2rad(1);
phi_max         = deg2rad(179);

theta           = -theta_max:theta_step:theta_max;
phi             = 0:phi_step:phi_max;

[theta, phi]    = meshgrid(theta,phi);

beamwidth_max = zeros(length(theta_scan), length(phi_scan), N_Fc);
phi_beamwidth_max = beamwidth_max;

for i_theta = 1:length(theta_scan)
    for i_phi = 1:length(phi_scan)
        % Element pattern
        % element_FF = 'FF_ideal';
        element_FF = [];
        
        % Rotate array so that the scan direction is along the z-axis
%         ROT_theta = [cos(-theta_scan(i_theta)) 0 sin(-theta_scan(i_theta));
%                      0 1 0;
%                      -sin(-theta_scan(i_theta)) 0 cos(-theta_scan(i_theta))];
        ROT_theta = [1 0 0;
                     0 cos(-theta_scan(i_theta)) -sin(-theta_scan(i_theta));
                     0 sin(-theta_scan(i_theta)) cos(-theta_scan(i_theta))];
        ROT_phi   = [cos(-phi_scan(i_phi)-pi/2) -sin(-phi_scan(i_phi)-pi/2) 0;
                     sin(-phi_scan(i_phi)-pi/2) cos(-phi_scan(i_phi)-pi/2) 0;
                     0 0 1];
        
        element_loc_scan1    = ROT_theta*ROT_phi*element_loc1;
        element_norm_scan1   = ROT_theta*ROT_phi*element_norm1;
        
        element_loc_scan2    = ROT_theta*ROT_phi*element_loc2;
        element_norm_scan2   = ROT_theta*ROT_phi*element_norm2;
        
        element_loc_scan3    = ROT_theta*ROT_phi*element_loc3;
        element_norm_scan3   = ROT_theta*ROT_phi*element_norm3;
        
        % Array FF calculation
        FF1 = FF_conformal(theta, phi, 0, 0, Fc, ...
                          element_loc_scan1, element_norm_scan1, ...
                          element_FF, element_max_angle);
        
        FF2 = FF_conformal(theta, phi, 0, 0, Fc, ...
                          element_loc_scan2, element_norm_scan2, ...
                          element_FF, element_max_angle);
                      
        FF3 = FF_conformal(theta, phi, 0, 0, Fc, ...
                          element_loc_scan3, element_norm_scan3, ...
                          element_FF, element_max_angle);
                      
        % Estimate beamwidth for every phi
        [N_phi, ~] = size(phi);
        beamwidth1 = zeros(N_phi, N_Fc);
        beamwidth2 = beamwidth1;
        beamwidth3 = beamwidth1;
        
        for j_Fc = 1:N_Fc
            % Check the number of frequencies to select the right input
            % format
            if N_Fc == 1
                for j_phi = 1:N_phi
                    beamwidth1(j_phi, N_Fc) = HPBW(FF1(j_phi, :).', theta(j_phi,:), 0);
                    beamwidth2(j_phi, N_Fc) = HPBW(FF2(j_phi, :).', theta(j_phi,:), 0);
                    beamwidth3(j_phi, N_Fc) = HPBW(FF3(j_phi, :).', theta(j_phi,:), 0);
                end
            else
                for j_phi = 1:N_phi
                    beamwidth1(j_phi, :) = HPBW(squeeze(FF1(j_phi, :, :)), theta(j_phi,:), 0);
                    beamwidth2(j_phi, :) = HPBW(squeeze(FF2(j_phi, :, :)), theta(j_phi,:), 0);
                    beamwidth3(j_phi, :) = HPBW(squeeze(FF3(j_phi, :, :)), theta(j_phi,:), 0);
                end
            end
        end
        
        % Extract maximum beamwidth for every frequency
        [beamwidth_max1(i_theta, i_phi, :), max_index1] = max(beamwidth1);
        [beamwidth_max2(i_theta, i_phi, :), max_index2] = max(beamwidth2);
        [beamwidth_max3(i_theta, i_phi, :), max_index3] = max(beamwidth3);
        
        % Find corresponding phi angle for these max beamwidths
        phi_beamwidth_max1(i_theta, i_phi, :) = phi(max_index1,1);
        phi_beamwidth_max2(i_theta, i_phi, :) = phi(max_index2,1);
        phi_beamwidth_max3(i_theta, i_phi, :) = phi(max_index3,1);
    end
end

%% Find critical angle
% Find the phi_can with the largest beamwidth
crit_phi = zeros(1, N_Fc); crit_phi_index = crit_phi;
for i = 1:N_Fc
    [~, index] = find(beamwidth_max1(:,:,i) == max(max(beamwidth_max1(:,:,i))));
    crit_phi_index(i) = index(1);
    crit_phi1(i) = phi_scan(crit_phi_index(i));

    [~, index2] = find(beamwidth_max2(:,:,i) == max(max(beamwidth_max2(:,:,i))));
    crit_phi_index(i) = index(1);
    crit_phi2(i) = phi_scan(crit_phi_index(i));
    
    [~, index3] = find(beamwidth_max3(:,:,i) == max(max(beamwidth_max3(:,:,i))));
    crit_phi_index(i) = index(1);
    crit_phi3(i) = phi_scan(crit_phi_index(i));
end

%% Plot stuff
% Plot beamwidth as function of theta at every frequency
for i_Fc = 1:N_Fc
    figure;
    hold all;
    plot(theta_scan./pi*180, rad2deg(beamwidth_max1(:, i, i_Fc)) , ...
         'DisplayName', ['Arclength']);
    plot(theta_scan./pi*180, rad2deg(beamwidth_max2(:, i, i_Fc)) , ...
         'DisplayName', ['Geodesic']);
    plot(theta_scan./pi*180, rad2deg(beamwidth_max3(:, i, i_Fc)) , ...
         'DisplayName', ['HEALPix']);
    
    title(['Beamwidths at F_c = ' num2str(Fc(i_Fc)/1e9) ' GHz']);
    xlabel('\theta_s'); ylabel('HPBW [deg]'); grid on; legend;
    
    
    figure; 
    subplot(2,1,1); hold all;
    for i = 1:length(phi_scan)
        if i < 8
            plot(theta_scan./pi*180, rad2deg(beamwidth_max1(:, i, i_Fc)) , ...
                'DisplayName', ['\phi_s = ' num2str(rad2deg(phi_scan(i))) 'deg']);
        else
            plot(theta_scan./pi*180, rad2deg(beamwidth_max1(:, i, i_Fc)) , '--', ...
                'DisplayName', ['\phi_s = ' num2str(rad2deg(phi_scan(i))) 'deg']);
        end
    end

    title(['Beamwidths at F_c = ' num2str(Fc(i_Fc)/1e9) ' GHz']);
    xlabel('\theta_s'); ylabel('HPBW [deg]'); grid on; legend;
    
    % Plot corresponding phi for this maximum beamwidth
    subplot(2,1,2); hold all;
    for i = 1:length(phi_scan)
        if i < 8
            plot(theta_scan./pi*180, rad2deg(phi_beamwidth_max(:, i, i_Fc)) , ...
                'DisplayName', ['\phi_s = ' num2str(rad2deg(phi_scan(i))) 'deg']);
        else
            plot(theta_scan./pi*180, rad2deg(phi_beamwidth_max(:, i, i_Fc)) , '--', ...
                 'DisplayName', ['\phi_s = ' num2str(rad2deg(phi_scan(i))) 'deg']);
        end
    end

    xlabel('\theta_s'); ylabel('\phi_{max} [deg]'); grid on;
    
    figure; 
    subplot(2,1,1); hold all;
    for i = 1:length(phi_scan)
        if i < 8
            plot(theta_scan./pi*180, rad2deg(beamwidth_max2(:, i, i_Fc)) , ...
                'DisplayName', ['\phi_s = ' num2str(rad2deg(phi_scan(i))) 'deg']);
        else
            plot(theta_scan./pi*180, rad2deg(beamwidth_max2(:, i, i_Fc)) , '--', ...
                'DisplayName', ['\phi_s = ' num2str(rad2deg(phi_scan(i))) 'deg']);
        end
    end
    
    title(['Beamwidths at F_c = ' num2str(Fc(i_Fc)/1e9) ' GHz']);
    xlabel('\theta_s'); ylabel('HPBW [deg]'); grid on; legend;
    
    % Plot corresponding phi for this maximum beamwidth
    subplot(2,1,2); hold all;
    for i = 1:length(phi_scan)
        if i < 8
            plot(theta_scan./pi*180, rad2deg(phi_beamwidth_max2(:, i, i_Fc)) , ...
                'DisplayName', ['\phi_s = ' num2str(rad2deg(phi_scan(i))) 'deg']);
        else
            plot(theta_scan./pi*180, rad2deg(phi_beamwidth_max2(:, i, i_Fc)) , '--', ...
                 'DisplayName', ['\phi_s = ' num2str(rad2deg(phi_scan(i))) 'deg']);
        end
    end
    
    xlabel('\theta_s'); ylabel('\phi_{max} [deg]'); grid on;
    
    figure; 
    subplot(2,1,1); hold all;
    for i = 1:length(phi_scan)
        if i < 8
            plot(theta_scan./pi*180, rad2deg(beamwidth_max3(:, i, i_Fc)) , ...
                'DisplayName', ['\phi_s = ' num2str(rad2deg(phi_scan(i))) 'deg']);
        else
            plot(theta_scan./pi*180, rad2deg(beamwidth_max3(:, i, i_Fc)) , '--', ...
                'DisplayName', ['\phi_s = ' num2str(rad2deg(phi_scan(i))) 'deg']);
        end
    end

    title(['Beamwidths at F_c = ' num2str(Fc(i_Fc)/1e9) ' GHz']);
    xlabel('\theta_s'); ylabel('HPBW [deg]'); grid on; legend;
    
    % Plot corresponding phi for this maximum beamwidth
    subplot(2,1,2); hold all;
    for i = 1:length(phi_scan)
        if i < 8
            plot(theta_scan./pi*180, rad2deg(phi_beamwidth_max3(:, i, i_Fc)) , ...
                'DisplayName', ['\phi_s = ' num2str(rad2deg(phi_scan(i))) 'deg']);
        else
            plot(theta_scan./pi*180, rad2deg(phi_beamwidth_max3(:, i, i_Fc)) , '--', ...
                 'DisplayName', ['\phi_s = ' num2str(rad2deg(phi_scan(i))) 'deg']);
        end
    end
    
    xlabel('\theta_s'); ylabel('\phi_{max} [deg]'); grid on;
end

% plot FF
figure;
surf(theta./pi*180, phi./pi*180, 20*log10(abs(squeeze(FF1(:,:,1)))))

view([0 0 1]);
grid on; shading interp; colorbar; caxis([-40 0]);
xlabel('\theta [deg]'); ylabel('\phi [deg]'); title('FF Arclength');

figure;
surf(theta./pi*180, phi./pi*180, 20*log10(abs(squeeze(FF2(:,:,1)))))

view([0 0 1]);
grid on; shading interp; colorbar; caxis([-40 0]);
xlabel('\theta [deg]'); ylabel('\phi [deg]'); title('FF Geodesic');

figure;
surf(theta./pi*180, phi./pi*180, 20*log10(abs(squeeze(FF3(:,:,1)))))

view([0 0 1]);
grid on; shading interp; colorbar; caxis([-40 0]);
xlabel('\theta [deg]'); ylabel('\phi [deg]'); title('FF HEALPix');

