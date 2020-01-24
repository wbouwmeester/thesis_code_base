%% FEKO Input generator
%  This script generates the input for the FEKO script so it can generate
%  the requested array.
%
%  Written by Wietse Bouwmeester
%  Date: 2019-12-7

clear;
close all;

% Constants and settings
c = 3e8;
f = 1.5e9;

lambda = c/f;
k = 2*pi/lambda;

% Scan angles
theta_scan = deg2rad(30):deg2rad(20):deg2rad(90);
phi_scan = 0:deg2rad(20):deg2rad(40);

[theta_scan, phi_scan] = meshgrid(theta_scan, phi_scan);
theta_scan_beta = reshape(theta_scan, [numel(theta_scan), 1]);
phi_scan_beta = reshape(phi_scan, [numel(phi_scan), 1]);

%% Generate topology
% Generate topology
[element_loc, element_norm] = sphere_geodesic(1.55, 0.3, deg2rad(145));

% Translate so that the sphere is standing on the x,y plane (optional)
% element_loc(3,:) = element_loc(3,:)+1.55;

%% Remove elements from set to generate partial array
% Define scan angle and max angle
theta_scan = deg2rad(90);
phi_scan = deg2rad(0);
max_angle = deg2rad(180);

% Calculate angle between scan and element normals
[element_loc, element_norm] = active_elements(element_loc, element_norm, max_angle, theta_scan, phi_scan);

% Calculate beta phase shifts
beta = -k.*(sin(theta_scan_beta).*cos(phi_scan_beta).*element_loc(1,:) + ...
            sin(theta_scan_beta).*sin(phi_scan_beta).*element_loc(2,:) + ...
            cos(theta_scan_beta).*element_loc(3,:)).';

beta = rad2deg(beta).';       
        
% element_loc = rotate(element_loc, deg2rad(-90), 'y');
% element_norm = rotate(element_norm, deg2rad(-90), 'y');

% figure;
% plot3(element_loc_rot(1,:), element_loc_rot(2,:), element_loc_rot(3,:), '*')
% 
% grid on; axis equal;
% xlabel('x'); ylabel('y'); zlabel('z');

%% Find theta and phi off all remaining elements
theta = atan2(sqrt(element_norm(1,:).^2+element_norm(2,:).^2),element_norm(3,:));
phi = atan2(element_norm(2,:), element_norm(1,:));

%% Generate the rotations and translation
% First rotation around y (assuming the antenna element is in the x,y plane)
rot1 = rad2deg(theta);

% Second rotation along z
rot2 = rad2deg(phi);

% Translations
posx = element_loc(1,:);
posy = element_loc(2,:);
posz = element_loc(3,:);

%% Generate input file
filename = 'FEKO_input.txt';
fid = fopen(filename, 'w');

fprintf(fid, 'N_elements = %d\n', length(rot1));

fprintf(fid, 'rot1 = {');
for i = 1:length(rot1)-1
    fprintf(fid, '%f, ', rot1(i)); 
end
fprintf(fid, '%f}\n', rot1(i+1));

fprintf(fid, 'rot2 = {');
for i = 1:length(rot2)-1
    fprintf(fid, '%f, ', rot2(i)); 
end
fprintf(fid, '%f}\n', rot2(i+1));

fprintf(fid, 'posx = {');
for i = 1:length(posx)-1
    fprintf(fid, '%f, ', posx(i)); 
end
fprintf(fid, '%f}\n', posx(i+1));

fprintf(fid, 'posy = {');
for i = 1:length(posy)-1
    fprintf(fid, '%f, ', posy(i)); 
end
fprintf(fid, '%f}\n', posy(i+1));

fprintf(fid, 'posz = {');
for i = 1:length(posz)-1
    fprintf(fid, '%f, ', posz(i)); 
end
fprintf(fid, '%f}\n', posz(i+1));

% beta
fprintf(fid, 'beta = {');
for i = 1:size(beta,1)
    fprintf(fid, '{');
    for j = 1:size(beta,2)-1
        fprintf(fid, '%f, ', beta(i,j));
    end
    
    if i == size(beta, 1)
        fprintf(fid, '%f}', beta(i,j+1));
    else
        fprintf(fid, '%f}, ', beta(i,j+1));
    end
end
fprintf(fid, '}');

fclose(fid);

%% Check how the array would look in Feko
element_theta = [1; 0; 0];
element_phi = [0; 1; 0];
element_norm_original = [0; 0; 1];

% Apply rotations and translations
for i = 1:length(rot1)
    element_theta_feko(:,i) = rotate(element_theta, deg2rad(rot1(i)), 'y');
    element_phi_feko(:,i) = rotate(element_phi, deg2rad(rot1(i)), 'y');
    element_norm_feko(:,i) = rotate(element_norm_original, deg2rad(rot1(i)), 'y');

    element_theta_feko(:,i) = rotate(element_theta_feko(:,i), deg2rad(rot2(i)), 'z');
    element_phi_feko(:,i) = rotate(element_phi_feko(:,i), deg2rad(rot2(i)), 'z');
    element_norm_feko(:,i) = rotate(element_norm_feko(:,i), deg2rad(rot2(i)), 'z');
end

% element_theta_feko = rotate(element_theta_feko, deg2rad(-90), 'y');
% element_phi_feko = rotate(element_phi_feko, deg2rad(-90), 'y');
% element_norm_feko = rotate(element_norm_feko, deg2rad(-90), 'y');
% 
% element_loc = rotate(element_loc, deg2rad(-90), 'y');
% posx = element_loc(1,:);
% posy = element_loc(2,:);
% posz = element_loc(3,:);

figure; hold on;
plot3(posx, posy, posz, '*', 'DisplayName', 'Pos');
quiver3(posx, posy, posz, ...
        element_norm_feko(1,:), element_norm_feko(2,:), element_norm_feko(3,:), 'DisplayName', 'Norm');
quiver3(posx, posy, posz, ...
        element_theta_feko(1,:), element_theta_feko(2,:), element_theta_feko(3,:), 'DisplayName', 'Theta');
quiver3(posx, posy, posz, ...
        element_phi_feko(1,:), element_phi_feko(2,:), element_phi_feko(3,:), 'DisplayName', 'Phi');

grid on; xlabel('x'); ylabel('y'); zlabel('z'); axis equal; legend;