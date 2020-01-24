function [element_FF] = FF_cloverleaf(theta_obs, phi_obs)
%FF_cloverleaf Cloverleaf Element radiation pattern
%   [element_FF] = FF_cloverleaf(theta, phi) generates an element far field 
%   pattern that was calculated in CST.
%
%   Written by Wietse Bouwmeester
%   Date: 2019-12-16

load('fits/cloverleaf_far_field.mat', 'far_field_fit');

element_FF = far_field_fit(theta_obs, phi_obs);
end

