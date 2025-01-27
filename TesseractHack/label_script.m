savefile=fullfile('Cache','objects.mat');
%savefile=fullfile('Cache','Paragraph.mat');

if exist(savefile,'file') == 2
    fprintf('Loading savefile %s', savefile);
    load(savefile)
else
    [objects,lines]=bounding_boxes(~I);
    save(savefile,'objects','lines');
end

max_h = 0;
max_w = 0;

for j=1:length(objects)
    [h,w] = size(objects(j).bwimage);
    max_h = max(max_h, h);
    max_w = max(max_w, w);
end

for j=1:length(objects)
    J = zeros([max_h,max_w],'uint8');
    BW = objects(j).bwimage;
    [h,w] = size(BW);
    x = round((max_w - w)/2);
    y = round((max_h - h)/2);
    J( (y+1):(y+h), (x+1):(x+w) ) = BW .* 255;
    objects(j).grayscaleimage = J;
    objects(j).char = '';
end

objects = label_objects(objects);