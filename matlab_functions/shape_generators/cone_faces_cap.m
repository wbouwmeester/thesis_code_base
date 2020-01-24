function [element_loc, element_norm] = cone_faces_cap(R, H, N_faces, dx, dy, d_edge, z_max)
%CONE_FACES_CAP Generate a faced conical array with a rectangular
%topology with a cap
%   [element_loc, element_norm] = CONE_FACES_CAP(R, H, N_faces, dx, dy, d_edge, z_max)
%   Generates a faced conical array with a distance R on the ground to the
%   corners of the faces and a cone height H. N_faces is the number of
%   faces that is generated, dx is the spacing of the elements
%   along x, when the face is projected on the x,y plane. dy is the spacing
%   of the elements along y when projected on the x,y plane. d_edge is the 
%   edge clearance for the elements. z_max determines the height of the 
%   array and removes all elements above that z value. On this height z_max 
%   an diamond grid array is placed that is normal to the z-axis as a cap.
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
%   Date: 2019-06-27

% Calculate faced cone dimension parameters
L_ground = 2*R*sin(pi/N_faces);
a = sqrt(R.^2-(L_ground./2).^2);

H_flat = sqrt(a.^2+H.^2);

% Generate x point grid
x = 0:dx:(L_ground-d_edge*2);
x = x-max(x)/2;

% Generate y point grid
y = 0:dy:H_flat;
y = y+(H_flat-max(y))/2;

[x,y] = meshgrid(x,y);

% Reshape to element_loc format
N_elements = numel(x);
element_loc = [reshape(x, [1, N_elements]); reshape(y, [1, N_elements]); zeros(1, N_elements)];

% Calculate edge clearance
offset = d_edge./cos(atan2(2*H_flat,L_ground));

% figure; hold on;
% plot(element_loc(1,:), element_loc(2,:), '*');
% plot(element_loc(1,:), -element_loc(1,:).*2.*H_flat./L_ground+offset);
% plot(element_loc(1,:), element_loc(1,:).*2.*H_flat./L_ground+offset);
% plot(element_loc(1,:), ones(1,length(element_loc(1,:))).*(H-z_max)*H_flat./H);
% grid on; axis equal;

% Cut out points outside the triangle
elements_in_tri = element_loc(2,:) >= -element_loc(1,:).*2.*H_flat./L_ground+offset & ...
                  element_loc(2,:) >= element_loc(1,:).*2.*H_flat./L_ground+offset & ...
                  element_loc(2,:) > ones(1,length(element_loc(1,:))).*(H-z_max)*H_flat./H+d_edge;

element_loc = [element_loc(1,elements_in_tri); ...
               element_loc(2,elements_in_tri); ...
               element_loc(3,elements_in_tri)];

N_elements = numel(element_loc(1,:));

% figure; hold on;
% plot(element_loc(1,:), element_loc(2,:), '*');
% plot(element_loc(1,:), -element_loc(1,:).*2.*H_flat./L_ground+offset);
% plot(element_loc(1,:), element_loc(1,:).*2.*H_flat./L_ground+offset);
% plot(element_loc(1,:), ones(1,length(element_loc(1,:))).*(H-z_max)*H_flat./H);
% grid on; axis equal;

% Setup rotation matrix
theta = atan2(-H,a);
ROT = [1 0 0; 0 cos(theta) -sin(theta); 0 sin(theta) cos(theta)];

% Rotate elements along x
element_loc_face = ROT*element_loc;

% Rotate normal vector along x
element_norm_face = ROT*[zeros(1, N_elements); zeros(1, N_elements); ones(1, N_elements)];

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

% Translate everything up by H
element_loc(3,:) = element_loc(3,:)+H;

% Remove everything below z_max
islower = element_loc(3,:)<=z_max;
element_loc = [element_loc(1,islower); element_loc(2,islower); element_loc(3, islower)];
element_norm = [element_norm(1,islower); element_norm(2,islower); element_norm(3, islower)];

% Cap calculations
% Calculate cap subtriangle dimensions parameters
R_cap = R-(R.*z_max)/H;
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
                  cap_loc_face(2,:) < ones(1,N_elements).*(R_half-d_edge);

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
cap_loc(3,:) = cap_loc(3,:) + z_max;

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
end

