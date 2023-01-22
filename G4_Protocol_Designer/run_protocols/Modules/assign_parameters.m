function params = assign_parameters(p)
    % Assigns all parameters that don't change (all but the parameters for
    % the block trials)
    
    %pretrial params-----------------------------------------------------
     if isempty(p.pretrial{1}) %no need to set up pretrial params
         params.pre_start = 0;
     else %set up pretrial params here
         params.pre_start = 1;
         params.pre_mode = p.pretrial{1};
         params.pre_pat = p.pretrial_pat_index;
         params.pre_pos = p.pretrial_pos_index;
         params.pre_ao_ind = p.pretrial_ao_indices;

         if isempty(p.pretrial{8})
             params.pre_frame_ind = 1;
         elseif strcmp(p.pretrial{8},'r')
             params.pre_frame_ind = randperm(p.num_pretrial_frames, 1); %use this later to randomize
         else
             params.pre_frame_ind = str2num(p.pretrial{8});
         end

         params.pre_frame_rate = p.pretrial{9};
         params.pre_gain = p.pretrial{10};
         params.pre_offset = p.pretrial{11};
         params.pre_dur = p.pretrial{12};
     end
 
 %intertrial params---------------------------------------------------
 
     if isempty(p.intertrial{1})
         params.inter_type = 0;%indicates whether or not there is an intertrial
     else
         params.inter_type = 1;
         params.inter_mode = p.intertrial{1};
         params.inter_pat = p.intertrial_pat_index;
         params.inter_pos = p.intertrial_pos_index;
         params.inter_ao_ind = p.intertrial_ao_indices;

         if isempty(p.intertrial{8})
             params.inter_frame_ind = 1;
         elseif strcmp(p.intertrial{8},'r')
             params.inter_frame_ind = 0; %use this later to randomize
         else
             params.inter_frame_ind = str2num(p.intertrial{8});
         end

         params.inter_frame_rate = p.intertrial{9};
         params.inter_gain = p.intertrial{10};
         params.inter_offset = p.intertrial{11};
         params.inter_dur = p.intertrial{12};
     end
 
 %posttrial params------------------------------------------------------
     if isempty(p.posttrial{1})
         params.post_type = 0;%indicates whether or not there is a posttrial
     else
         params.post_type = 1;
         params.post_mode = p.posttrial{1};
         params.post_pat = p.posttrial_pat_index;
         params.post_pos = p.posttrial_pos_index;
         params.post_ao_ind = p.posttrial_ao_indices;

         if isempty(p.posttrial{8})
             params.post_frame_ind = 1;
         elseif strcmp(p.posttrial{8},'r')
             params.post_frame_ind = randperm(p.num_posttrial_frames, 1); 
         else
             params.post_frame_ind = str2num(p.posttrial{8});
         end

         params.post_frame_rate = p.posttrial{9};
         params.post_gain = p.posttrial{10};
         params.post_offset = p.posttrial{11};
         params.post_dur = p.posttrial{12};
     end
 
 %define static block trial params (will define the ones that change every
 %loop later)--------------------------------------------------------------
     params.block_trials = p.block_trials; 
     params.block_ao_indices = p.block_ao_indices;
     params.reps = p.repetitions;
     params.num_cond = length(params.block_trials(:,1)); %number of conditions
     params.active_ao_channels = p.active_ao_channels;

     if ~isempty(p.active_ao_channels)
         params.aobits = 0;
        for bit = p.active_ao_channels
            params.aobits = bitset(aobits,bit+1); %plus 1 bc aochans are 0-3
        end

     end


end