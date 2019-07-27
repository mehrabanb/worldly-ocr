classdef PageScanParameterTuner < handle
    properties
        scan;
    end

    methods
        function PageScanParameterTuner
            scan = PageScan;
        end


        function this = LoadFcn(this, event)
        % LOADFCN loads saved state from file
            [file, path] = uigetfile('*.bmp *.png *.tif *.ppm',...
                                     'Select an image file', 'page-06.ppm');

            if isequal(file,0)
                disp(['User selected ', fullfile(path,file)]);
                disp('User selected Cancel');
            else
                filepath = fullfile(path,file)
                this = this.scan.set_source(filepath);
            end
        end
    end
end