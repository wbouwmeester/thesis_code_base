%% SLL comparison
%  This script computes the radiation patterns of the geodesic and healpix
%  spherical arrays to see the influence of topology on side lobe level.
%
%  Written by Wietse Bouwmeester
%  Date: 2020-01-20

clear;
close all;

%% Settings
Fc = 3e9;
N_Fc = length(Fc);

theta_scan = deg2rad(90);
phi_scan = deg2rad(30);
element_max_angle   = deg2rad(60.01);

%% Array geometries
% Setup array element locations, specified as x,y,z per point in a column 
% vector
R =0.5;
[element_loc_1, element_norm_1, A_1] = sphere_geodesic(R,0.06,pi);
[element_loc_2, element_norm_2, A_2] = sphere_HEALPix(R,0.05,pi);

%element_loc_1 = [0;0;0]; element_norm_1 = [0;0;1];
%element_loc_2 = [0;0;0]; element_norm_2 = [0;0;1];

% Plot apertures as seen from scan angle
plot_geometry2(element_loc_1, element_norm_1, true, false, false, true, theta_scan, phi_scan, element_max_angle, true);
title(['Geodesic Spherical Array (\theta_s = ' num2str(rad2deg(theta_scan)) ' deg, \phi_s = ' ...
       num2str(rad2deg(phi_scan)) ' deg)']);
xlim([-1.5*R 1.5*R]); ylim([-1.5*R 1.5*R]); zlim([-1.5*R 1.5*R]);
   
plot_geometry2(element_loc_2, element_norm_2, true, false, false, true, theta_scan, phi_scan, element_max_angle, true);
title(['HEALPix Spherical Array (\theta_s = ' num2str(rad2deg(theta_scan)) ' deg, \phi_s = ' ...
       num2str(rad2deg(phi_scan)) ' deg)']);
xlim([-1.5*R 1.5*R]); ylim([-1.5*R 1.5*R]); zlim([-1.5*R 1.5*R]);

%% FF calculations
% Setup observation grid
theta_step      = deg2rad(0.1);
theta_max       = deg2rad(90);
phi_step        = deg2rad(1);
phi_max         = deg2rad(179);

theta           = -theta_max:theta_step:theta_max;
phi             = 0:phi_step:phi_max;

[theta, phi]    = meshgrid(theta,phi);

for i_theta = 1:length(theta_scan)
    for i_phi = 1:length(phi_scan)
        % Element pattern
        element_FF = 'FF_ideal';
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
        
        element_loc_scan_1    = ROT_theta*ROT_phi*element_loc_1;
        element_norm_scan_1   = ROT_theta*ROT_phi*element_norm_1;
        
        element_loc_scan_2    = ROT_theta*ROT_phi*element_loc_2;
        element_norm_scan_2   = ROT_theta*ROT_phi*element_norm_2;
        
        % Array FF calculation
        FF_1 = FF_conformal(theta, phi, 0, 0, Fc, ...
                          element_loc_scan_1, element_norm_scan_1, ...
                          element_FF, element_max_angle);
                      
        FF_2 = FF_conformal(theta, phi, 0, 0, Fc, ...
                          element_loc_scan_2, element_norm_scan_2, ...
                          element_FF, element_max_angle);
                     
        % Estimate beamwidth for every phi
        [N_phi, ~] = size(phi);
        sll_1 = zeros(N_phi, N_Fc);
        sll_2 = zeros(N_phi, N_Fc);
        
        for j_Fc = 1:N_Fc
            % Check the number of frequencies to select the right input
            % format
            if N_Fc == 1
                for j_phi = 1:N_phi
                    sll_1(j_phi, N_Fc) = SLL(FF_1(j_phi, :).', theta(j_phi,:), 0);
                    sll_2(j_phi, N_Fc) = SLL(FF_2(j_phi, :).', theta(j_phi,:), 0);
                end
            else
                for j_phi = 1:N_phi
                    sll_1(j_phi, N_Fc) = SLL(FF_1(j_phi, :).', theta(j_phi,:), 0);
                    sll_2(j_phi, N_Fc) = SLL(FF_2(j_phi, :).', theta(j_phi,:), 0);
                end
            end
        end
        
        % Extract maximum side lobe levels
        [sll_max_1(i_theta, i_phi, :), max_index_1] = max(sll_1);
        [sll_max_2(i_theta, i_phi, :), max_index_2] = max(sll_2);
        
        % Find corresponding phi angle for maximum side lobe levels
        phi_sll_max_1(i_theta, i_phi, :) = phi(max_index_1,1);
        phi_sll_max_2(i_theta, i_phi, :) = phi(max_index_2,1);
        
        % Make a 3D radiation plot
        C = 20.*log10(abs(squeeze(FF_1(:,:))));
        C(C<-40) = -40;
        R = C-min(min(C));

        figure;
        surf(R.*sin(theta).*cos(phi), R.*sin(theta).*sin(phi), R.*cos(theta), C)

        grid on; shading interp; colorbar; caxis([-40 0]);
        title('3D Normalized Array Far Field [dB]'); axis equal;
        xlabel('x'); ylabel('y');
        
        % Make a 3D radiation plot of HEALPix
        C = 20.*log10(abs(squeeze(FF_2(:,:))));
        C(C<-40) = -40;
        R = C-min(min(C));

        figure;
        surf(R.*sin(theta).*cos(phi), R.*sin(theta).*sin(phi), R.*cos(theta), C)

        grid on; shading interp; colorbar; caxis([-40 0]);
        title('3D Normalized Array Far Field [dB]'); axis equal;
        xlabel('x'); ylabel('y');

        % Plot critical cuts
        figure; hold on;
        plot(rad2deg(theta(max_index_1,:)), 20*log10(abs(FF_1(max_index_1,:))), 'DisplayName', ['Geodesic \phi = ' num2str(rad2deg(phi_sll_max_1)) '^\circ Cut']);
        plot(rad2deg(theta(max_index_2,:)), 20*log10(abs(FF_2(max_index_2,:))), 'DisplayName', ['HEALPix \phi = ' num2str(rad2deg(phi_sll_max_2)) '^\circ Cut']);

        grid on; xlabel('\theta'); ylabel('Normalised FF [dB]'); title(['Critical Normalised Far-Field \phi Cuts @ ' num2str(Fc/1e9) ' GHz']);
        legend; %ylim([-60 0]);

        % Report side lobe levels
        fprintf('Geodesic Sphere: %f dB\n', 20*log10(sll_max_1));
        fprintf('HEALPix: %f dB\n', 20*log10(sll_max_2));
    end
end