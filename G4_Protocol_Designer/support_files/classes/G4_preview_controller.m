classdef G4_preview_controller < handle

    properties
         model_;

        fig_;
        im_;
        pat_axes_;
        pos_line_;
        
        ao_lines_;
      
        dummy_line_;
        frames_;
        
        making_video_;
         
    end
    
    properties (Dependent)
         model;

        fig;
        im;
        pat_axes;
        pos_line;
       
        ao_lines;
        dummy_line;
        frames
        
        making_video;

    end
    
    
    
    methods
 %CONSTRUCTOR
        function self = G4_preview_controller(data, doc)
            self.model = G4_preview_model(data, doc);
            
            self.fig = figure( 'Name', 'Trial Preview', 'NumberTitle', 'off','units', 'pixels'); 
            self.frames = struct('cdata', [], 'colormap', []);
            self.making_video = 0;


            self.layout();
            self.update_layout();
            
        
        end
        
        
        function layout(self, varargin)

            if ~isempty(varargin) && self.making_video == 1
                currentFig = varargin{1};
            else
                currentFig = self.fig;
            end
            pix = get(0, 'screensize'); 
            
            [patternSize, pat_xlim, pat_ylim] = self.get_pattern_axis_sizes();
            %ratios of y direction to x direction in pattern/function
            %files so images don't get squished forced into axes that
            %don't fit the data correctly.

            yTOx_pat_ratio = patternSize(2)/patternSize(1);

            
            if self.model.mode ~= 6 %There only needs to be a spot for one position function

                
                [fig_pos, pat_pos, pos_pos, ao1_pos, ao2_pos, ao3_pos, ao4_pos] ...
                = self.set_object_positions(pix, yTOx_pat_ratio);
                

            else %There needs to be space for two position functions
                [fig_pos, pat_pos, pos_pos, dum_pos, ao1_pos, ao2_pos, ao3_pos, ao4_pos] ...
                = self.set_object_positions_mode6(pix, yTOx_pat_ratio);
                
            end

                    %pat_num_frames = length(self.model.pattern_data(1,1,:));
            ao_xlabel = 'Time';
            ao_ylabel = 'Volts';
            
            set(currentFig, 'Position', fig_pos); %create overall figure for preview
            %Files are all loaded, now create figure and axes
            self.pat_axes = axes(currentFig, 'units', 'pixels', 'Position', pat_pos, ...
                'XLim', pat_xlim, 'YLim', pat_ylim);
            
            first_frame = self.get_first_frame();
            
