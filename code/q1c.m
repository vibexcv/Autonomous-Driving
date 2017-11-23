%% Code reference: 
% Training Classifier:
% https://www.mathworks.com/help/vision/examples/digit-classification-using-hog-features.html
% HOG: 
% https://www.mathworks.com/matlabcentral/fileexchange/28689-hog-descriptor-for-matlab?focused=5179304&tab=function

addpath(genpath(pwd));

%% 1. Get Road Data Set
% Load training and test data using |imageDatastore|.
trainingDir   = fullfile('../data-road', 'train','gt_image_2');
testDir = fullfile('../data-road', 'test','left');

% |imageDatastore| recursively scans the directory tree containing the
% images. Folder names are automatically used as labels for each image.
trainingSet = imageDatastore(trainingDir);
testSet = imageDatastore(testDir);

imgfiles = trainingSet.Files;
numFiles = length(imgfiles);

for i = 1:numFiles
    fileName = imgfiles(i);
    [filepath,imgName,ext] = fileparts(char(fileName));
    imgName = strsplit(imgName, '_');
    imgName = char(imgName(3));
    gt_trainingData = getDataRoad(imgName, 'train', 'gt');
    trainingData = getDataRoad(imgName, 'train', 'left');
    
    % Find superpixels of trainingImg
    img = trainingData.im;
    [L,N] = superpixels(img, 500);
%     figure
%     BW = boundarymask(L);
%     imshow(imoverlay(A,BW,'cyan'))

	gtImg = rgb2gray(gt_trainingData.gt);

    % All superpixels that belong to road.
    spLabel = zeros(N, 1);
    
    [m,n] = size(L);
    coordsGroupBySp = cell(1, length(N));
    for x = 1:m
        for y = 1:n
            % Check if this coordinate can be labeled as 'road'
            % by looking at its gt value(red).
            spIdx = L(x,y);
            if gtImg(x,y) == 105 % This is a 'road' pixel -> SP at (x,y) belongs to road
                spLabel(spIdx) = 1;
            end
            
        end
    end
    
    %% Compute features for each SP
    % Find all pixels for each SP and compute features for that SP group
    % Features = [r g b x y depth gradiant]
    features = zeros(length(N), 7);
    % Get depth image
    getDepth()
    for j = 1:length(N)
        [x, y] = find(L==j);
        numPixels = length(x);
        r = sum(img(x,y,1)) / numPixels;
        g = sum(img(x,y,2)) / numPixels;
        b = sum(img(x,y,3)) / numPixels;
        depth = 
    end

% % For each image, find depth of each pixel using similar triangles.
% for i = 1:numFiles
%     fileName = files(i);
%     [filepath,imgName,ext] = fileparts(char(fileName));
%     imgName = strsplit(imgName, '_');
%     imgName = char(imgName(1));
%     data = getData(imgName, 'test', 'calib');
%     data.P_left
%     data.P_right
%     % Find f and T.
%     f = data.f*10;
%     T = data.baseline*1000;
%     img = readimage(imgStorage,i);
%     depthImage = f*T./img;
% %     imshow(img);
%     fileName = fullfile(destDir, [imgName, '_depth_left.txt']);
%     dlmwrite(fileName, depthImage);
% end
% 
% depth1c(99,'train');

%     [x,y] = find(gtImg == 105);
%     roadLabelInicies = unique(L(1:x,1:y));
%     spLabel(roadLabelInicies) = 1;
        
end