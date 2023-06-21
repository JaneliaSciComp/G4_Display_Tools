%% Default protocol by which to run a flight experiment. 

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

function [success] = G4_default_run_protocol(runcon, p)%input should always be 1 or 2 items

%% Get access to the figure and progress bar in the run gui IF it was passed in.
global ctlr;

%        fig = runcon.fig;
if ~isempty(runcon.view)
    progress_bar = runcon.view.progress_bar;
    progress_axes = runcon.view.progress_axes;
    axes_label = runcon.view.axes_label;
end


 %% Set up parameters 
 params = assign_parameters(p);
 if params.inter_type == 1
    ctlr_parameters_intertrial = {params.inter_mode, params.inter_pat, params.inter_gain, ...
                            params.inter_offset, params.inter_pos, params.inter_frame_rate, params.inter_frame_ind, ...
                            p.active_ao_channels, params.inter_ao_ind};
 else
     ctlr_parameters_intertrial = {};
 end

 %% Start host and switch to correct directory
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
   check_successful_tcp();

    %% Set root directory to the experiment folder
    ctlr.setRootDirectory(p.experiment_folder);

%% set active ao channels
     if ~isempty(p.active_ao_channels)
        
        ctlr.setActiveAOChannels(dec2bin(params.aobits,4));
     end

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
         case 'Start' %The rest of the code to run the experiment goes under this case
         
%% Determine the total number of trials in order to define in what increments 
%the progress bar will progress.-------------------------------------------
            total_num_steps = get_total_num_trials(params);
            

%% Determine how long the experiment will take and update the title of the 
%progress bar to reflect it------------------------------------------------
            total_time = get_total_experiment_length(params);
            
            %Update the progress bar's label to reflect the expected
            %duration.
            axes_label.String = "Estimated experiment duration: " + num2str(total_time/60) + " minutes.";
            
            %Will increment this every time a trial is completed to track how far along 
            %in the experiment we are
            num_trial_of_total = 0;

%% Make sure the pause button hasn't been pressed

            is_paused = runcon.check_if_paused();
            if is_paused
                 disp("Experiment is paused. Please press pause button again to continue.");
                 runcon.pause();
                 
             end

%% Start log, if fails twice, abort------------------------------------

             log_started = ctlr.startLog();
             if ~log_started
                log_started = log_start_fail(runcon);
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
             if params.pre_start == 1
                 %First update the progress bar to show pretrial is running----
                 runcon.update_progress('pre');
                 num_trial_of_total = num_trial_of_total + 1;

                 %Set the panel values appropriately----------------

                 ctlr_parameters_pretrial = {params.pre_mode, params.pre_pat, params.pre_gain, ...
                     params.pre_offset, params.pre_pos, params.pre_frame_rate, params.pre_frame_ind, ...
                     p.active_ao_channels, params.pre_ao_ind};

                 ctlr.setControllerParameters(ctlr_parameters_pretrial);

                 %Update status panel to show current parameters
                 runcon.update_current_trial_parameters(params.pre_mode, params.pre_pat, ...
                     params.pre_pos, p.active_ao_channels, params.pre_ao_ind, ...
                     params.pre_frame_ind, params.pre_frame_rate, params.pre_gain, ...
                     params.pre_offset, params.pre_dur);

                 pause(0.01);
                 
                 %Run pretrial on screen
                 if params.pre_dur ~= 0
                    ctlr.startDisplay(params.pre_dur*10); %Panelcom usually did the *10 for us. Controller expects time in deciseconds
                 else
                     ctlr.startDisplay(2000, false); %second input, waitForEnd, equals false so code will continue executing
                     w = waitforbuttonpress; %If pretrial duration is set to zero, this
                     %causes it to loop until you press a button.
                 end
             end

             %Turn off AO functions if there are any
%              for i = 1:length(p.active_ao_channels)
%                 self.setAOFunctionID(p.active_ao_channels(i), 0);  
%             end            
%              
             if runcon.check_if_aborted()
                ctlr.stopDisplay();
                log_stopped = ctlr.stopLog();
                if ~log_stopped
                    log_stopped = log_stop_fail();
                end
                if isa(ctlr, 'PanelsController')
                    ctlr.close();
                end
                clear global;
                success = 0;
                return;
             
             end

             is_paused = runcon.check_if_paused();
             if is_paused
                 ctlr.stopLog();
                 disp("Experiment is paused. Please press pause button again to continue.");
                 runcon.pause()
                 ctlr.startLog();
             end

             
             runcon.update_elapsed_time(round(toc(startTime),2));
             

