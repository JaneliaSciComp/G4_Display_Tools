%% Default protocol by which to run a flight experiment. 

%The first input is the currently open instance (called runcon) of the run_gui's class.
%This allows this script to access the figure, progress bar, etc.

%The second input is a struct p which contains all the parameters needed to
%run the experiment on the screens. The structure is as follows: 

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

function G4_default_run_protocol(runcon, p)

%% Get access to the figure and progress bar in the run gui.

    fig = runcon.fig;
    progress_bar = runcon.progress_bar;
    progress_axes = runcon.progress_axes;
    axes_label = runcon.axes_label;

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
     
 
 %% Start host and switch to correct directory
 
     connectHost;
     pause(10);
     Panel_com('change_root_directory', p.experiment_folder);
     
 
 %% set active ao channels
     if ~isempty(p.active_ao_channels)
         aobits = 0;
        for bit = p.active_ao_channels
            aobits = bitset(aobits,bit+1); %plus 1 bc aochans are 0-3
        end
        Panel_com('set_active_ao_channels', dec2bin(aobits,4));
      
     end
     
%% confirm start experiment
     start = questdlg('Start Experiment?','Confirm Start','Start','Cancel','Start');
 
     switch start
     
         case 'Cancel'
             disconnectHost;
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

%% Start log---------------------------------------------------------

             Panel_com('start_log');
             pause(1);

%% run pretrial if it exists----------------------------------------

             if pre_start == 1
                 %First update the progress bar to show pretrial is running----
                 progress_axes.Title.String = "Running Pre-trial..."; 
                 num_trial_of_total = num_trial_of_total + 1;
                 progress_bar.YData = num_trial_of_total/total_num_steps;
                 drawnow;
                 
                 
                %Set the panel values appropriately----------------
                 Panel_com('set_control_mode',pre_mode);
                 
                 Panel_com('set_pattern_id', pre_pat);
                 
                 
                 %randomize frame index if indicated
                 if pre_frame_ind == 0
                     pre_frame_ind = randperm(p.num_pretrial_frames, 1);
                     
                 end
                 
                 Panel_com('set_position_x',pre_frame_ind);
                 

                 if pre_pos ~= 0
                     Panel_com('set_pattern_func_id', pre_pos);   
                     
                 end

                 if ~isempty(pre_gain) %this assumes you'll never have gain without offset
                     Panel_com('set_gain_bias', [pre_gain, pre_offset]);
                     
                 end

                 if pre_mode == 2
                     Panel_com('set_frame_rate', pre_frame_rate);
                     
                 end

                 for i = 1:length(pre_ao_ind)
                     if pre_ao_ind(i) ~= 0 %if it is zero, there was no ao function for this channel
                         Panel_com('set_ao_function_id',[p.active_ao_channels(i), pre_ao_ind(i)]);%[channel number, index of ao func]
                        
                     end
                 end
                 
                 %Update status panel to show current parameters
                 runcon.current_mode.String = num2str(pre_mode);
                 runcon.current_pat.String = num2str(pre_pat);
                 runcon.current_pos.String = num2str(pre_pos);
                 for i = 1:length(p.active_ao_channels) %This figures out which ao channel to put the ao function index under.
                    if p.active_ao_channels(i) == 0
                        runcon.current_ao1.String = num2str(pre_ao_ind(i));
                    elseif p.active_ao_channels(i) == 1
                        runcon.current_ao2.String = num2str(pre_ao_ind(i));
                    elseif p.active_ao_channels(i) == 2
                        runcon.current_ao3.String = num2str(pre_ao_ind(i));
                    else
                        runcon.current_ao4.String = num2str(pre_ao_ind(i));
                    end
                 end
                 runcon.current_frInd.String = num2str(pre_frame_ind);
                 runcon.current_frRate.String = num2str(pre_frame_rate);
                 runcon.current_gain.String = num2str(pre_gain);
                 runcon.current_offset.String = num2str(pre_offset);
                 runcon.current_duration.String = num2str(pre_dur);

                 pause(0.01);
                 
                 %Run pretrial on screen
                 if pre_dur ~= 0
                    Panel_com('start_display', (pre_dur*10));
                    pause(pre_dur + .01);
                 else
                     Panel_com('start_display', 20);
                     w = waitforbuttonpress; %If pretrial duration is set to zero, this
                     %causes it to loop until you press a button.
                 end
             end

