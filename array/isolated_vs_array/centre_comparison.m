%% Comparison of Feko simulations
%  This script compares resutls from Feko simulations
%
%  Written by Wietse Bouwmeester
%  Date: 2020-01-06

clear;
close all;

% Settings
ff_frequency = 1.5e9;

%% Import Feko files
filenames = [{'Isolated'} {'isolated.ffe'};
             {'Array'} {'side_array_1G5.ffe'}];

for i = 1:size(filenames,1)
    % Load far fields
    % Open file
    filename = cell2mat(filenames(i,2));
    fid = fopen(filename);
    
    % Discard first 6 header lines
    for j = 1:6
        fgets(fid);            
    end
    
    % Discard first two lines
    fgets(fid); fgets(fid);

    % Read frequency
    i_freq = 1;
    FF_f(i, i_freq) = fscanf(fid, '#Frequency: %f\n');

    % Skip more lines
    for j = 1:6
        fgets(fid);
    end
    
    endfile = false; Nline = 1;
    while endfile == false
        % Load data
        FF = fscanf(fid, '%f %f %f %f %f %f %f %f %f\n', [9, 1]);

        if isempty(FF)
            if feof(fid) == true
                break;                
            end
            
            i_freq = i_freq+1;
            Nline = 1;
            
            % Discard first two lines
            fgets(fid); fgets(fid);

            % Read frequency
            FF_f(i, i_freq) = fscanf(fid, '#Frequency: %f\n');

            % Skip more lines
            for j = 1:6
                fgets(fid);
            end
        else
            E_theta(i, i_freq, Nline) = FF(3)+1j.*FF(4);
            E_phi(i, i_freq, Nline)   = FF(5)+1j.*FF(6);
            
            theta(i, i_freq, Nline) = deg2rad(FF(1));
            phi(i, i_freq, Nline) = deg2rad(FF(2));
            
            Nline = Nline+1;
        end

    end
    
    % Close file
    fclose(fid);
end

%% Plot far fields
% Calculate absolute values of far field
E_abs = sqrt(abs(E_theta).^2+abs(E_phi).^2);

% Plot the far field cuts
%Initialise figure
fig_compare = figure; 
hold on;
phi_cut_1 = 0;
phi_cut_2 = deg2rad(90);

for i = 1:size(filenames,1)
    % Find index that is closest to frequency
    index_f = find(abs(FF_f(i,:) - ff_frequency) == min(abs(FF_f(i,:) - ff_frequency)));
    
    % Find number of unique theta and phi coordinates
    N_theta = length(unique(theta(i, index_f, :)));
    N_phi = length(unique(phi(i, index_f, :)));
    N_angles = N_theta.*N_phi;
    
    % Reshape everything
    theta_res = reshape(theta(i, index_f, 1:N_angles), [N_theta N_phi]);
    phi_res   = reshape(phi(i, index_f, 1:N_angles), [N_theta N_phi]);
    
    E_abs_res = reshape(E_abs(i, index_f, 1:N_angles), [N_theta N_phi]);
    
    % Normalise E field
    E_abs_res = E_abs_res./max(max(E_abs_res));
    
    % Find indices of phi cuts
    [~,index_phi_1] = find(abs(phi_res - phi_cut_1) == min(min(abs(phi_res - phi_cut_1))), 1);
    [~,index_phi_2] = find(abs(phi_res - phi_cut_2) == min(min(abs(phi_res - phi_cut_2))), 1);
    
    % Plot radiation pattern
    figure(fig_compare); subplot(2,1,1); hold on;  
    plot(rad2deg(theta_res(:,index_phi_1)), E_abs_res(:,index_phi_1), 'DisplayName', cell2mat(filenames(i,1)));

    subplot(2,1,2); hold on;
    plot(rad2deg(theta_res(:,index_phi_2)), E_abs_res(:,index_phi_2), 'DisplayName', cell2mat(filenames(i,1)));

    % Plot 3D pattern
    C = E_abs_res;
    R = C-min(min(C));

    figure;
    surf(R.*sin(theta_res).*cos(phi_res), R.*sin(theta_res).*sin(phi_res), R.*cos(theta_res), C)

    grid on; shading interp; colorbar;
    title('Rotated 3D Embedded Far E-Field'); axis equal;
    xlabel('x'); ylabel('y'); zlabel('z');
    view([0 0 1]);
end

figure(fig_compare); subplot(2,1,1); 
grid on; xlabel('\theta'); ylabel(' Normalised |E|'); xlim([0 180]); legend;
title(['\phi = ' num2str(rad2deg(phi_res(1,index_phi_1)))]);

subplot(2,1,2);
grid on; xlabel('\theta'); ylabel('Normalised |E|'); xlim([0 180]); legend;
title(['\phi = ' num2str(rad2deg(phi_res(1,index_phi_2)))]);

sgtitle(['E-field cuts @ ' num2str(FF_f(i,index_f)./1e9) ' GHz']);