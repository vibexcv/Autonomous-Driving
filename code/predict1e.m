%1e predict images predict on test set
function predict1e(numOfTestImgs)
%Set Parameters
close all;
globals;
%numOfTestImgs = 10; 
numOfFeatures = 9;
imset = 'test'; 

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
        [G,D] = imgradient(cloud_img(:,:,1));
        [G2,D2] = imgradient(cloud_img(:,:,2));
        [G3,D3] = imgradient(cloud_img(:,:,3));

        %get depth
        %depthdata = getDataRoad(imageNums{i},imset,'depth');
        %depth = depthdata.depth.depth;

        hsv = rgb2hsv(left_imdata.im); % hues


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
            %xs = sum(x)/numPixels;
            %ys = sum(y)/numPixels;
            %g_x = mean2(grad_x(y,x));
            %g_y = mean2(grad_y(y,x));
            %g_z = mean2(grad_z(y,x));
            %z = mean2(depth(y,x));
            Y3d = mean2(cloud_img(y,x,2));
            Gx = mean2(G(y,x));
            Gy = mean2(G2(y,x));
            Gz = mean2(G3(y,x));
            hue = mean(mean(hsv(y,x,:)));



            features = [r g b hue(1) hue(2) hue(3) Y3d Gx Gy];

            spFeatures(spIdx,:) = features;   
        end


        [prediction,score]= predict(svmmodel, double(spFeatures));



     %%convert back to image 
                 [m,n] = size(L);

        predicted_image_black = zeros(m, n);    % All superpixels that belong to road.
        predicted_image = left_imdata.im;

    %     % find all superpixels that belong to road.
    %     for spIdx = 1:N
    %         [y, x] = find(L==spIdx);
    %         if prediction(spIdx) == 1
    %            predicted_image(y,x,:) = [0 255 0]; %set the road to green
    %         end
    %         %predicted_image(y,x,2) = 255*prediction(spIdx);
    %         %set that pixel to current prediction
    %         
    %     end

        % set all pixels of road to green

        for x = 1:n
            for y = 1:m
                spIdx = L(y,x);
                if prediction(spIdx) == 1   %if this pixel is predicted to be a road
                    predicted_image(y,x,:) = [0 255 0]; %set color to be green
                    predicted_image_black(y,x) = 1;
                end
            end
        end


        %display & save the predicted outputs

        figure,
        imshow(predicted_image);
        BW = boundarymask(L);
        imshow(imoverlay(predicted_image,BW,'cyan'))
        imwrite(predicted_image, strcat('..\data-road\test\results\',imageNums{i},'_prediction.png'));
        imwrite(predicted_image_black, strcat('..\data-road\test\results\',imageNums{i},'_gt_prediction.png'));


    end 
end