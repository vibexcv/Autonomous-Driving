%function imgDepths = Q2A_depth(numOfTestImgs)
    close all;
    numOfTestImgs = 3; 
    imgsList = getData([], 'test', 'list'); 
    imageNums = imgsList.ids(1:numOfTestImgs);
    c_min = 0;
    c_max = 80;
    imgDepths = {};

    %go through each image and find/show depth
    for i = drange(1:numOfTestImgs)
        %get camera calibration matrix and disparity 
        dataCalib = getData(imageNums{i}, 'test', 'calib');
        dataDisparty = getData(imageNums{i}, 'test', 'disp');

        %compute depth using (f*B)/disparity
        dim = size(dataDisparty.disparity);
        numerator = (dataCalib.f*dataCalib.baseline);
        calibGrid = meshgrid(meshgrid(numerator,1:dim(2)),1:dim(1));  %repeat the numerator value so that matrix sizes match in division
        depth = calibGrid./dataDisparty.disparity;
        imgDepths{size(imgDepths,2)+1} = depth;

        %show the depth image
        figure,imagesc(depth, [c_min, c_max]), colorbar
    end;
%end