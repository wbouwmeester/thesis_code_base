function [element_loc, element_norm, A] = sphere_faces(R, N_sub, d_x, d_edge, element_max_angle, theta_view, phi_view)
%SPHERE_FACES generates a faced sphere
%   SPHERE_FACES(R, N_sub, d_x, d_edge, element_max_angle) generates a
%   faced sphere based on an icosahedron which is expanded to a radius R.
%   All of the faces of the icosahedron get subdivided N_sub times to
%   create more faces. d_x is the spacing along the longest side of an
%   individual face, the spacing in the y direction is calculated so that
%   a diamond grid with the same angles is created. d_edge is the distance
%   the elements should keep to the face edges. element_max_angle indicates
%   the maximum scan angle the sphere is to be used at and removes all
%   faces that are never active when scanning the upper hemisphere.
%
%   SPHERE_FACES returns element_loc which is a 3xN matrix with the element
%   locations, x in row 1, y in 2 and z in row 3. element_norm contains the
%   element normal vectors, again with x in row 1, y in row 2 and z in row
%   3.
%
%   Note: Since there are also non-isosceles triangles appearing after 4
%   subdivisions, diamond grids are not guaranteed to be neat.
%
%   Written by Wietse Bouwmeester
%   Date: 17-7-2019

% Check the number of arguments
if nargin == 7
    obscure = true;
else
    obsucre = false;
end


h = (1+sqrt(5))/2;

vertices = [0       0        0       0        (1+h)   (1+h)    -(1+h)   -(1+h)   (1-h^2) (1-h^2) -(1-h^2) -(1-h^2);
            (1+h)   (1+h)    -(1+h)  -(1+h)   (1-h^2) -(1-h^2) (1-h^2) -(1-h^2)  0       0       0        0;
            (1-h^2) -(1-h^2) (1-h^2) -(1-h^2) 0       0        0        0        (1+h)   -(1+h)  (1+h)    -(1+h)];

triangles = [1 1 1  1  1  2  2  2 3 3 3  3  3  4  4  4 5  5  7 7;
             2 2 6  10 8  6  9  8 4 4 5  7  10 5  9  7 6  6  8 8;
             6 8 12 12 10 11 11 9 5 7 12 10 12 11 11 9 11 12 9 10];

[~, N_triangles] = size(triangles);  
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
            
            figure; hold on;
            plot3(vertices(1, triangles(:,j)), vertices(2, triangles(:,j)), vertices(3, triangles(:,j)), 'ro', 'DisplayName', 'Original') 
            plot3(vertices_new(1,:), vertices_new(2,:), vertices_new(3,:), '*', 'DisplayName', 'New');
            plot3(vertices(1,triangles(1,j))+v_ort(1)*(i_row-1), vertices(2,triangles(1,j))+v_ort(2)*(i_row-1), vertices(3,triangles(1,j))+v_ort(3)*(i_row-1), 'yo', 'DisplayName', 'Reference');  
            grid on; legend; xlabel('x'); ylabel('y'); zlabel('z'); axis equal;
            close all;
        end
    end
end

% Load new vertices and triangles into original vertices and triangles
vertices = vertices_new;
triangles = triangles_new;
         
% Project the vertices on a sphere of radius R
vertices = vertices./vecnorm(vertices)*R;

% Calculate the normal vectors of the triangles
[~, N_triangles] = size(triangles);
triangle_norm = zeros(size(triangles));
for i = 1:N_triangles
    % Calculate face normal vectors
    triangle_norm(:,i) = cross(vertices(:,triangles(2,i))-vertices(:,triangles(1,i)), ...
                               vertices(:,triangles(3,i))-vertices(:,triangles(1,i)));
    
    % Normalize the normal vectors
    triangle_norm(:,i) = triangle_norm(:,i)./vecnorm(triangle_norm(:,i));                  
                      
    % Make sure that the normal vector is pointing outward
    if sqrt(sum((triangle_norm(:,i)*R+vertices(:,triangles(1,i))).^2)) <= R
        triangle_norm(:,i) = -triangle_norm(:,i);
    end
end

% If obscure is true, calculate the view vector
if obscure == true
    view_vec = [sin(theta_view)*cos(phi_view); 
                sin(theta_view)*sin(phi_view); 
                cos(theta_view)];
end

