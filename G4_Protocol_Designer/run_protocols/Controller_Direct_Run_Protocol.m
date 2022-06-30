%script testing out parfeval

function parfeval_test(runcon, p, Q)

     %% Get access to the figure and progress bar in the run gui IF it was passed in.
    global ctlr;
    tcpread = {};
    
    
    %        fig = runcon.fig;
    if ~isempty(runcon.view)
    
        axes_label = runcon.view.axes_label;
    end


 %% Set up parameters 
 %pretrial params-----------------------------------------------------
     if isempty(p.pretrial{1}) %no need to set up pretrial params
         pre_start = 0;
     else %set up pretrial params here
         pre_start = 1;
         pre_mode = p.pretrial{1};
         pre_pat = p.pretrial_pat_index;
         pre_pos = p.pretrial_pos_index;
         pre_ao_ind = p.pretrial_ao_indices;

         if isempty(p.pretrial{8})
             pre_frame_ind = 1;
         elseif strcmp(p.pretrial{8},'r')
             pre_frame_ind = 0; %use this later to randomize
         else
             pre_frame_ind = str2num(p.pretrial{8});
         end

         pre_frame_rate = p.pretrial{9};
         pre_gain = p.pretrial{10};
         pre_offset = p.pretrial{11};
         pre_dur = p.pretrial{12};
     end
 
 %intertrial params---------------------------------------------------
 
     if isempty(p.intertrial{1})
         inter_type = 0;%indicates whether or not there is an intertrial
     else
         inter_type = 1;
         inter_mode = p.intertrial{1};
         inter_pat = p.intertrial_pat_index;
         inter_pos = p.intertrial_pos_index;
         inter_ao_ind = p.intertrial_ao_indices;

         if isempty(p.intertrial{8})
             inter_frame_ind = 1;
         elseif strcmp(p.intertrial{8},'r')
             inter_frame_ind = 0; %use this later to randomize
         else
             inter_frame_ind = str2num(p.intertrial{8});
         end

         inter_frame_rate = p.intertrial{9};
         inter_gain = p.intertrial{10};
         inter_offset = p.intertrial{11};
         inter_dur = p.intertrial{12};
     end
 
 %posttrial params------------------------------------------------------
     if isempty(p.posttrial{1})
         post_type = 0;%indicates whether or not there is a posttrial
     else
         post_type = 1;
         post_mode = p.posttrial{1};
         post_pat = p.posttrial_pat_index;
         post_pos = p.posttrial_pos_index;
         post_ao_ind = p.posttrial_ao_indices;

         if isempty(p.posttrial{8})
             post_frame_ind = 1;
         elseif strcmp(p.posttrial{8},'r')
             post_frame_ind = 0; %use this later to randomize
         else
             post_frame_ind = str2num(p.posttrial{8});
         end

         post_frame_rate = p.posttrial{9};
         post_gain = p.posttrial{10};
         post_offset = p.posttrial{11};
         post_dur = p.posttrial{12};
     end
 
 %define static block trial params (will define the ones that change every
 %loop later)--------------------------------------------------------------
     block_trials = p.block_trials; 
     block_ao_indices = p.block_ao_indices;
     reps = p.repetitions;
     num_cond = length(block_trials(:,1)); %number of conditions
     
% Get input channels that are active for streaming
    
    active_ai_streaming_channels = [];
    if p.chan1_rate ~= 0
        active_ai_streaming_channels(end+1) = 1;
    end
    if p.chan2_rate ~= 0
        active_ai_streaming_channels(end+1) = 2;
    end
    if p.chan3_rate ~= 0
        active_ai_streaming_channels(end+1) = 3;
        
    end
    if p.chan4_rate ~= 0
        active_ai_streaming_channels(end+1) = 4;
    end
    
%     %establish cell array to carry all the raw streamed data
%     streamed_data = {};
    

%% Make sure panels controller isn't already open. If it is, close it
    if ~isempty(ctlr)
        if ctlr.isOpen() == 1
           ctlr.close()
        end
    end
%% Open new Panels controller instance
    ctlr = PanelsController();
    ctlr.mode = 0;
    ctlr.open(true);

