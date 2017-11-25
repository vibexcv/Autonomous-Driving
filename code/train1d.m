%% Code reference: 
% Training Classifier:
% https://www.mathworks.com/help/vision/examples/digit-classification-using-hog-features.html
% HOG: 
% https://www.mathworks.com/matlabcentral/fileexchange/28689-hog-descriptor-for-matlab?focused=5179304&tab=function

%using super pixels
function svmmodel = train1d(numOfTrainImgs, numOfRandom)

    %Set Parameters
    close all;
    globals; %make sure globals is loaded 
    %numOfTrainImgs = 94; 
    numOfFeatures = 9;
    %numOfRandom = 300;  %number of random superpixels from each image
    imset = 'train';
    total_time = 0;

    %get the image ids
    imgsList = getDataRoad([], imset, 'list'); 
    imageNums = imgsList.ids(1:numOfTrainImgs);  %get the images

    %empty train and label list
    trainFeatures = [];
    trainLabels = [];


    %go through each image and find features and labels
    for i = drange(1:numOfTrainImgs)        
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
        total_time = total_time+e;
        fprintf('finished geting labels! (took: %0.4f seconds)\n', e);

        %% Compute the Features 
        % All superpixels features
        tic;  %start time counter
        spFeatures = zeros(N, numOfFeatures); 

        %find the features for the image [color, 3d cord, gradient
        %get cloud for image 
        [cloud_img, cloud_rs]= findCloud(imageNums{i}, imset);
        cloud_img = cloud_img.Location; 
        surf(double(-cloud_img(:,:,1)), double(-cloud_img(:,:,2)), double(cloud_img(:,:,3)),'Cdata', double(left_imdata.im) / 255, 'EdgeColor', 'none');


        %find the gradient for the image     [gMag,gDir] = imgradient(left_img); %2d
        [grad_x, grad_y, grad_z] = imgradientxyz(cloud_img) ;

        [G,D] = imgradient(cloud_img(:,:,1));
        [G2,D2] = imgradient(cloud_img(:,:,2));
        [G3,D3] = imgradient(cloud_img(:,:,3));
         e = toc;
        fprintf('finished getting gradients! (took: %0.4f seconds)\n', e);


        hsv = rgb2hsv(left_imdata.im); % hues

        e = toc;
        total_time = total_time+e;
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
           % xs = sum(x)/numPixels;
           % ys = sum(y)/numPixels;
            %g_x = mean2(grad_x(y,x));
           % g_y = mean2(grad_y(y,x));
            %g_z = mean2(grad_z(y,x));
           % X3d = mean2(cloud_img(y,x,1));  
            Y3d = mean2(cloud_img(y,x,2));
            %Z3d = mean2(cloud_img(y,x,3));

            Gx = mean2(G(y,x));
            Gy = mean2(G2(y,x));
            Gz = mean2(G3(y,x));
            hue = mean(mean(hsv(y,x,:)));

            %BEST OPTIONS SOO FAR
            %features = [r g b hue(1) hue(2) hue(3) Y3d Gx Gy Gz];
            %features = [r g b hue(1) hue(2) hue(3) Y3d Gx Gy];

            features = [r g b hue(1) hue(2) hue(3) Y3d Gx Gy];


            spFeatures(spIdx,:) = features;   


        end
        e = toc;
        total_time = total_time+e;
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
    total_time = total_time+e;
    fprintf('finished training! (took: %0.4f seconds)\n', e);
    fprintf('Total Time taken: %0.4f seconds)\n', total_time);

    %save the model
    fileLocation = sprintf('%s/%s/model.mat', DATA_DIR_ROAD,imset); %save the model to mat file
    save(fileLocation,'svmmodel');
end
