classdef PageScanParameterTuner < handle
% PAGESCANPARAMETERTUNER - A utility class for GUI app PageScanParameterTunerApp
    properties
        app;
        scan;
    end

    properties(Dependent)
        ShortHeightThreshold;
        ColumnDistThreshold;
        MinCharHeight;
        MaxCharHeight;
        MinCharWidth;
        MaxCharWidth;
    end

    methods
        function this = PageScanParameterTuner(app)
            if nargin > 0
                this.app = app
            end
            opts.MergeCharacters = true;
            this.scan = PageScan(opts);
        end


        function this = LoadFcn(this, event)
        % LOADFCN loads saved state from file
            [file, path] = uigetfile({'*.bmp;*.png;*.tif;*.ppm'},...
                                     'Select an image file', 'page-06.ppm');

            if isequal(file,0)
                disp(['User selected ', fullfile(path,file)]);
                disp('User selected Cancel');
            else
                filepath = fullfile(path,file)
                this.LoadFile(filepath);

            end
        end

        function this = LoadFile(this, filepath)
            this.scan.Source = filepath;
            this.show_marked_page_img;
        end


        function show_marked_page_img(this)
            opts.Background = 'Mono';
            opts.ShowDilation = true;
            opts.ShowOutliers = false;
            opts.Axes = this.app.UIAxes;
            
            cla(opts.Axes);
            this.scan.show_marked_page_img(opts);
        end

        function rv = get.ShortHeightThreshold(this)
            rv = this.scan.opts.ShortHeightThreshold;
        end



        function rv = get.ColumnDistThreshold(this)
            rv = this.scan.opts.ColumnDistThreshold;
        end

        function this = set.ColumnDistThreshold(this, value)
            this.scan.opts.ColumnDistThreshold = value;
            this.scan.update;           % Rescan image with new params
        end


        function rv = get.MinCharHeight(this)
            rv = this.scan.opts.MinCharHeight;
        end


        function rv = get.MaxCharHeight(this)
            rv = this.scan.opts.MaxCharHeight;
        end

        function this = set.MaxCharHeight(this,value);
            this.scan.opts.MaxCharHeight = value;
            this.scan.update;           % Rescan image with new params
        end            



        function rv = get.MinCharWidth(this)
            rv = this.scan.opts.MinCharWidth;
        end
        function rv = get.MaxCharWidth(this)
            rv = this.scan.opts.MaxCharWidth;
        end


    end
end