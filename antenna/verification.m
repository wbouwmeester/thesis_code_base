%% Verification
%  This script compares simulation data of the same antenna for different
%  solver algorithms and/or mesh sizes.
%
%  Written by Wietse Bouwmeester
%  Date: 2020-01-14

clear;
close all;

filenames = [ {'\lambda/10'} {'Cloverleaf_Modified_Ground_10.s2p'} {'Cloverleaf_Modified_Ground_10_15.txt'} {'Cloverleaf_Modified_Ground_10_3.txt'}
              {'\lambda/20'} {'Cloverleaf_Modified_Ground_20.s2p'} {'Cloverleaf_Modified_Ground_20_15.txt'} {'Cloverleaf_Modified_Ground_20_3.txt'}
              {'\lambda/30'} {'Cloverleaf_Modified_Ground_30.s2p'} {'Cloverleaf_Modified_Ground_30_15.txt'} {'Cloverleaf_Modified_Ground_30_3.txt'}
             ];
Z_0 = 100;


fig_z = figure;
fig_ff_15 = figure;
fig_ff_3 = figure;
for i_files = 1:size(filenames,1)
    % Load touchstone
    touchstone = nport(cell2mat(filenames(i_files,2)));
    
    f   = touchstone.NetworkData.Frequencies;
    S11 = squeeze(touchstone.NetworkData.Parameters(1,1,:));
    
    % Calculate impedance
    Z = (S11+1)./(1-S11).*Z_0;
    
    % Plot impedances
    figure(fig_z);
    subplot(2,1,1);  hold on;
    plot(f, real(Z), 'DisplayName', cell2mat(filenames(i_files,1)));
    
    grid on; legend;
    xlabel('Frequency [Hz]'); ylabel('Re(Input Impedance) [\Omega]');
    title('Real Part of Input Impedance');
    
    subplot(2,1,2); hold on;
    plot(f, imag(Z), 'DisplayName', cell2mat(filenames(i_files,1)));
    
    grid on; legend;
    xlabel('Frequency [Hz]'); ylabel('Im(Input Impedance) [\Omega]');
    title('Imaginary Part of Input Impedance');
    
    % Load far fields
    fid = fopen(cell2mat(filenames(i_files, 3)));

    % Discard first two lines
    fgets(fid); fgets(fid);

    % Load data
    FF = fscanf(fid, '%f %f %f %f %f %f %f %f\n', [8, Inf]);

    % Close file
    fclose(fid);
    
    % Setup theta and phi
    theta = deg2rad(FF(1,:)).';
    phi = deg2rad(FF(2,:)).';

    % Setup E_theta and E_phi
    E_theta = FF(4,:).*exp(1j*deg2rad(FF(5,:)));
    E_phi   = FF(6,:).*exp(1j*deg2rad(FF(7,:)));

    % Find number of unique theta and phi coordinates
    N_theta = length(unique(theta));
    N_phi = length(unique(phi));

    % Calculate absolute values of E-fields
    E_abs = sqrt(abs(E_theta).^2+abs(E_phi).^2);
    
    % Normalise
    E_abs = E_abs./max(E_abs);
    
    % Reshape
    theta_res = reshape(theta, [N_theta N_phi]);
    phi_res   = reshape(phi, [N_theta N_phi]);
    E_abs_res = reshape(E_abs, [N_theta N_phi]);

    % Plot far fields at 1.5 GHz
    figure(fig_ff_15);
    subplot(2,1,1); hold on;
    plot(rad2deg(theta_res(:,1)), E_abs_res(:,1), 'DisplayName', cell2mat(filenames(i_files,1)));
    
    grid on; xlabel('\theta'); ylabel('|E|'); title(['\phi = ' num2str(rad2deg(phi_res(1,1)))]);
    legend; xlim([0 90]);
    
    subplot(2,1,2); hold on;
    plot(rad2deg(theta_res(:,91)), E_abs_res(:,91), 'DisplayName', cell2mat(filenames(i_files,1)));
    
    grid on; xlabel('\theta'); ylabel('|E|'); title(['\phi = ' num2str(rad2deg(phi_res(1,91)))]);
    legend; xlim([0 90]);
    
    sgtitle('Normalised E-field cuts @ 1.5 GHz');
    
    % Same for 3 GHz
    fid = fopen(cell2mat(filenames(i_files, 4)));

    % Discard first two lines
    fgets(fid); fgets(fid);

    % Load data
    FF = fscanf(fid, '%f %f %f %f %f %f %f %f\n', [8, Inf]);

    % Close file
    fclose(fid);
    
    % Setup theta and phi
    theta = deg2rad(FF(1,:)).';
    phi = deg2rad(FF(2,:)).';

    % Setup E_theta and E_phi
    E_theta = FF(4,:).*exp(1j*deg2rad(FF(5,:)));
    E_phi   = FF(6,:).*exp(1j*deg2rad(FF(7,:)));

    % Find number of unique theta and phi coordinates
    N_theta = length(unique(theta));
    N_phi = length(unique(phi));

    % Calculate absolute values of E-fields
    E_abs = sqrt(abs(E_theta).^2+abs(E_phi).^2);
    
    % Reshape
    theta_res = reshape(theta, [N_theta N_phi]);
    phi_res   = reshape(phi, [N_theta N_phi]);
    E_abs_res = reshape(E_abs, [N_theta N_phi]);

    % Plot far fields at 1.5 GHz
    figure(fig_ff_3);
    subplot(2,1,1); hold on;
    plot(rad2deg(theta_res(:,1)), E_abs_res(:,1), 'DisplayName', cell2mat(filenames(i_files,1)));
    
    grid on; xlabel('\theta'); ylabel('|E|'); title(['\phi = ' num2str(rad2deg(phi_res(1,1)))]);
    legend; xlim([0 90]);
    
    subplot(2,1,2); hold on;
    plot(rad2deg(theta_res(:,91)), E_abs_res(:,91), 'DisplayName', cell2mat(filenames(i_files,1)));
    
    grid on; xlabel('\theta'); ylabel('|E|'); title(['\phi = ' num2str(rad2deg(phi_res(1,91)))]);
    legend; xlim([0 90]);
    
    sgtitle('Normalised E-field cuts @ 3 GHz');
