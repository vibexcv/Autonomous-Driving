function plotGT(img, objects, seg, which)

if nargin < 3
    seg = [];
end;
if nargin < 4
    which = '2d';
end;
figure('position', [100, 150, size(img, 2)*0.7, size(img, 1)*0.7]);
subplot('position', [0,0,1,1]);
if ~isempty(seg)
      col = [1,0,0;0,0,1; 0,1,0; 1,1,0; 1,0,1; 0,1,1; 1,0.5, 0; 1,0,0.5; 0,0.5,1; 0.5,0,1; 0.5,1,0; 0,1,0.5];
      img = double(img); 
      u = unique(seg(:));
      u = u(u>0);
      alpha = 0.6;
      for i = 1 : length(u)
          ind = find(seg==u(i));
          id = mod(size(col, 1)-1, i)+1;
          for j = 1:3
              temp = img(:,:,j);
              temp(ind) = temp(ind)*alpha+col(id,j)*255*(1-alpha);
              img(:,:,j) = temp;
          end;
      end;
      img = uint8(img);
end;
imshow(img);
hold on;

    % title
    if strcmp(which, '2d')
        txt = '2D Bounding Boxes';
    else
        txt = '3D Bounding Boxes';
    end;
    text(size(img,2)/2,3,sprintf(txt),'color','g','HorizontalAlignment','center','VerticalAlignment','top','FontSize',14,'FontWeight','bold','BackgroundColor','black');
    
    % legend
    text(0,00,'Not occluded','color','g','HorizontalAlignment','left','VerticalAlignment','top','FontSize',14,'FontWeight','bold','BackgroundColor','black');
    text(0,30,'Partly occluded','color','y','HorizontalAlignment','left','VerticalAlignment','top','FontSize',14,'FontWeight','bold','BackgroundColor','black');
    text(0,60,'Fully occluded','color','r','HorizontalAlignment','left','VerticalAlignment','top','FontSize',14,'FontWeight','bold','BackgroundColor','black');
    text(0,90,'Unknown','color','w','HorizontalAlignment','left','VerticalAlignment','top','FontSize',14,'FontWeight','bold','BackgroundColor','black');
    text(0,120,'Don''t care region','color','c','HorizontalAlignment','left','VerticalAlignment','top','FontSize',14,'FontWeight','bold','BackgroundColor','black');

if strcmp(which, '2d')
   for i = 1 : length(objects)
       drawBox2D(objects(i))  
   end;
elseif strcmp(which, '3d')
   for i = 1 : length(objects)
       drawBox3D(objects(i))  
   end;
end;
    
    
    
function drawBox2D(object)

% set styles for occlusion and truncation
occ_col    = {'g','y','r','w'};
trun_style = {'-','--'};

% draw regular objects
if ~strcmp(object.type,'DontCare')

  % show rectangular bounding boxes
  pos = [object.x1,object.y1,object.x2-object.x1+1,object.y2-object.y1+1];
  trc = double(object.truncation>0.1)+1;
  rectangle('Position',pos,'EdgeColor',occ_col{object.occlusion+1},...
            'LineWidth',3,'LineStyle',trun_style{trc})
  rectangle('Position',pos,'EdgeColor','b')

  % draw label
  label_text = sprintf('%s\n%1.1f rad',object.type,object.alpha);
  x = (object.x1+object.x2)/2;
  y = object.y1;
  text(x,max(y-5,40),label_text,'color',occ_col{object.occlusion+1},...
       'BackgroundColor','k','HorizontalAlignment','center',...
       'VerticalAlignment','bottom','FontWeight','bold',...
       'FontSize',8);
     
% draw don't care regions
else
  
  % draw dotted rectangle
  pos = [object.x1,object.y1,object.x2-object.x1+1,object.y2-object.y1+1];
  rectangle('Position',pos,'EdgeColor','c',...
            'LineWidth',2,'LineStyle','-')
end


function drawBox3D(object)

% index for 3D bounding box faces
face_idx = [ 1,2,6,5   % front face
             2,3,7,6   % left face
             3,4,8,7   % back face
             4,1,5,8]; % right face
         
  % set styles for occlusion and truncation
  occ_col    = {'g','y','r','w'};
  trun_style = {'-','--'};
  trc        = double(object.truncation>0.1)+1;
  corners = object.corners2D;
  orientation = object.orientation3D;
  
  % draw projected 3D bounding boxes
  if ~isempty(corners)
    for f=1:4
      line([corners(1,face_idx(f,:)),corners(1,face_idx(f,1))]+1,...
           [corners(2,face_idx(f,:)),corners(2,face_idx(f,1))]+1,...
           'color',occ_col{object.occlusion+1},...
           'LineWidth',3,'LineStyle',trun_style{trc});
      line([corners(1,face_idx(f,:)),corners(1,face_idx(f,1))]+1,...
           [corners(2,face_idx(f,:)),corners(2,face_idx(f,1))]+1,...
           'color','b','LineWidth',1);
    end
  end
  
  % draw orientation vector
  if ~isempty(orientation)
    line([orientation(1,:),orientation(1,:)]+1,...
         [orientation(2,:),orientation(2,:)]+1,...
         'color','w','LineWidth',4);
    line([orientation(1,:),orientation(1,:)]+1,...
         [orientation(2,:),orientation(2,:)]+1,...
         'color','k','LineWidth',2);
  end