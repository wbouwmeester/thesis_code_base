function [HPBW] = HPBW(FF, angles, angle_scan)
%HPBW Estimate Half Power Beam Width along a theta or phi cut
%   [HPBW] = HPBW(FF, angles, angle_scan) finds the half power beamwidth of 
%   a specified field cut FF whose angles are defined by the argument 
%   angles. The HPBW is estimated using linear interpolation around the 
%   points before and after the FF crosses sqrt(0.5).
%
%   Written by Wietse Bouwmeester
%   Date: 2019-05-28

% Get input info
[N_angles, N_f] = size(FF);

% Eliminate complex part
FF = abs(FF);

% Find index of angle closest to the scan angle
angle_scan_index = find(abs(angles-angle_scan) == min(abs(angles-angle_scan)));
angle_scan_index = angle_scan_index(1);

BW_up_i = NaN(1,N_f);
BW_lo_i = NaN(1,N_f);
HPBW = zeros(1,N_f);
for j = 1:N_f
    % Search for upper bound
    for i = angle_scan_index:N_angles
        if FF(i, j) <= sqrt(0.5)
            BW_up_i(j) = i;
            break;
        end        
    end
    
    % Search for lower bound
    for i = angle_scan_index:-1:1
        if FF(i, j) <= sqrt(0.5)
            BW_lo_i(j) = i;
            break;
        end
    end
    
    % Calculate HPBW using linear estimations
    if ~isnan(BW_up_i(j)) && isnan(BW_lo_i(j))
        % Linear estimation of upper -3dB angle
        a = (FF(BW_up_i(j),j)-FF(BW_up_i(j)-1,j))./ ...
            (angles(BW_up_i(j))-angles(BW_up_i(j)-1));
        b = FF(BW_up_i(j),j)-a*angles(BW_up_i(j));  
        
        % Multiply times two since the other -3dB point is not in the
        % plotted region
        HPBW(j) = 2*((sqrt(0.5)-b)./a-angle_scan);
    elseif isnan(BW_up_i(j)) && ~isnan(BW_lo_i(j))
        % Linear estimation of lower -3dB angle
        a = (FF(BW_lo_i(j)+1,j)-FF(BW_lo_i(j),j))./ ...
            (angles(BW_lo_i(j)+1)-angles(BW_lo_i(j)));
        b = FF(BW_lo_i(j),j)-a*angles(BW_lo_i(j));  
        
        % Multiply times two since the other -3dB point is not in the
        % plotted region
        HPBW(j) = 2*(angle_scan-(sqrt(0.5)-b)./a);
    elseif isnan(BW_up_i(j)) && isnan(BW_lo_i(j))
        % If beam doesn't drop below sqrt(0.5), then beamwidth can't be
        % found and is set to NaN
        HPBW(j) = NaN;
    else
        % Linear estimation of upper -3dB angle
        a_up = (FF(BW_up_i(j),j)-FF(BW_up_i(j)-1,j))./ ...
               (angles(BW_up_i(j))-angles(BW_up_i(j)-1));
        b_up = FF(BW_up_i(j),j)-a_up*angles(BW_up_i(j));
        
        % Linear estimation of lower -3dB angle
        a_lo = (FF(BW_lo_i(j)+1,j)-FF(BW_lo_i(j),j))./ ...
               (angles(BW_lo_i(j)+1)-angles(BW_lo_i(j)));
        b_lo = FF(BW_lo_i(j),j)-a_lo*angles(BW_lo_i(j));
        
        HPBW(j) = (sqrt(0.5)-b_up)./a_up-(sqrt(0.5)-b_lo)./a_lo;
    end
end
end

