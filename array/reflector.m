%% Far field of reflector
%  This script computes the far field of a parabolic reflector
%
%  Written by Wietse Bouwmeester
%  Date: 2020-01-10

clear;
close all;

% Constants
c = 3e8;

% Settings
f = 3e9;

% Magnitude of equivalent current
M_0 = 1;

% Calculate wave length and wave number
lambda = c./f;
k = 2*pi./lambda;

% Desired HPBW (degrees)
HPBW_desired = deg2rad(2);

% Dish radius
a = 29.2*lambda/rad2deg(HPBW_desired);
a = 1.46;

% Scan angle
theta_scan = deg2rad(90);

% Observation grid
theta = 0:deg2rad(0.01):deg2rad(180);

%% Far field of uniform equivalent current distribution (Airy pattern)
% Airy pattern
FF = 2.*M_0.*pi.*a.^2.*besselj(1, k.*a.*sin(theta-theta_scan))./(k.*a.*sin(theta-theta_scan));

% HPBW
HPBW = 57.3.*lambda/(2.*a);

%% Plot far field
% Normalise far field
FF = FF./max(abs(FF));

figure;
plot(rad2deg(theta), 20*log10(abs(FF)));

grid on; xlabel('\theta'); ylabel('Normalised FF [dB]'); title(['Ideal Parabolic Reflector Far Field @ ' num2str(f/1e9) ' GHz']);
ylim([-60 0]);