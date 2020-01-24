function [element_FF] = FF_ideal(theta, phi)
%FF_IDEAL Generate ideal radiation pattern
%   [element_FF] = FF_ideal(theta, max_scan_angle) Generates the ideal
%   element radiation pattern for an array that is allowed to scan to a
%   maximum angle specified by max_scan_angle. This ideal pattern is
%   isotropic within the max scan angle and 0 outside.
%
%   Written by Wietse Bouwmeester
%   Date: 2019-06-11

max_scan_angle = deg2rad(60.01);

element_FF = ones(size(theta));
element_FF(theta>max_scan_angle) = 0;

end

