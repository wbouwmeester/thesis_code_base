%% Full Array Far Field
%  This script plots the far field of the final array using embedded
%  element pattern
%
%  Written by Wietse Bouwmeester
%  Date: 2020-01-09

close all;
clear;

%% Settings
% Frequency
Fc                  = 1.3e9;

% Element locations
[element_loc, element_norm] = sphere_geodesic(1.55, 0.3, 2.6180);

% Element pattern
element_FF = 'FF_cloverleaf_theta_1G3';
element_FF_isotropic = [];

% Dish radius
a = 1.46;

% Wave number
k = 2*pi*Fc/3e8;

% Scan angle settings
theta_scan          = deg2rad(90);
phi_scan            = deg2rad(0);
element_max_angle   = deg2rad(60.01);

% Observation grid
theta               = 0:deg2rad(0.1):deg2rad(180);
phi                 = 0:deg2rad(1):deg2rad(360);
[theta, phi]        = meshgrid(theta,phi);

%% Calculate Far Field
FF = FF_conformal(theta, phi, theta_scan, phi_scan, Fc, ...
                  element_loc, element_norm, element_FF, element_max_angle);
              
FF_isotropic = FF_conformal(theta, phi, theta_scan, phi_scan, Fc, ...
                            element_loc, element_norm, element_FF_isotropic, element_max_angle);
              
%% Rotate FF for HPBW computation
% reshape everything to linear vectors
N_angles = numel(theta);
theta_lin = reshape(theta, [N_angles 1]);
phi_lin = reshape(phi, [N_angles 1]);
FF_lin = reshape(FF_isotropic, [N_angles 1]);

x_obs = (sin(theta_lin).*cos(phi_lin)).';
y_obs = (sin(theta_lin).*sin(phi_lin)).';
z_obs = (cos(theta_lin)).';

% Rotate to find the apparent observation vectors
obs_ap = rotate([x_obs; y_obs; z_obs], theta_scan, 'y');
obs_ap = rotate(obs_ap, phi_scan, 'z');
   
% Calculate apparent angles
theta_ap = atan2(sqrt(obs_ap(1,:).^2+obs_ap(2,:).^2),obs_ap(3,:));
phi_ap = atan2(obs_ap(2,:), obs_ap(1,:));

% Make sure apparent angles are within 0 and 180 for theta and 0 and
% 360 for phi
theta_ap = mod(theta_ap, pi);
phi_ap = mod(phi_ap, 2*pi);

% Interpolate radiation pattern at apparent observation angles
FF_fit = fit([theta_lin, phi_lin], abs(FF_lin), 'linearinterp');

% Calculate field at apparent angles
FF_rot = FF_fit(theta_ap, phi_ap);
FF_rot_res = reshape(FF_rot, size(theta));

% Determine for every phi cut the HPBW
for i = 1:size(phi,1)
    beamwidth(i) = HPBW(FF_rot_res(i,:).', theta(i,:).', 0);
end

% Report minimum and maximum beam widths
fprintf('Minimum HPBW: %f degrees\n', rad2deg(min(beamwidth)));
fprintf('Maximum HPBW: %f degrees\n', rad2deg(max(beamwidth)));

%% Calculate ideal parabolic reflector antenna pattern
% Airy pattern
FF_reflector = 2.*pi.*a.^2.*besselj(1, k.*a.*sin(theta-theta_scan))./(k.*a.*sin(theta-theta_scan));

% Normalise the pattern
FF_reflector = FF_reflector./max(max(FF_reflector));

%% Make plots
% Make surface plot
figure;
surf(theta./pi*180, phi./pi*180, 20*log10(abs(FF)))

view([0 0 1]);
grid on; shading interp; colorbar; caxis([-40 0]); axis equal;
xlabel('\theta [deg]'); ylabel('\phi [deg]'); title('Array Far Field');

% Make uv surface plot
figure;
surf(sin(theta).*cos(phi), sin(theta).*sin(phi), 20.*log10(abs(FF)))

view([0 0 1]);
grid on; shading interp; colorbar; caxis([-40 0]); axis equal;
xlabel('u [m]'); ylabel('v [m]'); title('Array Far Field');

% Make a 3D radiation plot
C = 20.*log10(abs(FF));
C(C<-40) = -40;
R = C-min(min(C));

figure;
surf(R.*sin(theta).*cos(phi), R.*sin(theta).*sin(phi), R.*cos(theta), C)

grid on; shading interp; colorbar; caxis([-40 0]);
title('3D Normalized Array Far Field [dB]'); axis equal;
xlabel('x'); ylabel('y');

% Make radiation pattern cut
index_phi = 1;

figure;
plot(theta(index_phi,:)./pi*180, 20*log10(abs(FF(index_phi,:))))

grid on;
xlabel('\theta'); ylabel('Far Field [dB]'); title(['Normalised \phi = ' num2str(rad2deg(phi(index_phi,1))) ' Far Field Cut @ ' num2str(Fc./1e9) ' GHz']);

% Make radiation pattern cuts with comparison between isotropic and
% elements
index_phi = 1;

figure; hold on;
plot(theta(index_phi,:)./pi*180, 20*log10(abs(FF(index_phi,:))), 'DisplayName', 'Modified Bow-Tie')
plot(theta(index_phi,:)./pi*180, 20*log10(abs(FF_isotropic(index_phi,:))), 'DisplayName', 'Isotropic')

grid on; legend
xlabel('\theta'); ylabel('Far Field [dB]'); title(['Normalised \phi = ' num2str(rad2deg(phi(index_phi,1))) ' Far Field Cut @ ' num2str(Fc./1e9) ' GHz']);

% Make radiation pattern cuts with comparison between array and parabolic
% reflector
index_phi = 1;

figure; hold on;
plot(theta(index_phi,:)./pi*180, 20*log10(abs(FF(index_phi,:))), 'DisplayName', 'Quasi-Spherical Array')
plot(theta(index_phi,:)./pi*180, 20*log10(abs(FF_reflector(index_phi,:))), 'DisplayName', '2.92m-Parabolic Reflector')

grid on; legend
xlabel('\theta'); ylabel('Normalised Far Field [dB]'); title(['\phi = ' num2str(rad2deg(phi(index_phi,1))) ' Far Field Cut @ ' num2str(Fc./1e9) ' GHz']);
ylim([-60 0]);