function [element_loc, element_norm, A] = sphere_geodesic(R, d, theta_max)
%SPHERE_GEODESIC generates a sphere with a geodesic distribution of points
%   SPHERE_GEODESIC(R, d, theta_max) generates a sphere with a geodisic
%   distribution of points. The number of subdivisions is calculated so
%   that the distance over the sphere is as close as possible to the
%   argument d. Theta_max is the angle below which all the elements are
%   removed, e.g. theta_max = pi/2 generates a hemispherical array.
%
%   element_loc is a 3xN array where N is the number of
%   points and the first, second and third row represent the x, y and z
%   coordinates respectively.
%  
%   element_norm is the same format as element_loc, except for the fact
%   that it contains the normal vector for each element corresponding to 
%   the element in element_loc.
%
%   Written by Wietse Bouwmeester
%   Date: 18-9-2019

h = (1+sqrt(5))/2;

vertices = [0       0        0       0        (1+h)   (1+h)    -(1+h)   -(1+h)   (1-h^2) (1-h^2) -(1-h^2) -(1-h^2);
            (1+h)   (1+h)    -(1+h)  -(1+h)   (1-h^2) -(1-h^2) (1-h^2) -(1-h^2)  0       0       0        0;
            (1-h^2) -(1-h^2) (1-h^2) -(1-h^2) 0       0        0        0        (1+h)   -(1+h)  (1+h)    -(1+h)];

triangles = [1 1 1  1  1  2  2  2 3 3 3  3  3  4  4  4 5  5  7 7;
             2 2 6  10 8  6  9  8 4 4 5  7  10 5  9  7 6  6  8 8;
             6 8 12 12 10 11 11 9 5 7 12 10 12 11 11 9 11 12 9 10];

[~, N_triangles] = size(triangles);  

% Calculate the number of subdivisions required, first step is to calculate
% the angle one edge of a triangle spans
angle = 2*atan2(-(1-h^2), 1+h);

% Calculate the arclength corresponding to this angle
arclength = R*angle;

% Calculate number of subdivisions required
N_sub = round(arclength./d);

% Make sure the number of subdivisions is always 1 or larger
N_sub = max(1, N_sub);

% Create the vertices
triangles_new = [];
vertices_new = double.empty(3,0);
for j = 1:N_triangles    
    % Find subdivided edge length vectors
    v_base = (vertices(:,triangles(2,j))-vertices(:,triangles(1,j)))/N_sub;
    v_ort = (vertices(:,triangles(3,j))-vertices(:,triangles(1,j)))/N_sub;
         
    % Make triangles for every row
    for i_row = 1:N_sub
        for i_col = 1:(N_sub-(i_row-1))
            % Calculate three new vertice coordinates
            v1 = vertices(:,triangles(1,j))+v_ort*(i_row-1)+v_base*(i_col-1);
            v2 = vertices(:,triangles(1,j))+v_ort*(i_row-1)+v_base*i_col;
            v3 = vertices(:,triangles(1,j))+v_ort*(i_row-1)+v_base*(i_col-1)+v_ort;
            
            % Check if the vertices are in vertices_new already, otherwise
            % add the vertex
            i_v1 = find(ismembertol(vertices_new.', v1.', 'ByRows', true),1);
            i_v2 = find(ismembertol(vertices_new.', v2.', 'ByRows', true),1);
            i_v3 = find(ismembertol(vertices_new.', v3.', 'ByRows', true),1);
            
            if isempty(i_v1)
                vertices_new = [vertices_new v1];
                [~, i_v1] = size(vertices_new); 
            end
            if isempty(i_v2)
                vertices_new = [vertices_new v2];
                [~, i_v2] = size(vertices_new);
            end
            if isempty(i_v3)
                vertices_new = [vertices_new v3];
                [~, i_v3] = size(vertices_new);
            end
            
            % Add triangle to triangles_new
            triangles_new = [triangles_new [i_v1; i_v2; i_v3]];
            
            % Also add the upside down triangle
            if i_col > 1
                [~, i_tri] = size(triangles_new);
                triangles_new = [triangles_new [triangles_new(3, i_tri-1); i_v1; i_v3]]; 
            end         
        end
    end
end

% Calculate element locations by projecting them on a sphere and find the
% element normals by just calculating the normalised radial vector
element_loc = vertices_new./vecnorm(vertices_new)*R;
element_norm = vertices_new./vecnorm(vertices_new);

% Remove all elements below theta_max
z_min = R*cos(theta_max);
valid = element_loc(3,:)>=z_min;

element_loc = element_loc(:, valid);
element_norm = element_norm(:, valid);

% Calculate area
A = 2*pi*R^2*(1-cos(theta_max));
end