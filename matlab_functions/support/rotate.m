function [pos_rotated] = rotate(pos, angle, axis)
%ROTATE Summary of this function goes here
%   Detailed explanation goes here

if axis == 'x'
    pos_rotated = [1 0 0; 0 cos(angle) -sin(angle); 0 sin(angle) cos(angle)]*pos;
elseif axis == 'y'
    pos_rotated = [cos(angle) 0 sin(angle); 0 1 0; -sin(angle) 0 cos(angle)]*pos;
elseif axis == 'z'
    pos_rotated = [cos(angle) -sin(angle) 0; sin(angle) cos(angle) 0; 0 0 1]*pos;
else
    error('Invalid axis of rotation')
end

end

