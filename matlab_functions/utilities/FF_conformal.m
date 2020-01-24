function [array_FF] = FF_conformal(theta, phi, theta_scan, phi_scan, f, ...
                                   element_loc, element_norm, single_element_FF, element_max_angle)
%FF_CONFORMAL Far field of a conformal array
%   [array_AF] = FF_CONFORMAL(theta, phi, theta_scan, phi_scan, f, element_loc, element_norm, single_element_FF, element_max_angle)
%   calculates the far field of a certain array geometry specified by
%   element_loc at observation angles specified by theta and phi. 
%   element_loc is a 3xN_elements array with the rows indicating x, y and z
%   respectively. f is a list of frequencies for which the far field
%   pattern is to be calculated. The scan angle is specified by theta_scan
%   and phi_scan. element_norm contains the normal vectors of all elements
%   specified in the same format as element_loc. The active element pattern
%   can be specified by the single_element_FF parameter. This parameter
%   should have the same format as theta and phi meshgrids. If this is not
%   the case, isotropic elements are assumed.
%
%   FF_CONFORMAL returns a 3 dimensional matrix where the first two
%   dimensions correspond to the meshgrid of theta and phi observation
%   angles and the 3 dimension indicates the frequency.
%
%   The individual element far fields are considered in
%   this calculations, this can be an active element pattern in order to
%   also take coupling into consideration. 
%   
%   Excitations of elements are calculated on a maximum scan angle per
%   element. For elements with scanning angles beyond the 
%   element_max_angle, their excitation is set to 0.
%
%   TO DO'S:
%   1. TAKE EXCITATION CALCULATIONS OUTSIDE THE FUNCTION SO THAT A SEPERATE
%   SCRIPT CAN OPTIMISE THE ELEMENT EXCITATIONS FOR IDEAL SIDELOBE
%   BEHAVIOUR.
%   2. SINGLE_ELEMENT_FF IS CURRENTLY OVERWRITTEN BY ANALYTICAL FF 
%   FUNCTIONS FOR SPEED IMPROVEMENTS. IF A CUSTOM PATTERN IS REQUIRED,
%   THE INTERPOLATION PART OF THE SCRIPT SHOULD BE COMMENTED OUT.
%
%   Written by Wietse Bouwmeester
%   Date: 2019-05-27

% Settings
mem_ratio_min = 3;

% Constants
c = 3e8;

% Derived values
k = 2*pi*f./c;

% Determine the number of elements in array and frequencies to be
% considered
N_f = numel(f);

%% Element Excitations
% Calculate element excitations -- IN FUTURE TAKE THIS OUTSIDE FUNCTION SO
% IT CAN BE OPTIMIZED IN ANOTHER SCRIPT

% Find active elements
[element_active, element_active_norm, N_active_elements] = ...
    active_elements(element_loc, element_norm, element_max_angle, ...
                    theta_scan, phi_scan);

% Assign weights to all elements
A_active = ones(1, N_active_elements);

%% Element Phase Shifts
% Calculate the phase shift of the elements to steer the main beam in the
% phi_scan and theta_scan directions (only for active elements to speed up
% calculations)
beta = -k.'*(sin(theta_scan).*cos(phi_scan).*element_active(1,:) + ...
             sin(theta_scan).*sin(phi_scan).*element_active(2,:) + ...
             cos(theta_scan).*element_active(3,:));
         
%% Element Radiation Patterns
% Setup element far fields

% Check if an isotropic pattern is given
if isempty(single_element_FF)
    isotropic = true;
else
    isotropic = false;
end

