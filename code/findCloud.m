function [ptc, ptc_rs] = findCloud(imname, imset)
    disp = getDataRoad(imname, imset, 'disp');
    calib = getDataRoad(imname, imset, 'calib');

    depthdata = getDataRoad(imname,imset,'depth');
    depth = depthdata.depth.depth;
    
    [Y, X] = size(depth);

    px = calib.K(1, 3);
    py = calib.K(2, 3);

    cloud = zeros(Y, X, 3);
    for ix = 1:X
        for iy = 1:Y
            
           cloud(iy, ix, :) = [(ix - px) * depth(iy, ix) / calib.f, (iy - py) * depth(iy, ix) / calib.f, depth(iy, ix)];
        end
    end
    cloud = single(cloud);
    ptc = pointCloud(cloud); %convert to point cloud format
    ptc_rs = pointCloud(reshape(cloud,[size(cloud,1)*size(cloud,2) 3]));

end