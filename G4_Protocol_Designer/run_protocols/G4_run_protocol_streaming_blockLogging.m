%% Run protocol which streams data back and logs every repetition
% No combined command

%Notice that the inputs can be variable. In fact, there should only ever be
%one or two inputs. The first should always be a struct of the experiment
%parameters, following the format listed below. The second is the handle to
%the run_gui instance that is currently open. If you are running this from
%the command line, leave the second input out, but when running from the
%GUI, it is needed to access the progress bar and other GUI items. 

%PARAMETERS BELONGING TO EACH TRIAL
    %p.pretrial - cell array with all table values
    %p.pretrial_pat_index - index of the pattern in the pretrial
    %p.pretrial_pos_index = index of the position function in the pretrial
    %p.pretrial_ao_indices = indices of ao functions in the pretrial
 
    %p.intertrial - same as above, replacing "pretrial" with "intertrial"
    %p.posttrial - same as above, replacing "pretrial" with "posttrial"
    %p.block_trials - naming is slightly different. p.block_pat_indices,
        %p.block_pos_indices, etc. 

    %p.num_pretrial_frames gives the number of frames in the pretrial pattern
        %in case it needs to be randomized. 
 
    %p.num_intertrial_frames - same as above
    %p.num_posttrial_frames - same as above
 
    %p.num_block_frames - m x 1 matrix, m being the number of conditions,
        %where each element is the number of frames in that trial's pattern
        %library.
 
%PARAMETERS NOT SPECIFIC TO A TRIAL
  
    %p.active_ao_channels - [2 3 4 5]
    %p.repetitions
    %p.is_randomized
    %p.fly_name
    %p.save_filename - name under which experiment is saved
    %p.exp_order - vector with the order conditions are run in
    %p.experiment_folder - path to experiment folder
    %p.is_chan1 - Indicates whether analog input channel 1 is streaming (1) or
        %not(0)
    %p.is_chan2 - is_chan4 - same as is_chan1, for channels 2,3,and 4
 
%NOTES
    %The arrays of block indices are m x n where m is number of conditions and
    %n is 1 in the case of pat/pos, or the number of active
    %channels in the case of ao. In any position where there was no pos/ao
    %function, the value is a 0.
 
    %p.active_ao_channels lists the channels that are active - [2 4 5] for
    %example means channels 2, 4, and 5 are active.