if isotropic == false
    % Find angle between z-axis and normal vector and setup theta_hat and
    % phi_hat
    theta_rot = acos(element_active_norm(3,:));
    phi_rot = atan2(element_active_norm(2,:), element_active_norm(1,:));
    
    theta_hat = [cos(theta_rot).*cos(phi_rot); 
                 cos(theta_rot).*sin(phi_rot);
                 -sin(theta_rot)];
    phi_hat = [-sin(phi_rot);
               cos(phi_rot);
               zeros(1, N_active_elements)];
    
    % Save original size and vectorize observation angles
    oSize = size(theta);
    N_angles = numel(theta);

    theta_lin = reshape(theta, [1, N_angles]);
    phi_lin = reshape(phi, [1, N_angles]);
    
    % Find x, y and z components for all observation angles
    x_obs = sin(theta_lin).*cos(phi_lin);
    y_obs = sin(theta_lin).*sin(phi_lin);
    z_obs = cos(theta_lin);
    
    % Setup element_FF
    element_FFs = zeros([size(theta), N_active_elements]); 
    element_FFs_lin = zeros(N_active_elements, N_angles);
    
    for i = 1:N_active_elements
        % Calculate projections of observation vectors on local grids to
        % find the apparent observation vectors
        x_apparent = theta_hat(:,i)'*[x_obs; y_obs; z_obs];
        y_apparent = phi_hat(:,i)'*[x_obs; y_obs; z_obs];
        z_apparent = element_active_norm(:,i)'*[x_obs; y_obs; z_obs];
        
        % Transform these observation vectors to theta and phi
        theta_apparent = acos(z_apparent);
        phi_apparent = atan2(y_apparent, x_apparent);
        
        % Throw away imagnary part that occurs due to numerical errors
        theta_apparent = real(theta_apparent);
        
        % Resample at original theta and phi
        % element_FFs_lin = single_element_FF(mod(theta_apparent,pi), mod(phi_apparent,2*pi));
        % element_FFs_lin(i,:) = FF_cloverleaf(mod(theta_apparent,pi), mod(phi_apparent, 2*pi));
        % element_FFs_lin(i,:) = FF_ideal(mod(theta_apparent,pi), element_max_angle);
        
        element_FFs_lin(i,:) = eval([single_element_FF '(mod(theta_apparent,pi), mod(phi_apparent, 2*pi))']);
        
        % Reformat to theta and phi grids
        element_FFs(:,:,i) = reshape(element_FFs_lin(i,:), oSize);        
    end
end
         
%% Array Far Field
% Calculate the array far field using one of two methods for array far
% field computation. The first one relies on matrix math, the second one on 
% a loop per element. Matrix method is quicker if enough free memory is
% available, the element method is quicker when memory is limited.

% Allocate memory for FF
array_FF = zeros([size(theta) N_f]);

% Estimate needed memory for matrix method
N_angles = numel(theta);
mem_req = N_angles*N_active_elements*16;
[~, mem_free] = memory; mem_free = mem_free.PhysicalMemory.Available;
mem_ratio = mem_free/mem_req;

% Choose between fast memory intesive method or slow non-intensive memory 
% method 
if mem_ratio > mem_ratio_min
    % Save original size and vectorize observation angles
    oSize = size(theta);
    N_angles = numel(theta);

    theta_lin = reshape(theta, [1, N_angles]);
    phi_lin = reshape(phi, [1, N_angles]);

    % Setup position matrix
    POS = [element_active(1,:).', element_active(2,:).', element_active(3,:).'];

    for i = 1:N_f
        % Calculate wave vector matrix with -1's for beta subtraction
        K = [k(i)*sin(theta_lin).*cos(phi_lin); ...
             k(i)*sin(theta_lin).*sin(phi_lin); ...
             k(i)*cos(theta_lin); ...
             ones(1, N_angles)];

        % Add beta to position matrix 
        POS_beta = [POS, beta(i,:).'];

        % Calculate AF contributions
        FF_lin = 1j*POS_beta*K;
        FF_lin = exp(FF_lin);
        
        if isotropic == true
            FF_lin = A_active.'.*FF_lin;
        else
            FF_lin = A_active.'.*FF_lin.*element_FFs_lin;
        end

        % Sum AF contributions
        FF_lin = sum(FF_lin,1);

        % Reshape and write back to original format
        array_FF(:,:,i) = reshape(FF_lin, oSize);
    end
else
    % Setup wave vectors
    kx = zeros(size(array_FF)); ky = kx; kz = kx;
    for i = 1:N_f
        kx(:,:,i) = k(i).*sin(theta).*cos(phi);
        ky(:,:,i) = k(i).*sin(theta).*sin(phi);
        kz(:,:,i) = k(i).*cos(theta);
    end

    % Calculate the final array factor (only active elements)
    for i = 1:N_f
        FF_int = zeros(size(theta));
        for j = 1:N_active_elements
            if isotropic == true
                element_FF = 1;
            else
                element_FF = element_FFs(:,:,j);
            end
            FF_int = FF_int + element_FF .* A_active(j) .* ...
                     exp(1j .* (kx(:,:,i).*element_active(1,j) + ...
                                ky(:,:,i).*element_active(2,j) + ...
                                kz(:,:,i).*element_active(3,j) + ...
                                beta(i,j)));
        end
        array_FF(:,:,i) = FF_int;
    end
end 

%% Normalize radiation patterns
for i = 1:N_f
    array_FF(:,:,i) = array_FF(:,:,i)./max(max(abs(array_FF(:,:,i))));    
end
end

