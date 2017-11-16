%Find the depth of the images
%imset is either 'train' or 'test'
%numOfImgs is the number ofe images you want to run this function on
%sample run command: depth1b(3,'train')

function depth1b(numOfImgs,imset)
    close all;
    globals;
    %numOfTestImgs = 3; 
    %imset = 'train'
    imgsList = getDataRoad([], imset, 'list'); 
    imageNums = imgsList.ids(1:numOfImgs); %get the images
    c_min = 0;   %parameter for imsec, lowest depth
    c_max = 80;  %parameter for imsec, highest depth 

    %go through each image and find/show depth
    for i = drange(1:numOfImgs)
        
        %get camera calibration matrix and disparity 
        dataCalib = getDataRoad(imageNums{i}, imset, 'calib');
        dataDisparity = getDataRoad(imageNums{i}, imset, 'disp');
        dataDisparity = dataDisparity.disparity;
        
        %compute depth using (f*B)/disparity
        dim = size(dataDisparity);
        numerator = (dataCalib.f*dataCalib.baseline);
        calibGrid = meshgrid(meshgrid(numerator,1:dim(2)),1:dim(1));  %repeat the numerator value so that matrix sizes match in division
        depth = calibGrid./dataDisparity.disparityMap;

        %show the depth image & save
        figure,imagesc(depth, [c_min, c_max]), colorbar
        fileLocation = sprintf('%s/%s/results/%s_depth.mat', DATA_DIR_ROAD,imset,imageNums{i});
        save(fileLocation,'depth');
    end;
end