end

%% Feko comparison
% Feko filenames
feko_names = [%{'Feko \lambda/10'} {'cloverleaf_ground_plane_10_feko.s1p'} {'feko_10.ffe'}
              %{'Feko \lambda/20'} {'cloverleaf_ground_plane_20_feko.s1p'} {'feko_20.ffe'}
              %{'Feko \lambda/30'} {'cloverleaf_ground_plane_30_feko.s1p'} {'feko_30.ffe'}
              %{'Feko fine'} {'cloverleaf_ground_plane_fine_feko.s1p'} {'feko_fine.ffe'}
              {'Standard'} {'cloverleaf_ground_spherical_standard.s1p'} {'ff_standard.ffe'}
              {'Coarse'} {'cloverleaf_ground_spherical_coarse.s1p'} {'ff_coarse.ffe'}
              ];
cst_index = [%3
            ];

% Initialize Feko comparison figures
phi_cut_1 = 0;
phi_cut_2 = deg2rad(90);
ff_frequency = 3e9;

fig_z_feko = figure;
fig_ff_15_feko = figure;
for i_feko = 1:size(feko_names, 1)
    % Reset E_theta E_phi theta and phi
    E_theta = []; E_phi = []; theta = []; phi = [];
    
    % Load touchstone
    touchstone = nport(cell2mat(feko_names(i_feko,2)));
    
    f   = touchstone.NetworkData.Frequencies;
    S11 = squeeze(touchstone.NetworkData.Parameters(1,1,:));
    
    % Calculate impedance and subtract load
    Z = (S11+1)./(1-S11).*Z_0 - Z_0;
    
    % Plot impedances
    figure(fig_z_feko);
    subplot(2,1,1);  hold on;
    plot(f, real(Z), 'DisplayName', [cell2mat(feko_names(i_feko,1))]);
    
    grid on; legend;
    xlabel('Frequency [Hz]'); ylabel('Re(Input Impedance) [\Omega]');
    title('Real Part of Input Impedance');
    
    subplot(2,1,2); hold on;
    plot(f, imag(Z), 'DisplayName', [cell2mat(feko_names(i_feko,1))]);
    
    grid on; legend;
    xlabel('Frequency [Hz]'); ylabel('Im(Input Impedance) [\Omega]');
    title('Imaginary Part of Input Impedance');
    
    % Open far field file
    fid = fopen(cell2mat(feko_names(i_feko,3)));
    
    % Discard first 6 header lines
    for j = 1:6
        fgets(fid);            
    end
    
    % Discard first two lines
    fgets(fid); fgets(fid);

    % Read frequency
    i_freq = 1;
    FF_f(i_feko) = fscanf(fid, '#Frequency: %f\n');

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
            FF_f(i_freq) = fscanf(fid, '#Frequency: %f\n');

            % Skip more lines
            for j = 1:6
                fgets(fid);
            end
        else
            E_theta(i_freq, Nline) = FF(3)+1j.*FF(4);
            E_phi(i_freq, Nline)   = FF(5)+1j.*FF(6);
            
            theta(i_freq, Nline) = deg2rad(FF(1));
            phi(i_freq, Nline) = deg2rad(FF(2));
            
            Nline = Nline+1;
        end

    end
    
    % Close file
    fclose(fid);    
    
    % Calculate E_abs
    E_abs = sqrt(abs(E_theta).^2+abs(E_phi).^2);
    
    % Far fields
    % Find index that is closest to frequency
    index_f = find(abs(FF_f - ff_frequency) == min(abs(FF_f - ff_frequency)));
    
    % Find number of unique theta and phi coordinates
    N_theta = length(unique(theta(index_f, :)));
    N_phi = length(unique(phi(index_f, :)));
    
    % Reshape everything
    theta_res = reshape(theta(index_f, :), [N_theta N_phi]);
    phi_res   = reshape(phi(index_f, :), [N_theta N_phi]);
    
    E_abs_res = reshape(E_abs(index_f, :), [N_theta N_phi]);
    
    % Normalise
    E_abs_res = E_abs_res./max(max(E_abs_res));
    
    % Find indices of phi cuts
    [~,index_phi_1] = find(abs(phi_res - phi_cut_1) == min(min(abs(phi_res - phi_cut_1))), 1);
    [~,index_phi_2] = find(abs(phi_res - phi_cut_2) == min(min(abs(phi_res - phi_cut_2))), 1);
    
    % Plot radiation pattern
    figure(fig_ff_15_feko); subplot(2,1,1); hold on;  
    plot(rad2deg(theta_res(:,index_phi_1)), E_abs_res(:,index_phi_1), 'DisplayName', cell2mat(feko_names(i_feko,1)));
    
    grid on; xlabel('\theta'); ylabel('|E|'); title(['\phi = ' num2str(rad2deg(phi_res(1,index_phi_1)))]);
    legend; xlim([0 180]);
    
    subplot(2,1,2); hold on;
    plot(rad2deg(theta_res(:,index_phi_2)), E_abs_res(:,index_phi_2), 'DisplayName', cell2mat(feko_names(i_feko,1)));

    grid on; xlabel('\theta'); ylabel('|E|'); title(['\phi = ' num2str(rad2deg(phi_res(1,index_phi_2)))]);
    legend; xlim([0 180]);
    
    sgtitle('Normalised E-field cuts @ 3 GHz');
