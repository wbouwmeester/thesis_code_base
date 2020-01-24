%% Impedance Plot
%  This script plots the impedances as exported from CST or FEKO
%
%  Written by Wietse Bouwmeester
%  Date: 2020-01-03

clear;
close all;

%% Import files from CST
filename = 'Cloverleaf_Coarse_Ground_Spherical.s1p';

data = nport(filename);

Z_0 = 100;

%% Plot smith chart
smith_grid = [50 20 10 5 4 3 2 1.8 1.6 1.4 1.2 1 0.9 0.8 0.7 0.6 0.5 0.4 0.3 0.2 0.1;
              Inf 20 20 10 5 5 5 2 2 2 2 5 2 2 2 2 2 2 2 2 2];

figure; hold on;
smithplot(data, 1, 1,  ...
          'GridValue', smith_grid, ...
          'TitleTop', ['S_{11}'], ...
          'TitleTopTextInterpreter', 'tex', 'GridBackgroundColor', 'w', ...
          'TitleBottom', ['Z_0 = ' num2str(Z_0)], 'TitleBottomTextInterpreter', 'tex');

% Plot first and last frequency indicator
f_min = min(data.NetworkData.Frequencies);
f_max = max(data.NetworkData.Frequencies);

S11 = squeeze(data.NetworkData.Parameters(1,1,:));
line(real(S11(1)), imag(S11(1)), 'DisplayName', [num2str(f_min./1e6) ' MHz'], 'Marker', 'o', 'MarkerSize', 10, 'color', 'r');
line(real(S11(length(S11))), imag(S11(length(S11))), 'DisplayName', [num2str(f_max./1e6) ' MHz'], 'Marker', 'd', 'MarkerSize', 10, 'color', 'r');


%% Calculate and plot impedance
Z_antenna = (S11+1)./(1-S11).*Z_0;

figure; hold on;
plot(data.NetworkData.Frequencies, real(Z_antenna), 'DisplayName', 'Real');
plot(data.NetworkData.Frequencies, imag(Z_antenna), 'DisplayName', 'Imaginary');

grid on; legend;
xlabel('Frequency [Hz]'); ylabel('Input Impedance [\Omega]');
title('Input Impedance'); xlim([f_min f_max]);