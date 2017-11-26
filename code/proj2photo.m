function pt2d = proj2photo(calib, pt3d)
% x<0 -> on my left; x>0 -> on my right
% y<0 -> above my camera; y>0 -> below my camera 
% z increasing -> further

q = calib.P_left * [pt3d'; ones(1,size(pt3d,1))];
pt2d = q(1:2,:)./[q(3,:);q(3,:)];
pt2d = pt2d';
end 