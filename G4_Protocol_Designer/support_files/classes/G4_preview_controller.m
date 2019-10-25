classdef G4_preview_controller < handle

    properties
        model_
        view_
        frames_
        making_video_
        pattern_only_
         
    end
    
    properties (Dependent)
        model
        view
        frames        
        making_video
        pattern_only
        

    end
    
    
    
    methods
 %CONSTRUCTOR
        function self = G4_preview_controller(doc)
            self.model = G4_preview_model(doc);
            self.frames = {};
            self.making_video = 0;
            self.pattern_only = 0;
            
        end
        
        function layout_view(self)
            
            self.view = G4_preview_view(self);
            self.view.layout();
            self.view.update_layout();
        end
        
        function update_fr_increment(self, new_value)
            
            if mod(new_value,1) == 0 && self.model.is_realtime == 0
                self.model.fr_increment = new_value;
                self.model.ao_increment = self.model.fr_increment;
            end
            self.view.update_variables();        
        end
        
        function update_pattern_only(self)
        
            if self.pattern_only == 1
                self.pattern_only = 0;
            else
                self.pattern_only = 1;
            end
        
        end
        
        function update_slow_frRate(self, new_value)
           
            if new_value > 60 || new_value < 1
                self.create_error_box("Please choose a frame rate between 1 and 60");
                return;
            else
                self.model.set_slow_frRate(new_value);
            end
            
        end

        function create_error_box(self, varargin)
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
                currentFig = self.view.fig;
            end
            
            screen_fr_rate = self.model.slow_frRate;
            ao_to_fr_ratio = 1000/self.model.rt_frRate;
            self.model.is_paused = false;
            time = self.model.dur*1000;
            time_between_frames = 1/screen_fr_rate;
            num_frames = round((self.model.dur * self.model.rt_frRate)/self.model.fr_increment);
            self.model.fr_increment = self.model.fr_increment*ao_to_fr_ratio;
            frame_count = 1;
            self.frames = cell(1, num_frames);

            if self.view.pos_line == 0
                
                self.create_error_box("Please make sure you've entered a position function and try again.");
                
            else

                aoLineDist = [0 0 0 0];
                self.model.ao_increment = self.model.fr_increment;
                

                for i = 1:4
                    if self.view.ao_lines{i} ~= 0
                        aoLineDist(i) = length(self.model.ao_data{i});
                    end
                end
                
                for i = floor(self.model.preview_index/self.model.fr_increment):num_frames
                    inside = tic;

                    if self.model.is_paused == true
                        return;
                    end
   
                    %move ao lines
                    
                    for k = 1:4
                        if self.view.ao_lines{k} ~= 0
                            if self.view.ao_lines{k}.XData(1) >= aoLineDist(k)
                                self.view.ao_lines{k}.XData = [1,1];
                            else
                                self.view.ao_lines{k}.XData = [self.view.ao_lines{k}.XData(1) + self.model.ao_increment, self.view.ao_lines{k}.XData(2) + self.model.ao_increment];
                            end
                            
                            if i == num_frames
                                self.view.ao_lines{k}.XData = [aoLineDist(k), aoLineDist(k)];
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

                    if self.model.preview_index > length(self.model.pos_data) || self.model.preview_index == 0
                        self.model.preview_index = 1;
                    end

                    frame = self.model.pos_data(self.model.preview_index);
                    set(self.view.im,'cdata',self.model.pattern_data(:,:,frame));

                    if self.view.pos_line ~= 0
                        if self.view.pos_line.XData(1) >= length(self.model.pos_data)
                            self.view.pos_line.XData = [1,1];
                        else
                            self.view.pos_line.XData = [self.model.preview_index,self.model.preview_index];
                        end
                    end

                    self.model.preview_index = self.model.preview_index + self.model.fr_increment;
                    
                    self.view.draw();
                    
                    if self.making_video == 1
                        if self.pattern_only == 1
                            self.frames{frame_count} = getframe(self.view.pat_axes);
                        else
                        
                            self.frames{frame_count} = getframe(currentFig);
                        end
                        frame_count = frame_count + 1;
                    end
                        

                    timeElapsed = toc(inside);
                    if self.making_video == 0

                        time_to_pause = time_between_frames - timeElapsed;%if realtime, ao line moves once every millsecond no matter what.
                        if time_to_pause < 0
                            time_to_pause = 0;
                        end
                        pause(time_to_pause);
                    end

                end
 
            end
  

            if self.model.is_paused == 0
                
                self.stop();
            end

        end

        
        function preview_Mode2(self, varargin)
            
            if ~isempty(varargin) && self.making_video == 1
                currentFig = varargin{1};
            else
                currentFig = self.view.fig;
            end
            
            screen_fr_rate = self.model.slow_frRate;
            ao_to_fr_ratio = 1000/self.model.rt_frRate;
            self.model.is_paused = false;
            time = self.model.dur*1000;
            time_between_frames = 1/screen_fr_rate;
            num_frames = round((self.model.dur * self.model.rt_frRate)/self.model.fr_increment);

            frame_count = 1;
            self.frames = cell(1, num_frames);

            aoLineDist = [0 0 0 0];


            for i = 1:4
                if self.view.ao_lines{i} ~= 0
                    aoLineDist(i) = length(self.model.ao_data{i});
                end
            end

            for i = floor(self.model.preview_index/self.model.fr_increment):num_frames
                inside = tic;

                if self.model.is_paused == true
                    return;
                end

                %move ao lines

                for k = 1:4
                    if self.view.ao_lines{k} ~= 0
                        if self.view.ao_lines{k}.XData(1) >= aoLineDist(k)
                            self.view.ao_lines{k}.XData = [1,1];
                        else
                            self.view.ao_lines{k}.XData = [self.view.ao_lines{k}.XData(1) + self.model.ao_increment, self.view.ao_lines{k}.XData(2) + self.model.ao_increment];
                        end

                        if i == num_frames
                            self.view.ao_lines{k}.XData = [aoLineDist(k), aoLineDist(k)];
                        end

                    end

                end


                if self.model.preview_index > length(self.model.pattern_data(1,1,:)) || self.model.preview_index == 0
                    self.model.preview_index = 1;
                end

                
                set(self.view.im,'cdata',self.model.pattern_data(:,:,self.model.preview_index));

                self.model.preview_index = self.model.preview_index + self.model.fr_increment;

                drawnow limitrate %nocallbacks

                if self.making_video == 1
                    if self.pattern_only == 1
                        self.frames{frame_count} = getframe(self.view.pat_axes);
                    else

                        self.frames{frame_count} = getframe(currentFig);
                    end
                    frame_count = frame_count + 1;
                end


                timeElapsed = toc(inside);
                if self.making_video == 0

                    time_to_pause = time_between_frames - timeElapsed;%if realtime, ao line moves once every millsecond no matter what.
                    if time_to_pause < 0
                        time_to_pause = 0;
                    end
                    pause(time_to_pause);
                end

 
            end
  

            if self.model.is_paused == 0
                
                self.stop();
            end
        end
        
                 
        
        function preview_Mode3(self)
            
            %This preview just shows the single frame at the given index,
            %so just leave the layout up.
            
        end
        
        function preview_Mode4(self, varargin)
            
            if ~isempty(varargin) && self.making_video == 1
                currentFig = varargin{1};
            else
                currentFig = self.view.fig;
            end
            
            screen_fr_rate = self.model.slow_frRate;
            ao_to_fr_ratio = 1000/self.model.rt_frRate;
            self.model.is_paused = false;
            time = self.model.dur*1000;
            time_between_frames = 1/screen_fr_rate;
            num_frames = round((self.model.dur * self.model.rt_frRate)/self.model.fr_increment);
            self.model.fr_increment = self.model.fr_increment*ao_to_fr_ratio;
            frame_count = 1;
            self.frames = cell(1, num_frames);

            if self.view.pos_line == 0
                
                self.create_error_box("Please make sure you've entered a position function and try again.");
                
            else

                aoLineDist = [0 0 0 0];
                self.model.ao_increment = self.model.fr_increment;
                

                for i = 1:4
                    if self.view.ao_lines{i} ~= 0
                        aoLineDist(i) = length(self.model.ao_data{i});
                    end
                end
                
                for i = floor(self.model.preview_index/self.model.fr_increment):num_frames
                    inside = tic;

                    if self.model.is_paused == true
                        return;
                    end
   
                    %move ao lines
                    
                    for k = 1:4
                        if self.view.ao_lines{k} ~= 0
                            if self.view.ao_lines{k}.XData(1) >= aoLineDist(k)
                                self.view.ao_lines{k}.XData = [1,1];
                            else
                                self.view.ao_lines{k}.XData = [self.view.ao_lines{k}.XData(1) + self.model.ao_increment, self.view.ao_lines{k}.XData(2) + self.model.ao_increment];
                            end
                            
                            if i == num_frames
                                self.view.ao_lines{k}.XData = [aoLineDist(k), aoLineDist(k)];
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

                    if self.model.preview_index > length(self.model.dummy_data) || self.model.preview_index == 0
                        self.model.preview_index = 1;
                    end

                    frame = self.model.dummy_data(self.model.preview_index);
                    set(self.view.im,'cdata',self.model.pattern_data(:,:,frame));

                    if self.view.dummy_line ~= 0
                        if self.view.dummy_line.XData(1) >= length(self.model.dummy_data)
                            self.view.dummy_line.XData = [1,1];
                        else
                            self.view.dummy_line.XData = [self.model.preview_index,self.model.preview_index];
                        end
                    end

                    self.model.preview_index = self.model.preview_index + self.model.fr_increment;

                    drawnow limitrate %nocallbacks
                    
                    if self.making_video == 1
                        if self.pattern_only == 1
                            self.frames{frame_count} = getframe(self.view.pat_axes);
                        else
                        
                            self.frames{frame_count} = getframe(currentFig);
                        end
                        frame_count = frame_count + 1;
                    end
                        

                    timeElapsed = toc(inside);
                    if self.making_video == 0

                        time_to_pause = time_between_frames - timeElapsed;%if realtime, ao line moves once every millsecond no matter what.
                        if time_to_pause < 0
                            time_to_pause = 0;
                        end
                        pause(time_to_pause);
                    end

                end
 
            end
  
            if self.model.is_paused == 0
                
                self.stop();
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

           

            if self.view.pos_line == 0
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

                            set(self.view.im,'cdata',self.model.pattern_data(:,:,frame1, frame2));
                            if self.view.pos_line ~= 0
                                self.view.pos_line.XData = [self.view.pos_line.XData(1) + 1, self.view.pos_line.XData(2) + 1];
                            end
                            
                            if self.view.dummy_line ~= 0
                                self.view.dummy_line.XData = [self.view.dummy_line.XData(1) + 1, self.view.dummy_line.XData(2) + 1];
                            end
                            for k = 1:4
                                if self.view.ao_lines{k} ~= 0
                                    self.view.ao_lines{k}.XData = [self.view.ao_lines{k}.XData(1) + 1, self.view.ao_lines{k}.XData(2) + 1];
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

        function pause(self)
        
            self.model.is_paused = true;
            self.model.preview_index = self.model.preview_index + 1;
            if self.model.mode == 1 
                self.model.fr_increment = self.model.fr_increment/(1000/self.model.rt_frRate);
            end
        
        end

        function stop(self)

            self.model.is_paused = true;
            self.model.preview_index = 1;

            if self.model.mode == 1 || self.model.mode == 4
                ratio = 1000/self.model.rt_frRate;
                self.model.fr_increment = self.model.fr_increment/ratio;

            end
            

        end
        
        function set_realtime(self)
            if self.model.is_realtime == 0
                self.model.is_realtime = 1;
                
            else
                self.model.is_realtime = 0;
                
            end
            self.calculate_fr_increment();
        end
        
        function calculate_fr_increment(self)
        
            if self.model.is_realtime == 0
                self.model.fr_increment = 1;
                self.model.ao_increment = 1;
            else
                self.model.fr_increment = floor(self.model.rt_frRate/self.model.slow_frRate);
                self.model.ao_increment = floor(1000/self.model.slow_frRate);
                
            end
            
            self.view.update_variables();
            

        end
        
        function [patternSize, pat_xlim, pat_ylim] = get_pattern_axis_sizes(self)
            patternSize = size(self.model.pattern_data(:,:,1));
            pat_xlim = [0 length(self.model.pattern_data(1,:,1))];
            pat_ylim = [0 length(self.model.pattern_data(:,1,1))];
        end
        
        function generate_video(self)
            
            self.making_video = 1;
            [file, path] = uiputfile('*.avi','File Selection','preview');
            video_savepath = fullfile(path, file);
            new_figure = figure('Visible', 'off');
            if ~isempty(self.view)
                self.view.layout(new_figure);
            else
                self.view = G4_preview_view(self, new_figure);
                self.view.layout(new_figure)
            end
            self.model.preview_index = 1; 
            progress = waitbar(.25, 'Creating Frames');
            
            if self.model.mode == 1
                self.preview_Mode1(new_figure)
            elseif self.model.mode == 2
                self.preview_Mode2(new_figure)
            elseif self.model.mode == 4 || self.model.mode == 5 || self.model.mode == 7
                self.preview_Mode4(new_figure)
            elseif self.model.mode == 6
                self.create_error_box("We are still working on video functionality for mode 6!");
                return;
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
            self.view.layout();
            
        end

        

        
        %GETTERS

        
        function value = get.model(self)
            value = self.model_;
        end
        
        function value = get.view(self)
            value = self.view_;
        end
        
        function value = get.frames(self)
            value = self.frames_;
        end
        
        function value = get.making_video(self)
            value = self.making_video_;
        end
        
        function value = get.pattern_only(self)
            value = self.pattern_only_;
        end
        
            
        
        
        %SETTERS
        
        function set.model(self, value)
            self.model_ = value;
        end
        
        function set.view(self, value)
            self.view_ = value;
        end

        function set.frames(self, value)
            self.frames_ = value;
        end
        
        function set.making_video(self, value)
            self.making_video_ = value;
        end
        
        function set.pattern_only(self, value)
            self.pattern_only_ = value;
        end
        
        
    
    
    end
    



end