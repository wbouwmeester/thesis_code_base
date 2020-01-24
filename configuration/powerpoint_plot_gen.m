%% Powerpoint Plot generator

clear;
close all;

max_scan_angle = deg2rad(60.01);

% .mat files of interest
mat_files = [%{'sphere\_arclength(1.5, 0.3, 1.5708)'}, {'sphere_arclength(1.5, 0.3, 1.5708).mat'}
             %{'sphere\_arclength(1.55, 0.3, 2.6180)'}, {'sphere_arclength(1.55, 0.3, 2.6180).mat'}
             %{'cone\_arclength(1.4, 2.2, 0.3, 10)'}, {'cone_arclength(1.4, 2.2, 0.3, 10).mat'}
             %{'cylinder\_arclength(1.4, 2.3, 0.3, 0.15)'}, {'cylinder_arclength(1.4, 2.3, 0.3, 0.15).mat'}
             {'sphere\_HEALPix(1.5, 0.3, 2.6180)'}, {'sphere_HEALPix(1.5, 0.3, 2.6180).mat'}
             %{'ellipsoid\_arclength(1.5, 2.1, 0.3)'}, {'ellipsoid_arclength(1.5, 2.1, 0.3).mat'}
             %{'cylinder\_faces(1.5, 1.8, 6, 0.3, 0.3, 0.15, 0.2)'}, {'cylinder_faces(1.5, 1.8, 6, 0.3, 0.3, 0.15, 0.2).mat'}
             %{'cone\_faces(1.6, 1.8, 6, 0.3, 0.3, 0.15, 10)'}, {'cone_faces(1.6, 1.8, 6, 0.3, 0.3, 0.15, 10).mat'}
             %{'sphere\_faces(1.6, 4, 0.3, 0.1, deg2rad(60))'}, {'sphere_faces(1.6, 4, 0.3, 0.1, deg2rad(60)).mat'}
             %{'sphere\_faces(1.6, 2, 0.3, 0.15, deg2rad(60))'}, {'sphere_faces(1.6, 2, 0.3, 0.15, deg2rad(60)).mat'}
             %{'sphere\_geodesic(1.55, 0.3, 2.6180)'}, {'sphere_geodesic(1.55, 0.3, 2.6180).mat'}
             ];

[N_files,~] = size(mat_files);

% Plot beamwidth as function of theta (new figure for every geometry)
for i_files = 1:N_files
    load(cell2mat(mat_files(i_files,2)));
    
    % Plot geometry
    plot_geometry(element_loc, element_norm, true);
    title(['Array Geometry for ', cell2mat(mat_files(i_files, 1))]);
    
    for i_Fc = 1:length(Fc)
        figure; 
        subplot(3,1,1); hold all;
        for i = 1:length(phi_scan)
            if i < 8
                plot(theta_scan./pi*180, rad2deg(beamwidth_max(:, i, i_Fc)) , ...
                    'DisplayName', ['\phi = ' num2str(rad2deg(phi_scan(i))) 'deg']);
            else
                plot(theta_scan./pi*180, rad2deg(beamwidth_max(:, i, i_Fc)) , '--', ...
                    'DisplayName', ['\phi = ' num2str(rad2deg(phi_scan(i))) 'deg']);
            end
        end

        title(['Beam Width @ F_c = ' num2str(Fc(i_Fc)/1e9) ' GHz for ' cell2mat(mat_files(i_files, 1))]);
        xlabel('\theta_s'); ylabel('HPBW [deg]'); grid on; legend;

        % Plot corresponding phi for this maximum beamwidth
        subplot(3,1,2); hold all;
        for i = 1:length(phi_scan)
            if i < 8
                plot(theta_scan./pi*180, rad2deg(phi_beamwidth_max(:, i, i_Fc)) , ...
                    'DisplayName', ['\phi = ' num2str(rad2deg(phi_scan(i))) 'deg']);
            else
                plot(theta_scan./pi*180, rad2deg(phi_beamwidth_max(:, i, i_Fc)) , '--', ...
                     'DisplayName', ['\phi = ' num2str(rad2deg(phi_scan(i))) 'deg']);
            end
        end

        xlabel('\theta_s'); ylabel('\phi_{max} [deg]'); grid on;
        
        % Plot active elements
        subplot(3,1,3); hold all;
        for i = 1:length(phi_scan)
            % Calculate number of active elements
            for j = 1:length(theta_scan)
                [~, ~, N_active(j,i)] = active_elements(element_loc, element_norm, max_scan_angle, theta_scan(j), phi_scan(i));
            end
            
            if i < 8
                plot(theta_scan./pi*180, N_active(:,i), ...
                    'DisplayName', ['\phi = ' num2str(rad2deg(phi_scan(i))) 'deg']);
            else
                plot(theta_scan./pi*180, N_active(:,i), '--', ...
                     'DisplayName', ['\phi = ' num2str(rad2deg(phi_scan(i))) 'deg']);
            end 
        end
        
        xlabel('\theta_s'); ylabel('N_{active}'); grid on;
    end
end