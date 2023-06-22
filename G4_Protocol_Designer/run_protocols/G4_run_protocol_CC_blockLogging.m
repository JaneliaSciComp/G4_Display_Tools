%% Run protocol using the combined command and logging each repetition separately
% No streaming

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

    %p.active_ao_channels - [0 1 2 3]
    %p.repetitions
    %p.is_randomized
    %p.fly_name
    %p.save_filename - name under which experiment is saved
    %p.exp_order - vector with the order conditions are run in
    %p.experiment_folder - path to experiment folder


%NOTES

    %The arrays of block indices are m x n where m is number of conditions and
    %n is 1 in the case of pat/pos, or the number of active
    %channels in the case of ao. In any position where there was no pos/ao
    %function, the value is a 0.

    %p.active_ao_channels lists the channels that are active - [0 2 3] for
    %example means channels 1, 3, and 4 are active.

function [success] = G4_run_protocol_CC_blockLogging(runcon, p) %input should always be 1 or 2 items

    if ~isempty(runcon.view)
        progress_bar = runcon.view.progress_bar;
        progress_axes = runcon.view.progress_axes;
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
        if isempty(pre_frame_rate)
            pre_frame_rate = 0;
        end
        pre_gain = p.pretrial{10};
        pre_offset = p.pretrial{11};
        pre_dur = p.pretrial{12};

        if isempty(pre_frame_rate)
            pre_frame_rate = 0;
        end
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
        if isempty(inter_frame_rate)
            inter_frame_rate = 0;
        end
        inter_gain = p.intertrial{10};
        inter_offset = p.intertrial{11};
        inter_dur = p.intertrial{12};

        if isempty(inter_frame_rate)
            inter_frame_rate = 0;
        end
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
        if isempty(post_frame_rate)
            post_frame_rate = 0;
        end
        post_gain = p.posttrial{10};
        post_offset = p.posttrial{11};
        post_dur = p.posttrial{12};

        if isempty(post_frame_rate)
            post_frame_rate = 0;
        end
    end

    %define static block trial params (will define the ones that change every
    %loop later)--------------------------------------------------------------
    block_trials = p.block_trials;
    block_ao_indices = p.block_ao_indices;
    reps = p.repetitions;
    num_cond = length(block_trials(:,1)); %number of conditions

    %% Open new Panels controller instance
    ctlr = PanelsController();
    ctlr.open(true);

    %% Set root directory to the experiment folder
    ctlr.setRootDirectory(p.experiment_folder);

    %% set active ao channels
    ctlr.setActiveAOChannels(p.active_ao_channels+2);

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


            %% run pretrial if it exists----------------------------------------
            startTime = tic;
            if pre_start == 1
                %First update the progress bar to show pretrial is running----
                runcon.update_progress('pre');
                num_trial_of_total = num_trial_of_total + 1;

                %randomize frame index if indicated
                if pre_frame_ind == 0
                    pre_frame_ind = randperm(p.num_pretrial_frames, 1);

                end

                %Update status panel to show current parameters
                runcon.update_current_trial_parameters(pre_mode, pre_pat, pre_pos, p.active_ao_channels, ...
                    pre_ao_ind, pre_frame_ind, pre_frame_rate, pre_gain, pre_offset, pre_dur);

                pause(0.01);

                ctlr.setPositionX(pre_frame_ind);

                if ~isempty(pre_gain) %this assumes you'll never have gain without offset
                    ctlr.setGain(pre_gain, pre_offset);
                end

                ctlr.startLog();
                if pre_dur ~= 0
                    ctlr.combinedCommand(pre_mode, pre_pat, pre_pos, pre_ao_ind(1), pre_ao_ind(2), pre_ao_ind(3), pre_ao_ind(4), pre_frame_rate, pre_dur*10);
                else
                    ctlr.combinedCommand(pre_mode, pre_pat, pre_pos, pre_ao_ind(1), pre_ao_ind(2), pre_ao_ind(3), pre_ao_ind(4), pre_frame_rate, 2000, false);
                    w = waitforbuttonpress;
                end
                ctlr.stopLog();
            end

            if runcon.check_if_aborted()
                ctlr.stopDisplay();
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
                ctlr.startLog();
                for c = 1:num_cond
                    %define which condition we're using
                    cond = p.exp_order(r,c);

                    %Update the progress bar--------------------------
                    num_trial_of_total = num_trial_of_total + 1;
                    runcon.update_progress('block', r, reps, c, num_cond, cond, num_trial_of_total);

                    %define parameters for this trial----------------
                    trial_mode = block_trials{cond,1};
                    pat_id = p.block_pat_indices(cond);
                    pos_id = p.block_pos_indices(cond);
                    if length(block_ao_indices) >= cond
                        trial_ao_indices = block_ao_indices(cond,:);
                    else
                        trial_ao_indices = [0 0 0 0];
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
                    if isempty(frame_rate)
                        frame_rate = 0;
                    end
                    gain = block_trials{cond, 10};
                    offset = block_trials{cond, 11};
                    dur = block_trials{cond, 12};

                    %Update controller-----------------------------
                    if ~isempty(block_trials{cond,10})
                        ctlr.setGain(gain, offset);
                    end

                    if frame_ind == 0
                        frame_ind = randperm(p.num_block_frames(c),1);
                    end

                    ctlr.setPositionX(frame_ind);

                    %Update status panel to show current parameters
                    runcon.update_current_trial_parameters(trial_mode, pat_id, pos_id, p.active_ao_channels, ...
                        trial_ao_indices, frame_ind, frame_rate, gain, offset, dur);

                    %Run block trial--------------------------------------
                    ctlr.combinedCommand(trial_mode, pat_id, pos_id, trial_ao_indices(1), trial_ao_indices(2), trial_ao_indices(3), trial_ao_indices(4),frame_rate, dur*10);

                    runcon.update_progress('block', r, reps, c, num_cond, cond, num_trial_of_total);

                    isAborted = runcon.check_if_aborted();
                    if isAborted == 1
                        ctlr.stopDisplay();
                        ctlr.stopLog('timeout', 60.0, 'showTimeoutMessage', true);
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
                        runcon.update_progress('inter', r, reps, c, num_cond, num_trial_of_total)
                        progress_axes.Title.String = "Rep " + r + " of " + reps +...
                            ", Trial " + c + " of " + num_cond + ". Inter-trial running...";
                        progress_bar.YData = num_trial_of_total/total_num_steps;
                        drawnow;

                        %Run intertrial-------------------------

                        %randomize frame index if indicated
                        if inter_frame_ind == 0
                            inter_frame_ind = randperm(p.num_intertrial_frames, 1);
                        end
                        ctlr.setPositionX(inter_frame_ind);

                        if ~isempty(inter_gain) %this assumes you'll never have gain without offset
                            ctlr.setGain(inter_gain, inter_offset);
                        end

                        %Update status panel to show current parameters
                        runcon.update_current_trial_parameters(inter_mode, inter_pat, inter_pos, p.active_ao_channels, ...
                            inter_ao_ind, inter_frame_ind, inter_frame_rate, inter_gain, inter_offset, inter_dur);

                        pause(0.01);

                        ctlr.combinedCommand(inter_mode, inter_pat, inter_pos, inter_ao_ind(1), inter_ao_ind(2), inter_ao_ind(3), inter_ao_ind(4),inter_frame_rate, inter_dur*10);

                        if runcon.check_if_aborted() == 1
                            ctlr.stopDisplay();
                            ctlr.stopLog('timeout', 60.0, 'showTimeoutMessage', true);
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
                ctlr.stopLog();
            end

            %% Run post-trial if there is one--------------------------------------------

            if post_type == 1
                %Update progress bar--------------------------
                num_trial_of_total = num_trial_of_total + 1;
                runcon.update_progress('post', num_trial_of_total);

                if ~isempty(post_gain)
                    ctlr.setGain(post_gain, post_offset);
                end

                if post_frame_ind == 0
                    post_frame_ind = randperm(p.num_posttrial_frames, 1);
                end

                ctlr.setPositionX(post_frame_ind);

                %Update status panel to show current parameters
                runcon.update_current_trial_parameters(post_mode, post_pat, post_pos, p.active_ao_channels, ...
                    post_ao_ind, post_frame_ind, post_frame_rate, post_gain, post_offset, post_dur);

                ctlr.startLog();

                ctlr.combinedCommand(post_mode, post_pat, post_pos, post_ao_ind(1), post_ao_ind(2), post_ao_ind(3), post_ao_ind(4),post_frame_rate, post_dur*10);
                ctlr.stopLog('timeout', 60, 'showTimeoutDialog', true);

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
