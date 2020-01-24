function [element_loc, element_norm, min_dist] = sphere_distance(A, R, N_iterations, delta_max)
%SPHERE_DISTANCE Generates a spherical array with maximised minimum
%distance
%   [element_loc, element_norm, min_dist] = SPHERE_DISTANCE(A, R, N_iterations, delta_max) 
%   generates a sphere with A random points with radius R and then perturbs 
%   these points for a number of N_iterations iterations with a maximum 
%   angle specified by delta_max (in radians).
%
%   SPHERE_DISTANCE returns element_loc, which is an 3xN matrix with the
%   rows representing the x, y and z coordinates of the generated points.
%   min_dist is the minimum distance between any two points on the sphere.
%
%   element_norm is the same format as element_loc, except for the fact
%   that it contains the normal vector for each element corresponding to 
%   the element in element_loc.
%
%   The input variable A can also be of the same form as element_loc. In
%   this case, these element locations are used as initial distribution
%   which are then perturbed for N_iterations.
%
%   Written by Wietse Bouwmeester
%   Date: 2019-05-28

% Check for input type
[N_rows, N_columns] = size(A);
if N_rows == 3
    % Load points from seed and convert to spherical coordinates
    theta = atan2(sqrt(A(1,:).^2+A(2,:).^2), A(3,:));
    phi = atan2(A(2,:), A(1,:));
elseif N_rows == 1 && N_columns == 1
    % Generate initial points on sphere
    rng(0);
    theta = rand(1, A)*pi;
    phi = rand(1, A)*2*pi;

    % Find cartesian coordinates
    x = R*sin(theta).*cos(phi);
    y = R*sin(theta).*sin(phi);
    z = R*cos(theta);
else
    error('Invalid input arguments');
end

% Pertubation loop
D_min = zeros(1,N_iterations);
min_dist = 0;
for i = 1:N_iterations
    % Find cartesian coordinates
    x = R*sin(theta).*cos(phi);
    y = R*sin(theta).*sin(phi);
    z = R*cos(theta);
    
    % Calculate smallest distance
    D = triu(dist([x; y; z]));
    D(D == 0) = NaN; 
    D_min(i) = min(min(D));
    
    [P1, P2] = find(D == D_min(i));
    
    if D_min(i) >= min_dist
        min_dist = D_min(i);
        theta_best = theta;
        phi_best = phi;
    else
        theta = theta_best;
        phi = phi_best;
    end
    
    % Perturb distance randomly
    delta = (rand(1,4)-0.5)*delta_max;
    theta(P1) = delta(1)+theta(P1); theta(P2) = delta(2)+theta(P2);
    phi(P1) = delta(3)+phi(P1); phi(P2) = delta(4)+phi(P2);
end

element_loc = [x; y; z];
element_norm = [x./R; y./R; z./R];

end