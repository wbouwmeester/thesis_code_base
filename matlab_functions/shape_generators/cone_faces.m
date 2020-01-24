function [element_loc, element_norm] = cone_faces(R, H, N_faces, dx, dy, d_edge, z_max)
%CONE_FACES Generate a faced conical array
%   [element_loc, element_norm] = cone_faces(R, H, N_faces, dx, dy, d_edge, z_max)
%   Generates a faced conical array with a distance R on the ground to the
%   corners of the faces and a cone height H. N_faces is the number of
%   faces that is generated, dx and dy are the spacing of the elements
%   along x and y axis, when the face is projected on the x,y plane. d_edge
%   is the edge clearance for the elements. z_max determines the height of
%   the array and removes all elements above that z value.
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
%   Date: 2019-06-03


% Calculate faced cone dimension parameters
L_ground = 2*R*sin(pi/N_faces);
a = sqrt(R.^2-(L_ground./2).^2);

H_flat = sqrt(a.^2+H.^2);

% Generate x point grid
x = 0:dx:L_ground;
x = x-max(x)/2;

% Generate y point grid
y = 0:dy:H_flat;
y = y+(H_flat-max(y))/2;

%x = linspace(-L_ground/2, L_ground/2, Nx);
%y = linspace(0, H_flat, Ny);
[x,y] = meshgrid(x,y);

% Reshape to element_loc format
N_elements = numel(x);
element_loc = [reshape(x, [1, N_elements]); reshape(y, [1, N_elements]); zeros(1, N_elements)];

% Calculate edge clearance
offset = d_edge./cos(atan2(2*H_flat, L_ground));

% Cut out points outside the triangle
elements_in_tri = element_loc(2,:) >= -element_loc(1,:).*2.*H_flat./L_ground+offset & ...
                  element_loc(2,:) >= element_loc(1,:).*2.*H_flat./L_ground+offset;

element_loc = [element_loc(1,elements_in_tri); ...
               element_loc(2,elements_in_tri); ...
               element_loc(3,elements_in_tri)];

N_elements = numel(element_loc(1,:));
           
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
for i = 1:N_faces
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
end