%% Loop to run the block/inter trials --------------------------------------

             for r = 1:reps
                 for c = 1:num_cond
                    %define which condition we're using
                    cond = p.exp_order(r,c);
                    
                    %Update the progress bar--------------------------
                    num_trial_of_total = num_trial_of_total + 1;
                    progress_axes.Title.String = "Rep " + r + " of " + reps +...
                        ", Trial " + c + " of " + num_cond + ". Condition number: " + cond;
                    progress_bar.YData = num_trial_of_total/total_num_steps;
                    drawnow;
                    
                    %define parameters for this trial----------------
                    trial_mode = block_trials{cond,1};
                    pat_id = p.block_pat_indices(cond);
                    pos_id = p.block_pos_indices(cond);
                    if length(block_ao_indices) >= cond
                        trial_ao_indices = block_ao_indices(cond,:);
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
                     
                    %Update panel_com-----------------------------
                    Panel_com('set_control_mode', trial_mode)
                    
                    Panel_com('set_pattern_id', pat_id)
                    
                    if ~isempty(block_trials{cond,10})
                        Panel_com('set_gain_bias', [gain, offset]);
                    end
                    if pos_id ~= 0

                        Panel_com('set_pattern_func_id', pos_id)
                        
                    end
                    if trial_mode == 2
                        Panel_com('set_frame_rate',frame_rate);
                    end

                    Panel_com('set_position_x', frame_ind);
                    
                    for i = 1:length(p.active_ao_channels)
                        Panel_com('set_ao_function_id',[p.active_ao_channels(i), trial_ao_indices(i)]);
                        
                    end
                    
                    %Update status panel to show current parameters
                     runcon.current_mode.String = num2str(trial_mode);
                     runcon.current_pat.String = num2str(pat_id);
                     runcon.current_pos.String = num2str(pos_id);
                     for i = 1:length(p.active_ao_channels) %This figures out which ao channel to put the ao function index under.
                        if p.active_ao_channels(i) == 0
                            runcon.current_ao1.String = num2str(trial_ao_indices(i));
                        elseif p.active_ao_channels(i) == 1
                            runcon.current_ao2.String = num2str(trial_ao_indices(i));
                        elseif p.active_ao_channels(i) == 2
                            runcon.current_ao3.String = num2str(trial_ao_indices(i));
                        else
                            runcon.current_ao4.String = num2str(trial_ao_indices(i));
                        end
                    end
                     runcon.current_frInd.String = num2str(frame_ind);
                     runcon.current_frRate.String = num2str(frame_rate);
                     runcon.current_gain.String = num2str(gain);
                     runcon.current_offset.String = num2str(offset);
                     runcon.current_duration.String = num2str(dur);
                    pause(0.01)
                    
                    %Run block trial--------------------------------------
                    Panel_com('start_display', (dur*10)); %duration expected in 100ms units
                    pause(dur + .01)

                    %Tells loop to skip the intertrial if this is the last iteration of the last rep
                    if r == reps && c == num_cond
   
                        continue 
                    end
                    
        %Run inter-trial assuming there is one-------------------------
                    if inter_type == 1
                    
                        %Update progress bar to indicate start of inter-trial
                        num_trial_of_total = num_trial_of_total + 1;
                        progress_axes.Title.String = "Rep " + r + " of " + reps +...
                            ", Trial " + c + " of " + num_cond + ". Inter-trial running...";
                        progress_bar.YData = num_trial_of_total/total_num_steps;
                        drawnow;

                        %Run intertrial-------------------------
                        Panel_com('set_control_mode',inter_mode);
                       
                        Panel_com('set_pattern_id', inter_pat);
                       
                        %randomize frame index if indicated
                        if inter_frame_ind == 0
                            inter_frame_ind = randperm(p.num_intertrial_frames, 1);
                        end
                        Panel_com('set_position_x',inter_frame_ind);
                        

                        if inter_pos ~= 0
                            Panel_com('set_pattern_func_id', inter_pos);
                            
                        end

                         if ~isempty(inter_gain) %this assumes you'll never have gain without offset
                             Panel_com('set_gain_bias', [inter_gain, inter_offset]);
                         end

                         if inter_mode == 2
                             Panel_com('set_frame_rate', inter_frame_rate);
                         end

                         for i = 1:length(inter_ao_ind)
                             if inter_ao_ind(i) ~= 0 %if it is zero, there was no ao function for this channel
                                 Panel_com('set_ao_function_id',[p.active_ao_channels(i), inter_ao_ind(i)]);%[channel number, index of ao func]
                                 
                             end
                         end
                         
                         %Update status panel on gui w/ intertrial parameters
                         runcon.current_mode.String = num2str(inter_mode);
                         runcon.current_pat.String = num2str(inter_pat);
                         runcon.current_pos.String = num2str(inter_pos);
                         
                         for i = 1:length(p.active_ao_channels) %This figures out which ao channel to put the ao function index under.
                            if p.active_ao_channels(i) == 0
                                runcon.current_ao1.String = num2str(inter_ao_ind(i));
                            elseif p.active_ao_channels(i) == 1
                                runcon.current_ao2.String = num2str(inter_ao_ind(i));
                            elseif p.active_ao_channels(i) == 2
                                runcon.current_ao3.String = num2str(inter_ao_ind(i));
                            else
                                runcon.current_ao4.String = num2str(inter_ao_ind(i));
                            end
                        end
                         runcon.current_frInd.String = num2str(inter_frame_ind);
                         runcon.current_frRate.String = num2str(inter_frame_rate);
                         runcon.current_gain.String = num2str(inter_gain);
                         runcon.current_offset.String = num2str(inter_offset);
                         runcon.current_duration.String = num2str(inter_dur);

                         pause(0.01);
                         Panel_com('start_display', (inter_dur*10));
                         pause(inter_dur + .01);
                    end 
                 end
             end
             
