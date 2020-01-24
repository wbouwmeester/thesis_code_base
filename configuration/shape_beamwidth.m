%% Shape beamwidth
%  This script is used to calculate beamwidths along theta and phi of
%  different array shapes. The results should be saved to a .mat file and
%  processed in beamwidth_comparison.mat
%
%  Written by Wietse Bouwmeester
%  Date: 2019-06-13

clear;
close all;

%% Frequencies
Fc                  = 3e9;
N_Fc                = length(Fc);

%% Scan angle settings
theta_scan_step     = deg2rad(1);
phi_scan_step       = deg2rad(30);

theta_scan          = deg2rad(0):theta_scan_step:deg2rad(90);
phi_scan            = deg2rad(0):phi_scan_step:deg2rad(90);
element_max_angle   = deg2rad(60.01);

% Add some special angles of interest
phi_scan = [phi_scan deg2rad(180)];
    
%% Array geometry
% Setup array element locations, specified as x,y,z per point in a column 
% vector
savename = 'sphere_arclength(1.5,0.3,1.5708)';
[element_loc, element_norm, A] = eval(savename);

%% Beamwidth calculations
% Setup observation grid
theta_step      = deg2rad(1);
theta_max       = deg2rad(90);
phi_step        = deg2rad(1);
phi_max         = deg2rad(179);

theta           = -theta_max:theta_step:theta_max;
phi             = 0:phi_step:phi_max;

[theta, phi]    = meshgrid(theta,phi);

beamwidth_min = zeros(length(theta_scan), length(phi_scan), N_Fc);
phi_beamwidth_min = beamwidth_min;
beamwidth_max = beamwidth_min;
phi_beamwidth_max = beamwidth_min;
sll_max = beamwidth_min;
phi_sll_max = beamwidth_min;

