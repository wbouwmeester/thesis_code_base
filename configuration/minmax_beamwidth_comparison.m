%% Minimum and Maximum Beamwidth comparison
%  This script is used to plot the minimum and maximum bandwidths of an
%  array configuration as function of scan angle. These plots are used for
%  the section on array comparison in the thesis.
%
%  Written by Wietse Bouwmeester
%  Date: 2019-12-18
clear;
close all;

% .mat files of interest
mat_files = [%{'sphere\_arclength(1.45, 0.3, 1.5708)'}, {'sphere_arclength(1.45, 0.3, 1.5708).mat'}
             %{'sphere\_arclength(1.5, 0.3, 2.6180)'}, {'sphere_arclength(1.5, 0.3, 2.6180).mat'}
             %{'cone\_arclength(1.2, 2, 0.3, 10)'}, {'cone_arclength(1.2, 2, 0.3, 10).mat'}
             %{'cylinder\_arclength(1, 1.6, 0.3, 0.1)'}, {'cylinder_arclength(1, 1.6, 0.3, 0.1).mat'}
             
             %{'ellipsoid\_arclength(1.4, 2, 0.3)'}, {'ellipsoid_arclength(1.4, 2, 0.3).mat'}
             
             %{'cone\_faces\_tri\_cap(1.3, 1.5, 6, 0.3, 0.15, 10)'}, {'cone_faces_tri_cap(1.3, 1.5, 6, 0.3, 0.15, 10).mat'}
             %{'cone\_faces\_tri\_cap(1.2, 1.5, 7, 0.3, 0.15, 10)'}, {'cone_faces_tri_cap(1.2, 1.5, 7, 0.3, 0.15, 10).mat'}
             %{'cone\_faces\_tri(1.3, 1.7, 7, 0.3, 0.15, 10)'}, {'cone_faces_tri_cap(1.3, 1.7, 7, 0.3, 0.15, 10).mat'}
             
             %{'cylinder\_faces(1.1, 1.5, 6, 0.3, 0.3, 0.15, 0.2)'}, {'cylinder_faces(1.1, 1.5, 6, 0.3, 0.3, 0.15, 0.2).mat'}
             %{'cylinder\_faces(1.3, 1.8, 5, 0.3, 0.3, 0.15, 0.2)'}, {'cylinder_faces(1.3, 1.8, 5, 0.3, 0.3, 0.15, 0.2).mat'}
             
             %{'sphere\_faces(1.5, 2, 0.3, 0.15, 1.0473)'}, {'sphere_faces(1.5, 2, 0.3, 0.15, 1.0473).mat'}
             %{'sphere\_faces(1.55, 4, 0.3, 0.1, 1.0473)'}, {'sphere_faces(1.55, 4, 0.3, 0.1, 1.0473).mat'}
             
             {'sphere\_geodesic(1.55, 0.3, 2.6180)'}, {'sphere_geodesic(1.55, 0.3, 2.6180).mat'}
             
             %{'sphere\_HEALPix(1.5, 0.3, 2.6180)'}, {'sphere_HEALPix(1.5, 0.3, 2.6180).mat'}
             ];

[N_files,~] = size(mat_files);

% Max scan angle
max_scan_angle = deg2rad(60.01);

