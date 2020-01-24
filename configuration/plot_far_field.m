%% Plot Far Field
%  This scripts makes figures for the far field of an element.
%
%  Written by Wietse Bouwmeester
%  Date: 2019-12-28

clear;
close all;

% Constants
theta = 0:deg2rad(0.1):deg2rad(180);
phi = 0:deg2rad(1):deg2rad(360);
max_angle = deg2rad(60);

[theta, phi] = meshgrid(theta, phi);

%% Create far field
FF = FF_cloverleaf_theta_3G(theta, phi);

%% Plot fields
index_phi = 1;

% 2D plot
figure; hold on;
plot(theta(index_phi,:)./pi*180, abs(squeeze(FF(index_phi,:))), ...
     'DisplayName', 'Far Field');   

grid on;
xlabel('\theta [deg]'); ylabel('FF'); title('Ideal Far Field');

% Make a 3D radiation plot
C = 20.*log10(abs(squeeze(FF(:,:))));
C(C<-40) = -40;
R = C-min(min(C));

figure;
surf(R.*sin(theta).*cos(phi), R.*sin(theta).*sin(phi), R.*cos(theta), C)

grid on; shading interp; colorbar; caxis([-40 0]);
title('3D Normalized Array Far Field [dB]'); axis equal;
xlabel('x'); ylabel('y');