%% Loop to run the block/inter trials --------------------------------------

             for r = 1:params.reps
                 for c = 1:params.num_cond
                    %define which condition we're using
                    cond = p.exp_order(r,c);
                    
                    %Update the progress bar--------------------------
                    num_trial_of_total = num_trial_of_total + 1;
                    runcon.update_progress('block', r, params.reps, c, params.num_cond, cond, num_trial_of_total);

                    
                    %define parameters for this trial----------------
                    tparams = assign_block_trial_parameters(params, p, c);
                     
                     %Update controller-----------------------------

                    ctlr_parameters = {tparams.trial_mode, tparams.pat_id, tparams.gain, ...
                        tparams.offset, tparams.pos_id, tparams.frame_rate, tparams.frame_ind...
                        params.active_ao_channels, tparams.trial_ao_indices};

                     
                    ctlr.setControllerParameters(ctlr_parameters);

                    pause(0.01)

                    %Update status panel to show current parameters
                    runcon.update_current_trial_parameters(tparams.trial_mode, ...
                        tparams.pat_id, tparams.pos_id, p.active_ao_channels, ...
                      tparams.trial_ao_indices, tparams.frame_ind, tparams.frame_rate, ...
                      tparams.gain, tparams.offset, tparams.dur);
                    
                    %Run block trial--------------------------------------

                    ctlr.startDisplay((tparams.dur + .5)*10); %duration expected in 100ms units
                    
                    %Update the progress bar--------------------------
                    runcon.update_progress('block', r, params.reps, c, params.num_cond, cond, num_trial_of_total);
 
                    isAborted = runcon.check_if_aborted();
                    if isAborted == 1
                        ctlr.stopDisplay();
                        log_stopped = ctlr.stopLog();
                        if ~log_stopped
                            log_stopped = log_stop_fail();
                        end
                        if isa(ctlr, 'PanelsController')
                            ctlr.close();
                        end
                        clear global;
                        success = 0;
                        return;
                  
                    end

                    is_paused = runcon.check_if_paused();
                    if is_paused
                        ctlr.stopLog();
                        disp("Experiment is paused. Please press pause button again to continue.");
                        runcon.pause()
                        ctlr.startLog();
                     end

                    
                    runcon.update_elapsed_time(round(toc(startTime),2));
                    
                    %Tells loop to skip the intertrial if this is the last iteration of the last rep
                    if r == params.reps && c == params.num_cond
   
                        continue 
                    end
                    
        %Run inter-trial assuming there is one-------------------------
                    if params.inter_type == 1
                    
                        %Update progress bar to indicate start of inter-trial
                        num_trial_of_total = num_trial_of_total + 1;
                        runcon.update_progress('inter', r, params.reps, c, params.num_cond, num_trial_of_total)
                        progress_axes.Title.String = "Rep " + r + " of " + params.reps +...
                            ", Trial " + c + " of " + params.num_cond + ". Inter-trial running...";
                        progress_bar.YData = num_trial_of_total/total_num_steps;
                        drawnow;

                        if params.inter_frame_ind == 0
                            inter_frame_ind = randperm(p.num_intertrial_frames,1);
                            ctlr_parameters_intertrial{7} = inter_frame_ind;
                        end

                        ctlr.setControllerParameters(ctlr_parameters_intertrial);

                          %Update status panel to show current parameters
                        runcon.update_current_trial_parameters(params.inter_mode, ...
                            params.inter_pat, params.inter_pos, p.active_ao_channels, ...
                            params.inter_ao_ind, params.inter_frame_ind, params.inter_frame_rate,...
                            params.inter_gain, params.inter_offset, params.inter_dur);
                        
                         pause(0.01);

               %Run intertrial-------------------------
                         ctlr.startDisplay((params.inter_dur + .5)*10);
                         
                         if runcon.check_if_aborted() == 1
                            ctlr.stopDisplay();
                            log_stopped = ctlr.stopLog();
                            if ~log_stopped
                               log_stopped = log_stop_fail();
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
             
%% Run post-trial if there is one--------------------------------------------

            if params.post_type == 1
                
                %Update progress bar--------------------------
                num_trial_of_total = num_trial_of_total + 1;
                runcon.update_progress('post', num_trial_of_total);


                 ctlr_parameters_posttrial = {params.post_mode, params.post_pat, params.post_gain, ...
                       params.post_offset, params.post_pos, params.post_frame_rate, params.post_frame_ind, ...
                       p.active_ao_channels, params.post_ao_ind};

                 ctlr.setControllerParameters(ctlr_parameters_posttrial);
                 
                  %Update status panel to show current parameters
                 runcon.update_current_trial_parameters(params.post_mode, ...
                     params.post_pat, params.post_pos, p.active_ao_channels, ...
                     params.post_ao_ind, params.post_frame_ind, params.post_frame_rate, ...
                     params.post_gain, params.post_offset, params.post_dur);
                

                 ctlr.startDisplay((params.post_dur + .5)*10);
                 
                if runcon.check_if_aborted() == 1
                    ctlr.stopDisplay();
                    log_stopped = ctlr.stopLog();
                    if ~log_stopped
                        log_stopped = log_stop_fail();
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

            ctlr.stopDisplay();

            log_stopped = ctlr.stopLog();
            if ~log_stopped
                waitfor(errordlg("Stop Log command failed, please stop log manually then hit a key"));
                waitforbuttonpress;
            end         

            if isa(ctlr, 'PanelsController')
                ctlr.close();
            end
            clear global;

            success = 1;

     end

end