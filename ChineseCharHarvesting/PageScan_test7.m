disp(mfilename);

config_pages;

keep_outliers=false;
show_horizontal=true;
show_vertical=true;
erase_vertical_lines=false;

for page=pages
    filename=fullfile(pagedir,sprintf(page_img_pattern,page));
    ps = PageScan(filename,'KeepOutliers',keep_outliers);
    ps.show_boundary('ShowHorizontal',show_horizontal,...
                     'ShowVertical',show_vertical,...
                     'EraseVerticalLines',erase_vertical_lines);
    title(sprintf('Page %d', page));
    drawnow;
    uiwait(gcf);
    %pause;
end;