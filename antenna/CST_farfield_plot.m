%% CST Farfield Plot
%  This script plots the far field as exported from CST
%
%  Written by Wietse Bouwmeester
%  Date: 2019-12-31

clear;
close all;

%% Import files from CST
filename = 'Cloverleaf_Modified_Ground'; indB = false;
f = [1.5e9 2.25e9 3e9 1.2e9];

E_hor = []; E_ver = []; 
for i = 1:length(f)
    fid = fopen([filename num2str(i) '.txt']);

    % Discard first two lines
    fgets(fid); fgets(fid);

    % Load data
    FF = fscanf(fid, '%f %f %f %f %f %f %f %f\n', [8, Inf]);

    % Setup E_theta and E_phi
     if indB == true
        E_hor = [E_hor; 
                 10.^(FF(4,:)./20).*exp(1j*deg2rad(FF(5,:)))];
        E_ver = [E_ver;
                 10.^(FF(6,:)./20).*exp(1j*deg2rad(FF(7,:)))];
    else
        E_hor = [E_hor; 
                 FF(4,:).*exp(1j*deg2rad(FF(5,:)))];
        E_ver = [E_ver;
                 FF(6,:).*exp(1j*deg2rad(FF(7,:)))];
    end
    
           
    % Close file
    fclose(fid);
end

% Setup theta and phi
theta = deg2rad(FF(1,:)).';
phi = deg2rad(FF(2,:)).';

% Find number of unique theta and phi coordinates
N_theta = length(unique(theta));
N_phi = length(unique(phi));

% Reshape all data
theta_res = reshape(theta, [N_theta, N_phi]);
phi_res = reshape(phi, [N_theta, N_phi]);

% E_theta_res = double.empty(length(f), 0, 0);
% E_phi_res = E_theta_res;
for i = 1:length(f)
    E_hor_res(i, :, :) = reshape(E_hor(i,:), [N_theta, N_phi]);
    E_ver_res(i, :, :) = reshape(E_ver(i,:), [N_theta, N_phi]);
end

% Calculate absolute values of E-fields
E_abs = sqrt(abs(E_hor_res).^2+abs(E_ver_res).^2);
E_abs_db = 20.*log10(E_abs);

% Normalise
E_abs_db = E_abs_db - max(max(E_abs_db, [], 3), [], 2);

%% X-pol isolation
X_pol_ver = sqrt(abs(E_ver_res./E_hor_res));
X_pol_ver_db = 10*log10(X_pol_ver);

% Find minimum value within the range theta <= 60
X_pol_ver_min = min(min(X_pol_ver(:, 1:61, :), [], 2), [], 3);
X_pol_ver_min_db = 10*log10(X_pol_ver_min);

%% Plot farfield
% Absolute far fields
figure; 
subplot(2,1,1); hold on;
for i = 1:length(f)
    plot(rad2deg(theta_res(:,1)), E_abs_db(i, :,1), 'DisplayName', [num2str(f(i)/1e9) ' GHz']);
end

xlabel('\theta'); ylabel('Normalised |E| [dB]'); title('H-plane');
legend; grid on; ylim([-10 0]); xlim([0 90]);

subplot(2,1,2); hold on;
for i = 1:length(f)
    plot(rad2deg(theta_res(:,91)), E_abs_db(i,:,91), 'DisplayName', [num2str(f(i)/1e9) ' GHz']);
end

xlabel('\theta'); ylabel('Normalised |E| [dB]'); title('E-plane');
legend; grid on; ylim([-10 0]); xlim([0 90]);

% Plot X-pol
figure; hold on;
for i = 1:length(f)
    plot(rad2deg(theta_res(:,46)), X_pol_ver(i,:,46), 'DisplayName', [num2str(f(i)/1e9) ' GHz']);
end

xlabel('\theta'); ylabel('Xpol [dB]'); title('X-pol isolation');
legend; grid on; xlim([0 90]);

% Surface plot of X-plot
for i = 1:length(f)
    figure;
    surf(rad2deg(theta_res), rad2deg(phi_res), squeeze(X_pol_ver_db(i,:,:)));

    title(['Cross Polarisation Isolation [dB] @ ' num2str(f(i)./1e9) ' GHz']);
    colorbar; caxis([0 30]); xlabel('\theta'); ylabel('\phi');
    shading interp; view([0 0 1]); xlim([0 60]); ylim([0 359]);
end