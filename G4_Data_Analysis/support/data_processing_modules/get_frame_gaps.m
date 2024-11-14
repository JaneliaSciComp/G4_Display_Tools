function [expected_frame_moves, frame_moves, expected_frame_gaps,frame_gaps] = get_frame_gaps(position_functions, ...
    unaligned_cond_data, Frame_ind)

expected_frame_move_inds = [];
expected_frame_moves = [];
    for posfunc = 1:length(position_functions)
        count = 1;
        for pt = 1:length(position_functions{posfunc})-1            
            if position_functions{posfunc}(pt+1) - position_functions{posfunc}(pt) ~= 0 
                expected_frame_move_inds(posfunc, count) = pt+1;
                expected_frame_moves(posfunc, count) = [position_functions{posfunc}(pt), position_functions{posfunc}(pt+1)];
                count = count + 1;   
            end
        end
        expected_frame_gaps(posfunc, :) = diff(expected_frame_moves(posfunc,:));
    end
    frame_moves = nan([size(squeeze(unaligned_cond_data(Frame_ind, :,:,:)))]);
    for cond = 1:size(unaligned_cond_data,2)
        for rep = 1:size(unaligned_cond_data,3)
            c = 1;
            for t = 1:size(unaligned_cond_data,4)
                if unaligned_cond_data(Frame_ind, cond, rep, t+1)-unaligned_cond_data(Frame_ind, cond, rep, t)~= 0
                    frame_moves(cond, rep, c) = t+1;
                    c = c+1;
                end
            end
            frame_gaps(cond, rep, :) = diff(frame_moves(cond, rep, :));
        end
    end

    

end