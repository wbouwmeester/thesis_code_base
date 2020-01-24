function [element_FF] = FF_cos(theta, phi)
%FF_COS Element cosine radiation pattern
%   [element_FF] = FF_COS(theta) generates an element far field pattern
%   that has a cos(theta) shape.
%
%   Written by Wietse Bouwmeester
%   Date: 2019-06-04

element_FF = cos(theta);
element_FF(theta>pi/2) = 0;
end

