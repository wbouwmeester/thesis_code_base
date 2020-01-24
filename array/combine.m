%% FF combination
%  This script applies the post-processing of combining the calculated
%  embedded element patterns in CST or FEKO to calculate final radiation
%  patterns.
%
%  Written by Wietse Bouwmeester
%  Date: 2019-12-06
clear;
close all;

% Constants
f = 1.5e9;
c = 3e8;
lambda = c/f;
k = 2*pi/lambda;
theta_scan = deg2rad(0);
phi_scan = deg2rad(0);

% Filetype ('CST' or 'FEKO')
filetype = 'FEKO';

% Plot element radiation patterns
plot_element = false;

% Correct phase
correct_phase = false;

% Compare fields
compare_fields = false;

% Beta calculation mode (0 for "traditional" or 1 for new method)
beta_calc_method = 0;

% Beta phase inversion
beta_phase_inversion = false;

% Set to true if both phi and theta sub-elements are present
all_elements = true;
all_active = false;

% Set to true when considering a side face
side = false;

%% Load element locations and far fields
load element_locations.mat

% Expand element loc and element norm if all elements are active
if all_active == true
    element_loc_new = []; element_norm_new = [];
    for i_element = 1:size(element_loc, 2)
        element_loc_new = [element_loc_new element_loc(:,i_element) element_loc(:,i_element)];
        element_norm_new = [element_norm_new element_norm(:,i_element) element_norm(:,i_element)];
    end
    element_loc = element_loc_new;
    element_norm = element_norm_new;
end

N_elements = size(element_loc, 2);

% Active elements
index_active = 1:N_elements;
N_elements_active = length(index_active);

% Initialize E_theta and E_phi
E_theta = []; E_phi = [];
if strcmp(filetype, 'CST')
    for i = index_active
        % Open file
        filename = [num2str(i) '.txt'];
        fid = fopen(filename);

        % Discard first two lines
        fgets(fid); fgets(fid);

        % Load data
        FF = fscanf(fid, '%f %f %f %f %f %f %f %f\n', [8, Inf]);

        % Setup E_theta and E_phi
        E_theta = [E_theta;
                   FF(4,:).*exp(1j*deg2rad(FF(5,:)))];
        E_phi   = [E_phi;
                   FF(6,:).*exp(1j*deg2rad(FF(7,:)))];

        % Close file
        fclose(fid);    
    end
elseif strcmp(filetype, 'FEKO')
    for i = index_active
        % Open file
        if all_elements == true
            if all_active == true
                filename = [num2str(i) '.ffe'];                
            else
                filename = [num2str(2*i) '.ffe'];
            end            
        else
            filename = [num2str(i) '.ffe'];
        end
        
        fid = fopen(filename);

        % Discard first 13 lines
        for j = 1:13
            fgets(fid);
        end
        
        % Load data
        FF = fscanf(fid, '%f %f %f %f %f %f %f %f %f\n', [9, Inf]);

        % Setup E_theta and E_phi
        E_theta = [E_theta;
                   FF(3,:)+1j.*FF(4,:)];
        E_phi   = [E_phi;
                   FF(5,:)+1j.*FF(6,:)];

        % Close file
        fclose(fid);         
    end
end

% Setup theta and phi
theta = deg2rad(FF(1,:)).';
phi = deg2rad(FF(2,:)).';

% Find number of unique theta and phi coordinates
N_theta = length(unique(theta));
N_phi = length(unique(phi));

% Calculate absolute values of E-fields
E_abs = sqrt(abs(E_theta).^2+abs(E_phi).^2);

%% Phase calculation and correction
% Apply phase correction
if correct_phase == true
    % Calculate wave vectors
    kx = k.*sin(theta).*cos(phi);
    ky = k.*sin(theta).*sin(phi);
    kz = k.*cos(theta);

    % Calculate phase correction factor
    phase_correction_factor = exp(-1j .* (kx.*element_loc(1,:) + ...
                                          ky.*element_loc(2,:) + ...
                                          kz.*element_loc(3,:))).';
    
    E_theta = E_theta.*phase_correction_factor;
    E_phi = E_theta.*phase_correction_factor;
end                  

% Calculate phase of E_theta and E_phi
E_theta_phase = rad2deg(atan2(imag(E_theta), real(E_theta)));
E_phi_phase = rad2deg(atan2(imag(E_phi), real(E_phi)));

%% Make a 3D radiation plots and phase fronts
theta_res = reshape(theta, [N_theta N_phi]);
phi_res   = reshape(phi, [N_theta N_phi]);

