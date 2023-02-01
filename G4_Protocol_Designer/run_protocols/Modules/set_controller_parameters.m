% Only used if you are not using the combined command in the controller

function set_controller_parameters(p)

    global ctlr

    % p should be a cell array as follows: 
    % {trial_mode, pat_id, gain, offset, pos_id, frame_rate, frame_ind, active_ao_channels, trial_ao_indices};

    ctlr.setControlMode(p{1});
    ctlr.setPatternID(p{2});
    
    if ~isempty(p{3})
        ctlr.setGain(p{3}, p{4});
    end
       
    if p{5} ~= 0

       ctlr.setPatternFunctionID(p{5});
        
    end
    if p{1} == 2
        ctlr.setFrameRate(p{6});
    end
   
    ctlr.setPositionX(p{7});
    
    for i = 1:length(p{8})
        ctlr.setAOFunctionID(p{8}(i), p{9}(i));  
    end                                    

end