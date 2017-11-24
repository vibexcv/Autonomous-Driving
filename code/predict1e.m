%1e predict images predict on test set

%Set Parameters
close all;
globals;
numOfTestImgs = 3; 
numOfFeatures = 9;
imset = 'train'; 
disparityRange = [-6 10];   %parameter for matlab disparity function
patch_size = 15;    %parameter for matlab disparity function

%get the image ids & model
imgsList = getDataRoad([], imset, 'list'); 
imageNums = imgsList.ids(1:numOfTestImgs);  %get the images
model = getDataRoad([], 'train', 'model'); 
svmmodel = model.svmmodel; % get the svmmodel


%go through each image 
for i = drange(1:numOfTestImgs)        

    %get left & gt of current imageid 
    left_imdata = getDataRoad(imageNums{i}, imset, 'left');
    left_img = rgb2gray(double(left_imdata.im)/255);
    
    
    % Find superpixels of trainingImg
    [L,N] = superpixels(left_img, 500);
    %figure
    %BW = boundarymask(L);
    %imshow(imoverlay(left_img,BW,'cyan'))
    
    %% Compute the Features 
    % All superpixels features    
    spFeatures = zeros(N, numOfFeatures); 
    
    %find the features for the image [color, 3d cord, gradient
    %get cloud for image 
    [cloud_img, cloud_rs]= findCloud(imageNums{i}, imset);
    cloud_img = cloud_img.Location;
    
    
    %find the gradient for the image 
    [gMag,gDir] = imgradient(left_img);
    
    %get depth
    depthdata = getDataRoad(imageNums{i},imset,'depth');
    depth = depthdata.depth.depth;
    
    
    %find feature set for each superpixel
    for spIdx = 1:N
        [y, x] = find(L==spIdx);
        % find the average of the features inside each super pixel
        numPixels = length(y);
        
        %take the average of the pixels in the superpixel
        r = mean2(left_imdata.im(y,x,1));
        g = mean2(left_imdata.im(y,x,2));
        b = mean2(left_imdata.im(y,x,3));
%         cloud = sum(sum(cloud_img(y,x,:)))/ (numPixels^2); %3d point
%         cloud = reshape(cloud,[1,3]);
%         grad = sum(sum(gMag(y,x)))/(numPixels^2);
        xs = sum(x)/numPixels;
        ys = sum(y)/numPixels;
        g_x = mean2(grad_x(y,x));
        g_y = mean2(grad_y(y,x));
        g_z = mean2(grad_z(y,x));
        z = mean2(depth(y,x));
        
        features = [r g b xs ys z g_x g_y g_z];
        spFeatures(spIdx,:) = features;   
    end
   
     
    [prediction,score]= predict(svmmodel, double(spFeatures));
    
    
    
    %%convert back to image 
    predicted_image = zeros(m, n, 3);    % All superpixels that belong to road.
      [m,n] = size(L);
       
    % find all superpixels that belong to road.
    for spIdx = 1:N
        [y, x] = find(L==spIdx);
        predicted_image(y,x) = left_img(y,x)*prediction(spIdx);
        %predicted_image(y,x,2) = 255*prediction(spIdx);
        %set that pixel to current prediction
        
    end
    

    
    %display & save the predicted outputs
        
    figure,
    imshow(predicted_image);
         BW = boundarymask(L);
     imshow(imoverlay(predicted_image,BW,'cyan'))
    imwrite(predicted_image, strcat('..\data-road\test\results\',imageNums{i},'_prediction.png'));

    
end 