if plot_element == true
    % Plot radiation patterns
    for i = 1:N_elements_active
        C = abs(reshape(E_abs(i,:), [N_theta N_phi]));
        R = C-min(min(C));

        figure;
        surf(R.*sin(theta_res).*cos(phi_res), R.*sin(theta_res).*sin(phi_res), R.*cos(theta_res), C)

        grid on; shading interp; colorbar;
        title('3D Embedded Far E-Field'); axis equal;
        xlabel('x'); ylabel('y'); zlabel('z');
        view([0 0 1]);
    end
    
    % Plot theta phase front
    for i = 1:N_elements_active
        C = abs(reshape(E_theta_phase(i,:), [N_theta N_phi]));
        
        figure;
        surf(sin(theta_res).*cos(phi_res), sin(theta_res).*sin(phi_res), cos(theta_res), C);
        grid on; shading interp; colorbar; caxis([-180 180]);
        title('3D E_\theta Phase Distribution'); axis equal;
        xlabel('x'); ylabel('y'); zlabel('z');
        view([0 0 1]);
    end
    
    % Plot phi phase front
    for i = 1:N_elements_active
        C = abs(reshape(E_phi_phase(i,:), [N_theta N_phi]));
        
        figure;
        surf(sin(theta_res).*cos(phi_res), sin(theta_res).*sin(phi_res), cos(theta_res), C);
        grid on; shading interp; colorbar; caxis([-180 180]);
        title('3D E_\phi Phase Distribution'); axis equal;
        xlabel('x'); ylabel('y'); zlabel('z');
        view([0 0 1]);
    end
end

