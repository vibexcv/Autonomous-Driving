addpath(genpath('dpm-windows'));
 

%% ROAD Detection 
numOfTrainImgs = 20; 
numOfTestImgs = 20;
imsetTest = 'train';
imsetTrain = 'test';
numOfRandom = 250;  %number of random superpixels from each image

%Get the disparity
%Trainning 
% disparity1b(numOfTrainImgs,imsetTrain);
% depth1c(numOfTrainImgs,imsetTrain);
% svmmodel = train1d(numOfTrainImgs, numOfRandom);  %gets and save the model in train folder

%Get training Precsion recall curve for the model
model = getDataRoad([], 'train', 'model'); 
svmmodel = model.svmmodel; % get the svmmodel

%predict on test images
tic;
disparity1b(numOfTestImgs,imsetTest);
depth1c(numOfTestImgs,imsetTest);
predict1e(numOfTestImgs)% gets and saves the predicted images in test/results folder
e = toc;
fprintf('finished predicting! (took: %0.4f seconds)\n', e);

%% Car detection 
%  detect cars in n images and save as ds
q2b(20);
 
%  train a classifier


%  plot arrows