% Remove all triangles that are never active by calculating angle between 
% normal and the scan vector at horizon, if this is smaller than the max 
% scan angle, the triangle can be removed
triangles_new = [];
triangle_norm_new = [];
for i = 1:N_triangles
    scan_vector = [triangle_norm(1,i); triangle_norm(2,i); 0];
    scan_vector = scan_vector./vecnorm(scan_vector);
    
    if triangle_norm(3,i) >= 0 || acos(dot(scan_vector, triangle_norm(:,i))) <= element_max_angle
        % Check if the facet is obscured if obscure is true
        if obscure == true
            % Obscure element if necessary for plotting
            face_angle = acos(dot(view_vec, triangle_norm(:,i)));

            if face_angle < deg2rad(89)      
                triangles_new = [triangles_new triangles(:,i)];
                triangle_norm_new = [triangle_norm_new triangle_norm(:,i)];
            end
        else
            triangles_new = [triangles_new triangles(:,i)];
            triangle_norm_new = [triangle_norm_new triangle_norm(:,i)];
        end
    end
end
triangles = triangles_new;
triangle_norm = triangle_norm_new;

% Fill every triangle with elements
element_loc = [];
element_norm = [];

[~, N_triangles] = size(triangles);
for i = 1:N_triangles
    tri_vertices = [vertices(:, triangles(1,i)) ...
                    vertices(:, triangles(2,i)) ...
                    vertices(:, triangles(3,i))];
                
    % Calculate rotation around along x (so that the triangle norm vector
    % aligns with the x axis
    alpha = atan2(triangle_norm(2,i), triangle_norm(1,i));

    % Calculate rotation around y (so that the triangle norm vector aligns
    % with the z_axis
    beta = acos(triangle_norm(3,i));

    % Rotate along alpha
    ROT = [cos(-alpha) -sin(-alpha) 0;
           sin(-alpha) cos(-alpha) 0;
           0 0 1];
    tri_vertices_alpha = ROT*tri_vertices;    

    % Rotate along beta
    ROT = [cos(-beta) 0 sin(-beta);
           0 1 0;
           -sin(-beta) 0 cos(-beta)];
    tri_vertices_beta = ROT*tri_vertices_alpha;    

    % Calculate rotation around z (so that the unique edge is parallel to
    % the x-axis, if not available take longest edge)
    D = dist(tri_vertices_beta);
    D = triu(D); D(D==0) = NaN;
    
    D_values = uniquetol(D(~isnan(D)));
    if length(D_values) == 2
        if sum(D(:) <= D_values(1)+1e-6 & D(:) >= D_values(1)-1e-6) == 1
            [i_v1, i_v2] = find(D == D_values(1));
        else
            [i_v1, i_v2] = find(D == D_values(2));
        end
    else
        [i_v1, i_v2] = find(D == max(max(D)));
        i_v1 = i_v1(1); i_v2 = i_v2(1);
    end    
    i_v3 = find(~ismember([1 2 3], [i_v1, i_v2]));

    gamma = atan2(tri_vertices_beta(2,i_v2)-tri_vertices_beta(2,i_v1), tri_vertices_beta(1,i_v2)-tri_vertices_beta(1,i_v1));

    % Rotate along gamma
    ROT = [cos(-gamma) -sin(-gamma) 0;
           sin(-gamma) cos(-gamma) 0;
           0 0 1];
    tri_vertices_gamma = ROT*tri_vertices_beta;

    % Translate in y and z
    delta_y = tri_vertices_gamma(2,i_v1);
    delta_z = tri_vertices_gamma(3,i_v2);

    tri_vertices_delta = tri_vertices_gamma - [0; delta_y; delta_z];
    
    % Calculate area
    A_tri(i) = polyarea(tri_vertices_delta(1,:), tri_vertices_delta(2,:));
    
    % Calculate diamond grid angle, should be the less steepest one
    angle1 = atan2(tri_vertices_delta(2,i_v3),tri_vertices_delta(1,i_v3)-tri_vertices_delta(1,i_v1));
    angle2 = atan2(tri_vertices_delta(2,i_v3),tri_vertices_delta(1,i_v2)-tri_vertices_delta(1,i_v3));
    angle = sign(angle1)*min(abs([angle1, angle2]));
    
    % Setup boundaries
    a1 = (tri_vertices_delta(2,i_v3)-tri_vertices_delta(2,i_v1))./(tri_vertices_delta(1,i_v3)-tri_vertices_delta(1,i_v1));
    b1 = tri_vertices_delta(2,i_v1)-tri_vertices_delta(1,i_v1)*a1;

    a2 = (tri_vertices_delta(2,i_v3)-tri_vertices_delta(2,i_v2))./(tri_vertices_delta(1,i_v3)-tri_vertices_delta(1,i_v2));
    b2 = tri_vertices_delta(2,i_v2)-tri_vertices_delta(1,i_v2)*a2;

    o = sign(angle)*d_edge./cos(angle);

%     x = -1:0.01:1;
%     test_1 = a1*x+b1;
%     test_2 = a2*x+b2;
%     bound_1 = a1*x+b1-o;
%     bound_2 = a2*x+b2-o;
%     bound_3 = sign(angle)*ones(1,length(x))*d_edge;

    % Calculate d_y
    d_y = d_x*tan(angle)./2;

    % Find intersect point of boundary along x and left boundary and right
    % boundary
    x_min = (sign(angle)*d_edge-b1+o)/a1;
    x_max = (sign(angle)*d_edge-b2+o)/a2;

    % Generate points along x-axis
    x_element = x_min:d_x:x_max;

    % Generate points along y_axis;
    y_max = a1*(b2-b1)/(a1-a2)+b1-o;
    y_element = sign(angle)*d_edge:d_y:y_max;

    [x_element, y_element] = meshgrid(x_element, y_element);

    % Shift the coordinates of the even rows by half a d_x
    [N_rows, ~] = size(x_element);

    for j = 2:2:N_rows
        x_element(j,:) = x_element(j,:)+d_x/2;     
    end

    % Reformat to regular element form
    elements = [];
    N_elements = numel(x_element);
    elements(1,:) = reshape(x_element, 1, N_elements);
    elements(2,:) = reshape(y_element, 1, N_elements);

    % Remove all triangles outside triangle
    if sign(angle) < 0
        valid_elements = elements(2,:) >= a1*elements(1,:)+b1-o-1e-3 & ...
                         elements(2,:) >= a2*elements(1,:)+b2-o-1e-6 & ...
                         elements(2,:) <= d_edge;
    else
        valid_elements = elements(2,:) <= a1*elements(1,:)+b1-o+1e-6 & ...
                         elements(2,:) <= a2*elements(1,:)+b2-o+1e-6 & ...
                         elements(2,:) >= d_edge;
    end
    elements = [elements(1, valid_elements); elements(2, valid_elements)];

    % Center the elements
    elements(1,:) = elements(1,:)+(x_max-max(elements(1,:)))/2;
    if sign(angle) < 0
        elements(2,:) = elements(2,:)+(y_max-min(elements(2,:)))/2;
    else
        elements(2,:) = elements(2,:)+(y_max-max(elements(2,:)))/2;
    end

    % Add z-coordinate
    elements(3,:) = zeros(1,length(elements(1,:)));

    % Transform elements back
    elements = elements + [0; delta_y; delta_z];

    % Rotate elements back along z to the original orientation
    ROT = [cos(gamma) -sin(gamma) 0;
           sin(gamma) cos(gamma) 0;
           0 0 1];
    elements = ROT*elements;

    % Rotate elements back along y to the original theta
    ROT = [cos(beta) 0 sin(beta);
           0 1 0;
           -sin(beta) 0 cos(beta)];
    elements = ROT*elements;

    % Rotate elements back to original location
    ROT = [cos(alpha) -sin(alpha) 0;
           sin(alpha) cos(alpha) 0;
           0 0 1];
    elements = ROT*elements;

    % Add normal vector to all elements
    elements_norm = ones(3, length(elements(1,:))).*triangle_norm(:,i);

    % Add elements to element_loc and element_norm
    element_loc = [element_loc elements];
    element_norm = [element_norm elements_norm];

%     % Debug plot
%     figure; axis equal; hold on; grid on;
%     plot3(tri_vertices(1,:), tri_vertices(2,:), tri_vertices(3,:), 'DisplayName', 'Original');
%     plot3(tri_vertices_alpha(1,:), tri_vertices_alpha(2,:), tri_vertices_alpha(3,:), 'DisplayName', '\alpha');
%     plot3(tri_vertices_beta(1,:), tri_vertices_beta(2,:), tri_vertices_beta(3,:), 'DisplayName', '\beta');
%     plot3(tri_vertices_gamma(1,:), tri_vertices_gamma(2,:), tri_vertices_gamma(3,:), 'DisplayName', '\gamma');
%     plot3(tri_vertices_delta(1,:), tri_vertices_delta(2,:), tri_vertices_delta(3,:), 'DisplayName', '\delta');
%     plot3(x,test_1,zeros(1,length(x)), 'DisplayName', 'Edge Boundary 1');
%     plot3(x,test_2,zeros(1,length(x)), 'DisplayName', 'Edge Boundary 2');
%     plot3(x,bound_1,zeros(1,length(x)), 'DisplayName', 'Edge Boundary 1 offset');
%     plot3(x,bound_2,zeros(1,length(x)), 'DisplayName', 'Edge Boundary 2 offset');
%     plot3(x,bound_3,zeros(1,length(x)), 'DisplayName', 'Edge Boundary 3 offset');
%     plot3(elements(1,:), elements(2,:), elements(3,:), '*', 'DisplayName', 'Elements');
% 
%     quiver3(0, 0, 0, triangle_norm(1,i), triangle_norm(2,i), triangle_norm(3,i), 'DisplayName', 'Norm Original');
%     quiver3(0, 0, 0, tri_norm_alpha(1), tri_norm_alpha(2), tri_norm_alpha(3), 'DisplayName', 'Norm \alpha');
%     quiver3(0, 0, 0, tri_norm_beta(1), tri_norm_beta(2), tri_norm_beta(3), 'DisplayName', 'Norm \beta');
% 
%     legend; xlabel('x'); ylabel('y'); zlabel('z');
end

A = sum(A_tri);

% Plot vertices and edges and elements
figure; hold on;
grid on;
axis equal; xlabel('x'); ylabel('y'); zlabel('z');
cmap = get(gca, 'colororder');

% [~ , N_vertices] = size(vertices);
% for i = 1:N_vertices
%     plot3(vertices(1,i), vertices(2,i), vertices(3,i), '*', 'HandleVisibility', 'off');
%     text(vertices(1,i), vertices(2,i), vertices(3,i), num2str(i));
% end

plotted_edges = [NaN NaN];
for i = 1:N_triangles
    if ~ismember([triangles(1,i) triangles(2,i)], plotted_edges, 'Rows') || ...
       ~ismember([triangles(2,i) triangles(1,i)], plotted_edges, 'Rows')
        % Setup edge
        edge = [vertices(:, triangles(1,i)) vertices(:, triangles(2,i))];
        
        % Plot edge
        ax = gca;
        ax.ColorOrderIndex = 1;
        plot3(edge(1,:), edge(2,:), edge(3,:), 'DisplayName', 'Edge', 'HandleVisibility', 'off');
        
        % Add edge to plotted edges
        plotted_edges = [plotted_edges; [triangles(1,i) triangles(2,i)]];
    end
    
    if ~ismember([triangles(2,i) triangles(3,i)], plotted_edges, 'Rows') || ...
       ~ismember([triangles(3,i) triangles(2,i)], plotted_edges, 'Rows')
        % Setup edge
        edge = [vertices(:, triangles(2,i)) vertices(:, triangles(3,i))];
        
        % Plot edge
        ax = gca;
        ax.ColorOrderIndex = 1;
        plot3(edge(1,:), edge(2,:), edge(3,:), 'DisplayName', 'Edge', 'HandleVisibility', 'off');
        
        % Add edge to plotted edges
        plotted_edges = [plotted_edges; [triangles(2,i) triangles(3,i)]];
    end
    
    if ~ismember([triangles(3,i) triangles(1,i)], plotted_edges, 'Rows') || ...
       ~ismember([triangles(1,i) triangles(3,i)], plotted_edges, 'Rows')
        % Setup edge
        edge = [vertices(:, triangles(3,i)) vertices(:, triangles(1,i))];
        
        % Plot edge
        ax = gca;
        ax.ColorOrderIndex = 1;
        plot3(edge(1,:), edge(2,:), edge(3,:), 'DisplayName', 'Edge', 'HandleVisibility', 'off');
        
        % Add edge to plotted edges
        plotted_edges = [plotted_edges; [triangles(3,i) triangles(1,i)]];
    end
    
%     % Plot the normal vectors
%     quiver3(vertices(1,triangles(1,i)), vertices(2,triangles(1,i)), vertices(3,triangles(1,i)), ...
%             triangle_norm(1,i), triangle_norm(2,i), triangle_norm(3,i), 'r');
%     quiver3(vertices(1,triangles(2,i)), vertices(2,triangles(2,i)), vertices(3,triangles(2,i)), ...
%             triangle_norm(1,i), triangle_norm(2,i), triangle_norm(3,i), 'r');
%     quiver3(vertices(1,triangles(3,i)), vertices(2,triangles(3,i)), vertices(3,triangles(3,i)), ...
%             triangle_norm(1,i), triangle_norm(2,i), triangle_norm(3,i), 'r');
end

plot3(element_loc(1,:), element_loc(2,:), element_loc(3,:), 'o', 'Color', cmap(1,:), 'MarkerFaceColor', cmap(1,:), 'DisplayName', 'Elements');
%plot3(element_loc(1,:), element_loc(2,:), element_loc(3,:), '*', 'DisplayName', 'Elements');
quiver3(element_loc(1,:), element_loc(2,:), element_loc(3,:), ...
        element_norm(1,:), element_norm(2,:), element_norm(3,:), 'DisplayName', 'Element normals', 'Color', cmap(2,:));
legend;
    
% Set view angle correctly
view(90+rad2deg(phi_view),90-rad2deg(theta_view));
end