%% Compare element radiation patterns
if compare_fields == true
    % Calculate element rotations
    theta_norm = atan2(sqrt(element_norm(1,:).^2+element_norm(2,:).^2),element_norm(3,:));
    phi_norm = atan2(element_norm(2,:), element_norm(1,:));

    %Initialise figure
    fig_compare = figure; 
    hold on;
    index_phi = 1;
    index_phi_2 = 91;

    for i = 1:N_elements
        % Find observation vectors
        x_obs = (sin(theta).*cos(phi)).';
        y_obs = (sin(theta).*sin(phi)).';
        z_obs = (cos(theta)).';

        % Rotate to find the apparent observation vector if side is true,
        % rotate by -90 degrees extra        
        if side == true
            obs_ap = rotate([x_obs; y_obs; z_obs], theta_norm(i), 'y');
            obs_ap = rotate(obs_ap, phi_norm(i), 'z');
            obs_ap = rotate(obs_ap, -pi/2, 'y');
        else
            obs_ap = rotate([x_obs; y_obs; z_obs], theta_norm(i), 'y');
            obs_ap = rotate(obs_ap, phi_norm(i), 'z');
        end        

        % Calculate apparent angles
        theta_ap = atan2(sqrt(obs_ap(1,:).^2+obs_ap(2,:).^2),obs_ap(3,:));
        phi_ap = atan2(obs_ap(2,:), obs_ap(1,:));

        % Make sure apparent angles are within 0 and 180 for theta and 0 and
        % 360 for phi
        theta_ap = mod(theta_ap, pi);
        phi_ap = mod(phi_ap, 2*pi);

        % Interpolate radiation pattern at apparent observation angles
        E_abs_fit = fit([theta, phi], E_abs(i,:).', 'linearinterp');

        % Calculate field at apparent angles
        E_abs_rot = E_abs_fit(theta_ap, phi_ap);
        E_abs_rot_res = reshape(E_abs_rot, [N_theta, N_phi]);

        % Plot radiation pattern
        figure(fig_compare); subplot(2,1,1); hold on;  
        plot(rad2deg(theta_res(:,index_phi)), E_abs_rot_res(:,index_phi));
        
        subplot(2,1,2); hold on;
        plot(rad2deg(theta_res(:,index_phi_2)), E_abs_rot_res(:,index_phi_2));
        
        % Plot 3D pattern
        C = abs(reshape(E_abs_rot, [N_theta N_phi]));
        R = C-min(min(C));

        figure;
        surf(R.*sin(theta_res).*cos(phi_res), R.*sin(theta_res).*sin(phi_res), R.*cos(theta_res), C)

        grid on; shading interp; colorbar;
        title('Rotated 3D Embedded Far E-Field'); axis equal;
        xlabel('x'); ylabel('y'); zlabel('z');
        view([0 0 1]);
    end

    figure(fig_compare); subplot(2,1,1); 
    grid on; xlabel('\theta'); ylabel('|E|'); xlim([0 120]);
    title(['\phi = ' num2str(rad2deg(phi_res(1,index_phi)))]);
    
    subplot(2,1,2);
    grid on; xlabel('\theta'); ylabel('|E|'); xlim([0 120]);
    title(['\phi = ' num2str(rad2deg(phi_res(1,index_phi_2)))]);
    
    sgtitle(['E-field cuts @ ' num2str(f./1e9) ' GHz'])
end

%% Combine the Fields
% Select one of the two beta calculation methods
if beta_calc_method == 0
    % Calculate phase shifts (More or less traditional)
    beta = -k.*(sin(theta_scan).*cos(phi_scan).*element_loc(1,index_active) + ...
                sin(theta_scan).*sin(phi_scan).*element_loc(2,index_active) + ...
                cos(theta_scan).*element_loc(3,index_active)).';

    % Correct for element rotation
    if beta_phase_inversion == true
        elements_left_hemisphere = element_loc(2,:)<-1e-6 | element_loc(1,:) <= 0 & element_loc(2,:) < 1e-6;
        beta(elements_left_hemisphere) = beta(elements_left_hemisphere)+pi;
    
        % Plot elements of left hemisphere
        figure; hold on;
        cmap = get(gca, 'colororder');
        
        plot3(element_loc(1,~elements_left_hemisphere), element_loc(2,~elements_left_hemisphere), element_loc(3,~elements_left_hemisphere), 'o', 'MarkerFaceColor', cmap(1,:), 'DisplayName', '+0^\circ phase shift');
        plot3(element_loc(1,elements_left_hemisphere), element_loc(2,elements_left_hemisphere), element_loc(3,elements_left_hemisphere), 'o', 'MarkerFaceColor', cmap(2,:), 'DisplayName', '+180^\circ phase shift');

        axis equal; grid on; legend;
        xlabel('x'); ylabel('y'); zlabel('z');
        title('Orientation Correction');
    end    
elseif beta_calc_method == 1
    % Calculate phase shifts (non traditional)
    % Calculate phase of elements at scan angle
    % Find index of scan angle
    index_scan = find(theta==theta_scan & phi==phi_scan);

    % Calculate beta
    beta = -atan2(imag(E_theta(:,index_scan)), real(E_theta(:,index_scan)));
elseif beta_calc_method == 2
    % Set beta to 0 for no phase shift
    beta = zeros(length(beta),1); 
end

% Apply phase shifts
E_theta = E_theta.*exp(1j*beta);
E_phi   = E_phi.*exp(1j*beta);

% Calculate combined fields
E_theta_tot = sum(E_theta,1);
E_phi_tot   = sum(E_phi,1);

% Calculate absolute values
E_tot_abs = sqrt(abs(E_theta_tot).^2+abs(E_phi_tot).^2);

% % Debug - IILEGAL!! - NON PHYSICAL!! - CANT JUST THROW AWAY PHASE WHENEVER
% % YOU LIKE
% kx = k.*sin(theta).*cos(phi);
% ky = k.*sin(theta).*sin(phi);
% kz = k.*cos(theta);
% 
% phase_change = exp(1j .* (kx.*element_loc(1,:) + ...
%                          ky.*element_loc(2,:) + ...
%                          kz.*element_loc(3,:))).';
% 
% E_abs = E_abs.*exp(1j .* (kx.*element_loc(1,:) + ...
%                          ky.*element_loc(2,:) + ...
%                          kz.*element_loc(3,:))).';
% 
% E_abs = E_abs.*exp(1j*beta);                         
% E_tot_abs = sum(E_abs, 1);
%
% % Debug end

% Reshape E_tot_abs for plotting purposes
E_tot_abs_dB = 20*log10(E_tot_abs./max(E_tot_abs));
E_tot_abs_res = reshape(E_tot_abs, [N_theta N_phi]);
E_tot_abs_dB_res = reshape(E_tot_abs_dB, [N_theta N_phi]);

% Plot combined fields (3D)
C = abs(E_tot_abs_res);
R = C-min(min(C));

figure;
surf(R.*sin(theta_res).*cos(phi_res), R.*sin(theta_res).*sin(phi_res), R.*cos(theta_res), C)

grid on; shading interp; colorbar;
title('3D Array Far E-Field'); axis equal;
xlabel('x'); ylabel('y'); zlabel('z');

% Plot phi = 0 cut
figure;
index_phi = 1;
plot(rad2deg(theta_res(:,index_phi)), E_tot_abs_dB_res(:,index_phi));

grid on;
xlabel('\theta'); ylabel('|E| [dB]'); ylim([-30 0]); xlim([0 90]);
title(['Normalised E-field \phi = ' num2str(rad2deg(phi_res(1,index_phi))) ' cut @ ' num2str(f./1e9) ' GHz']);