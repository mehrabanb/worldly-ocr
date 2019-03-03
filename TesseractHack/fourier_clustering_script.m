%savefile=fullfile('Cache','objects.mat');
savefile=fullfile('Cache','Paragraph.mat');

if exist(savefile,'file') == 2
    fprintf('Loading savefile %s', savefile);
    load(savefile)
else
    [objects,lines]=bounding_boxes(~I);
    save(savefile,'objects','lines');
end

wb = waitbar(0, 'Cropping/centering objects and converting to grayscale...');
num_objects = length(objects);
for j=1:num_objects;
    waitbar(j/num_objects, wb);
    J = zeros([max_h,max_w],'uint8');
    BW = objects(j).bwimage;
    [h,w] = size(BW);
    x = round((max_w - w)/2);
    y = round((max_h - h)/2);
    J( (y+1):(y+h), (x+1):(x+w) ) = BW .* 255;
    objects(j).grayscaleimage = J;
    objects(j).char = ' ';
end
close(wb);


[class_idx, class_num, class_reps] = fourier_clustering(objects)

% Label class representatives
reps = objects(class_reps);
reps = label_objects(reps);