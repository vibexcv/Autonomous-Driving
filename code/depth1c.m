'%Find the depth of the images
%imset is either 'train' or 'test'
%numOfImgs is the number ofe images you want to run this function on
%sample run command: depth1c(3,'train')

function depth1c(numOfImgs,imset)
    close all;
    globals;
    imgsList = getDataRoad([], imset, 'list'); 
    imageNums = imgsList.ids(1:numOfImgs); %get the images
    c_min = 0;   %parameter for imsec, lowest depth
    c_max = 4000;  %parameter for imsec, highest depth 

    %go through each image and find/show depth
    for i = drange(1:numOfImgs)
        
        %get camera calibration matrix and disparity 
        calib = getDataRoad(imageNums{i}, imset, 'calib');
        disp = getDataRoad(imageNums{i}, imset, 'disp');   %get the saved disp from disparity1b.m
        
        %compute depth using (f*B)/dif = calib.f*10;
        depth = calib.f * calib.baseline ./ disp.disparity; 
        depth = min(depth, 4000);
        
        %show the depth image & save
        figure,imagesc(depth, [c_min, c_max]), colorbar
        fileLocation = sprintf('%s/%s/results/%s_depth.mat', DATA_DIR_ROAD,imset,imageNums{i});
        save(fileLocation,'depth');
    end;
end