%% Check tcp connection was successful.
    if ctlr.tcpConn == -1
        system('"C:\Program Files (x86)\HHMI G4\G4 Host" &');
        status = 1;
        while status~=0
            [status, ~] = system('tasklist | find /I "G4 Host.exe"');
            pause(0.1);
        end
        ctlr = PanelsController();
        ctlr.mode = 0;
        ctlr.open();
    end

%% Set root directory to the experiment folder
    ctlr.setRootDirectory(p.experiment_folder);

%% set active ao channels
     if ~isempty(p.active_ao_channels)
         aobits = 0;
        for bit = p.active_ao_channels
            aobits = bitset(aobits,bit+1); %plus 1 bc aochans are 0-3
        end
        ctlr.setActiveAOChannels(dec2bin(aobits,4));
     end

%% set active ai channels for streaming
    %set aibits for later telling panel_com which analog input channels are
    %streaming
    aibits = 0;
    for bit = active_ai_streaming_channels
        aibits = bitset(aibits, bit);
    end
    ctlr.setActiveAIChannels(aibits);

%% Determine the total number of trials in order to define in what increments 
%the progress bar will progress.-------------------------------------------
    total_num_steps = 0; 
    if pre_start == 1
        total_num_steps = total_num_steps + 1;
    end
    if inter_type == 1
        total_num_steps = total_num_steps + (reps*num_cond) - 1;
        %Minus 1 because there is no intertrial before the first
        %block trial OR after the last block trial.

    end
    if post_type == 1
        total_num_steps = total_num_steps + 1;
    end
    total_num_steps = total_num_steps + (reps*num_cond);
    %adds total number of block trials (not including intertrials)

    %% Determine how long the experiment will take and update the title of the 
%progress bar to reflect it------------------------------------------------
    total_time = 0; 
    if inter_type == 1
        for i = 1:num_cond
            total_time = total_time + p.block_trials{i,12} + inter_dur;
        end
        total_time = (total_time * reps) - inter_dur; %bc no intertrial before first rep OR after last rep of the block.
    else %meaning no intertrial
        for i = 1:num_cond
            total_time = total_time + p.block_trials{i,12};
        end
        total_time = total_time * reps;
    end

    if pre_start == 1
        total_time = total_time + pre_dur;
    end
    if post_type == 1
        total_time = total_time + post_dur;
    end

    %Update the progress bar's label to reflect the expected
    %duration.
    axes_label.String = "Estimated experiment duration: " + num2str(total_time/60) + " minutes.";

    %Will increment this every time a trial is completed to track how far along 
    %in the experiment we are
    num_trial_of_total = 0;

    %% Start log, if fails twice, abort------------------------------------

     log_started = ctlr.startLog();
     if ~log_started
         disp("Log failed to start, retrying...");
         log_started = ctlr.startLog();
         if ~log_started
             disp("Log failed a second time, aborting experiment.");
             runcon.abort_experiment();
         end
     end
     if runcon.check_if_aborted()

        if isa(ctlr, 'PanelsController')
            ctlr.close();
        end
        clear global;
        success = 0;
        return;

     end

     %% run pretrial if it exists----------------------------------------
     startTime = tic;

     if pre_start == 1
         %First update the progress bar to show pretrial is running----
         runcon.update_progress('pre');
         num_trial_of_total = num_trial_of_total + 1;

        %Set the panel values appropriately----------------
         ctlr.setControlMode(pre_mode);
         ctlr.setPatternID(pre_pat);

         %randomize frame index if indicated
         if pre_frame_ind == 0
             pre_frame_ind = randperm(p.num_pretrial_frames, 1);  
         end

         ctlr.setPositionX(pre_frame_ind);
         if pre_pos ~= 0
             ctlr.setPatternFunctionID(pre_pos); 
         end

         if ~isempty(pre_gain) %this assumes you'll never have gain without offset
             ctlr.setGain(pre_gain, pre_offset);                     
         end

         if pre_mode == 2
             ctlr.setFrameRate(pre_frame_rate);         
         end

         for i = 1:length(pre_ao_ind)
             if pre_ao_ind(i) ~= 0 %if it is zero, there was no ao function for this channel
                 ctlr.setAOFunctionID(p.active_ao_channels(i), pre_ao_ind(i));%[channel number, index of ao func]                    
             end
         end

         %Update status panel to show current parameters
         runcon.update_current_trial_parameters(pre_mode, pre_pat, pre_pos, p.active_ao_channels, ...
            pre_ao_ind, pre_frame_ind, pre_frame_rate, pre_gain, pre_offset, pre_dur);

         pause(0.01);

         %Run pretrial on screen
         if pre_dur ~= 0
            ctlr.startDisplay(pre_dur*10); %Panel_com usually did the *10 for us. Controller expects time in deciseconds
