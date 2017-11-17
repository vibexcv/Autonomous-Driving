function P = readCalibration(calib_dir,img_idx,whichcam)

if nargin < 3, whichcam = 'left'; end;
  % load 3x4 projection matrix
  P = dlmread(sprintf('%s/%06d.txt',calib_dir,img_idx),' ',0,1);
  if strcmp(whichcam, 'right')
      i = 4;
  else
      i=3;
  end;
  P = P(i,:);
  P = reshape(P ,[4,3])';
  
end
