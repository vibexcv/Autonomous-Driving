function features = extractHOGFeaturesFromImageSet(imgSet, hogFeatureSize)
    numImages = numel(imgSet.Files);
    features = zeros(numImages, hogFeatureSize, 'single');

    for i = 1:numImages
        img = readimage(imgSet, i);
        img = rgb2gray(img);
        % Apply pre-processing steps
        img = imbinarize(img);
        features(i, :) = HOG(img);
    end
end