%          else
%              ctlr.startDisplay(2000, false); %second input, waitForEnd, equals false so code will continue executing
%              w = waitforbuttonpress; %If pretrial duration is set to zero, this
%              %causes it to loop until you press a button.
         end
     end

     tcpread{end+1} = pnet(ctlr.tcpConn, 'read', 'noblock'); % read data that's been streamed since clearing cache

     if runcon.check_if_aborted()
        ctlr.stopDisplay();
        log_stopped = ctlr.stopLog();
        if ~log_stopped
            disp("Log failed to stop. Retrying...");
            log_stopped = ctlr.stopLog();
            if ~log_stopped
                disp("Log failed to stop. Please stop manually.");
            end
        end
        if isa(ctlr, 'PanelsController')
            ctlr.close();
        end
        clear global;
        success = 0;
        return;

     end

     runcon.update_elapsed_time(round(toc(startTime),2));

     %% Loop to run the block/inter trials --------------------------------------

     for r = 1:reps
         for c = 1:num_cond
            %define which condition we're using
            cond = p.exp_order(r,c);


            num_trial_of_total = num_trial_of_total + 1;



            %define parameters for this trial----------------
            trial_mode = block_trials{cond,1};
            pat_id = p.block_pat_indices(cond);
            pos_id = p.block_pos_indices(cond);
            if length(block_ao_indices) >= cond
                trial_ao_indices = block_ao_indices(cond,:);
            else
                trial_ao_indices = [];
            end
            %Set frame index
            if isempty(block_trials{cond,8})
                frame_ind = 1;
            elseif strcmp(block_trials{cond,8},'r')
                frame_ind = 0; %use this later to randomize
            else
               frame_ind = str2num(block_trials{cond,8});
            end

            frame_rate = block_trials{cond, 9};
            gain = block_trials{cond, 10};
            offset = block_trials{cond, 11};
            dur = block_trials{cond, 12};

            %Update controller-----------------------------

            ctlr.setControlMode(trial_mode);
            ctlr.setPatternID(pat_id);

            if ~isempty(block_trials{cond,10})
                ctlr.setGain(gain, offset);
            end
            if pos_id ~= 0

               ctlr.setPatternFunctionID(pos_id);

            end
            if trial_mode == 2
                ctlr.setFrameRate(frame_rate);
            end

            if frame_ind == 0
                frame_ind = randperm(p.num_block_frames(c),1);
            end

            ctlr.setPositionX(frame_ind);

            for i = 1:length(p.active_ao_channels)
                ctlr.setAOFunctionID(p.active_ao_channels(i), trial_ao_indices(i));  
            end

            tcpread_cache = pnet(ctlr.tcpConn, 'read', 'noblock'); % clear cache


            %Run block trial--------------------------------------

            %Gather data for GUI and send it back to client so the client can update
            %the screen while the next trial runs.


            %Establish parameters needed for all gui updates
            prog_bar_vars = {'block', r, reps, c, num_cond, cond, num_trial_of_total};
            trial_params = {trial_mode, pat_id, pos_id, p.active_ao_channels, ...
              trial_ao_indices, frame_ind, frame_rate, gain, offset, dur};
            if r ~=1 || c ~= 1
                if inter_type
                    stream_params = {tcpread{end}, 'inter', prev_r, prev_c, prev_num_trials};
                else
                    stream_params = {tcpread{end}, 'block', prev_r, prev_c, prev_num_trials};
                end
            else
                stream_params = {};
            end

            %send gui data back to client so it can update the GUI
            %while the trial displays
            gui_data = struct;
            gui_data.prog_bar_vars = prog_bar_vars;
            gui_data.trial_params = trial_params;
            gui_data.stream_params = stream_params;
            send(Q, gui_data);

            %Start displaying current trial - code will pause here
            %until the trial is finished.
            ctlr.startDisplay((dur)*10); %duration expected in 100ms units

            tcpread{end+1} = pnet(ctlr.tcpConn, 'read', 'noblock');

            % Save values of this trial so they can be used in next
            % streaming update
            prev_c = c;
            prev_r = r;
            prev_num_trials = num_trial_of_total;

            %Reset gui update parameters
            prog_bar_vars = {};
            trial_params = {};
            stream_params = {};

            isAborted = runcon.check_if_aborted();
            if isAborted == 1
                ctlr.stopDisplay();
                log_stopped = ctlr.stopLog();
                if ~log_stopped
                    disp("Log failed to stop. Retrying...");
                    log_stopped = ctlr.stopLog();
                    if ~log_stopped
                        disp("Log failed to stop. Please stop manually.");
                    end
                end
                if isa(ctlr, 'PanelsController')
                    ctlr.close();
                end
                clear global;
                success = 0;
                return;

            end
            runcon.update_elapsed_time(round(toc(startTime),2));

            %Tells loop to skip the intertrial if this is the last iteration of the last rep
            if r == reps && c == num_cond

                continue 
            end