% Make plots
for i_files = 1:N_files
    load(cell2mat(mat_files(i_files,2)));
    
    % Plot geometry
    plot_geometry2(element_loc, element_norm, true, false, false, true, deg2rad(90), deg2rad(0), deg2rad(60.01), true, deg2rad(90), deg2rad(-0));
    title(['Array Configuration for ', cell2mat(mat_files(i_files, 1))]);
    
    % Plot beam widths
    for i_Fc = 1:length(Fc)
        figure;
        subplot(2,1,2); hold all;
        for i = 1:length(phi_scan)
            if i < 8
                plot(theta_scan./pi*180, rad2deg(beamwidth_max(:, i, i_Fc)) , ...
                    'DisplayName', ['\phi_s = ' num2str(rad2deg(phi_scan(i))) 'deg']);
            else
                plot(theta_scan./pi*180, rad2deg(beamwidth_max(:, i, i_Fc)) , '--', ...
                    'DisplayName', ['\phi_s = ' num2str(rad2deg(phi_scan(i))) 'deg']);
            end
        end

        title(['Max Beam Width @ F_c = ' num2str(Fc(i_Fc)/1e9) ' GHz for ' cell2mat(mat_files(i_files, 1))]);
        xlabel('\theta_s'); ylabel('HPBW [deg]'); grid on; legend;
        
        subplot(2,1,1); hold all;
        for i = 1:length(phi_scan)
            if i < 8
                plot(theta_scan./pi*180, rad2deg(beamwidth_min(:, i, i_Fc)) , ...
                    'DisplayName', ['\phi_s = ' num2str(rad2deg(phi_scan(i))) 'deg']);
            else
                plot(theta_scan./pi*180, rad2deg(beamwidth_min(:, i, i_Fc)) , '--', ...
                    'DisplayName', ['\phi_s = ' num2str(rad2deg(phi_scan(i))) 'deg']);
            end
        end

        title(['Min Beam Width @ F_c = ' num2str(Fc(i_Fc)/1e9) ' GHz for ' cell2mat(mat_files(i_files, 1))]);
        xlabel('\theta_s'); ylabel('HPBW [deg]'); grid on; legend;
        
        % Calculate maximum operational bandwidth
        bandwidth_max = (1-rad2deg(max(max(beamwidth_max(:,:,i_Fc))))/15)*3e9;
        
        % Calculate eccentricity
        eccentricity = sqrt(1-beamwidth_min(:, :, i_Fc).^2./beamwidth_max(:, :, i_Fc).^2);
        
        % Plot eccentricity
        figure; hold all;
        for i = 1:length(phi_scan)
            if i < 8                                
                plot(theta_scan./pi*180, eccentricity(:, i, i_Fc), ...
                    'DisplayName', ['\phi_s = ' num2str(rad2deg(phi_scan(i))) 'deg']);               
            else                               
                plot(theta_scan./pi*180, eccentricity(:, i, i_Fc), '--', ...
                    'DisplayName', ['\phi_s = ' num2str(rad2deg(phi_scan(i))) 'deg']);               
            end
        end

        title(['Eccentricity of Main Beam @ F_c = ' num2str(Fc(i_Fc)/1e9) ' GHz for ' cell2mat(mat_files(i_files, 1))]);
        xlabel('\theta_s'); ylabel('Eccentricity'); grid on; legend;
    
        % Calculate active area
        [~, N_total] = size(element_loc);
        
        N_active = zeros(length(theta_scan), length(phi_scan));
        for i_theta_scan = 1:length(theta_scan)
            for i_phi_scan = 1:length(phi_scan)
                [~, ~, N_active(i_theta_scan, i_phi_scan)] = active_elements(element_loc, element_norm, max_scan_angle, theta_scan(i_theta_scan), phi_scan(i_phi_scan));
            end
        end
        
        A_active = N_active./N_total.*A;
        
        % Plot fraction of elements times area
        figure; hold all;
        for i = 1:length(phi_scan)
            if i < 8                                
                plot(theta_scan./pi*180, A_active(:,i), ...
                    'DisplayName', ['\phi_s = ' num2str(rad2deg(phi_scan(i))) 'deg']);               
            else                               
                plot(theta_scan./pi*180, A_active(:,i), '--', ...
                    'DisplayName', ['\phi_s = ' num2str(rad2deg(phi_scan(i))) 'deg']);               
            end
        end

        title(['Active Aperture Area @ F_c = ' num2str(Fc(i_Fc)/1e9) ' GHz for ' cell2mat(mat_files(i_files, 1))]);
        xlabel('\theta_s'); ylabel('Area [m^2]'); grid on; legend;
        
        % Report stats
        fprintf('Stats for %s @ %s GHz:\n', cell2mat(mat_files(i_files, 1)), num2str(Fc(i_Fc)/1e9));
        fprintf('\tBandwidth_max: %f MHz\n', bandwidth_max/1e6);
        fprintf('\tHPBW_min: %f\n', rad2deg(min(min(beamwidth_min(:,:,i_Fc)))));
        fprintf('\tHPBW_max: %f\n', rad2deg(max(max(beamwidth_max(:,:,i_Fc)))));
        fprintf('\teccentricity_max: %f\n', max(max(eccentricity)));
        fprintf('\tArea: %f\n', A);
        fprintf('\tA_active_max: %f\n', max(max(A_active)));
    end
end