%% Run post-trial if there is one--------------------------------------------

            if post_type == 1
                
                %Update progress bar--------------------------
                num_trial_of_total = num_trial_of_total + 1;
                progress_axes.Title.String = "Post-trial running...";
                progress_bar.YData = num_trial_of_total/total_num_steps;
                drawnow;

                 Panel_com('set_control_mode', post_mode);
                 
                 Panel_com('set_pattern_id', post_pat);
                 
                 if ~isempty(post_gain)
                     Panel_com('set_gain_bias', [post_gain, post_offset]);
                 end
                 if post_pos ~= 0
                     Panel_com('set_pattern_func_id', post_pos);
                     
                 end
                 if post_mode == 2
                     Panel_com('set_frame_rate', post_frame_rate);
                 end
                 Panel_com('set_position_x',post_frame_ind);
                 
                 for i = 1:length(post_ao_ind)
                     if post_ao_ind(i) ~= 0 %if it is zero, there was no ao function for this channel
                         Panel_com('set_ao_function_id',[p.active_ao_channels(i), post_ao_ind(i)]);%[channel number, index of ao func]
                         
                     end
                 end
                 
                 %Update status panel on gui w/ current parameters
                 runcon.current_mode.String = num2str(post_mode);
                 runcon.current_pat.String = num2str(post_pat);
                 runcon.current_pos.String = num2str(post_pos);
                 for i = 1:length(p.active_ao_channels) %This figures out which ao channel to put the ao function index under.
                    if p.active_ao_channels(i) == 0
                        runcon.current_ao1.String = num2str(post_ao_ind(i));
                    elseif p.active_ao_channels(i) == 1
                        runcon.current_ao2.String = num2str(post_ao_ind(i));
                    elseif p.active_ao_channels(i) == 2
                        runcon.current_ao3.String = num2str(post_ao_ind(i));
                    else
                        runcon.current_ao4.String = num2str(post_ao_ind(i));
                    end
                end
                 runcon.current_frInd.String = num2str(post_frame_ind);
                 runcon.current_frRate.String = num2str(post_frame_rate);
                 runcon.current_gain.String = num2str(post_gain);
                 runcon.current_offset.String = num2str(post_offset);
                 runcon.current_duration.String = num2str(post_dur);

                 Panel_com('start_display',post_dur*10);

                 pause(post_dur + 1);
                 
                 
            end

            Panel_com('stop_display');
            
            pause(1);

            Panel_com('stop_log');
            
            pause(1);
            
            disp("Disconnecting!");
            disconnectHost;
            
            pause(1);

     end

end
