%1e predict images%% predict on test set
fileLocation = sprintf('%s/%s/results/model.mat', DATA_DIR_ROAD,'train');
model = load(fileLocation);
svmmodel = model.svmmodel;






close all;
globals;
numOfTestImgs = 3; 
imset = 'test';
imgsList = getDataRoad([], imset, 'list'); 
imageNums = imgsList.ids(1:numOfTestImgs);  %get the images
disparityRange = [-6 10];   %parameter for matlab disparity function
patch_size = 15;    %parameter for matlab disparity function

X = []; 
Y = [];
%go through each image 
for i = drange(1:numOfTestImgs)        

    %get left & gt of current imageid 
    left_imdata = getDataRoad(imageNums{i}, imset, 'left');
    left_img = rgb2gray(double(left_imdata.im)/255);
    [image_sy, image_sx, image_sz] = size(left_imdata.im); 
    
    
    %get cloud for image 
    [cloud_img, cloud_rs]= findCloud(imageNums{i}, imset);
    [imidxx, imidxy] = meshgrid(1:image_sx,1:image_sy);
    cloud_img = cloud_img.Location;
    
    %% 2. Use HOG Features
    %left_img_bin = imbinarize(left_img);
    featureVector = HOGdescriptor(left_imdata.im);
    size(featureVector)
    
        
    %% generate training data x
    xim = reshape(left_imdata.im, [image_sy * image_sx image_sz]);
    xcloud = reshape(cloud_img, [image_sy * image_sx 3]);
    xidx = reshape(imidxy, [image_sy * image_sx 1]);
    
    xdesc = reshape(featureVector,[image_sy*image_sx 9]);
    xim = reshape(left_imdata.im, [image_sy * image_sx image_sz]);
    xcloud = reshape(cloud_img, [image_sy * image_sx 3]);
    xidx = reshape(imidxy, [image_sy * image_sx 1]);

    testx = [xim xcloud xidx xdesc];
    
    
    image = left_imdata;
    testim = left_imdata;   
   
        
        
    py = predict(svmmodel, double(testx));
    %display the predicted outputs
    iy = reshape(py, [size(testim.im,1) size(testim.im,2)]);
     figure, imshow(iy);
    imwrite(iy, strcat('..\data-road\test\results\aa_',imageNums{i},'_predroad.png'));
end 