% List of classes for training data
classes = {'um_lane', 'um_road', 'umm_road', 'uu_road'};
numClasses = size(classes, 2);

Compute HOG feature vector for each image
for i = 1:numClasses
    class = char(classes(i));
    class = strsplit(class, '_');
    fprintf('Computing on dataset: %s for class: %s', char(class(1)), char(class(2)));
    % Load train images
    dir = fullfile('../data-road/train/gt_image_2');
    trainingSet = imageDatastore(dir);
    files = trainingSet.Files;
    numFiles = size(files);
end


%% Detect Road

testDetectDir = fullfile('../data-road', 'test','left','um');
imgStorage = imageDatastore(testDetectDir);
files = imgStorage.Files;
numFiles = length(files);

for i = 1:1
    im = readimage(imgStorage,1);
    % Detect each object of interest
    detect(im, classifier, [24,32]);
%     pred = predict(classifier, trainingFeatures);
%     cp = classperf(cp, pred, testIdx);
end

topLeftRow = 1;
topLeftCol = 1;
[bottomRightCol bottomRightRow d] = size(im);

fcount = 1;

wSize = [24,32];
% this for loop scan the entire image and extract features for each sliding window
for y = topLeftCol:wSize(2):bottomRightCol-wSize(2)   
    for x = topLeftRow:wSize(1):bottomRightRow-wSize(1)
        img = imcrop(im, [x,y, x+(wSize(1)-1), y+(wSize(2)-1)]);     
        featureVector{fcount} = HOG(double(img));
        boxPoint{fcount} = [x,y];
        fcount = fcount+1;
    end
    [x, y]
end

label = ones(length(featureVector),1);
features = cell2mat(featureVector);
% each row of P' correspond to a window
predictions = svmclassify(classifier, features'); % classifying each window

indx = find(predictions=='road');
pts = boxPoint(indx);
pts = [cell2mat(pts(:))];

imshow(im);
hold on;
plot(pts(:, 1), pts(:, 2), 'r*', 'LineWidth', 2, 'MarkerSize', 15);