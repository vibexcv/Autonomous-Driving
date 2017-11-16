function [ptc, ptc_rs] = getCloud(imname)
    
    disp = getData(imname, 'test', 'disp');
    calib = getData(imname, 'test', 'calib');
    
    depth = getDepth(imname);
    [Y, X] = size(depth);

    px_d = calib.K(1, 3);
    py_d = calib.K(2, 3);
    f = calib.f;
    
    cloud = zeros(Y, X, 3);
    for x = 1:X
        for y = 1:Y
            cloud(y, x, 1) = (x - px_d) * (depth(y,x) / f);
            cloud(y, x, 2) = (y - py_d) * (depth(y,x) / f);
            cloud(y, x, 3) = depth(y,x);
        end
    end
    
    cloud = single(cloud);
    ptc = pointCloud(cloud); 
    ptc_rs = pointCloud(reshape(cloud,[size(cloud,1)*size(cloud,2) 3]));

end