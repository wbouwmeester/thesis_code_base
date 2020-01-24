%% Active Impedance
%  This script takes and plots the active impedances output from the active
%  Feko input files.
%
%  Written by Wietse Bouwmeester
%  Date: 2020-01-15

clear;
close all;

% Scan angles
theta_scan = deg2rad(30):deg2rad(20):deg2rad(90);
phi_scan = 0:deg2rad(20):deg2rad(40);

[theta_scan, phi_scan] = meshgrid(theta_scan, phi_scan);
theta_scan_beta = reshape(theta_scan, [numel(theta_scan), 1]);
phi_scan_beta = reshape(phi_scan, [numel(phi_scan), 1]);

% Number of angles and elements
N_angles = length(theta_scan_beta);
N_elements = 19;

% Reference impedance
Z_0 = 100;
freq = 1.5e9;

%% Read all files
for i_angles = 1:N_angles
    for i_elements = 1:N_elements
        % Load the touchstone files
        filename = [num2str(i_angles) '_' num2str(i_elements) '.s1p'];
        touchstone = nport(filename);
        
        % Extract reflection coefficient and frequency
        f(i_angles, i_elements) = touchstone.NetworkData.Frequencies;
        S11(i_angles, i_elements) = squeeze(touchstone.NetworkData.Parameters(1,1,1));       
    end
end

%% Impedance calculations
Z = (S11+1)./(1-S11).*Z_0;

% Subtract load impedance
Z = Z - Z_0;

%% Load isolated element impedance
touchstone = nport('cloverleaf_ground_spherical_standard.s1p');

% Extract reflection coefficient and frequency
f_isolated = touchstone.NetworkData.Frequencies;
S11_isolated = squeeze(touchstone.NetworkData.Parameters(1,1,:)); 

% Calculate impedance
Z_isolated = (S11_isolated+1)./(1-S11_isolated).*Z_0 - Z_0;

% Find index of frequency
f_index = find(abs(f_isolated - freq) == min(abs(f_isolated - freq)));

% Expand Z_isolated
Z_isolated_exp = ones(1, N_elements).*Z_isolated(f_index);

%% Plots
figure;

subplot(2,1,1); hold on;
for i = 1:N_angles
    plot(1:N_elements, real(Z(i,:)), 'o', 'DisplayName', ['\theta_s = ' num2str(rad2deg(theta_scan_beta(i))) '^\circ \phi_s = ' num2str(rad2deg(phi_scan_beta(i))) '^\circ']);
end
plot(1:N_elements, real(Z_isolated_exp), 'DisplayName', 'Isolated Impedance');

grid on; xlabel('Element'); ylabel('Re(Z_{in}) [\Omega]');
legend;

subplot(2,1,2); hold on;
for i = 1:N_angles
    plot(1:N_elements, imag(Z(i,:)), 'o', 'DisplayName', ['\theta_s = ' num2str(rad2deg(theta_scan_beta(i))) '^\circ \phi_s = ' num2str(rad2deg(phi_scan_beta(i))) '^\circ']);
end
plot(1:N_elements, imag(Z_isolated_exp), 'DisplayName', 'Isolated Impedance');

grid on; xlabel('Element'); ylabel('Im(Z_{in}) [\Omega]', 'DisplayName', 'Active Impedance');
legend;

sgtitle(['Active Impedance vs. Isolated Impedance @ ' num2str(freq./1e9) ' GHz']);
