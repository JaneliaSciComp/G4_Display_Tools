classdef G4_preview_view < handle
    
    
    properties
        con_
        fig_
        im_
        pat_axes_
        pos_line_
        ao_lines_
        dummy_line_
        fr_increment_box_
        frame_rate_box_
        
    end
    
    
    properties (Dependent)
        con
        fig
        im
        pat_axes
        pos_line
        ao_lines
        dummy_line
        fr_increment_box
        frame_rate_box
        
    end
    
    methods
        
        %% Constructor
        
        function self = G4_preview_view(varargin)
            
            if isempty(varargin)
                self.con = G4_preview_controller();
            else
                self.con = varargin{1};
            end
            
            if length(varargin) > 2
                self.fig = varargin{2};
            else
               
                self.fig = figure( 'Name', 'Trial Preview', 'NumberTitle', 'off','units', 'pixels'); 
            end

        end
        
        function layout(self, varargin)

            if ~isempty(varargin) && self.con.making_video == 1
                currentFig = varargin{1};
            else
                currentFig = self.fig;
            end
            pix = get(0, 'screensize'); 
            
            [patternSize, pat_xlim, pat_ylim] = self.con.get_pattern_axis_sizes();
            %ratios of y direction to x direction in pattern/function
            %files so images don't get squished forced into axes that
            %don't fit the data correctly.

            yTOx_pat_ratio = patternSize(2)/patternSize(1);

            if self.con.model.mode ~= 6 %There only needs to be a spot for one position function

                [fig_pos, pat_pos, pos_pos, ao1_pos, ao2_pos, ao3_pos, ao4_pos] ...
                = self.set_object_positions(pix, yTOx_pat_ratio);                

            else %There needs to be space for two position functions
                [fig_pos, pat_pos, pos_pos, dum_pos, ao1_pos, ao2_pos, ao3_pos, ao4_pos] ...
                = self.set_object_positions_mode6(pix, yTOx_pat_ratio);
                
            end

            ao_xlabel = 'Time';
            ao_ylabel = 'Volts';
            
            set(currentFig, 'Position', fig_pos); %create overall figure for preview
            %Files are all loaded, now create figure and axes
            self.pat_axes = axes(currentFig, 'units', 'pixels', 'Position', pat_pos, ...
                'XLim', pat_xlim, 'YLim', pat_ylim);
            
            first_frame = self.con.get_first_frame();            
            self.plot_pattern(first_frame);

           %Check for a position function and graph it according to mode
           if self.con.model.mode == 1
               if strcmp(self.con.model.data(3),'')
                   self.con.create_error_box("To preview in mode one please enter a position function");
                   return;
               else
                   
                   pos_title = 'Position Function Preview';
                   pos_xlabel = 'Time';
                   pos_ylabel = 'Frame Index';
                   self.pos_line = self.plot_function(currentFig, self.con.model.pos_data, pos_pos, pos_title, ...
                           pos_xlabel, pos_ylabel);
                   self.place_red_dur_line(self.con.model.pos_data);
               end
           end
               
           if self.con.model.mode == 4 || self.con.model.mode == 5 || self.con.model.mode == 7
               
               self.con.create_dummy_function();
               if self.con.model.mode == 4 || self.con.model.mode == 7
                   pos_title = "Closed-loop displayed as 1 Hz sine wave";
               else
                   pos_title = "Closed-loop displayed as combination dummy function";
               end
               pos_xlabel = 'Time';
               pos_ylabel = 'Frame Index';
               self.dummy_line = self.plot_function(currentFig, self.con.model.dummy_data, pos_pos, pos_title, ...
                    pos_xlabel, pos_ylabel);
                self.place_red_dur_line(self.con.model.dummy_data);
               
           end
           
           if self.con.model.mode == 6
           
                pos_title = 'Position Function Preview';
                pos_xlabel = 'Time';
                pos_ylabel = 'Frame Index';
                
                self.con.create_dummy_function();
                dummy_title = "closed loop displayed as 1 Hz sine wave";
                
                self.dummy_line = self.plot_function(currentFig, self.con.model.dummy_data, dum_pos, ...
                    dummy_title, pos_xlabel, pos_ylabel);
                self.pos_line = self.plot_function(currentFig, self.con.model.pos_data, pos_pos, ...
                    pos_title, pos_xlabel, pos_ylabel);
                self.place_red_dur_line(self.con.model.pos_data);
                self.place_red_dur_line(self.con.model.dummy_data);
           
           
           end
           
           %Cycle through ao functions and graph any that are present. 
           ao_positions = {ao1_pos, ao2_pos, ao3_pos, ao4_pos};
   
           for i = 1:4
               aoTitle = "Analog Output " + (i);
               if ~strcmp(self.con.model.data(i+3),'')
                   self.ao_lines{i} = self.plot_function(currentFig, self.con.model.ao_data{i}, ...
                       ao_positions{i}, aoTitle, ao_xlabel, ao_ylabel);
                   self.place_red_dur_line(self.con.model.ao_data{i});
               else
                   self.ao_lines{i} = 0;
               end
           end

           
           playButton = uicontrol(currentFig, 'Style', 'pushbutton', 'String', 'Play', 'FontSize', ...
                14, 'units', 'pixels', 'Position', [(pat_pos(1) + pat_pos(3))/2 + 25, 75, 50, 25], 'Callback', @self.play);
           stopButton = uicontrol(currentFig, 'Style', 'pushbutton', 'String', 'Stop', 'FontSize', ...
                14, 'units', 'pixels', 'Position', [(pat_pos(1) + pat_pos(3))/2 - 50, 75, 50, 25], 'Callback', @self.stop_playing);
           pauseButton = uicontrol(currentFig, 'Style', 'pushbutton', 'String', 'Pause', 'FontSize', ...
                14, 'units', 'pixels', 'Position', [ (pat_pos(1) + pat_pos(3))/2 + 100, 75, 90, 25], 'Callback', @self.pause_on);
           realtime = uicontrol(currentFig, 'Style', 'checkbox', 'String', 'Real-time speed', 'Value', ...
               self.con.model.is_realtime, 'FontSize', 14, 'Position', [ ((pat_pos(1) + pat_pos(3))/2 +215), 75, 200, 25],...
               'Callback', @self.change_realtime); 
           video_panel = uipanel(currentFig, 'Title', 'Video Generation', 'FontSize', 12, 'units', 'pixels', 'Position', ...
               [ao_positions{1}(1), 5, ao_positions{1}(3), 105]);
           generate_video = uicontrol(video_panel, 'Style', 'pushbutton', 'String', 'Generate Video', 'FontSize', ...
               14, 'units', 'normalized', 'Position', [.05, .05, .9, .25], 'Callback', @self.video);
           frame_rate_label = uicontrol(video_panel, 'Style', 'text', 'String', 'Video Frame Rate: ', ...
               'FontSize', 14, 'units', 'normalized', 'HorizontalAlignment', 'left', 'Position', [.05, .4, .5, .25]);
           self.frame_rate_box = uicontrol(video_panel, 'Style', 'edit', 'String', num2str(self.con.model.slow_frRate), ...
               'units', 'normalized', 'Position', [.6, .4, .3, .25], 'Callback', @self.change_slow_frRate);
           pattern_only_box = uicontrol(video_panel, 'Style', 'checkbox', 'String', 'Pattern Only Video', 'FontSize', ...
               14, 'units', 'normalized', 'Value', self.con.pattern_only, 'Position', [.05, .7, .9, .25],'Callback', @self.change_pat_only);
           note = uicontrol(currentFig, 'Style', 'text', 'String', "Please note: Video frame rates above 20 will make the on screen preview choppy or slow, " + ...
               "but video frame rates up to 60 will produce accurate, high-quality videos.", 'FontSize', 12, 'Position', ...
               [video_panel.Position(1) + video_panel.Position(3) + 10, video_panel.Position(2), ...
               250, 100]);
           self.fr_increment_box = uicontrol(currentFig, 'Style', 'edit', 'String', num2str(self.con.model.fr_increment),...
               'units', 'pixels', 'Position', [stopButton.Position(1), stopButton.Position(2) - 35, 50, 25], 'Callback', @self.change_fr_increment);
           fr_increment_label = uicontrol(currentFig, 'Style', 'text', 'String', 'Frame Increment', ...
               'units', 'pixels', 'FontSize', 14, 'Position', [self.fr_increment_box.Position(1) + self.fr_increment_box.Position(3) + 5, self.fr_increment_box.Position(2),...
               150,25]);

        end
        
        %% Update functions
        function update_layout(self)
            first_frame = self.con.get_first_frame();

            set(self.im,'cdata',self.con.model.pattern_data(:,:,first_frame))
            
            xdata = [1,1];
            if self.pos_line ~= 0
                self.pos_line.XData = xdata;
      
            end
            if self.dummy_line ~= 0
                self.dummy_line.XData = xdata;
                %set dummy_line position
            end
            
            %cycle through ao functions and update their data
            for i = 1:4
                if self.ao_lines{i} ~= 0
                    self.ao_lines{i}.XData = xdata;
                end
            end
            
        end
        
        function update_variables(self)
           
            self.fr_increment_box.String = num2str(self.con.model.fr_increment);
            self.frame_rate_box.String = num2str(self.con.model.slow_frRate);

            
        end
        
        function set_fr_increment(self)
        
            self.fr_increment_box.String = num2str(self.con.model.fr_increment);
        
        end
        
        %% Callbacks
        
        function change_pat_only(self, ~, ~)
            self.con.update_pattern_only();
        end
        
        function change_fr_increment(self, src, ~)
            self.con.update_fr_increment(str2double(src.String));
            self.update_variables();
        end
        
        function play(self, ~, ~)

            if self.con.model.mode == 1
               self.con.preview_Mode1();
            elseif self.con.model.mode == 2
                self.con.preview_Mode2();
            elseif self.con.model.mode == 3
                self.con.preview_Mode3();
            elseif self.con.model.mode == 4 
                self.con.preview_Mode4();
            elseif self.con.model.mode == 5
                self.con.preview_Mode4();
            elseif self.con.model.mode == 6
                self.con.preview_Mode6();
            else
                self.con.preview_Mode4();
            end

        end
        
        function stop_playing(self, ~, ~)
           
            self.con.stop();
            self.update_layout;
            
        end
        
        function change_realtime(self, ~, ~)
           
            self.con.set_realtime();
            
        end
        
        function pause_on(self, ~, ~)
            
            self.con.pause();
            
        end
        
        function video(self, ~, ~)
            self.con.generate_video();
        end
        
        function change_slow_frRate(self, src, ~)
            new_val = str2double(src.String);
            self.con.update_slow_frRate(new_val);
            if self.con.model.is_realtime == 1
                self.con.calculate_fr_increment();
            end
            self.update_variables(); 
        end
        
        %% General functions
        function draw(self)
            drawnow limitrate %nocallbacks
        end
        
        function plot_pattern(self, first_frame)
            self.im = imshow(self.con.model.pattern_data(:,:,first_frame), 'Colormap', gray);
            set(self.im, 'parent', self.pat_axes);
            title(self.pat_axes, 'Pattern Preview');
        end
        
        function [dur_line] = place_red_dur_line(self, data)
            dur = self.con.model.dur*1000;
            len = length(data(1,:));
            yax = [min(data) max(data)];
            if dur <= len
                 dur_line = line('XData', [dur, dur], 'YData', yax, 'Color', [1 0 0], 'LineWidth', 2);
            else
                dur_line = 0;
            end

        
        end
        
        function [func_line] = plot_function(self, fig, func, position, graph_title, x_label, y_label)
            
            xlim = [0 length(func(1,:))];
            ylim = [min(func) max(func)];
            func_axes = axes(fig, 'units','pixels','Position', position, ...
                'XLim', xlim, 'YLim', ylim);
            p = plot(func);
            set(p, 'parent', func_axes);
            func_line = line('XData',[self.con.model.preview_index, self.con.model.preview_index],'YData',[ylim(1), ylim(2)]);
            title(graph_title);
            xlabel(x_label);
            ylabel(y_label);
                

        end
        
         function [fig_pos, pat_pos, pos_pos, ao1_pos, ao2_pos, ao3_pos, ao4_pos] ...
                = set_object_positions(~, pix, yTOx_pat_ratio)
        
            fig_height = pix(4)*.65;
            fig_width = pix(3)*.9;
            fig_x = (pix(3) - fig_width)/2;
            fig_y = (pix(4)-fig_height)/2;
            fig_pos = [fig_x, fig_y, fig_width, fig_height];


            %charts h/w
            chart_height = fig_height/2 - pix(4)*.18;
            pat_chart_width = chart_height*yTOx_pat_ratio;
            pos_chart_width = pat_chart_width;
            aoChart_height = chart_height/2 - pix(4)*.02;
            aoChart_width = pat_chart_width/2;

            %title height plus buffer
            title_height = pix(4)*.1;
            aoTitle_height = title_height*.75;
            buffer = pix(4)*.05;

            %x/y positions of charts in figure
            patpos_x = pix(3)*.05;
            pos_y = pix(4)*.18;
            pat_y = pos_y + chart_height + title_height + buffer;
            ao_x = patpos_x + pat_chart_width + pix(3)*.15;
            ao1_y = pat_y + aoChart_height;
            ao2_y = ao1_y - aoTitle_height - aoChart_height;
            ao3_y = ao2_y - aoTitle_height - aoChart_height;
            ao4_y = ao3_y - aoTitle_height - aoChart_height;

            pat_pos = [patpos_x, pat_y, pat_chart_width, chart_height];
            pos_pos = [patpos_x, pos_y, pos_chart_width, chart_height];
            ao1_pos = [ao_x, ao1_y, aoChart_width, aoChart_height];
            ao2_pos = [ao_x, ao2_y, aoChart_width, aoChart_height];
            ao3_pos = [ao_x, ao3_y, aoChart_width, aoChart_height];
            ao4_pos = [ao_x, ao4_y, aoChart_width, aoChart_height];

        
         end
        
         function [fig_pos, pat_pos, pos_pos, dum_pos, ao1_pos, ao2_pos, ao3_pos, ao4_pos] ...
                = set_object_positions_mode6(~, pix, yTOx_pat_ratio)
        
        %figure
            fig_height = pix(4)*.85;
            fig_width = pix(3)*.97;
            fig_x = (pix(3) - fig_width)/2;
            fig_y = (pix(4)-fig_height)/2;
            fig_pos = [fig_x, fig_y, fig_width, fig_height];

            %charts h/w
            chart_height = fig_height/3 - 200;
            pat_chart_width = chart_height*yTOx_pat_ratio;
            aoChart_height = chart_height/2 - 20;
            aoChart_width = pat_chart_width/2;

            %title height plus buffer
            title_height = 100;
            aoTitle_height = title_height*.75;
            buffer = 50;

            %x/y positions of charts in figure
            patpos_x = 100;
            dummy_y = 150;
            pos_y = dummy_y + chart_height + title_height + buffer;
            pat_y = pos_y + chart_height + title_height + buffer;
            ao_x = patpos_x + pat_chart_width + 150;
            ao1_y = pat_y + aoChart_height;
            ao2_y = ao1_y - aoTitle_height - aoChart_height;
            ao3_y = ao2_y - aoTitle_height - aoChart_height;
            ao4_y = ao3_y - aoTitle_height - aoChart_height;

            pat_pos = [patpos_x, pat_y, pat_chart_width, chart_height];
            pos_pos = [patpos_x, pos_y, pat_chart_width, chart_height];
            dum_pos = [patpos_x, dummy_y, pat_chart_width, chart_height];
            ao1_pos = [ao_x, ao1_y, aoChart_width, aoChart_height];
            ao2_pos = [ao_x, ao2_y, aoChart_width, aoChart_height];
            ao3_pos = [ao_x, ao3_y, aoChart_width, aoChart_height];
            ao4_pos = [ao_x, ao4_y, aoChart_width, aoChart_height];
        
        end
        
        
        %% Setters
        
        function set.con(self, value)
            self.con_ = value;
        end
        function set.fr_increment_box(self, value)
            self.fr_increment_box_ = value;
        end
        function set.ao_lines(self, value)
            self.ao_lines_ = value;
        end
        function set.fig(self, value)
            self.fig_ = value;
        end
        
        function set.im(self, value)
            self.im_ = value;
        end
        function set.pat_axes(self, value)
            self.pat_axes_ = value;
        end
        function set.pos_line(self, value)
            self.pos_line_ = value;
        end

        function set.dummy_line(self, value)
            self.dummy_line_ = value;
        end
        
        function set.frame_rate_box(self, value)
            self.frame_rate_box_ = value;
        end
        
        %% Getters
        
        function value = get.con(self)
            value = self.con_;
        end
        
        function value = get.fr_increment_box(self)
            value = self.fr_increment_box_;
        end
        function value = get.ao_lines(self)
            value = self.ao_lines_;
        end
        function value = get.fig(self)
            value = self.fig_;
        end
        
        function value = get.im(self)
            value = self.im_;
        end
        function value = get.pat_axes(self)
            value = self.pat_axes_;
        end
        function value = get.pos_line(self)
            value = self.pos_line_;
        end

        function value = get.dummy_line(self)
            value = self.dummy_line_;
        end
        
        function value = get.frame_rate_box(self)
            value = self.frame_rate_box_;
        end
        
        
    end
    
    
end