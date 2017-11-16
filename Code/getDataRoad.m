function data = getData(imname, imset, whatdata)

% example to run: data = getData('000120', 'train', 'left');
% to load a detector, e.g.: data = getData([],[],'detector-car');

if nargin < 2
    fprintf('run with: data = getData(imname, imset, whatdata);\n');
    fprintf('where:\n');
    fprintf('   imset: ''train'' or ''test''\n');
    fprintf('   whatdata: ''list'', ''left'', ''right'', ''calib'', ''disp''\n')
    fprintf('   ''left-plot'' and ''right-plot'' and ''disp-plot'' will plot the data\n');
    fprintf('if the function doesn''t work, please check if globals.m is correctly set\n');
end;

globals;
data = [];

switch whatdata
    case {'list'}
        fid = fopen(fullfile(DATA_DIR_ROAD, imset, [imset '.txt']), 'r+');
        ids = textscan(fid, '%s');
        ids = ids{1};
        fclose(fid);
        data.ids = ids;
    case {'left', 'left-plot', 'right', 'right-plot'}
        leftright = strrep(whatdata, '-plot', '');
        imfile = fullfile(DATA_DIR_ROAD, imset, leftright, sprintf('%s.png', imname));
        im = imread(imfile);
        data.im = im;
        if strcmp(whatdata, sprintf('%s-plot', leftright))
            figure('position', [100,100,size(im,2)*0.7,size(im,1)*0.7]);
            subplot('position', [0,0,1,1]);
            imshow(im);
        end;
    case {'disp'}   %disparity
        dispdir = fullfile(DATA_DIR_ROAD, imset, 'results');
        dispfile = fullfile(dispdir, sprintf('%s_disparity.mat', imname));
        if ~exist(dispfile, 'file')
            fprintf('you haven''t computed disparity yet...\n');
        end;
        data.disparity = load(dispfile,'disparityMap');
        
    case 'calib'
        % read internal params
        calib_dir = fullfile(DATA_DIR_ROAD, imset, 'calib');
        [~, ~, calib] = loadCalibration(fullfile(calib_dir, sprintf('%s.txt', imname)));
        [Kl,~,tl] = KRt_from_P(calib.P_rect{3});  % left camera
        [~,~,tr] = KRt_from_P(calib.P_rect{4});  % right camera
        f = Kl(1,1);
        baseline = abs(tr(1)-tl(1));   % distance between cams
        data.f = f;
        data.baseline = baseline;
        data.K = Kl;
        data.P_left = calib.P_rect{3};
        data.P_right = calib.P_rect{4};
    
    
                
end;