%%%%%%%%%%%%%Make plotting a frame a different function 
            self.im = imshow(self.model.pattern_data(:,:,first_frame), 'Colormap', gray);
            set(self.im, 'parent', self.pat_axes);
            title(self.pat_axes, 'Pattern Preview');


           %Check for a position function and graph it according to mode
           if self.model.mode == 1
               if strcmp(self.model.data(3),'')
                   self.create_error_box("To preview in mode one please enter a position function");
                   return;
               else
                   
                   pos_title = 'Position Function Preview';
                   pos_xlabel = 'Time';
                   pos_ylabel = 'Frame Index';
                   self.pos_line = self.plot_function(currentFig, self.model.pos_data, pos_pos, pos_title, ...
                           pos_xlabel, pos_ylabel);
                   self.place_red_dur_line(self.model.pos_data);
               end
           end
               
           if self.model.mode == 4 || self.model.mode == 5 || self.model.mode == 7
               
               self.create_dummy_function();
               if self.model.mode == 4 || self.model.mode == 7
                   pos_title = "Closed-loop displayed as 1 Hz sine wave";
               else
                   pos_title = "Closed-loop displayed as combination dummy function";
               end
               pos_xlabel = 'Time';
               pos_ylabel = 'Frame Index';
               self.dummy_line = self.plot_function(currentFig, self.model.dummy_data, pos_pos, pos_title, ...
                    pos_xlabel, pos_ylabel);
                self.place_red_dur_line(self.model.dummy_data);
               
           end
           
           if self.model.mode == 6
           

                pos_title = 'Position Function Preview';
                pos_xlabel = 'Time';
                pos_ylabel = 'Frame Index';
                
                self.create_dummy_function();
                dummy_title = "closed loop displayed as 1 Hz sine wave";
                
                self.dummy_line = self.plot_function(currentFig, self.model.dummy_data, dum_pos, ...
                    dummy_title, pos_xlabel, pos_ylabel);
                self.pos_line = self.plot_function(currentFig, self.model.pos_data, pos_pos, ...
                    pos_title, pos_xlabel, pos_ylabel);
                self.place_red_dur_line(self.model.pos_data);
                self.place_red_dur_line(self.model.dummy_data);
           
           
           end
           
           %Cycle through ao functions and graph any that are present. 
           ao_positions = {ao1_pos, ao2_pos, ao3_pos, ao4_pos};
           
           
           for i = 1:4
               aoTitle = "Analog Output " + (i);
               if ~strcmp(self.model.data(i+3),'')
                   self.ao_lines{i} = self.plot_function(currentFig, self.model.ao_data{i}, ...
                       ao_positions{i}, aoTitle, ao_xlabel, ao_ylabel);
                   self.place_red_dur_line(self.model.ao_data{i});
               else
                   self.ao_lines{i} = 0;
               end
           end

           
           playButton = uicontrol(currentFig, 'Style', 'pushbutton', 'String', 'Play', 'FontSize', ...
                14, 'units', 'pixels', 'Position', [(pat_pos(1) + pat_pos(3))/2 + 25, 75, 50, 25], 'Callback', @self.play);
           stopButton = uicontrol(currentFig, 'Style', 'pushbutton', 'String', 'Stop', 'FontSize', ...
                14, 'units', 'pixels', 'Position', [(pat_pos(1) + pat_pos(3))/2 - 50, 75, 50, 25], 'Callback', @self.stop);
           pauseButton = uicontrol(currentFig, 'Style', 'pushbutton', 'String', 'Pause', 'FontSize', ...
                14, 'units', 'pixels', 'Position', [ (pat_pos(1) + pat_pos(3))/2 + 100, 75, 90, 25], 'Callback', @self.pause);
           realtime = uicontrol(currentFig, 'Style', 'checkbox', 'String', 'Real-time speed', 'Value', ...
               self.model.is_realtime, 'FontSize', 14, 'Position', [ ((pat_pos(1) + pat_pos(3))/2 +215), 75, 200, 25],...
               'Callback', @self.set_realtime); 
           generate_video = uicontrol(currentFig, 'Style', 'pushbutton', 'String', 'Generate Video', 'FontSize', ...
               14, 'units', 'pixels', 'Position', [ ao_positions{1}(1) + .5*ao_positions{1}(3) - 75, realtime.Position(2), 150, realtime.Position(4)], ...
               'Callback', @self.generate_video);
          

           
        
        
        end
        
        
        function update_layout(self)
            first_frame = self.get_first_frame();

            set(self.im,'cdata',self.model.pattern_data(:,:,first_frame))
            
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
        
        function [fig_pos, pat_pos, pos_pos, ao1_pos, ao2_pos, ao3_pos, ao4_pos] ...
                = set_object_positions(self, pix, yTOx_pat_ratio)
        
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
%             ao2Chart_width = pat_chart_width/2;
%             ao3Chart_width = pat_chart_width/2;
%             ao4Chart_width = pat_chart_width/2;



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
                = set_object_positions_mode6(self, pix, yTOx_pat_ratio)
        
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
%             ao2Chart_width = pat_chart_width/2;
%             ao3Chart_width = pat_chart_width/2;
%             ao4Chart_width = pat_chart_width/2;



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

        function create_error_box(varargin)
            if isempty(varargin)
                return;
            else
                msg = varargin{1};
                if length(varargin) >= 2
                    title = varargin{2};
                else
                    title = "";
                end

                e = errordlg(msg, title);
                set(e, 'Resize', 'on');
                waitfor(e);

            end

        end
        
        function preview_Mode1(self, varargin)
            
            if ~isempty(varargin) && self.making_video == 1
                currentFig = varargin{1};
            else
                currentFig = self.fig;
            end
            
            self.model.is_paused = false;
            time = self.model.dur*1000;
            if self.model.is_realtime == 1
                
                fr_rate = self.model.rt_frRate;
                aofr_rate = 1000;
                fr_increment = floor(fr_rate/self.model.slow_frRate);
                ao_increment = floor(aofr_rate/self.model.slow_frRate);
                
                
            else
                fr_rate = self.model.slow_frRate;
                aofr_rate = 1000*(self.model.slow_frRate/self.model.rt_frRate);
                fr_increment = 1;
                ao_increment = 1;
                
            end
            frame_count = 1; 
             
            num_frames = ceil((self.model.rt_frRate*self.model.dur)/fr_increment);
            self.frames = cell(1, num_frames);

            if self.pos_line == 0
                
                self.create_error_box("Please make sure you've entered a position function and try again.");
                
            else

                ratio = aofr_rate/fr_rate;
                count = 1;
                aoLineDist = [0 0 0 0];
                fr_increment = fr_increment*ratio;
                
                if self.model.is_realtime == 0

                    ao_increment = ao_increment*ratio;
                end
                
                
                
                for i = 1:4
                    if self.ao_lines{i} ~= 0
                        aoLineDist(i) = length(self.model.ao_data{i});
                    end
                end
                
                for i = floor(self.model.preview_index/fr_increment):num_frames
                    inside = tic;

                    if self.model.is_paused == true
                        return;
                    end
                    
                    
                    %move ao lines
                    
                    for k = 1:4
                        if self.ao_lines{k} ~= 0
                            if self.ao_lines{k}.XData(1) >= aoLineDist(k)
                                self.ao_lines{k}.XData = [1,1];
                            else
                                self.ao_lines{k}.XData = [self.ao_lines{k}.XData(1) + ao_increment, self.ao_lines{k}.XData(2) + ao_increment];
                            end
                            
                        if i == num_frames
                            self.ao_lines{k}.XData = [aoLineDist(k), aoLineDist(k)];
                        end

                        end
                        
                    end

                    if i == num_frames
                        if time > length(self.model.pos_data)
                            self.model.preview_index = rem(time,length(self.model.pos_data));
                        else
                            self.model.preview_index = time;
                        end
                     

                    end

                    if self.model.preview_index > length(self.model.pos_data)
                        self.model.preview_index = 1;
                    end
                    if self.model.preview_index == 0
                        self.model.preview_index = 1;
                    end
                    
                    frame = self.model.pos_data(self.model.preview_index);
                    set(self.im,'cdata',self.model.pattern_data(:,:,frame));

                    if self.pos_line ~= 0
                        if self.pos_line.XData(1) >= length(self.model.pos_data)
                            self.pos_line.XData = [1,1];
                        else
                            self.pos_line.XData = [self.model.preview_index,self.model.preview_index];
                        end
                    end

                    self.model.preview_index = self.model.preview_index + fr_increment;

                    drawnow limitrate %nocallbacks
                    
                    if self.making_video == 1
                        
                        self.frames{frame_count} = getframe(currentFig);
                        frame_count = frame_count + 1;
                    end
                        

                    timeElapsed = toc(inside);

                    if self.model.is_realtime == 1
                        time_to_pause = 1/self.model.slow_frRate - timeElapsed;%if realtime, ao line moves once every millsecond no matter what.
                        if time_to_pause < 0
                            time_to_pause = 0;
                        end
                        pause(time_to_pause);

                    else

                        time_to_pause = ((1/fr_rate)/ratio) - timeElapsed;%if slow, ao line still moves same number of times but at ratio of whatever the pattern frame rate is.
                        if time_to_pause < 0
                            time_to_pause = 0;
                        end 
                        pause(time_to_pause);

                    end
                    

                
                end
            
            end

        end

        
        function preview_Mode2(self)
            
            self.model.is_paused = false;
            time = self.model.dur*1000;
            if self.model.is_realtime == 1
                
                fr_rate = self.model.rt_frRate;
                aofr_rate = 1000;
                fr_increment = floor(fr_rate/self.model.slow_frRate);
                ao_increment = floor(aofr_rate/self.model.slow_frRate);
                
                
            else
                fr_rate = self.model.slow_frRate;
                aofr_rate = 1000*(self.model.slow_frRate/self.model.rt_frRate);
                fr_increment = 1;
                ao_increment = 1;
                
            end
            
            num_frames = ceil((self.model.rt_frRate*self.model.dur)/fr_increment);
            
            
            ratio = floor(aofr_rate/fr_rate);
            count = 1;
            aoLineDist = [0 0 0 0];
            fr_increment = fr_increment*ratio;
            if self.model.is_realtime == 0

                ao_increment = ao_increment*ratio;
            end



            for i = 1:4
                if self.ao_lines{i} ~= 0
                    aoLineDist(i) = length(self.model.ao_data{i});
                end
            end

            for i = floor(self.model.preview_index/fr_increment):num_frames
                inside = tic;

                if self.model.is_paused == true
                    return;
                end


                for k = 1:4
                    if self.ao_lines{k} ~= 0
                        if self.ao_lines{k}.XData(1) >= aoLineDist(k)
                            self.ao_lines{k}.XData = [1,1];
                        else
                            self.ao_lines{k}.XData = [self.ao_lines{k}.XData(1) + ao_increment, self.ao_lines{k}.XData(2) + ao_increment];
                        end

                        if i == num_frames
                            self.ao_lines{k}.XData = [aoLineDist(k), aoLineDist(k)];
                        end

                    end

                end
                
               
                frame = rem(self.model.preview_index,length(self.model.pattern_data(1,1,:)));
                
                if frame == 0
                    frame = 1;
                end
                
                set(self.im,'cdata',self.model.pattern_data(:,:,frame));

                 self.model.preview_index = self.model.preview_index + fr_increment;

                drawnow limitrate %nocallbacks
                timeElapsed = toc(inside);


                if self.model.is_realtime == 1
                    time_to_pause = 1/self.model.slow_frRate - timeElapsed;
                    if time_to_pause < 0
                        time_to_pause = 0;
                    end
                    pause(time_to_pause);

                else

                    time_to_pause = 1/self.model.slow_frRate - timeElapsed;
                    if time_to_pause < 0
                        time_to_pause = 0;
                    end 
                    pause(time_to_pause);

                end

            end

        end
        
                 
        
        function preview_Mode3(self)
            
            %This preview just shows the single frame at the given index,
            %so just leave the layout up.
            
        end
        
        function preview_Mode4(self)
            
            self.model.is_paused = false;
            time = self.model.dur*1000;
            
            if self.model.is_realtime == 1
                
                fr_rate = self.model.rt_frRate;
                aofr_rate = 1000;
                fr_increment = floor(fr_rate/self.model.slow_frRate);
                ao_increment = floor(aofr_rate/self.model.slow_frRate);
                
            else
                fr_rate = self.model.slow_frRate;
                aofr_rate = 1000*(self.model.slow_frRate/self.model.rt_frRate);
                fr_increment = 1;
                ao_increment = 1;
                
            end
            
            num_frames = ceil((self.model.rt_frRate*self.model.dur)/fr_increment);
            
                ratio = aofr_rate/fr_rate;
                count = 1;
                aoLineDist = [0 0 0 0];
                fr_increment = fr_increment*ratio;
                if self.model.is_realtime == 0

                    ao_increment = ao_increment*ratio;
                end
                
                for i = 1:4
                    if self.ao_lines{i} ~= 0
                        aoLineDist(i) = length(self.model.ao_data{i});
                    end
                end
                
                for i = floor(self.model.preview_index/fr_increment):num_frames
                    inside = tic;

                    if self.model.is_paused == true
                        return;
                    end
                    
                    for k = 1:4
                        if self.ao_lines{k} ~= 0
                            if self.ao_lines{k}.XData(1) >= aoLineDist(k)
                                self.ao_lines{k}.XData = [1,1];
                            else
                                self.ao_lines{k}.XData = [self.ao_lines{k}.XData(1) + ao_increment, self.ao_lines{k}.XData(2) + ao_increment];
                            end
                            
                        if i == num_frames
                            self.ao_lines{k}.XData = [aoLineDist(k), aoLineDist(k)];
                        end

                        end
                        
                    end

                    if i == num_frames
                        if time > length(self.model.dummy_data)
                            self.model.preview_index = rem(time,length(self.model.dummy_data));
                        else
                            self.model.preview_index = time;
                        end
                     

                    end

                    if self.model.preview_index > length(self.model.dummy_data)
                        self.model.preview_index = 1;
                    end

                    frame = self.model.dummy_data(self.model.preview_index);
                    set(self.im,'cdata',self.model.pattern_data(:,:,frame));

                    if self.dummy_line ~= 0
                        if self.dummy_line.XData(1) >= length(self.model.dummy_data)
                            self.dummy_line.XData = [1,1];
                        else
                            self.dummy_line.XData = [self.model.preview_index,self.model.preview_index];
                        end
                    end

                    self.model.preview_index = self.model.preview_index + fr_increment;

                    drawnow limitrate %nocallbacks

                    timeElapsed = toc(inside);

                    if self.model.is_realtime == 1
                        time_to_pause = 1/self.model.slow_frRate - timeElapsed;%if realtime, ao line moves once every millsecond no matter what.
                        if time_to_pause < 0
                            time_to_pause = 0;
                        end
                        pause(time_to_pause);

                    else

                        time_to_pause = ((1/fr_rate)/ratio) - timeElapsed;%if slow, ao line still moves same number of times but at ratio of whatever the pattern frame rate is.
                        if time_to_pause < 0
                            time_to_pause = 0;
                        end 
                        pause(time_to_pause);

                    end
                    

                
                end
            
            end
            
            
        
        
        function preview_Mode5(self)
            
            %Same as mode 4
        end
        
        function preview_Mode6(self)

            
             self.model.is_paused = false;


            if self.model.is_realtime == 1
                fr_rate = self.model.rt_frRate;
            else 
                fr_rate = self.model.slow_frRate;
            end

           

            if self.pos_line == 0
                self.create_error_box("Please make sure you have entered a position function and try again.");
            else
                
                
                if length(self.model.dummy_data) ~= length(self.model.pos_data)
                    self.create_error_box("Please make sure your position function is the same length as your duration");
                else
                
                    for i = self.model.preview_index:length(self.model.pos_data)
                        tic
                        if self.model.is_paused == false
                            
                            frame1 = self.model.dummy_data(i);
                            frame2 = self.model.pos_data(i);

                            set(self.im,'cdata',self.model.pattern_data(:,:,frame1, frame2));
                            if self.pos_line ~= 0
                                self.pos_line.XData = [self.pos_line.XData(1) + 1, self.pos_line.XData(2) + 1];
                            end
                            
                            if self.dummy_line ~= 0
                                self.dummy_line.XData = [self.dummy_line.XData(1) + 1, self.dummy_line.XData(2) + 1];
                            end
                            for k = 1:4
                                if self.ao_lines{k} ~= 0
                                    self.ao_lines{k}.XData = [self.ao_lines{k}.XData(1) + 1, self.ao_lines{k}.XData(2) + 1];
                                end
                            end

                            drawnow limitrate %nocallbacks
                             time_taken = toc;
                             self.frames(i) = getframe(gcf);
                        
                            time_to_pause = ((1/fr_rate)*1000) - (time_taken*1000);
                            if time_to_pause < 0
                                time_to_pause = 0;
                            end

                            java.lang.Thread.sleep(time_to_pause);       
                            self.model.preview_index = self.model.preview_index + 1;


                        end



                    
                    
                    end
                end
            end
            
        end
        
        function preview_Mode7(self)
            
            %Same as mode 4
            
        end
        
        function [func_line] = plot_function(self, fig, func, position, graph_title, x_label, y_label)
            
            xlim = [0 length(func(1,:))];
            ylim = [min(func) max(func)];
            func_axes = axes(fig, 'units','pixels','Position', position, ...
                'XLim', xlim, 'YLim', ylim);
            %title(func_axes, graph_title);
    %         xlabel(func_axes, x_label);
    %         ylabel(func_axes, y_label);
            p = plot(func);
            set(p, 'parent', func_axes);
            func_line = line('XData',[self.model.preview_index, self.model.preview_index],'YData',[ylim(1), ylim(2)]);
            title(graph_title);
            xlabel(x_label);
            ylabel(y_label);
                

        end
        
        function [first_frame] = get_first_frame(self)


            if self.model.mode == 1
                first_frame = self.model.pos_data(1);
            elseif self.model.mode == 2
                first_frame = 1;
            elseif self.model.mode == 3
                if strcmp(self.model.data{8},'r')
                    num_frames = length(self.model.pattern_data(1,1,:));
                    first_frame = randperm(num_frames,1);
                else
                    first_frame = str2num(self.model.data{8});
                end
            elseif self.model.mode == 4 || self.model.mode == 7
                first_frame = 1;
            elseif self.model.mode == 5
                first_frame = 1; %Where the dummy_pos is the result of combining the original dummy (1 hz sine wave) and the pos function
            elseif self.model.mode == 6
                first_frame = [1, self.model.pos_data(1)];
            end

        
        end
        
        function [dur_line] = place_red_dur_line(self, data)
            dur = self.model.dur*1000;
            len = length(data(1,:));
            yax = [min(data) max(data)];
            if dur <= len
                 dur_line = line('XData', [dur, dur], 'YData', yax, 'Color', [1 0 0], 'LineWidth', 2);
            else
                dur_line = 0;
            end

        
        end
        
        function create_dummy_function(self)
 
            ybound = length(self.model.pattern_data(1,1,:));

            
            if self.model.mode == 4 || self.model.mode == 7 || self.model.mode == 6

                time = self.model.dur*1000;
                sample_rate = 1;
                frequency = .001;
                step_size = 1/sample_rate;
                t = 0:step_size:(time - step_size);
                self.model.dummy_data = round((ybound/2 - 1)*sin(2*pi*frequency*t)+((ybound/2)+1),0);
            
            elseif self.model.mode == 5

                xlim = length(self.model.pos_data);
                dummy = zeros(1,xlim);
                ybnd = ybound/2;
                

                time = xlim;
                sample_rate = 1;
                frequency = .001;
                step_size = 1/sample_rate;
                t = 0:step_size:(time - step_size);
                dummy = round((ybnd - 1)*sin(2*pi*frequency*t)+(ybnd+1),0);
                
                
                for m = 1:xlim
                    self.model.dummy_data(m) = self.model.pos_data(m) + dummy(m);
                    if self.model.dummy_data(m) > ybound
                        factor = floor(self.model.dummy_data(m)/ybound);
                        self.model.dummy_data(m) = self.model.dummy_data(m) - (factor*ybound);
                        if self.model.dummy_data(m) == 0
                            self.model.dummy_data(m) = self.model.dummy_data(m) + 1;
                        end
                    end
                end
                
            end

                
        end
         


        
        function pause(self, src, event)
        
            self.model.is_paused = true;
            self.model.preview_index = self.model.preview_index + 1;
        
        end
        
        function play(self, src, event)

            if self.model.mode == 1
               self.preview_Mode1();
            elseif self.model.mode == 2
                self.preview_Mode2();
            elseif self.model.mode == 3
                self.preview_Mode3();
            elseif self.model.mode == 4 
                self.preview_Mode4();
            elseif self.model.mode == 5
                self.preview_Mode4();
            elseif self.model.mode == 6
                self.preview_Mode6();
            else
                self.preview_Mode4();
            end
        end
        
        function stop(self, src, event)
        
            
            self.model.is_paused = true;
            self.model.preview_index = 1;
            self.update_layout();
            

        
        end
        
        function set_realtime(self, src, event)
            if self.model.is_realtime == 0
                self.model.is_realtime = 1;
            else
                self.model.is_realtime = 0;
            end
        end
        
        function [patternSize, pat_xlim, pat_ylim] = get_pattern_axis_sizes(self)
            patternSize = size(self.model.pattern_data(:,:,1));
            pat_xlim = [0 length(self.model.pattern_data(1,:,1))];
            pat_ylim = [0 length(self.model.pattern_data(:,1,1))];
        end
        
        function generate_video(self, src, event)
            
            self.making_video = 1;
            [file, path] = uiputfile('*.avi','File Selection','preview');
            video_savepath = fullfile(path, file);
            new_figure = figure('Visible', 'off');
            self.layout(new_figure);
            self.model.preview_index = 1; 
            progress = waitbar(.25, 'Creating Frames');
            
            if self.model.mode == 1
                self.preview_Mode1(new_figure)
            end
            
            waitbar(.5, progress, 'Creating video writer');
            
            writer = VideoWriter(video_savepath);
            writer.FrameRate = self.model.slow_frRate;
            open(writer);
            
            waitbar(.75, progress, 'Writing Video');
            for i = 1:length(self.frames)
                writeVideo(writer, self.frames{i});
            end
            delete(new_figure);
            close(progress);
            
            self.making_video = 0;
            self.model.preview_index = 1;
            
            %reset old figure
            self.layout();
            %self.update_layout();
            
            
            
            
            
           
            
        end
        
        
        %GETTERS

        
        function value = get.model(self)
            value = self.model_;
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
        function value = get.frames(self)
            value = self.frames_;
        end
        function value = get.ao_lines(self)
            value = self.ao_lines_;
        end
        function value = get.making_video(self)
            value = self.making_video_;
        end
        
        
        %SETTERS
        
        function set.model(self, value)
            self.model_ = value;
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
        function set.frames(self, value)
            self.frames_ = value;
        end
        function set.ao_lines(self, value)
            self.ao_lines_ = value;
        end
        function set.making_video(self, value)
            self.making_video_ = value;
        end
        
        
    
    
    end
    



end