end

% Load and plot the CST Results in the same figures
for i_files = cst_index
    % Load touchstone
    touchstone = nport(cell2mat(filenames(i_files,2)));
    
    f   = touchstone.NetworkData.Frequencies;
    S11 = squeeze(touchstone.NetworkData.Parameters(1,1,:));
    
    % Calculate impedance
    Z = (S11+1)./(1-S11).*Z_0;
    
    % Plot impedances
    figure(fig_z_feko);
    subplot(2,1,1);  hold on;
    plot(f, real(Z), 'DisplayName', ['CST ' cell2mat(filenames(i_files,1))]);
    
    grid on; legend;
    xlabel('Frequency [Hz]'); ylabel('Re(Input Impedance) [\Omega]');
    title('Real Part of Input Impedance');
    
    subplot(2,1,2); hold on;
    plot(f, imag(Z), 'DisplayName', ['CST ' cell2mat(filenames(i_files,1))]);
    
    grid on; legend;
    xlabel('Frequency [Hz]'); ylabel('Im(Input Impedance) [\Omega]');
    title('Imaginary Part of Input Impedance');
    
    % Load far fields
    fid = fopen(cell2mat(filenames(i_files, 3)));

    % Discard first two lines
    fgets(fid); fgets(fid);

    % Load data
    FF = fscanf(fid, '%f %f %f %f %f %f %f %f\n', [8, Inf]);

    % Close file
    fclose(fid);
    
    % Setup theta and phi
    theta = deg2rad(FF(1,:)).';
    phi = deg2rad(FF(2,:)).';

    % Setup E_theta and E_phi
    E_theta = FF(4,:).*exp(1j*deg2rad(FF(5,:)));
    E_phi   = FF(6,:).*exp(1j*deg2rad(FF(7,:)));

    % Find number of unique theta and phi coordinates
    N_theta = length(unique(theta));
    N_phi = length(unique(phi));

    % Calculate absolute values of E-fields
    E_abs = sqrt(abs(E_theta).^2+abs(E_phi).^2);
    
    % Normalise
    E_abs = E_abs./max(E_abs);
    
    % Reshape
    theta_res = reshape(theta, [N_theta N_phi]);
    phi_res   = reshape(phi, [N_theta N_phi]);
    E_abs_res = reshape(E_abs, [N_theta N_phi]);

    % Plot far fields at 1.5 GHz
    figure(fig_ff_15_feko);
    subplot(2,1,1); hold on;
    plot(rad2deg(theta_res(:,1)), E_abs_res(:,1), 'DisplayName', ['CST ' cell2mat(filenames(i_files,1))]);
    
    grid on; xlabel('\theta'); ylabel('|E|'); title(['\phi = ' num2str(rad2deg(phi_res(1,1)))]);
    legend; xlim([0 90]);
    
    subplot(2,1,2); hold on;
    plot(rad2deg(theta_res(:,91)), E_abs_res(:,91), 'DisplayName', ['CST ' cell2mat(filenames(i_files,1))]);
    
    grid on; xlabel('\theta'); ylabel('|E|'); title(['\phi = ' num2str(rad2deg(phi_res(1,91)))]);
    legend; xlim([0 90]);
    
    sgtitle('Normalised E-field cuts @ 1.5 GHz');    
end
         