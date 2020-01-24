function [element_loc, element_norm, A] = ellipsoid_arclength(R, H, arclength)
%ELLIPSOID_ARCLENGTH Ellipsoidal array with equal arclength distribution
%   [element_loc, element_norm] = ellipsoid_arclength(R, H, arclength)
%   generates an ellipsoidal array of height H and radius R. The elements
%   on this array are distributed with equal arclengths along theta and phi
%   as close as possible to the arclength argument of the function.
%
%   ELLIPSOID_ARCLENGTH returns element_loc which is a 3xN array containing
%   the element x in row 1, y in row 2 and z in row 3. element_norm is in
%   the same format, and specifies the element normal vectors.
%
%   Written by Wietse Bouwmeester
%   Date: 2019-06-25

% Find number of points along theta
arclength_theta = abs(R).*ellipticE(1-H^2/R^2);
N_c = round(arclength_theta./arclength)+1;
spacing = arclength_theta/(N_c-1);

% Solve numerically to find the correct theta steps
theta = zeros(1,N_c);
for i=2:N_c
    syms theta_solve;
    eqn = R*(ellipticE(theta_solve,1-H^2/R^2)-ellipticE(theta(i-1), 1-H^2/R^2)) == spacing;
    theta(i) = double(vpasolve(eqn, theta_solve, [0 pi]));   
end

% Calculate circle radius for every theta
R_c = R*sin(theta);

% Calculate how many points will fit on each circle
N_points_on_c = round(2*pi*R_c./arclength);

% Also place point on the top of the sphere
N_points_on_c(1) = 1;

% Calculate phi step for every circle
phi_step = 2*pi./N_points_on_c;

% Generate points phi and theta
theta_s = []; phi_s = [];
for i = 1:numel(theta)
    theta_s = [theta_s theta(i).*ones(1,N_points_on_c(i))];
    phi_s = [phi_s (0:N_points_on_c(i)-1).*phi_step(i)]; 
end

% Reshape theta_s and phi_s to arrays
N_elements = numel(theta_s);
theta_s = reshape(theta_s, [1, N_elements]);
phi_s = reshape(phi_s, [1, N_elements]);

% Calculate correspinding cartesian coordinates
x = R*sin(theta_s).*cos(phi_s);
y = R*sin(theta_s).*sin(phi_s);
z = H*cos(theta_s);

element_loc = [x; y; z];

% Calculate unit vectors theta and phi along the ellipsoidal surface and
% the normal vector
element_norm = [R*H*sin(theta_s).^2.*cos(phi_s); R*H*sin(theta_s).^2.*sin(phi_s); R^2*cos(theta_s).*sin(theta_s)];

% Normalize all vectors
element_norm = element_norm./vecnorm(element_norm);

% Make sure that the element normal on top of the ellipsoid is H
element_norm(:,1) = [0; 0; 1];

% Approximate ellipsoid area
if H>R
    A = pi*R^2+pi*R*H^2/sqrt(H^2-R^2)*asin(sqrt(H^2-R^2)/H);
else    
    A = pi*R^2-1i*pi*R*H^2/sqrt(R^2-H^2)*acos(R/H);
end
end