%Run inter-trial assuming there is one-------------------------
            if inter_type == 1                       

                %Update progress bar to indicate start of inter-trial
                num_trial_of_total = num_trial_of_total + 1;

                %Run intertrial-------------------------
                ctlr.setControlMode(inter_mode);
                ctlr.setPatternID(inter_pat);

                %randomize frame index if indicated
                if inter_frame_ind == 0
                    inter_frame_ind = randperm(p.num_intertrial_frames, 1);
                end
                ctlr.setPositionX(inter_frame_ind);

                if inter_pos ~= 0
                    ctlr.setPatternFunctionID(inter_pos);
                end

                 if ~isempty(inter_gain) %this assumes you'll never have gain without offset
                     ctlr.setGain(inter_gain, inter_offset);
                 end

                 if inter_mode == 2
                     ctlr.setFrameRate(inter_frame_rate);
                 end

                 for i = 1:length(inter_ao_ind)
                     if inter_ao_ind(i) ~= 0 %if it is zero, there was no ao function for this channel
                         ctlr.setAOFunctionID(p.active_ao_channels(i), inter_ao_ind(i));%[channel number, index of ao func]

                     end
                 end

                 tcpread_cache = pnet(ctlr.tcpConn, 'read', 'noblock'); % clear cache

                 %Establish parameters needed for all gui updates

                 prog_bar_vars = {'inter', r, reps, c, num_cond, num_trial_of_total};
                 trial_params = {trial_mode, pat_id, pos_id, p.active_ao_channels, ...
                 trial_ao_indices, frame_ind, frame_rate, gain, offset, dur};
                 stream_params = {tcpread{end}, 'block', r, c, prev_num_trials};

                 %Run gui update on separate thread
                 gui_data = struct;
                 gui_data.prog_bar_vars = prog_bar_vars;
                 gui_data.trial_params = trial_params;
                 gui_data.stream_params = stream_params;
                 send(Q, gui_data);

                 ctlr.startDisplay((inter_dur)*10);

                 tcpread{end+1} = pnet(ctlr.tcpConn, 'read', 'noblock');
                 prev_num_trials = num_trial_of_total;


                 if runcon.check_if_aborted() == 1
                    ctlr.stopDisplay();
                    log_stopped = ctlr.stopLog();
                    if ~log_stopped
                        disp("Log failed to stop. Retrying...");
                        log_stopped = ctlr.stopLog();
                        if ~log_stopped
                            disp("Log failed to stop. Please stop manually.");
                        end
                    end
                    if isa(ctlr, 'PanelsController')
                        ctlr.close();
                    end
                    clear global;
                    success = 0;
                    return;

                 end

                 runcon.update_elapsed_time(round(toc(startTime),2));

            end 
         end
     end
     
     ctlr.stopDisplay();
    log_stopped = ctlr.stopLog();
    if ~log_stopped
        disp("Log failed to stop. Retrying...");
        log_stopped = ctlr.stopLog();
        if ~log_stopped
            disp("Log failed to stop. Please stop manually.");
        end
    end
    if isa(ctlr, 'PanelsController')
        ctlr.close();
    end
    clear global;

 end

