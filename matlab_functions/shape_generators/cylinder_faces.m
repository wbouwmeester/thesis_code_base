function [element_loc, element_norm, A] = cylinder_faces(R, H, N_faces, dx, dy, d_edge, d_edge_cap)
%CYLINDER_FACES Generate a faced cylindrical array with a rectangular
%topology 
%   [element_loc, element_norm] = CYLINDER_FACES(R, H, N_faces, dx, dy, d_edge, d_edge_cap)
%   Generates a faced cylindrical array with a distance R on the ground to the
%   corners of the faces and a height H. N_faces is the number of
%   faces that is generated, dx is the spacing of the elements
%   along x, when the face is projected on the x,y plane. dy is the spacing
%   of the elements along y when projected on the x,y plane. d_edge is the 
%   edge clearance for the elements. The top of the cylinder is covered 
%   with a diamond grid array. d_edge indicates how much space is free 
%   between the elements and the edges of the faces. d_edge_cap
%   indicates the distance from the diamond grid on the top of the array to
%   the edges of the cap.
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
%   Date: 2019-06-30

% [element_loc, element_norm] = cone_faces_cap(R, 1000, N_faces, dx, dy, d_edge, H);

% Set cone height
H_cone = 1000;

% Calculate faced cone dimension parameters
L_ground = 2*R*sin(pi/N_faces);
a = sqrt(R.^2-(L_ground./2).^2);

% Generate x point grid
x = 0:dx:(L_ground)-2*d_edge;
x = x-max(x)/2;

% Generate y point grid
y = 0:dy:H-2*d_edge;
y = y+(H-max(y))/2;

[x,y] = meshgrid(x,y);

% Reshape to element_loc format
N_elements = numel(x);
element_loc_face = [reshape(x, [1, N_elements]); a*ones(1, N_elements); reshape(y, [1, N_elements])];

% Setup normals
element_norm_face = [zeros(1, N_elements); ones(1,N_elements); zeros(1, N_elements)];

% Create remaining faces by rotating along z
element_loc = element_loc_face;
element_norm = element_norm_face;
for i = 1:(N_faces-1)
    % Setup rotation matrix
    theta = 2*pi/N_faces*i;
    ROT = [cos(theta) -sin(theta) 0; sin(theta) cos(theta) 0; 0 0 1];
    
    % Rotate elements along z
    element_loc = [element_loc ROT*element_loc_face];
    
    % Rotate normals along z
    element_norm = [element_norm ROT*element_norm_face];
end

% Remove duplicates
[element_loc, i_unique, ~] = unique(element_loc.', 'rows');
element_loc = element_loc.';
element_norm = element_norm(:, i_unique);

% Cap calculations
% Calculate cap subtriangle dimensions parameters
R_cap = R-(R.*H)/H_cone;
L_side = 2*R_cap*sin(pi/N_faces);
R_half = R_cap*cos(pi/N_faces);

% Calculate dy for a neat triangular grid with the same angles as the
% triangular faces
dy = dx/(2*tan(pi/N_faces));

% Generate x point grid
x = 0:dx:L_side;
x = x-max(x)/2;

% Generate y point grid
y = 0:dy:R_half;

[x,y] = meshgrid(x,y);

% Shift the even or uneven rows depending on the number of rows by halve 
% the distance between the cells to make the triangular grid
d_shift = dx/2;
[N_rows, ~] = size(x);

if rem(N_rows,2) == 0
    i_start = 1;
else
    i_start = 2;
end

for i = i_start:2:N_rows
    x(i, :) = x(i, :)+d_shift; 
end

% Reshape to element_loc format
N_elements = numel(x);
cap_loc_face = [reshape(x, [1, N_elements]); reshape(y, [1, N_elements]); zeros(1, N_elements)];

% figure; hold on;
% plot(cap_loc_face(1,:), cap_loc_face(2,:), '*');
% plot(cap_loc_face(1,:), cap_loc_face(1,:).*2.*R_half./L_side-1e-6);
% plot(cap_loc_face(1,:), cap_loc_face(1,:).*-2.*R_half./L_side-1e-6);
% plot(cap_loc_face(1,:), ones(1,N_elements).*(R_half-d_edge));
% grid on; axis equal;

% Cut unwanted elements
elements_in_tri = cap_loc_face(2,:) >= -2*cap_loc_face(1,:).*R_half./L_side-1e-6 & ...
                  cap_loc_face(2,:) >= 2*cap_loc_face(1,:).*R_half./L_side-1e-6 & ...
                  cap_loc_face(2,:) < ones(1,N_elements).*(R_half-d_edge_cap);

cap_loc_face = [cap_loc_face(1, elements_in_tri); ...
                cap_loc_face(2, elements_in_tri); ...
                cap_loc_face(3, elements_in_tri)];
N_elements = length(cap_loc_face(1,:));
            
% Rotate to complete the cap
cap_loc = cap_loc_face;
for i = 1:(N_faces-1)
    % Setup rotation matrix
    theta = 2*pi/N_faces*i;
    ROT = [cos(theta) -sin(theta) 0; sin(theta) cos(theta) 0; 0 0 1];
    
    % Rotate elements along z
    cap_loc = [cap_loc ROT*cap_loc_face];
end

% Translate cap to z_max
cap_loc(3,:) = cap_loc(3,:) + H;

% Generate normal vectors
cap_norm = [zeros(1, N_elements*N_faces); zeros(1, N_elements*N_faces); ones(1, N_elements*N_faces)];

% Remove the duplicates
[cap_loc, i_unique, ~] = unique(cap_loc.', 'rows');
cap_loc = cap_loc.';
cap_norm = cap_norm(:, i_unique);

% Append cap to element_loc and element_norm
element_loc = [element_loc(1,:) cap_loc(1,:); ...
               element_loc(2,:) cap_loc(2,:); ...
               element_loc(3,:) cap_loc(3,:)];
       
element_norm = [element_norm(1,:) cap_norm(1,:); ...
                element_norm(2,:) cap_norm(2,:); ...
                element_norm(3,:) cap_norm(3,:)];

A_sides = L_ground*H*N_faces;
A_cap = N_faces*L_ground*a/2;

A = A_sides+A_cap;

end

