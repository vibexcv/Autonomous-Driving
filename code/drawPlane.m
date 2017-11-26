function corners = drawPlane(cloud, plane, inlier)
np = size(cloud, 1);
if nargin < 3
    inlier = 1:np;
end
mins = min(cloud(inlier, :), [], 1);
maxs = max(cloud(inlier, :), [], 1);
% mins = min(cloud, [], 1);
% maxs = max(cloud, [], 1);
incr = (maxs - mins) / 5;
[~, dir] = max(abs(plane(1:3)));
if (dir == 1)
    [y, z] = meshgrid(mins(2):incr(2):maxs(2),mins(3):incr(3):maxs(3));
    x = findX(plane, y, z);
elseif (dir == 2)
    [x, z] = meshgrid(mins(1):incr(1):maxs(1),mins(3):incr(3):maxs(3));
    y = findY(plane, x, z);
elseif (dir == 3)
    [x, y] = meshgrid(mins(1):incr(1):maxs(1),mins(2):incr(2):maxs(2));
    z = findZ(plane, x, y);
end
corners = [x(1, 1), y(1, 1), z(1, 1); x(1, end), y(1, end), z(1, end); x(end, end), y(end, end), z(end, end); x(end, 1), y(end, 1), z(end, 1); x(1, 1), y(1, 1), z(1, 1)];
plot3(cloud(:,1), cloud(:,2), cloud(:,3), 'ro'); hold on
plot3(cloud(inlier,1), cloud(inlier,2), cloud(inlier,3), 'bo'); hold on
surf(x, y, z); hold on
plot3(corners(:,1), corners(:,2), corners(:,3),'g.','markersize',50);
xlabel('X');
ylabel('Y');
zlabel('Z');
end 