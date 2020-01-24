%% Active element comparison
%  This script compares the number of active elements for a given geometry
%  and the achieved beamwidth
%
%  Written by Wietse Bouwmeester
%  Date: 2019-06-30
clear;
close all;

% Filenames
% .mat files of interest
mat_files = [%{'sphere\_arclength(3, 0.3, 1.5708)'}, {'sphere_arclength(3, 0.3, 1.5708).mat'}
             %{'sphere\_arclength(1.75, 0.3, 2.6180)'}, {'sphere_arclength(1.75, 0.3, 2.6180).mat'}
             %{'cone\_arclength(2.3, 3.2, 0.3, 10)'}, {'cone_arclength(2.3, 3.2, 0.3, 10).mat'}
             %{'cylinder\_arclength(1.95, 2.85, 0.3, 0.15)'}, {'cylinder_arclength(1.95, 2.85, 0.3, 0.15).mat'}
             %{'ellipsoid\_arclength(2, 2.9, 0.3)'}, {'ellipsoid_arclength(2, 2.9, 0.3).mat'}
             %{'cylinder\_faces(2.8, 3, 6, 0.3, 0.3, 0.15)'}, {'cylinder_faces(2.8, 3, 6, 0.3, 0.3, 0.15).mat'}
             %{'cone\_faces(4, 3.6, 6, 0.3, 0.3, 0.15, 10)'}, {'cone_faces(4, 3.6, 6, 0.3, 0.3, 0.15, 10).mat'}
             %{'cone\_faces\_cap(3, 8, 6, 0.3, 0.3, 0.15, 2.7)'}, {'cone_faces_cap(3, 8, 6, 0.3, 0.3, 0.15, 2.7).mat'}
             %{'sphere\_faces(1.75, 1, 0.3, 0.15, deg2rad(60))'}, {'sphere_faces(1.75, 1, 0.3, 0.15, deg2rad(60)).mat'}
             %{'sphere\_faces(1.6, 2, 0.3, 0.15, deg2rad(60))'}, {'sphere_faces(1.6, 2, 0.3, 0.15, deg2rad(60)).mat'}
             %{'sphere\_faces(1.6, 3, 0.3, 0.15, deg2rad(60))'}, {'sphere_faces(1.6, 3, 0.3, 0.15, deg2rad(60)).mat'}
             {'sphere\_faces(1.55, 4, 0.3, 0.1, 1.0473)'}, {'sphere_faces(1.55, 4, 0.3, 0.1, 1.0473).mat'}
            ];

[N_files,~] = size(mat_files);
         
% % Plot beamwidth as function of theta (new figure for every geometry)
% for i_files = 1:N_files
%     figure; hold on;
%     load(cell2mat(mat_files(i_files,2)));
%     for i = 1:length(phi_scan)
%         if i < 8
%             plot(theta_scan./pi*180, rad2deg(beamwidth_max(:, i, 1)), ...
%                 'DisplayName', ['\phi = ' num2str(rad2deg(phi_scan(i))) 'deg']);
%         else
%             plot(theta_scan./pi*180, rad2deg(beamwidth_max(:, i, 1)), '--', ...
%             'DisplayName', ['\phi = ' num2str(rad2deg(phi_scan(i))) 'deg']);
%         end
%     end
%     title(['Beamwidths ' cell2mat(mat_files(i_files,1)) ' at F_c = ' num2str(Fc(1)/1e9) ' GHz']);
%     xlabel('\theta_s'); ylabel('HPBW [deg]'); grid on; legend;
% end

% Plot beamwidth as function of theta (new figure for every geometry)
for i_files = 1:N_files
    load(cell2mat(mat_files(i_files,2)));
    plot_geometry(element_loc, element_norm);    
    
    for i_Fc = 1:length(Fc)
        figure; 
        subplot(2,1,1); hold all;
        for i = 1:length(phi_scan)
            if i < 8
                plot(theta_scan./pi*180, rad2deg(beamwidth_max(:, i, i_Fc)) , ...
                    'DisplayName', ['\phi = ' num2str(rad2deg(phi_scan(i))) 'deg']);
            else
                plot(theta_scan./pi*180, rad2deg(beamwidth_max(:, i, i_Fc)) , '--', ...
                    'DisplayName', ['\phi = ' num2str(rad2deg(phi_scan(i))) 'deg']);
            end
        end

        title([cell2mat(mat_files(i_files, 1)) ' @ F_c = ' num2str(Fc(i_Fc)/1e9) ' GHz']);
        xlabel('\theta_s'); ylabel('HPBW [deg]'); grid on; legend;

        % Plot corresponding phi for this maximum beamwidth
        subplot(2,1,2); hold all;
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
    end
end

% Plot number of active elements as function of theta (new figure for every 
% geometry)
for i_files = 1:N_files
    figure; hold on;
    load(cell2mat(mat_files(i_files,2)));
    
    for i = 1:length(phi_scan)
        N_active = zeros(1, length(theta_scan));
        for j = 1:length(theta_scan)
            [~, ~, N_active(j)] = active_elements(element_loc, element_norm, element_max_angle, theta_scan(j), phi_scan(i));
        end
        
        plot(theta_scan./pi*180, N_active, ...
            'DisplayName', ['\phi = ' num2str(rad2deg(phi_scan(i))) 'deg']);        
    end
    title(['Active Elements ' cell2mat(mat_files(i_files,1)) ' at F_c = ' num2str(Fc(1)/1e9) ' GHz']);
    xlabel('\theta_s'); ylabel('N_{active elements}'); grid on; legend;
end

