%% Polarisation demonstration
%  This script demonstrates the effect of phase and amplitude differences
%  between two orthogonal vectors of for example the electric field.
%
%  Written by Wietse Bouwmeester
%  Date: 2019-12-18

clear;
close all;

% Constants
calculate = true;
filename = 'ellipse_1_90.mat';

E_theta_abs     = 1;
E_theta_phase   = deg2rad(0);

E_phi_abs       = 1;
E_phi_phase     = deg2rad(45);

Fc              = 3e9; 

%% Calculate total field vectors
t = 0:1/(100*Fc):1/Fc;

E_theta = E_theta_abs.*exp(1j*E_theta_phase).*exp(-1j*2*pi*Fc*t);
E_phi = E_phi_abs.*exp(1j*E_phi_phase).*exp(-1j*2*pi*Fc*t);

%% Plot field
if calculate == true
    fig = figure;
    for i = 1:length(t)
        quiver(0,0, real(E_phi(i)), 0, 0, 'DisplayName', 'E_{\phi}');
        hold on;
        quiver(0,0, 0, real(E_theta(i)), 0, 'DisplayName', 'E_{\theta}');
        quiver(0,0, real(E_phi(i)), real(E_theta(i)), 0, 'DisplayName', 'E_{tot}');
        plot(real(E_phi), real(E_theta), 'DisplayName', 'Trace');

        xlabel('E_\phi'); ylabel('E_\theta'); grid on;
        axis equal; legend; drawnow;

        frame(i) = getframe(gcf);
        hold off;
    end
    save(filename, 'frame');
else
    load(filename);
    
    fig = figure;
    movie(fig, frame, 10, 30);
end
