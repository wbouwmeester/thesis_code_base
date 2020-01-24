%% Create far field fit
%  This script creates a fit of an embedded Feko far field pattern which 
%  can be used in a far field function.

clear;
close all;

% Settings
filename = '8.ffe';
savename = 'cloverleaf_theta_1G3';

resample_theta = 10;
resample_phi = 5;

%% Load Feko far field
% Open file
fid = fopen(filename);

% Discard first 13 lines
for j = 1:13
fgets(fid);
end

% Load data
FF = fscanf(fid, '%f %f %f %f %f %f %f %f %f\n', [9, Inf]);

% Setup E_theta and E_phi
E_theta = FF(3,:)+1j.*FF(4,:);
E_phi   = FF(5,:)+1j.*FF(6,:);

% Calculate absolute value
E_abs = sqrt(abs(E_theta).^2+abs(E_phi).^2); 

% Setup theta and phi
theta = deg2rad(FF(1,:)).';
phi = deg2rad(FF(2,:)).';

% Close file
fclose(fid);

%% Reshape
% Find number of unique theta and phi coordinates
N_theta = length(unique(theta));
N_phi = length(unique(phi));

theta_res = reshape(theta, [N_theta N_phi]);
phi_res = reshape(phi, [N_theta N_phi]);
E_abs_res = reshape(E_abs, [N_theta N_phi]);

%% Resample
% Resample the data with factors indicated in the settings
theta_res = theta_res(1:resample_theta:end, 1:resample_phi:end);
phi_res = phi_res(1:resample_theta:end, 1:resample_phi:end);
E_abs_res = E_abs_res(1:resample_theta:end, 1:resample_phi:end);

%% Create fit
% Shape the data back to column vectors
N_entries = numel(theta_res);
theta_res = reshape(theta_res, [N_entries 1]);
phi_res = reshape(phi_res, [N_entries 1]);
E_abs_res = reshape(E_abs_res, [N_entries 1]);

far_field_fit = fit([theta_res, phi_res], E_abs_res, 'linearinterp');

%% Save  the fit to a file
save(['matlab_functions/far_fields/fits/' savename '.mat'], 'far_field_fit');