clear;
close all;

%% Frequencies
N_Fc                = 2;
Fc                  = linspace(1.5e9, 3e9, N_Fc);

%% Scan angle settings
theta_scan          = deg2rad(40);
phi_scan            = deg2rad(0);
element_max_angle   = deg2rad(60.01);

%% Observation grid
theta               = 0:deg2rad(0.1):deg2rad(180);
phi                 = 0:deg2rad(1):deg2rad(360);
[theta, phi]        = meshgrid(theta,phi);

%% Array geometry
% Setup array element locations, specified as x,y,z per point in a column 
% vector

% [element_loc, element_norm] = cone_arclength(R,H,0.3,H);
% [element_loc, element_norm] = sphere_arclength(1.5, 0.3, 1.5708);
% [element_loc, element_norm] = cylinder_arclength(1.4, 2.3, 0.3, 0.15);
% [element_loc, element_norm] = sphere_distance(1000, R, 1000, deg2rad(225));
% [element_loc, element_norm] = sphere_spherical(1, 15, 15, 2*pi);
% [element_loc, element_norm] = sphere_cartesian(1.5, 5, 5);
% [element_loc, element_norm] = planar(21, 21, 2, 2);
% element_loc(3,:) = sqrt(2-element_loc(1,:).^2-element_loc(2,:).^2);
% [element_loc, element_norm] = planar_tri(11, 11, 10, 10);
% [element_loc, element_norm] = cone_faces(R, 4.3, 3, 0.5, 0.5, 0.25, 8.6);
% [element_loc, element_norm] = sphere_HEALPix(1, 0.3, pi/2);
% [element_loc, element_norm] = planar_regular_z(11,11,11,10,10,10);
% [element_loc, element_norm] = sphere_geodesic(1.55, 0.3, 2.6180);
[element_loc, element_norm] = planar(11, 11, 1, 1);

%% Element pattern
element_FF = 'FF_cos';
%element_FF = [];

%% Array FF calculation
FF = FF_conformal(theta, phi, theta_scan, phi_scan, Fc, ...
                  element_loc, element_norm, element_FF, element_max_angle);      
              
%% Estimate beamwidth
% Find the cut indices
[~, index_theta] = find(abs(theta-theta_scan) == min(min(abs(theta-theta_scan))));
index_theta = index_theta(1);

[index_phi, ~] = find(abs(phi-phi_scan) == min(min(abs(phi-phi_scan))));
index_phi = index_phi(1);

beamwidth_theta = rad2deg(HPBW((squeeze(FF(index_phi,:,:))), theta(index_phi,:), theta_scan));
beamwidth_phi = rad2deg(HPBW((squeeze(FF(:,index_theta,:))), phi(:,index_theta), phi_scan));

%% Plot stuff
% Plot the radiation patterns
figure; hold on;
for i = 1:N_Fc
    plot(theta(index_phi,:)./pi*180, 20*log10(abs(squeeze(FF(index_phi,:,i)))), ...
         'DisplayName', ['f = ' num2str(Fc(i)./1e6) 'MHz']);   
end

grid on; legend; ylim([-40 0]);
xlabel('\theta [deg]'); ylabel('FF [dB]'); title(['Array Far Field (\phi = ' num2str(rad2deg(phi(index_phi,1))) ' deg)']);

figure; hold on;
for i = 1:N_Fc
    plot(phi(:,index_theta)./pi*180, 20*log10(abs(squeeze(FF(:,index_theta,i)))), ...
         'DisplayName', ['f = ' num2str(Fc(i)./1e6) 'MHz']);   
end

grid on; legend; ylim([-40 0]);
xlabel('\phi [deg]'); ylabel('FF [dB]'); title(['Array Far Field (\theta = ' num2str(rad2deg(theta(1,index_theta))) ' deg)']);

% Make surface plot
figure;
surf(theta./pi*180, phi./pi*180, 20*log10(abs(squeeze(FF(:,:,1)))))

view([0 0 1]);
grid on; shading interp; colorbar; caxis([-40 0]); axis equal;
xlabel('\theta [deg]'); ylabel('\phi [deg]'); title('Array Far Field');

% Make uv surface plot
figure;
surf(sin(theta).*cos(phi), sin(theta).*sin(phi), 20.*log10(abs(squeeze(FF(:,:,1)))))

view([0 0 1]);
grid on; shading interp; colorbar; caxis([-40 0]); axis equal;
xlabel('u [m]'); ylabel('v [m]'); title('Array Far Field');

% Make a 3D radiation plot
C = 20.*log10(abs(squeeze(FF(:,:,1))));
C(C<-40) = -40;
R = C-min(min(C));

figure;
surf(R.*sin(theta).*cos(phi), R.*sin(theta).*sin(phi), R.*cos(theta), C)

grid on; shading interp; colorbar; caxis([-40 0]);
title('3D Normalized Array Far Field [dB]'); axis equal;
xlabel('x'); ylabel('y');

% Calculate and plot element radiation pattern
theta_lin = reshape(theta, [1, numel(theta)]);
phi_lin = reshape(phi, [1, numel(phi)]);

E_element = reshape(FF_cloverleaf(theta_lin, phi_lin), size(theta));
C = 20.*log10(abs(E_element));
C(C<-40) = -40;
R = C-min(min(C));

figure;
surf(R.*sin(theta).*cos(phi), R.*sin(theta).*sin(phi), R.*cos(theta), C)

grid on; shading interp; colorbar; caxis([-40 0]);
title('3D Normalized Element Far Field [dB]'); axis equal;
xlabel('x'); ylabel('y');