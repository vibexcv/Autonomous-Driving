function depth = getDepth(im)
    calib = getData(im, 'test', 'calib');
    image = getData(im, 'test', 'disp');
    f = calib.f * calib.baseline;
    depth = f./image.disparity;
end