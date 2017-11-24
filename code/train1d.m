%% Code reference: 
% Training Classifier:
% https://www.mathworks.com/help/vision/examples/digit-classification-using-hog-features.html
% HOG: 
% https://www.mathworks.com/matlabcentral/fileexchange/28689-hog-descriptor-for-matlab?focused=5179304&tab=function

%using super pixels


%Set Parameters
close all;
globals; %make sure globals is loaded 
numOfTestImgs = 80; 
numOfFeatures = 9;
numOfRandom = 450;  %450 is around all superpixels
imset = 'train';
disparityRange = [-6 10];   %parameter for matlab disparity function
patch_size = 15;    %parameter for matlab disparity function

%get the image ids
imgsList = getDataRoad([], imset, 'list'); 
imageNums = imgsList.ids(1:numOfTestImgs);  %get the images

%empty train and label list
trainFeatures = []; 
trainLabels = [];



%go through each image and find features and labels
for i = drange(1:numOfTestImgs)        
    sprintf('Image Number: %0.0f\n',i)
    
    
    %get left & gt of current imageid 
    left_imdata = getDataRoad(imageNums{i}, imset, 'left');
    left_img = rgb2gray(double(left_imdata.im)/255);
    gt_imgdata = getDataRoad(imageNums{i}, imset, 'gt');
    gt_img = rgb2gray(gt_imgdata.gt);
    %imshow(gt_img);
   
    
    % Find superpixels of trainingImg
     [L,N] = superpixels(left_img, 500);
     %figure
     %BW = boundarymask(L);
     %imshow(imoverlay(left_img,BW,'cyan'))


    %%Compute the labelstic;
    tic;
    spLabel = zeros(N, 1);    % All superpixels that belong to road.
    [m,n] = size(L);
       
    % find all superpixels that belong to road.
    for x = 1:n
        for y = 1:m
            % Check if this coordinate can be labeled as 'road'
            % by looking at its gt value(red).
            spIdx = L(y,x);
            if gt_img(y,x) == 105 % This is a 'road' pixel -> SP at (x,y) belongs to road
                spLabel(spIdx) = 1;
            end
        end
    end
            

    e = toc;
    fprintf('finished geting labels! (took: %0.4f seconds)\n', e);
    
    %% Compute the Features 
    % All superpixels features
    tic;  %start time counter
    spFeatures = zeros(N, numOfFeatures); 
    
    %find the features for the image [color, 3d cord, gradient
    %get cloud for image 
    [cloud_img, cloud_rs]= findCloud(imageNums{i}, imset);
    cloud_img = cloud_img.Location; 

    
    %find the gradient for the image     [gMag,gDir] = imgradient(left_img); %2d
    [grad_x, grad_y, grad_z] = imgradientxyz(cloud_img) ;
     e = toc;
    fprintf('finished getting gradients! (took: %0.4f seconds)\n', e);
    
    %get depth
    depthdata = getDataRoad(imageNums{i},imset,'depth');
    depth = depthdata.depth.depth;
    
    e = toc;
    fprintf('finished getting cloud, gradients, depth! (took: %0.4f seconds)\n', e);
    
    %find feature set for each superpixel
    tic; %start time counter
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
    e = toc;
    fprintf('finished getting features for each superpixel! (took: %0.4f seconds)\n', e);
    
    
    %get random sample of super pixels
    randIdxs = (randperm(N,min(numOfRandom,N)));
    randfeatures = spFeatures(randIdxs,:); % get a random subset of superpixels
    randLabels = spLabel(randIdxs);
      
    trainFeatures = [trainFeatures; randfeatures]; %concatenate current images features to features list
    trainLabels = [trainLabels; randLabels];%concatenate current images features to features list

    
end

%% Train the model using svm
tic;
svmmodel = fitcsvm(double(trainFeatures), double(trainLabels)); %train using svm
e = toc;
fprintf('finished training! (took: %0.4f seconds)\n', e);

%save the model
fileLocation = sprintf('%s/%s/model.mat', DATA_DIR_ROAD,imset); %save the model to mat file
save(fileLocation,'svmmodel');