function [success] = G4_run_protocol_streaming_blockLogging(runcon, p)%input should always be 1 or 2 items
    
    %% Get access to the figure and progress bar in the run gui IF it was passed in.
    tcpread = {};
    
    %        fig = runcon.fig;
    if ~isempty(runcon.view)
        axes_label = runcon.view.axes_label;
    end
    
    
    %% Set up parameters
    params = assign_parameters(p);
    
    pre_start = params.pre_start;
    if pre_start == 1
        pre_mode = params.pre_mode;
        pre_pat = params.pre_pat;
        pre_pos = params.pre_pos;
        pre_ao_ind = params.pre_ao_ind;
        pre_frame_ind = params.pre_frame_ind;
        pre_frame_rate = params.pre_frame_rate;
        pre_gain = params.pre_gain;
        pre_offset = params.pre_offset;
        pre_dur = params.pre_dur;
    end
    
    inter_type = params.inter_type;
    if inter_type == 1
        inter_mode = params.inter_mode;
        inter_pat = params.inter_pat;
        inter_pos = params.inter_pos;
        inter_ao_ind = params.inter_ao_ind;
        inter_frame_ind = params.inter_frame_ind;
        inter_frame_rate = params.inter_frame_rate;
        inter_gain = params.inter_gain;
        inter_offset = params.inter_offset;
        inter_dur = params.inter_dur;
    end
    
    post_type = params.post_type;
    if post_type == 1
        post_mode = params.post_mode;
        post_pat =params.post_pat;
        post_pos = params.post_pos;
        post_ao_ind = params.post_ao_ind;
        post_frame_ind = params.post_frame_ind;
        post_frame_rate = params.post_frame_rate;
        post_gain = params.post_gain;
        post_offset = params.post_offset;
        post_dur = params.post_dur;
    end
    
    reps = params.reps;
    num_cond = params.num_cond;
    active_ao_channels = params.active_ao_channels;
    
    if pre_start == 1
        ctlr_parameters_pretrial = {pre_mode, pre_pat, pre_gain, pre_offset, ...
            pre_pos, pre_frame_rate, pre_frame_ind, active_ao_channels, pre_ao_ind};
    else
        ctlr_parameters_pretrial = {};
    end
    
    if inter_type == 1
        ctlr_parameters_intertrial = {inter_mode, inter_pat, inter_gain, inter_offset, ...
            inter_pos, inter_frame_rate, inter_frame_ind, active_ao_channels, inter_ao_ind};
    else
        ctlr_parameters_intertrial = {};
    end
    
    if post_type == 1
        ctlr_parameters_posttrial = {post_mode, post_pat, post_gain, post_offset, ...
            post_pos, post_frame_rate, post_frame_ind, active_ao_channels, post_ao_ind};
    else
        ctlr_parameters_posttrial = {};
    end
    
    %% Open new Panels controller instance
    ctlr = PanelsController();
    ctlr.open(true);
    
    %% Set root directory to the experiment folder
    ctlr.setRootDirectory(p.experiment_folder);
    
    %% set active ao channels
    
    ctlr.setActiveAOChannels(p.active_ao_channels + 2); % FIXME: quick fix, find better solution
    
    %% confirm start experiment
    if ~isempty(runcon.view)
        start = questdlg('Start Experiment?','Confirm Start','Start','Cancel','Start');
    else
        start = 'Start';
    end
    
    switch start
        case 'Cancel'
            if isa(ctlr, 'PanelsController')
                ctlr.close();
            end
            clear global;
            success = 0;
            return;
            
        case 'Start'
            %The rest of the code to run the experiment goes under this case
            
            %% Determine the total number of trials in order to define in what increments
            %the progress bar will progress.-------------------------------------------
            total_num_steps = get_total_num_trials(params);
            
            %% Determine how long the experiment will take and update the title of the
            %progress bar to reflect it------------------------------------------------
            total_time = get_total_experiment_length(params);
            
            %Update the progress bar's label to reflect the expected
            %duration.
            axes_label.Text = "Estimated experiment duration: " + num2str(total_time/60) + " minutes.";
            
            %Will increment this every time a trial is completed to track how far along
            %in the experiment we are
            num_trial_of_total = 0;
            
            %% set active ai channels for streaming
            %set  for later telling panel_com which analog input channels are
            %streaming
            
            active_ai_channels = nonzeros([p.chan1_rate>0 p.chan2_rate>0 p.chan3_rate>0 p.chan4_rate>0] .* [1 2 3 4])' - 1;
            ctlr.setActiveAIChannels(active_ai_channels);
            
            %% run pretrial if it exists----------------------------------------
            startTime = tic;
            
            if pre_start == 1
                %First update the progress bar to show pretrial is running----
                runcon.update_progress('pre');
                num_trial_of_total = num_trial_of_total + 1;

                ctlr.startLog(); % Must start log before setting controller parameters or it'll affect data processing.
                
                %Set the controller values appropriately----------------
                ctlr.setControllerParameters(ctlr_parameters_pretrial);
                
                %Update status panel to show current parameters
                runcon.update_current_trial_parameters(pre_mode, pre_pat, pre_pos, active_ao_channels, ...
                    pre_ao_ind, pre_frame_ind, pre_frame_rate, pre_gain, pre_offset, pre_dur);
                pause(0.01);
                
                %Run pretrial on screen
                if pre_dur ~= 0
                    ctlr.startDisplay(pre_dur*10);
                else
                    ctlr.startDisplay(2000, false); %second input, waitForEnd, equals false so code will continue executing
                    w = waitforbuttonpress; %If pretrial duration is set to zero, this
                    %causes it to loop until you press a button.
                end
                ctlr.stopLog('showTimeoutMessage', true);
                
                if runcon.check_if_aborted()
                    ctlr.stopDisplay();
                    if isa(ctlr, 'PanelsController')
                        ctlr.close();
                    end
                    clear global;
                    success = 0;
                    return;
                end
            end
            
            tcpread{end+1} = pnet(ctlr.tcpConn, 'read', 'noblock'); % read data that's been streamed since clearing cache
            
            runcon.update_elapsed_time(round(toc(startTime),2));
            
            %% Loop to run the block/inter trials --------------------------------------
            
            for r = 1:reps
                ctlr.startLog();
                for c = 1:num_cond
                    %define which condition we're using
                    cond = p.exp_order(r,c);
                    num_trial_of_total = num_trial_of_total + 1;
                    
                    %define parameters for this trial----------------
                    tparams = assign_block_trial_parameters(params, p, cond);
                    
                    %Update controller-----------------------------
                    
                    ctlr_parameters = {tparams.trial_mode, tparams.pat_id, tparams.gain, ...
                        tparams.offset, tparams.pos_id, tparams.frame_rate, tparams.frame_ind...
                        params.active_ao_channels, tparams.trial_ao_indices};
                    
                    ctlr.setControllerParameters(ctlr_parameters);
                    
                    tcpread_cache = pnet(ctlr.tcpConn, 'read', 'noblock'); % clear cache
                    
                    %Run block trial--------------------------------------
                    
                    ctlr.startDisplay(tparams.dur*10, false); %duration expected in 100ms units
                    timeSinceTrial = tic;
                    
                    %Update the progress bar--------------------------
                    runcon.update_progress('block', r, reps, c, num_cond, cond, num_trial_of_total);
                    
                    %Update status panel to show current parameters
                    runcon.update_current_trial_parameters(tparams.trial_mode, ...
                        tparams.pat_id, tparams.pos_id, active_ao_channels, ...
                        tparams.trial_ao_indices, tparams.frame_ind, tparams.frame_rate, ...
                        tparams.gain, tparams.offset, tparams.dur);
                    
                    % Update plots showing previous trials data-----------
                    if r ~= 1 || c ~= 1
                        if inter_type
                            runcon.update_streamed_data(tcpread{end}, 'inter', prev_r, prev_c, prev_num_trials);
                        else
                            runcon.update_streamed_data(tcpread{end}, 'block', prev_r, prev_c, prev_num_trials);
                        end
                    end
                    %pause for however much time is left after doing updates
                    pause(tparams.dur - toc(timeSinceTrial));
                    
                    tcpread{end+1} = pnet(ctlr.tcpConn, 'read', 'noblock');
                    
                    % Save values of this trial so they can be used in next
                    % streaming update
                    prev_c = c;
                    prev_r = r;
                    prev_num_trials = num_trial_of_total;
                    
                    isAborted = runcon.check_if_aborted();
                    isEnded = runcon.check_if_ended();
                    if isAborted || isEnded
                        ctlr.stopDisplay();
                        ctlr.stopLog('showTimeoutMessage', true);
                        if isa(ctlr, 'PanelsController')
                            ctlr.close();
                        end
                        clear global;
                        if isAborted
                            success = 0;
                        else
                            success = 1;
                        end
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
                        if params.inter_frame_ind == 0
                            inter_frame_ind = randperm(p.num_intertrial_frames,1);
                            ctlr_parameters_intertrial{7} = inter_frame_ind;
                        end
                        
                        ctlr.setControllerParameters(ctlr_parameters_intertrial);
                        
                        tcpread_cache = pnet(ctlr.tcpConn, 'read', 'noblock'); % clear cache
                        
                        ctlr.startDisplay(inter_dur*10, false);
                        timeSinceInter = tic;
                        
                        runcon.update_progress('inter', r, reps, c, num_cond, num_trial_of_total);
                        %Update status panel to show current parameters
                        runcon.update_current_trial_parameters(inter_mode, inter_pat, inter_pos, p.active_ao_channels, ...
                            inter_ao_ind, inter_frame_ind, inter_frame_rate, inter_gain, inter_offset, inter_dur);
                        runcon.update_streamed_data(tcpread{end}, 'block', r, c, prev_num_trials);
                        
                        pause(inter_dur - toc(timeSinceInter));
                        
                        tcpread{end+1} = pnet(ctlr.tcpConn, 'read', 'noblock');
                        prev_num_trials = num_trial_of_total;
                        
                        isAborted = runcon.check_if_aborted();
                        isEnded = runcon.check_if_ended();
                        if isAborted || isEnded
                            ctlr.stopDisplay();
                            ctlr.stopLog('showTimeoutMessage', true);
                            if isa(ctlr, 'PanelsController')
                                ctlr.close();
                            end
                            clear global;
                            if isAborted
                                success = 0;
                            else
                                success = 1;
                            end
                            return;
                        end
                        
                        runcon.update_elapsed_time(round(toc(startTime),2));
                    end
                end
                ctlr.stopLog();
            end
            
            %% Run re-scheduled conditions if there are any------------------------------
            
            % Conditions that are marked as bad during streaming (meaning
            % the fly stopped flying too much or the data had a slope of 0)
            % are saved to the feedback model as bad_trials. This is a cell
            % array of short 2x1 arrays containing the condition number and
            % rep number of the bad trial, in the format bad_trials{1} =
            % [cond, rep]; This loop will re-run every trial that was
            % listed as bad however many times indicated in the settings
            % (or a default of 2). A trial will only be re-run an
            % additional time if the first re-run also fails.
            
            res_conds = runcon.fb_model.get_bad_trials();
            num_attempts = runcon.get_num_attempts();
            num_trial_including_rescheduled = num_trial_of_total;
            
            for attempt = 1:num_attempts
                ctlr.startLog();
                
                %This line saves all the bad trials to a separate variable in
                %the model so we can track how many extra conditions are run
                %total
                runcon.fb_model.set_bad_trials_before_reruns();
                
                %No intertrial at end of regular block trials, so do one now, assuming the protocol has intertrials
                if ~isempty(res_conds) && inter_type == 1
                    
                    %Update progress bar to indicate start of inter-trial
                    num_trial_including_rescheduled = num_trial_including_rescheduled + 1;
                    
                    %Run intertrial-------------------------
                    
                    ctlr.setControllerParameters(ctlr_parameters_intertrial);
                    
                    tcpread_cache = pnet(ctlr.tcpConn, 'read', 'noblock'); % clear cache
                    
                    ctlr.startDisplay((inter_dur + .5)*10, false);
                    timeSinceInter = tic;
                    
                    runcon.update_progress('inter', r, reps, c, num_cond, num_trial_of_total);
                    %Update status panel to show current parameters
                    runcon.update_current_trial_parameters(inter_mode, inter_pat, inter_pos, p.active_ao_channels, ...
                        inter_ao_ind, inter_frame_ind, inter_frame_rate, inter_gain, inter_offset, inter_dur);
                    runcon.update_streamed_data(tcpread{end}, 'block', prev_r, prev_c, prev_num_trials);
                    
                    pause(inter_dur - toc(timeSinceInter));
                    
                    tcpread{end+1} = pnet(ctlr.tcpConn, 'read', 'noblock');
                    prev_num_trials = num_trial_including_rescheduled;
                    
                    
                    if runcon.check_if_aborted() == 1
                        ctlr.stopDisplay();
                        ctlr.stopLog('showTimeoutMessage', true);
                        if isa(ctlr, 'PanelsController')
                            ctlr.close();
                        end
                        clear global;
                        success = 0;
                        return;
                    end
                    
                    runcon.update_elapsed_time(round(toc(startTime),2));
                end
                
                for badtrial = 1:length(res_conds)
                    cond = res_conds{badtrial}(1);
                    rep = res_conds{badtrial}(2);
                    
                    % update the progress bar
                    num_trial_including_rescheduled = num_trial_including_rescheduled + 1;
                    
                    % run that condition
                    
                    %define parameters for this trial----------------
                    tparams = assign_block_trial_parameters(params, p, cond);
                    
                    ctlr_parameters = {tparams.trial_mode, tparams.pat_id, tparams.gain, ...
                        tparams.offset, tparams.pos_id, tparams.frame_rate, tparams.frame_ind...
                        active_ao_channels, tparams.trial_ao_indices};
                    
                    ctlr.setControllerParameters(ctlr_parameters);
                    
                    tcpread_cache = pnet(ctlr.tcpConn, 'read', 'noblock'); % clear cache
                    
                    %Run block trial--------------------------------------
                    ctlr.startDisplay((tparams.dur + .5)*10, false); %duration expected in 100ms units
                    
                    timeSinceRes = tic;
                    
                    runcon.update_progress('rescheduled', cond, num_trial_of_total);
                    
                    %Update status panel to show current parameters
                    runcon.update_current_trial_parameters(tparams.trial_mode, ...
                        tparams.pat_id, tparams.pos_id, p.active_ao_channels, ...
                        tparams.trial_ao_indices, tparams.frame_ind, tparams.frame_rate, ...
                        tparams.gain, tparams.offset, tparams.dur);
                    
                    if inter_type
                        runcon.update_streamed_data(tcpread{end}, 'inter', prev_r, prev_c, prev_num_trials);
                    else
                        runcon.update_streamed_data(tcpread{end}, 'rescheduled', prev_r, prev_c, prev_num_trials);
                    end
                    
                    pause(tparams.dur - toc(timeSinceRes));
                    
                    tcpread{end+1} = pnet(ctlr.tcpConn, 'read', 'noblock');
                    prev_r = rep;
                    prev_c = cond;
                    prev_num_trials = num_trial_including_rescheduled;
                    
                    if runcon.check_if_aborted() == 1
                        ctlr.stopDisplay();
                        ctlr.stopLog('showTimeoutMessage', true);
                        if isa(ctlr, 'PanelsController')
                            ctlr.close();
                        end
                        clear global;
                        success = 0;
                        return;
                    end
                    runcon.update_elapsed_time(round(toc(startTime),2));
                    
                    if badtrial == length(res_conds)
                        continue;
                    end
                    
                    %run intertrial if there is one
                    if inter_type == 1
                        %Update total trial number
                        num_trial_including_rescheduled = num_trial_including_rescheduled + 1;
                        
                        %Run intertrial-------------------------
                        if params.inter_frame_ind == 0
                            inter_frame_ind = randperm(p.num_intertrial_frames,1);
                            ctlr_parameters_intertrial{7} = inter_frame_ind;
                        end
                        
                        ctlr.setControllerParameters(ctlr_parameters_intertrial);
                        
                        tcpread_cache = pnet(ctlr.tcpConn, 'read', 'noblock'); % clear cache
                        
                        ctlr.startDisplay((inter_dur + .5)*10, false);
                        
                        timeSinceResInter = tic;
                        %Update status panel to show current parameters
                        runcon.update_current_trial_parameters(inter_mode, inter_pat, inter_pos, p.active_ao_channels, ...
                            inter_ao_ind, inter_frame_ind, inter_frame_rate, inter_gain, inter_offset, inter_dur);
                        runcon.update_streamed_data(tcpread{end}, 'rescheduled', prev_r, prev_c, prev_num_trials);
                        
                        pause(inter_dur - toc(timeSinceResInter));
                        
                        tcpread{end+1} = pnet(ctlr.tcpConn, 'read', 'noblock');
                        prev_num_trials = num_trial_including_rescheduled;
                        
                        
                        if runcon.check_if_aborted() == 1
                            ctlr.stopDisplay();
                            ctlr.stopLog('showTimeoutMessage', true);
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
                
                %reset res_conds to equal the new updated badTrials list.
                %If it's empty, no more conditions will run
                res_conds = runcon.fb_model.get_bad_trials();
                ctlr.stopLog();
            end
            
            %% Run post-trial if there is one--------------------------------------------
            
            if post_type == 1
                
                %Update progress bar--------------------------
                num_trial_including_rescheduled = num_trial_including_rescheduled + 1;
                num_trial_of_total = num_trial_of_total + 1;

                ctlr.startLog(); % Must start log before setting controller parameters or it'll affect data processing.
                
                ctlr.setControllerParameters(ctlr_parameters_posttrial);
                
                tcpread_cache = pnet(ctlr.tcpConn, 'read', 'noblock'); % clear cache
                

                ctlr.startDisplay((post_dur + .5)*10, false);
                timeSincePost = tic;
                runcon.update_progress('post', num_trial_of_total);
                
                %Update status panel to show current parameters
                runcon.update_current_trial_parameters(post_mode, post_pat, post_pos, p.active_ao_channels, ...
                    post_ao_ind, post_frame_ind, post_frame_rate, post_gain, post_offset, post_dur);
                
                if num_trial_including_rescheduled > num_trial_of_total
                    runcon.update_streamed_data(tcpread{end}, 'rescheduled', prev_r, prev_c, prev_num_trials);
                else
                    runcon.update_streamed_data(tcpread{end}, 'block', prev_r, prev_c, prev_num_trials);
                end
                
                pause(post_dur - toc(timeSincePost));
                ctlr.stopLog('showTimeoutMessage', true);
                %tcpread = pnet(ctlr.tcpConn, 'read', 'noblock');
                
                pause(1);
                % runcon.update_streamed_data(tcpread, 'post');
                if runcon.check_if_aborted() == 1
                    ctlr.stopDisplay();
                    if isa(ctlr, 'PanelsController')
                        ctlr.close();
                    end
                    clear global;
                    success = 0;
                    return;
                end
                runcon.update_elapsed_time(round(toc(startTime),2));
            end
            
            ctlr.stopDisplay();
            
            if isa(ctlr, 'PanelsController')
                ctlr.close();
            end
            clear global;
            success = 1;
    end
end