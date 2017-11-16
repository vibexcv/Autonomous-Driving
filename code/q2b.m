function fname = q2b(n)

    data = getDataCar([], 'test','list');
    ids = data.ids(1:3);
    
% detect in the first three images 
    for i= 1:n
        ds = detect(ids{i});

        fname=sprintf('../data-car/test/results/%s_car', ids{i});
        save(fname, 'ds');
    end
end


function ds = detect(imagename);
%     modified from demo_cars.m from dpm

    data = getDataCar([], [], 'detector-car');
    model = data.model;
    col = 'r';

    imdata = getDataCar(imagename, 'test', 'left');
    im = imdata.im;
    f = 1.5;
    imr = imresize(im,f);

    fprintf('running the detector, may take a few seconds...\n');
    tic;
    [ds, bs] = imgdetect(imr, model, model.thresh + 0.35); 
    % you may need to reduce the threshold if you want more detections
    e = toc;
    fprintf('finished! (took: %0.4f seconds)\n', e);
    nms_thresh = 0.2; %reduce to decrease number of overlaps
    top = nms(ds, nms_thresh);
    if model.type == model_types.Grammar
      bs = [ds(:,1:4) bs];
    end
    if ~isempty(ds)
        % resize back
        ds(:, 1:end-2) = ds(:, 1:end-2)/f;
        bs(:, 1:end-2) = bs(:, 1:end-2)/f;
    end;

%     figure;showboxesMy(im, reduceboxes(model, bs(top,:)), col);
    fprintf('detections:\n');
    ds = ds(top, :);
end