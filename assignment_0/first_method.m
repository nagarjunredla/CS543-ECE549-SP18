

filenames = dir('data');
names_cell = {filenames.name};
names_cell = names_cell(3:end);
names_cell = char(strcat('data', '/', names_cell));

for i = 1:size(names_cell, 1)
    image = imread(names_cell(i,:));
    [height, width] = size(image);
    crop_size = floor(height/3);
    b_chan = image(              1:crop_size,:);
    g_chan = image(  crop_size+1:2*crop_size,:);
    r_chan = image(2*crop_size+1:3*crop_size,:);
    processed_image = process_image(b_chan, g_chan, r_chan);
    img_name = strcat('output/processed_image_', int2str(i), '.png');
    imwrite(processed_image, img_name);
end

function processed_image = process_image(b_chan, g_chan, r_chan)
    processed_image = cat(3, r_chan, g_chan, b_chan);
    [x1, y1] = slide_match(processed_image(:,:,3), processed_image(:,:,1))
    [x2, y2] = slide_match(processed_image(:,:,3), processed_image(:,:,2))
    processed_image(:,:,1) = imtranslate(processed_image(:,:,1), [x1,y1], 'FillValues', 255);
    processed_image(:,:,2) = imtranslate(processed_image(:,:,2), [x2,y2], 'FillValues', 255);
end

function [x,y] = slide_match(chan_1, chan_2)
    slide_window = 15;
    x = 0;
    y = 0;
    best_score = ssd_ncc_score(chan_1,chan_2);
    for j = 0:slide_window
        for k = 0:slide_window
            new_chan = imtranslate(chan_2, [j,k], 'FillValues', 0);
            new_score = ssd_ncc_score(chan_1, new_chan);
            if new_score < best_score
                best_score = new_score;
                x = j;
                y = k;
            end     
        end
    end
end
function score = ssd_ncc_score(image1, image2)
   u = double(reshape(image1, 1, []));
   v = double(reshape(image2, 1, []));
   ssd_score = sum((u-v).^2);
   ncc_score = dot(u,v)/(norm(u) * norm(v));
   score = ssd_score + ncc_score;
end