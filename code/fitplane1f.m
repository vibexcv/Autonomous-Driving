%fitplane 1f

%get predicted gt for image and the image point cloud
imset = 'test';
imname = '000000';
left_imdata = getDataRoad(imname, imset, 'left');
left_img = rgb2gray(double(left_imdata.im)/255);
test_gt =  getDataRoad(imname, imset, 'test-gt');
test_gt = test_gt.testgt;
[cloud_img, cloud_rs]= findCloud(imname, imset);


%get the indexs where gt == 1 
[road_y,road_x] = find(test_gt > 0);

%get crooped point cloud using select
ptCloudOutData = select(cloud_img,road_y,road_x);
ptCloudOut = ptCloudOutData.Location;
% 
% Z = ptCloudOut(:, :, 3);
% X = ptCloudOut(:, :, 1);
% Y = ptCloudOut(:, :, 2);

%show the 3 point cloud
%surf(double(-X), double(-Y), double(Z),'Cdata', double(data.im) / 255, 'EdgeColor', 'none');

%then use pcfitplane
ground = [0 1 0];
maxDistance = 2;
[plane_road,inliers_road,outliers_road] = fitPlane(ptCloudOutData,maxDistance,ground);
