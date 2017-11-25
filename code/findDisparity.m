function disparityMap = findDisparity(imname, imset)

left_imdata = getDataRoad(imname, imset, 'left');
left_img = rgb2gray(left_imdata.im);
right_imdata = getDataRoad(imname, imset, 'right');
right_img = rgb2gray(right_imdata.im);


disparityRange = [0 16*15];
disparityMap = disparity(left_img,right_img,'BlockSize',15,'DisparityRange',disparityRange)/disparityRange(2);

% imshow(disparityMap);
% colormap jet;
imwrite(disparityMap,strcat('../data-road/',imset,'/results/',imname,'_left_disparity.png'));

end 