for i_theta = 1:length(theta_scan)
    for i_phi = 1:length(phi_scan)
        % Element pattern
        % element_FF = FF_ideal(theta, element_max_angle);
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
        
        element_loc_scan    = ROT_theta*ROT_phi*element_loc;
        element_norm_scan   = ROT_theta*ROT_phi*element_norm;
        
        % Array FF calculation
        FF = FF_conformal(theta, phi, 0, 0, Fc, ...
                          element_loc_scan, element_norm_scan, ...
                          element_FF, element_max_angle);
                     
        % Estimate beamwidth for every phi
        [N_phi, ~] = size(phi);
        beamwidth = zeros(N_phi, N_Fc);
        sll = zeros(N_phi, N_Fc);
        
        for j_Fc = 1:N_Fc
            % Check the number of frequencies to select the right input
            % format
            if N_Fc == 1
                for j_phi = 1:N_phi
                    beamwidth(j_phi, N_Fc) = HPBW(FF(j_phi, :).', theta(j_phi,:), 0);
                    sll(j_phi, N_Fc) = SLL(FF(j_phi, :).', theta(j_phi,:), 0);
                end
            else
                for j_phi = 1:N_phi
                    beamwidth(j_phi, :) = HPBW(squeeze(FF(j_phi, :, :)), theta(j_phi,:), 0);
                    sll(j_phi, :) = SLL(squeeze(FF(j_phi, :, :)), theta(j_phi,:), 0);
                end
            end
        end
        
        % Extract minimum beamwidth for every frequency
        [beamwidth_min(i_theta, i_phi, :), min_index] = min(beamwidth);
        
        % Find corresponding phi angle for these min beamwidths
        phi_beamwidth_min(i_theta, i_phi, :) = phi(min_index,1);
        
        % Extract maximum beamwidth for every frequency
        % Replace NaN's with 2 pi since there most likely is no HPBW
        beamwidth(isnan(beamwidth)) = 2*pi;        
        [beamwidth_max(i_theta, i_phi, :), max_index] = max(beamwidth);
        
        % Find corresponding phi angle for these maximum beamwidths
        phi_beamwidth_max(i_theta, i_phi, :) = phi(max_index,1);
        
        % Extract maximum side lobe levels
        [sll_max(i_theta, i_phi, :), max_index] = max(sll);
        
        % Find corresponding phi angle for maximum side lobe levels
        phi_sll_max(i_theta, i_phi, :) = phi(max_index,1);
        
%         % Plot the array geometry
%         plot_geometry(element_loc_scan, element_norm_scan, false, 0, 0, element_max_angle);                      
%         view([0 0 1]);
%         
%         % Plot radiation pattern
%         figure;
%         surf(rad2deg(theta), rad2deg(phi), 20*log10(abs(squeeze(FF(:,:,1)))));
%         
%         grid on; view([0 0 1]); shading interp; caxis([(sqrt(0.5)) 1])
%         title(['\theta_s = ' num2str(rad2deg(theta_scan(i_theta))) ' deg, \phi_s = ' ...
%                num2str(rad2deg(phi_scan(i_phi))) ' deg']);
%         zlim([20*log10(sqrt(0.5)) 0]); caxis([20*log10(sqrt(0.5)) 0]);
%         
%         % Make uv surface plot
%         figure;
%         surf(sin(theta).*cos(phi), sin(theta).*sin(phi), 20.*log10(abs(squeeze(FF(:,:,1)))))
% 
%         view([0 0 1]);
%         grid on; shading interp; colorbar; axis equal;
%         xlabel('u [m]'); ylabel('v [m]'); title('Normalised Array Far Field [dB]'); caxis([20*log10(sqrt(0.5)) 0]);  zlim([20*log10(sqrt(0.5)) 0]);
%         
%         % Plot the beamwidth as function of phi
%         figure;
%         plot(rad2deg(phi(:,1)), rad2deg(beamwidth));
%         grid on; xlabel('\phi [deg]'); ylabel('HPBW [deg]'); title('HPBW');
    end
end

%% Find critical angles
% Find the phi_can with the smallest beamwidth
crit_phi_min = zeros(1, N_Fc); crit_phi_index_min = crit_phi_min;
for i = 1:N_Fc
    [~, index] = find(beamwidth_min(:,:,i) == min(min(beamwidth_min(:,:,i))));
    crit_phi_index_min(i) = index(1);
    crit_phi_min(i) = phi_scan(crit_phi_index_min(i));
end

% Find the phi with the largest beamwidth
crit_phi_max = zeros(1, N_Fc); crit_phi_index_max = crit_phi_max;
for i = 1:N_Fc
    [~, index] = find(beamwidth_max(:,:,i) == max(max(beamwidth_max(:,:,i))));
    crit_phi_index_max(i) = index(1);
    crit_phi_max(i) = phi_scan(crit_phi_index_max(i));
end

%% Plot stuff
% Plot beamwidth as function of theta at every frequency
for i_Fc = 1:N_Fc
    figure; 
    subplot(2,1,1); hold all;
    for i = 1:length(phi_scan)
        if i < 8
            plot(theta_scan./pi*180, rad2deg(beamwidth_min(:, i, i_Fc)) , ...
                'DisplayName', ['\phi_s = ' num2str(rad2deg(phi_scan(i))) 'deg']);
        else
            plot(theta_scan./pi*180, rad2deg(beamwidth_min(:, i, i_Fc)) , '--', ...
                'DisplayName', ['\phi_s = ' num2str(rad2deg(phi_scan(i))) 'deg']);
        end
    end

    title(['Minimum Beamwidths at F_c = ' num2str(Fc(i_Fc)/1e9) ' GHz']);
    xlabel('\theta_s'); ylabel('HPBW [deg]'); grid on; legend;

    % Plot corresponding phi for this minimum beamwidth
    subplot(2,1,2); hold all;
    for i = 1:length(phi_scan)
        if i < 8
            plot(theta_scan./pi*180, rad2deg(phi_beamwidth_min(:, i, i_Fc)) , ...
                'DisplayName', ['\phi_s = ' num2str(rad2deg(phi_scan(i))) 'deg']);
        else
            plot(theta_scan./pi*180, rad2deg(phi_beamwidth_min(:, i, i_Fc)) , '--', ...
                 'DisplayName', ['\phi_s = ' num2str(rad2deg(phi_scan(i))) 'deg']);
        end
    end

    xlabel('\theta_s'); ylabel('\phi_{min} [deg]'); grid on;
end

for i_Fc = 1:N_Fc
    figure; 
    subplot(2,1,1); hold all;
    for i = 1:length(phi_scan)
        if i < 8
            plot(theta_scan./pi*180, rad2deg(beamwidth_max(:, i, i_Fc)) , ...
                'DisplayName', ['\phi_s = ' num2str(rad2deg(phi_scan(i))) 'deg']);
        else
            plot(theta_scan./pi*180, rad2deg(beamwidth_max(:, i, i_Fc)) , '--', ...
                'DisplayName', ['\phi_s = ' num2str(rad2deg(phi_scan(i))) 'deg']);
        end
    end

    title(['Maximum Beamwidths at F_c = ' num2str(Fc(i_Fc)/1e9) ' GHz']);
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
end


for i_Fc = 1:N_Fc
    figure; 
    subplot(2,1,1); hold all;
    for i = 1:length(phi_scan)
        if i < 8
            plot(theta_scan./pi*180, 20*log10(sll_max(:, i, i_Fc)), ...
                'DisplayName', ['\phi_s = ' num2str(rad2deg(phi_scan(i))) 'deg']);
        else
            plot(theta_scan./pi*180, 20*log10(sll_max(:, i, i_Fc)), '--', ...
                'DisplayName', ['\phi_s = ' num2str(rad2deg(phi_scan(i))) 'deg']);
        end
    end

    title(['SLL [dB] at F_c = ' num2str(Fc(i_Fc)/1e9) ' GHz']);
    xlabel('\theta_s'); ylabel('HPBW [deg]'); grid on; legend;

    % Plot corresponding phi for this maximum side lobe level
    subplot(2,1,2); hold all;
    for i = 1:length(phi_scan)
        if i < 8
            plot(theta_scan./pi*180, rad2deg(phi_sll_max(:, i, i_Fc)) , ...
                'DisplayName', ['\phi_s = ' num2str(rad2deg(phi_scan(i))) 'deg']);
        else
            plot(theta_scan./pi*180, rad2deg(phi_sll_max(:, i, i_Fc)) , '--', ...
                 'DisplayName', ['\phi_s = ' num2str(rad2deg(phi_scan(i))) 'deg']);
        end
    end

    xlabel('\theta_s'); ylabel('\phi_{max} [deg]'); grid on;
end

%% Save data
save(['configuration/beamwidths/' savename '.mat'], 'beamwidth_min', 'phi_beamwidth_min', ...
               'crit_phi_min', 'crit_phi_index_min', 'theta_scan', 'phi_scan', 'Fc', ...
               'element_loc', 'element_norm', 'element_max_angle', 'element_FF', ...
               'beamwidth_max', 'phi_beamwidth_max', 'A');  