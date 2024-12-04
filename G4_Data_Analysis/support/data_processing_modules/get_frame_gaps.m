function [expected_frame_moves, expected_frame_move_inds, frame_moves, ...
    frame_move_inds, expected_frame_gaps,frame_gaps, bad_gaps] = get_frame_gaps(position_functions, ...
    cond_data, Frame_ind)

    expected_frame_move_inds = {};
    expected_frame_moves = {};
    for posfunc = 1:length(position_functions)
        count = 1;
        for pt = 1:length(position_functions{posfunc})-1            
            if position_functions{posfunc}(pt+1) - position_functions{posfunc}(pt) ~= 0 
                expected_frame_move_inds{posfunc}(count) = pt+1;
                expected_frame_moves{posfunc}(count, :) = [position_functions{posfunc}(pt), position_functions{posfunc}(pt+1)];
                count = count + 1;   
            end
        end
        expected_frame_gaps{posfunc} = diff(expected_frame_move_inds{posfunc}(:));
    end
    frame_move_inds = {};
    for cond = 1:size(cond_data,2)
        for rep = 1:size(cond_data,3)
            c = 1;
            for t = 1:size(cond_data,4)-1
                if cond_data(Frame_ind, cond, rep, t+1)-cond_data(Frame_ind, cond, rep, t)~= 0 ...
                        && ~isnan(cond_data(Frame_ind, cond, rep, t+1)-cond_data(Frame_ind, cond, rep, t))
                    frame_move_inds{cond, rep}(c) = t+1;
                    frame_moves{cond, rep}(c, :) = [cond_data(Frame_ind, cond, rep, t) cond_data(Frame_ind, cond, rep, t+1)];
                    c = c+1;
                end
            end
            
        end
    end
    
    for cond = 1:size(cond_data,2)
        for rep = 1:size(cond_data,3)
            exp_move = expected_frame_moves{cond}(1,:);
            count = 1; 
            while sum(exp_move ~= [frame_moves{cond, rep}(count, 1), frame_moves{cond, rep}(count, 2)])~=0 && count < size(frame_moves{cond, rep}, 1)
                count = count + 1;
            end
            if count > .5*size(frame_moves{cond, rep})
                warning(['Condition ' num2str(cond) ' rep ' num2str(rep) ' may not have displayed properly.']);
            elseif count > 1
                frame_move_inds{cond, rep}(1:count-1) = [];
                frame_moves{cond, rep}(1:count-1) = [];
            end
            frame_gaps{cond}(rep, :) = diff(frame_move_inds{cond, rep}(:));
        end
        
    end

    

    %Compare the expected and measured gaps and produce a warning if
    %they're too far off. 
    bad_gaps = {};
    for cond = 1:size(frame_gaps,1)
        for rep = 1:size(frame_gaps{cond},1)
            for gap = size(frame_gaps{cond},2)
                gapdiff = expected_frame_gaps{cond}(gap) - frame_gaps{cond}(rep, gap);
                if abs(gapdiff/expected_frame_gaps{cond}(gap)) > .2
                    warning(['Condition ' num2str(cond) ' rep ' num2str(rep) ' gap ' num2str(gap) 'is more than 20% off in length and should be investigated.']);
                    bad_gaps{end+1} = [cond rep gap];
                end
            end
        end
    end
end