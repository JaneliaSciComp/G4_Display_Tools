% Run protocol that uses the Panels controller directly, rather than the
% panel_com wrapper. 

% COPIED FROM OTHER RUN PROTOCOLS: 


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
     %p.is_chan1 - Indicates whether analog input channel 1 is streaming (1) or
     %not(0)
     %p.is_chan2 - is_chan4 - same as is_chan1, for channels 2,3,and 4
     
     %NOTES
      %The arrays of block indices are m x n where m is number of conditions and
     %n is 1 in the case of pat/pos, or the number of active
     %channels in the case of ao. In any position where there was no pos/ao
     %function, the value is a 0.
     
     %p.active_ao_channels lists the channels that are active - [0 2 3] for
     %example means channels 1, 3, and 4 are active.

function [success] = G4_panels_controller_run_protocol(runcon, p)%input should always be 1 or 2 items

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

end
