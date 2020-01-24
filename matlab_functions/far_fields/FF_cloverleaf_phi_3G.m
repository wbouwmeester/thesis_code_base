function [element_FF] = FF_cloverleaf_phi_3G(theta_obs, phi_obs)
%FF_cloverleaf Cloverleaf Element radiation pattern
%   [element_FF] = FF_cloverleaf_phi_3G(theta, phi) generates an element 
%   far field pattern that was calculated in Feko at 3 GHz.
%
%   Written by Wietse Bouwmeester
%   Date: 2020-01-10

load('fits/cloverleaf_phi_3G.mat', 'far_field_fit');

element_FF = far_field_fit(theta_obs, phi_obs);
end

