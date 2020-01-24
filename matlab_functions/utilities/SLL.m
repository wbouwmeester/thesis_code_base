function [SLL] = SLL(FF, angles, angle_scan)
%HPBW Estimate Side Lobe Level along a theta or phi cut
%   [SLL] = SLL(FF, angles, angle_scan) finds the SLL of 
%   a specified field cut FF whose angles are defined by the argument 
%   angles. 
%
%   Written by Wietse Bouwmeester
%   Date: 2020-01-20

% Get input info
[N_angles, N_f] = size(FF);

% Eliminate complex part
FF = abs(FF);

% Normalise the far fields
FF = FF./max(FF);

% Find index of angle closest to the scan angle
angle_scan_index = find(abs(angles-angle_scan) == min(abs(angles-angle_scan)));
angle_scan_index = angle_scan_index(1);

BW_up_i = NaN(1,N_f);
BW_lo_i = NaN(1,N_f);
SLL = zeros(1,N_f);
found = false;
for j = 1:N_f
    % Search for upper first minimum
    for i = (angle_scan_index+1):N_angles
        if FF(i, j) < FF(i-1, j)
            BW_up_i(j) = i;
        else
            found = true;
            break;
        end        
    end
    
    if found == false
        BW_up_i(j) = NaN;
    end        
    
    % Search for lower bound
    found = false;
    for i = (angle_scan_index-1):-1:1
        if FF(i, j) < FF(i+1, j)
            BW_lo_i(j) = i;
        else
            found = true;
            break;
        end 
    end
    
    if found == false
        BW_lo_i(j) = NaN;
    end
    
    % Find SLL
    if ~isnan(BW_up_i(j)) && isnan(BW_lo_i(j))
        SLL = max(FF(BW_up_i(j):end,j));
    elseif isnan(BW_up_i(j)) && ~isnan(BW_lo_i(j))
        SLL = max(FF(1:BW_lo_i(j),j));
    elseif ~isnan(BW_up_i(j)) && ~isnan(BW_lo_i(j))
        SLL = max(FF([1:BW_lo_i(j) BW_up_i(j):end] ,j));
    else
        SLL = NaN;
    end    
end
end

