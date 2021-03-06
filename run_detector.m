% Starter code prepared by James Hays for CS 143, Brown University
% This function returns detections on all of the images in a given path.
% You will want to use non-maximum suppression on your detections or your
% performance will be poor (the evaluation counts a duplicate detection as
% wrong). The non-maximum suppression is done on a per-image basis. The
% starter code includes a call to a provided non-max suppression function.
function [bboxes, confidences, image_ids] = .... 
    run_detector(test_scn_path, w, b, feature_params)
% 'test_scn_path' is a string. This directory contains images which may or
%    may not have faces in them. This function should work for the MIT+CMU
%    test set but also for any other images (e.g. class photos)
% 'w' and 'b' are the linear classifier parameters
% 'feature_params' is a struct, with fields
%   feature_params.template_size (probably 36), the number of pixels
%      spanned by each train / test template and
%   feature_params.hog_cell_size (default 6), the number of pixels in each
%      HoG cell. template size should be evenly divisible by hog_cell_size.
%      Smaller HoG cell sizes tend to work better, but they make things
%      slower because the feature dimensionality increases and more
%      importantly the step size of the classifier decreases at test time.
% 'bboxes' is Nx4. N is the number of detections. bboxes(i,:) is
%   [x_min, y_min, x_max, y_max] for detection i. 
%   Remember 'y' is dimension 1 in Matlab!
% 'confidences' is Nx1. confidences(i) is the real valued confidence of
%   detection i.
% 'image_ids' is an Nx1 cell array. image_ids{i} is the image file name
%   for detection i. (not the full path, just 'albert.jpg')
% The placeholder version of this code will return random bounding boxes in
% each test image. It will even do non-maximum suppression on the random
% bounding boxes to give you an example of how to call the function.
% Your actual code should convert each test image to HoG feature space with
% a _single_ call to vl_hog for each scale. Then step over the HoG cells,
% taking groups of cells that are the same size as your learned template,
% and classifying them. If the classification is above some confidence,
% keep the detection and then pass all the detections for an image to
% non-maximum suppression. For your initial debugging, you can operate only
% at a single scale and you can skip calling non-maximum suppression.
test_scenes = dir( fullfile( test_scn_path, '*.jpg' ));
fprintf('~~~path: %s', test_scn_path);
%initialize these as empty and incrementally expand them.
bboxes = zeros(0,4);
confidences = zeros(0,1);
image_ids = cell(0,1);
initial_point = [1,1;1,5;1,9;5,1;5,5;5,9;9,1;9,5;9,9];
for i = 1:length(test_scenes)
      
    fprintf('\n\nDetecting faces in %s', test_scenes(i).name)
    IMG = imread( fullfile( test_scn_path, test_scenes(i).name ));
    if(size(IMG,3) > 1)
        IMG = rgb2gray(IMG);
    end
    IMG = single(IMG)/255;
    img = IMG;
    num_cells= feature_params.template_size / feature_params.hog_cell_size; %6.
    num_orientations=9;
    D=(num_cells)^2 * 4 * num_orientations;
    cur_bboxes = zeros(0,4);
    cur_confidences = zeros(0,1);
    cur_image_ids = cell(0,1);
    rate=single(1.0);
    fprintf('\n');
    while 1
        %fprintf('size:%d*%d\n',size(img,1),size(img,2) );
        if size(img,1)<36 || size(img,2)<36
            break;
        end
        for ini=1:9
            %fprintf('rate: %f ',rate);
            Im=img(initial_point(ini,1):end,initial_point(ini,2):end);
            if size(Im,1)<36 || size(Im,2)<36
                break;
            end

            %You can delete all of this below.
            % Let's create 15 random detections per image
            %cur_x_min = rand(15,1) * size(img,2);
            %cur_y_min = rand(15,1) * size(img,1);
            %cur_bboxes = [cur_x_min, cur_y_min, cur_x_min + rand(15,1) * 50, cur_y_min + rand(15,1) * 50];
            %cur_confidences = rand(15,1) * 4 - 2; %confidences in the range [-2 2]
            %cur_image_ids(1:15,1) = {test_scenes(i).name};

            [X,Y]=size(Im);
            feature=rand(1,D);
            %fprintf('Find faces in %s\n', test_scenes(i).name);

            HOG = vl_hog(single(Im),feature_params.hog_cell_size,'variant','dalaltriggs','numOrientations',num_orientations);

            for j=0:(feature_params.hog_cell_size*2):(X-feature_params.template_size)
                for k=0:(feature_params.hog_cell_size*2):(Y-feature_params.template_size)
                    %Im=img((j+1):(j+feature_params.template_size),(k+1):(k+feature_params.template_size));
                    hog = HOG((j/feature_params.hog_cell_size+1) : (j/feature_params.hog_cell_size+num_cells),... 
                            (k/feature_params.hog_cell_size+1) : (k/feature_params.hog_cell_size+num_cells),:);
                    temp1=reshape(hog,[num_cells^2,num_orientations*4]);
                    temp2=transpose(temp1);
                    feature(1,:)=reshape(temp2,[1,D]); 
                    %for m=1:num_cells
                    %   for n=1:num_cells
                    %      last=((m-1)*num_cells+n-1)*36;
                    %     curr=((m-1)*num_cells+n)*36;
                    %    feature_pos((last+1):curr)=HOG(m,n,:);
                    % end 
                    %end
                    confidence=feature*w+b;
                    if confidence>0.9
                        cur_bboxes=[cur_bboxes; (k+initial_point(ini,2))/rate,(j+initial_point(ini,1))/rate,...
                            (k+feature_params.template_size+initial_point(ini,2))/rate,(j+feature_params.template_size+initial_point(ini,1))/rate];
                        cur_confidences=[cur_confidences;confidence];
                        cur_image_ids=[cur_image_ids;test_scenes(i).name];
                    end
                end
            end
        end
        img = imresize(img,0.9);
        rate = rate*0.9;
        
    end
    %fprintf('Suppress %d %d faces in %s\n', size(cur_bboxes,1),size(cur_confidences,1),test_scenes(i).name);
    %non_max_supr_bbox can actually get somewhat slow with thousands of
    %initial detections. You could pre-filter the detections by confidence,
    %e.g. a detection with confidence -1.1 will probably never be
    %meaningful. You probably _don't_ want to threshold at 0.0, though. You
    %can get higher recall with a lower threshold. You don't need to modify
    %anything in non_max_supr_bbox, but you can.
    [is_maximum] = non_max_supr_bbox(cur_bboxes, cur_confidences, size(IMG));
    cur_confidences = cur_confidences(is_maximum,:);
    cur_bboxes      = cur_bboxes(     is_maximum,:);
    cur_image_ids   = cur_image_ids(  is_maximum,:);

    bboxes      = [bboxes;      cur_bboxes];
    confidences = [confidences; cur_confidences];
    image_ids   = [image_ids;   cur_image_ids];
        
        
end
