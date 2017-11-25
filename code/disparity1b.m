%Find the disparity between left and right images
%imset is either 'train' or 'test'
%numOfImgs is the number of images you want to run this function on
%sample run command: disparity1a(3,'train')

function disparity1b(numOfTestImgs,imset)
    %TEMP CODE FOR TESTING. Using Matlabs test images
    close all;
    globals;
    %numOfTestImgs = 3; 
    %imset = 'test'
    imgsList = getDataRoad([], imset, 'list'); 
    imageNums = imgsList.ids(1:numOfTestImgs);  %get the images
    disparityRange = [0 16*15];   %parameter for matlab disparity function
    patch_size = 15;    %parameter for matlab disparity function

    %go through each image and find, show &save depth
    for i = drange(1:numOfTestImgs)        
            
        %get left and right of current imageid 
        left_imdata = getDataRoad(imageNums{i}, imset, 'left');
        left_img = rgb2gray(left_imdata.im);
        right_imdata = getDataRoad(imageNums{i}, imset, 'right');
        right_img = rgb2gray(right_imdata.im);

        %find the disparity between left and right image
        disparityMap = disparity(left_img,right_img,'BlockSize',15,'DisparityRange',disparityRange)/disparityRange(2);

        %save the disparity to .png file
        imwrite(disparityMap,strcat('../data-road/',imset,'/results/',imageNums{i},'_left_disparity.png'));
        
        %display the current disparity map
        figure,imshow(disparityMap);
        title('Test Disparity Map');

        
    end
    
    
    
    
    
    
    
% POSSIBLE CODE FOR MANUALLY COMPUTING DISPARITY WITH out matlab function ------------    


%     need to figure out camera parms for this to work
%     fx_d = 5.8262448167737955e+02;  
%     fy_d = 5.8269103270988637e+02;
%     px_d = 3.1304475870804731e+02;
%     py_d = 2.3844389626620386e+02;
%     matrix3d = zeros(size(disparityMap,1),size(disparityMap,2),3);
%     
%     for x =drange(1:size(disparityMap,2))
%         for y = drange(1:size(disparityMap,1))
%             z = disparityMap(y,x);
%             mx = (x-px_d).*z/fx_d; 
%             my = (y-py_d).*z/fy_d; 
%             matrix3d(y,x,:) = [mx,my,z];
%         end
%     end
% 
%     figure,plot3(matrix3d(:,:,1),matrix3d(:,:,2),matrix3d(:,:,3))
%     s = surf(matrix3d(:,:,1),matrix3d(:,:,2),matrix3d(:,:,3),imread('scene_left.png'))
%     set(s,'LineStyle','none');
% 
%     axis equal;
%     ------
%     
%    
%     for x = drange(15,size(left_img,2)-15)
%         for y = drange(15,size(left_img,1)-15)
%            xStart = floor(x-patch_size/2);
%            yStart = floor(y-patch_size/2);
%             
%             patch_left = imcrop(left_img,[xStart yStart patch_size patch_size]);
%             
%             currentSSDs = [];
%             
%             for xr = drange(15,size(right_img,2)-15)
%                 xrStart = floor(xr-patch_size/2);
%             
%                 patch_right = imcrop(right_img,[xrStart yStart patch_size patch_size]);
% 
%                 currentSSDs(size(currentSSDs,2)+1) = sum(sum((patch_left - patch_right)^2));
%                 
%             end
%         min(currentSSDs)
%         end
%     end
% 
% 
%     
%     
%     
%     
%     
%     
end