function visualize_text(objects,lines,right_to_left,get_image)
narginchk(2,4);
if nargin < 4
    get_image=@(obj)uint8(255.*obj.bwimage);
elseif nargin < 3
    right_to_left=false;
end
disp('Visualizing lines of text.');
l_cnt=size(lines,1);
figure;
clf;
% Flip vertical axis upside down
set(gca,'YDir','reverse');
% Make background black
whitebg('black');
hold on;
for l=1:l_cnt
    % Line objects
    l_objs=objects(lines{l});
    if right_to_left
        rng=numel(lines{l}):-1:1;
    else
        rng=1:numel(lines{l});
    end
    for j=rng
        r=l_objs(j).BoundingBox;
        x=r(1);y=r(2);w=r(3);h=r(4);
        % Plot characters
        J=get_image(l_objs(j));
        image([x,x+w],[y,y+h],J),drawnow;
        % Plot character bounding boxes only
        rectangle('Position',[x,y,w,h],'EdgeColor','green');
        colormap hot;
    end
end
hold off;

