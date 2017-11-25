function [ptc, ptc_rs] = findCloud(imname, imset)

% get the depth
calib = getDataRoad(imname, imset, 'calib');
data = getDataRoad(imname, imset, 'left');
depth = getDataRoad(imname, imset, 'depth');  %get the saved depth from depth1c.m
depth = depth.depth.depth;

[Y, X] = size(depth);

px = calib.K(1, 3);
py = calib.K(2, 3);

cloud = zeros(Y, X, 3);
for ix = 1:X
    for iy = 1:Y
         cloud(iy, ix, :) = [(ix - px) * depth(iy, ix) / calib.f,  (iy - py) * depth(iy, ix) / calib.f, depth(iy, ix)];
    end
end

Z = cloud(:, :, 3);
X = cloud(:, :, 1);
Y = cloud(:, :, 2);

%show the 3 point cloud
surf(double(-X), double(-Y), double(Z),'Cdata', double(data.im) / 255, 'EdgeColor', 'none');

cloud = single(cloud);
ptc = pointCloud(cloud); %convert to point cloud format
ptc_rs = pointCloud(reshape(cloud,[size(cloud,1)*size(cloud,2) 3]));

end