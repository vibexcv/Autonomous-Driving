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
trainingSet = imageDatastore(trainingDir,   'IncludeSubfolders', true, 'LabelSource', 'foldernames');
testSet     = imageDatastore(testDir, 'IncludeSubfolders', true, 'LabelSource', 'foldernames');

% Get labels for each image.
trainingLabels = trainingSet.Labels;
testLabels = testSet.Labels;
% cp = classperf(trainingLabels);

% countEachLabel(trainingSet)
% countEachLabel(testSet)

%% 2. Use HOG Features
img = readimage(trainingSet, 1);
hog_4x4 = HOG(img);
hogFeatureSize = length(hog_4x4);

%% 3. Train a Road Classifier
trainingFeatures = extractHOGFeaturesFromImageSet(trainingSet, hogFeatureSize);

classifier = svmtrain(trainingFeatures, trainingLabels);

%% Evaluate The Road Classifier
% Extract HOG features from the test set.
testFeatures = extractHOGFeaturesFromImageSet(testSet, hogFeatureSize);

% Make class predictions using the test features.
predictedLabels = svmclassify(classifier, testFeatures);

% Tabulate the results using a confusion matrix.
confMat = confusionmat(testLabels, predictedLabels);

%% Detect Road